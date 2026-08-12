# Web — Networking 모듈 레퍼런스

**최종 검증일:** 2026-08-06
**지식 격차:** 큰 격차는 없다 — 반복해서 발생하는 위험은 클라이언트를 신뢰하는 것이며, 이는 웹에서 특히 위험하다

---

## 개요

| 전송 방식 | 신뢰성 | 용도 |
|-----------|-------------|---------|
| **WebSocket** | 신뢰성 있음, 순서 보장 (TCP) | 턴제, 로비, 채팅, 대부분의 게임 |
| **WebRTC data channel** | 설정 가능, 비신뢰/비순서 가능 | 낮은 지연이 필요한 빠른 액션 |
| **HTTP / fetch** | 신뢰성 있음 | 리더보드, 세이브, 매치메이킹 |

**브라우저에서는 raw UDP를 쓸 수 없다.** 비신뢰·비순서 전달을 얻는 유일한 방법은
WebRTC data channel이며, 연결 복잡도(시그널링 서버, ICE, STUN/TURN)라는 상당한 비용이 따른다.

**WebSocket으로 시작한다.** 웹 멀티플레이 게임 대다수에는 이것으로 충분하고 훨씬 단순하다.
TCP head-of-line blocking이 실제로 게임을 해치고 있다는 측정 결과가 나왔을 때만 WebRTC로 넘어간다.

---

## 보안 규칙

**클라이언트는 완전히 장악당한 상태다. 언제나.**

웹에서 이것은 가정이 아니다. 플레이어는 DevTools를 열어 코드를 한 줄씩 읽고, 어떤 변수든
수정하고, 어떤 메시지든 재전송하거나 위조할 수 있다. 관심 있는 공격자를 견디는 난독화는
없으며, 미니피케이션은 보안 수단이 아니다.

- **중요한 모든 것에 대해 서버가 권위를 갖는다.** 점수, 재화, 인벤토리, 위치, 히트 판정
- 클라이언트는 *의도*("왼쪽을 눌렀다")를 보내지, *결과*("내 점수는 9999다")를 보내지 않는다
- 모든 메시지를 서버에서 실제로 가능한 값인지 검증한다
- 연결 단위로 레이트 리밋을 건다
- API 키, 시크릿, 관리자 엔드포인트를 번들에 절대 포함하지 않는다

```ts
// ❌ Client asserts the result
socket.send({ type: 'scoreUpdate', score: 9999 });

// ✅ Client reports input; the server computes and owns the result
socket.send({ type: 'input', seq: 42, left: true, right: false });
```

---

## WebSocket

```ts
const ws = new WebSocket('wss://example.com/game');   // wss:// always
ws.binaryType = 'arraybuffer';

ws.addEventListener('message', (e) => {
  const msg = decode(e.data);
  applyServerState(msg);
});
```

- **`wss://`만 쓴다.** HTTPS로 서빙된 페이지는 평문 `ws://` 연결을 열 수 없다
- `close`를 처리하고 **지수 백오프 + 지터**로 재연결한다 — 그러지 않으면 서버 재시작 시 모든 클라이언트가 동시에 재연결을 시도해 쇄도한다
- 죽은 연결을 감지하려면 하트비트/핑을 둔다. 브라우저는 네트워크 유실 시 `close`를 안정적으로 발생시키지 않는다
- `readyState !== OPEN`인 동안에는 나가는 메시지를 버퍼링한다

### 직렬화
턴제 게임에는 JSON으로 충분하고 디버깅도 쉽다. 실시간에는 바이너리(`DataView`를 쓴
`ArrayBuffer`, 또는 MessagePack)가 대역폭을 몇 배로 줄여 준다. 포맷과 무관하게 파싱된
메시지는 서버에서 Zod로 검증한다.

---

## 지연 처리

실시간이라면 표준적인 기법 세 가지가 필요하다.

**클라이언트 예측(client-side prediction)** — 서버 왕복을 기다리지 않고 로컬 입력을 즉시 적용한다. 그러지 않으면 조작이 굼뜨게 느껴진다.

**서버 조정(server reconciliation)** — 서버의 권위 있는 상태는 마지막으로 처리한 입력 시퀀스 번호와 함께 도착한다. 그 위에 아직 확인되지 않은 입력을 다시 재생한다.

```ts
function onServerState(state: ServerState): void {
  world.setState(state);
  for (const input of pendingInputs.filter((i) => i.seq > state.lastSeq)) {
    world.applyInput(input);      // replay
  }
}
```

**엔티티 보간(entity interpolation)** — 다른 플레이어를 약간 과거(~100ms) 시점으로 렌더링하고 수신된 상태 사이를 보간한다. 그러면 업데이트가 이산적이어도 움직임이 매끄럽다.

이 기법들은 **결정론적 고정 타임스텝 시뮬레이션**을 전제로 한다. 프레임레이트 독립성을
넘어 고정 타임스텝이 중요한 아키텍처적 이유가 바로 이것이다.

---

## Colyseus

상태 동기화, 룸, 매치메이킹을 처리해 주는 룸 기반 권위 서버 프레임워크다. 위의
보일러플레이트를 대부분 없애 준다.

**감수해야 할 부분:** Node 서버를 호스팅해야 한다. itch.io나 Netlify에서 정적 호스팅하던
것과는 차원이 다른 단계이며, 지속적인 비용과 운영 부담이 따른다. 코드 결정이 아니라
설계 결정으로 이 점을 반영한다.

`../PLUGINS.md`를 참고한다.

---

## 자주 발생하는 오류

| 증상 | 원인 |
|---------|-------|
| 프로덕션에서 연결이 차단됨 | HTTPS 페이지에서 `ws://` 사용 — `wss://`를 쓸 것 |
| 서버 재시작 후 서버가 뻗음 | 백오프/지터 없는 재연결 |
| 치팅 / 불가능한 점수 | 클라이언트 권위 상태 |
| 조작이 굼뜨게 느껴짐 | 클라이언트 예측 없음 |
| 다른 플레이어가 끊겨 보임 | 엔티티 보간 없음 |
| 부하가 걸릴 때만 나타나는 디싱크 | 비결정론적 시뮬레이션 |
| 죽은 연결이 감지되지 않음 | 하트비트 없음 |

---

## 출처

- https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API
- https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API
- https://colyseus.io/
- https://gafferongames.com/ (client prediction and reconciliation)
