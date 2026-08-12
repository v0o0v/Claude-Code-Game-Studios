# Web — Navigation 모듈 레퍼런스

**최종 검증일:** 2026-08-06
**지식 격차:** 두 라이브러리 모두 패스파인딩을 제공하지 않는다 — 항상 직접 작성하거나 의존성을 추가해야 한다

---

## 개요

**PixiJS와 Three.js 모두 내비게이션 기능이 없다.** NavMesh 베이킹도, `NavigationAgent`도,
내장 패스파인딩도 없다. Godot, Unity, Unreal과 달리 이 영역은 전적으로 개발자의 몫이다.

| 필요한 것 | 접근 방식 |
|------|----------|
| 그리드 / 타일 이동 | 그리드 위 A* — 직접 작성 |
| 자유로운 2D 이동 | 내비게이션 그리드 위 A* 후 string-pull |
| 3D 내비메시 | `recast-navigation-js`, 또는 오프라인 베이크 후 로드 |
| 지역 회피 | 스티어링 비헤이비어 또는 RVO |
| 단순 추격 AI | 직접 스티어링 — 패스파인딩 불필요 |

대부분의 2D 게임에는 그리드 A*만으로 충분하며, 100줄 정도면 되고 번들 크기도 늘지 않는다.

---

## 그리드 위의 A*

```ts
interface Node { x: number; y: number; }

function aStar(start: Node, goal: Node, isWalkable: (n: Node) => boolean): Node[] {
  const open = new PriorityQueue<Node>();
  const gScore = new Map<string, number>();
  const cameFrom = new Map<string, Node>();
  // ... 표준 A*
}
```

### 휴리스틱은 이동 방식과 일치해야 한다
| 이동 방식 | 휴리스틱 |
|----------|-----------|
| 4방향 | Manhattan |
| 8방향 | Octile / diagonal |
| 임의 각도 | Euclidean |

4방향 이동에 Euclidean을 쓰면 사실상 휴리스틱이 허용 불가능(inadmissible)해지고
눈에 띄게 이상한 경로가 나온다. 휴리스틱을 이동 규칙에 맞춘다.

---

## 성능 — 메인 스레드 문제

패스파인딩은 CPU 바운드이며 게임 루프와 메인 스레드를 공유한다. 큰 그리드에서 긴 경로
탐색을 한 번만 돌려도 프레임이 떨어진다.

**완화 방법, 선호 순서대로:**

1. **탐색에 예산을 둔다.** 프레임당 확장 노드 수에 상한을 두고, 끝나지 않으면 다음 프레임에 이어서 한다. 대부분의 게임은 경로가 2~3 프레임 늦게 도착해도 견딘다
2. **적극적으로 캐싱한다.** 레벨 지오메트리가 정적이라면 고정된 지점 사이의 경로는 미리 계산해 둘 수 있다
3. **에이전트를 분산시킨다.** 모든 에이전트를 같은 프레임에 다시 경로 탐색시키지 않는다 — 요청을 롤링 윈도로 퍼뜨린다
4. 큰 맵에는 **계층적 패스파인딩**: 먼저 개략적인 리전 경로를 구하고 지역적으로 정제한다
5. 무거운 3D 내비메시 질의에는 **Web Worker**. 탐색이 정말로 지배적일 때만 가치가 있다. postMessage 왕복이 지연을 더하고 그리드가 transferable이어야 한다

```ts
// 프레임 예산이 적용된 탐색
const MAX_NODES_PER_FRAME = 500;
let expanded = 0;
while (open.size > 0 && expanded < MAX_NODES_PER_FRAME) { /* ... */ expanded++; }
```

---

## 경로 스무딩

가공하지 않은 그리드 A*는 계단 모양 경로를 만든다. 표준적인 해결책은 두 가지다.

- **String pulling / funnel** — 양옆 노드를 잇는 직선이 막히지 않았다면 중간 노드를 제거한다
- **시야(line-of-sight) 검사** — 경로를 따라가며 앞선 노드에서 직접 도달 가능한 노드를 건너뛴다

```ts
function hasLineOfSight(a: Node, b: Node, isWalkable: (n: Node) => boolean): boolean {
  // a와 b 사이를 Bresenham으로 잇고, 처음 막힌 셀에서 false
}
```

스무딩이 없으면 에이전트가 타일 경계를 따라 눈에 띄게 지그재그로 움직인다.

---

## 스티어링과 지역 회피

패스파인딩은 경로를 주고, 스티어링은 순간순간의 움직임을 담당한다.

```ts
// 다음 웨이포인트를 향해 이동
const desired = normalize(sub(waypoint, pos));
const steering = sub(scale(desired, maxSpeed), velocity);
velocity = clampLength(add(velocity, scale(steering, dt)), maxSpeed);
```

군중에는 에이전트가 겹치지 않도록 분리(separation)를 추가한다. 수십 마리 이하에서는
완전한 RVO가 거의 필요 없다 — 단순 분리와 재경로 탐색으로 보통 충분하다.

---

## 3D 내비게이션

3D 내비메시가 필요하다면 `recast-navigation-js`가 업계 전반에서 쓰이는 Recast/Detour
라이브러리를 감싼다. WASM 의존성이므로 비동기로 로드하고 페이로드 예산을 잡아 둔다.

대안: Blender나 레벨 툴에서 내비메시를 오프라인으로 베이크해 지오메트리나 JSON 그래프로
익스포트한 뒤, 런타임에는 직접 만든 A*를 돌린다. 런타임 의존성이 0인 대신 툴링 작업이 든다.

---

## 자주 발생하는 오류

| 증상 | 원인 |
|---------|-------|
| 에이전트가 재경로 탐색할 때 프레임 드롭 | 메인 스레드에서 예산 없는 탐색 |
| 에이전트가 타일을 따라 지그재그로 움직임 | 경로 스무딩 없음 |
| 경로가 이상해 보임 | 휴리스틱이 이동 규칙과 맞지 않음 |
| 무리가 스폰될 때 프레임 스파이크 | 모든 에이전트가 같은 프레임에 경로 탐색 |
| 에이전트끼리 겹쳐 쌓임 | 분리 스티어링 없음 |
| 에이전트가 벽을 통과함 | 오래된 walkability 그리드로 경로를 계산 |

---

## 출처

- https://github.com/isaac-mason/recast-navigation-js
- https://www.redblobgames.com/pathfinding/a-star/introduction.html
