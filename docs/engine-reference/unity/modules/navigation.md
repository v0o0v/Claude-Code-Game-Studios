# Unity 6.3 — 내비게이션 모듈 레퍼런스

**최종 확인일:** 2026-02-13
**지식 공백:** Unity 6 NavMesh 개선 사항

---

## 개요

Unity 6 내비게이션 시스템:
- **NavMesh**: AI 에이전트용 내장 경로 탐색
- **NavMeshComponents**: 런타임 NavMesh 빌드용 패키지

---

## NavMesh 기초

### 내비게이션 메시 베이크

1. 이동 가능한 표면 표시:
   - GameObject 선택(바닥/지형)
   - Inspector > Navigation > Object 탭
   - "Navigation Static" 체크

2. NavMesh 베이크:
   - `Window > AI > Navigation`
   - Bake 탭
   - "Bake" 클릭

3. 설정 구성:
   - **Agent Radius**: 에이전트의 너비(기본값 0.5m)
   - **Agent Height**: 에이전트의 높이(기본값 2m)
   - **Max Slope**: 이동 가능한 최대 경사(기본값 45°)
   - **Step Height**: 오를 수 있는 최대 단차(기본값 0.4m)

---

## NavMeshAgent (AI 이동)

### 기본 에이전트 설정

```csharp
using UnityEngine;
using UnityEngine.AI;

public class Enemy : MonoBehaviour {
    private NavMeshAgent agent;
    public Transform target;

    void Start() {
        agent = GetComponent<NavMeshAgent>();
    }

    void Update() {
        // ✅ 타겟으로 이동
        agent.SetDestination(target.position);
    }
}
```

---

### NavMeshAgent 프로퍼티

```csharp
NavMeshAgent agent = GetComponent<NavMeshAgent>();

// 속도
agent.speed = 3.5f;

// 가속도
agent.acceleration = 8f;

// 정지 거리
agent.stoppingDistance = 2f; // 목적지 2m 전에 정지

// 자동 감속(목적지에서 속도를 줄임)
agent.autoBraking = true;

// 회전 속도
agent.angularSpeed = 120f; // 초당 각도

// 장애물 회피
agent.obstacleAvoidanceType = ObstacleAvoidanceType.HighQualityObstacleAvoidance;
```

---

### 경로 상태 확인

```csharp
void Update() {
    agent.SetDestination(target.position);

    // 에이전트가 경로를 가지고 있는지 확인
    if (agent.hasPath) {
        // 경로가 완전한지 확인
        if (agent.pathStatus == NavMeshPathStatus.PathComplete) {
            Debug.Log("Valid path");
        } else if (agent.pathStatus == NavMeshPathStatus.PathPartial) {
            Debug.Log("Partial path (destination unreachable)");
        } else {
            Debug.Log("Invalid path");
        }
    }

    // 에이전트가 목적지에 도달했는지 확인
    if (!agent.pathPending && agent.remainingDistance <= agent.stoppingDistance) {
        Debug.Log("Reached destination");
    }
}
```

---

### 경로 계산 (아직 이동하지 않음)

```csharp
NavMeshPath path = new NavMeshPath();
agent.CalculatePath(targetPosition, path);

if (path.status == NavMeshPathStatus.PathComplete) {
    // 유효한 경로가 존재함
    agent.SetPath(path); // 경로 적용
}
```

---

## NavMesh 영역 (이동 비용)

### 영역 정의
`Window > AI > Navigation > Areas tab`
- **Walkable**: 비용 1(기본값)
- **Not Walkable**: 이동 불가
- **Jump**: 비용 2(다른 경로를 우선함)
- **Custom**: 직접 정의

### 영역 비용 할당

```csharp
// 저비용 경로보다 더 짧은 경로를 우선
agent.areaMask = NavMesh.AllAreas; // 모든 영역에서 이동

// "Walkable" 영역에서만 이동("Jump"는 회피)
agent.areaMask = 1 << NavMesh.GetAreaFromName("Walkable");
```

---

## NavMesh 장애물 (동적 장애물)

### NavMeshObstacle 컴포넌트

```csharp
// Add: GameObject > Add Component > NavMesh Obstacle

// Carve: NavMesh에 구멍을 생성(에이전트가 회피함)
// Don't Carve: 에이전트가 통과함(로컬 회피)
```

### 동적 카빙 (움직이는 장애물)

```csharp
NavMeshObstacle obstacle = GetComponent<NavMeshObstacle>();
obstacle.carving = true; // NavMesh에 동적으로 구멍 생성
```

---

## Off-Mesh Link (점프, 텔레포트)

### Off-Mesh Link 생성

1. `GameObject > Create Empty` (점프 시작 지점)
2. `Off Mesh Link` 컴포넌트 추가
3. 시작/끝 Transform 설정
4. 구성:
   - **Bi-Directional**: 양방향 이동 가능
   - **Cost Override**: 이 링크의 경로 비용

### Off-Mesh Link 통과 감지

```csharp
void Update() {
    // 에이전트가 off-mesh link 위에 있는지 확인
    if (agent.isOnOffMeshLink) {
        // 수동으로 통과 처리(예: 점프 애니메이션 재생)
        StartCoroutine(TraverseOffMeshLink());
    }
}

IEnumerator TraverseOffMeshLink() {
    OffMeshLinkData data = agent.currentOffMeshLinkData;
    Vector3 startPos = agent.transform.position;
    Vector3 endPos = data.endPos;

    float duration = 0.5f;
    float elapsed = 0f;

    while (elapsed < duration) {
        agent.transform.position = Vector3.Lerp(startPos, endPos, elapsed / duration);
        elapsed += Time.deltaTime;
        yield return null;
    }

    agent.CompleteOffMeshLink(); // 일반 경로 탐색 재개
}
```

---

## NavMeshComponents 패키지 (런타임 베이킹)

### 설치

1. `Window > Package Manager`
2. Git URL로 추가: `com.unity.ai.navigation`

### 런타임 NavMesh 베이킹

```csharp
using Unity.AI.Navigation;

public class NavMeshBuilder : MonoBehaviour {
    public NavMeshSurface surface;

    void Start() {
        // 런타임에 NavMesh 베이크
        surface.BuildNavMesh();
    }

    void UpdateNavMesh() {
        // 지형 변경 후 NavMesh 업데이트
        surface.UpdateNavMesh(surface.navMeshData);
    }
}
```

---

## 자주 쓰이는 패턴

### 웨이포인트 사이 순찰

```csharp
public Transform[] waypoints;
private int currentWaypoint = 0;

void Update() {
    if (!agent.pathPending && agent.remainingDistance < 0.5f) {
        // 웨이포인트 도달, 다음으로 이동
        currentWaypoint = (currentWaypoint + 1) % waypoints.Length;
        agent.SetDestination(waypoints[currentWaypoint].position);
    }
}
```

### 플레이어 추적

```csharp
public Transform player;
public float chaseRange = 10f;

void Update() {
    float distance = Vector3.Distance(transform.position, player.position);

    if (distance <= chaseRange) {
        agent.SetDestination(player.position);
    } else {
        agent.ResetPath(); // 이동 정지
    }
}
```

### 플레이어로부터 도주

```csharp
public Transform player;
public float fleeRange = 5f;

void Update() {
    float distance = Vector3.Distance(transform.position, player.position);

    if (distance <= fleeRange) {
        // 플레이어로부터 도망
        Vector3 fleeDirection = transform.position - player.position;
        Vector3 fleeTarget = transform.position + fleeDirection.normalized * 10f;

        agent.SetDestination(fleeTarget);
    }
}
```

---

## 디버깅

### NavMesh 시각화
- `Window > AI > Navigation > Bake tab`
- "Show NavMesh" 체크로 이동 가능 영역 시각화

### 에이전트 경로 기즈모

```csharp
void OnDrawGizmos() {
    if (agent != null && agent.hasPath) {
        Gizmos.color = Color.green;
        Vector3[] corners = agent.path.corners;

        for (int i = 0; i < corners.Length - 1; i++) {
            Gizmos.DrawLine(corners[i], corners[i + 1]);
        }
    }
}
```

---

## 성능 팁

- **장애물 회피 품질 제한**: 멀리 있는 에이전트에는 `LowQualityObstacleAvoidance` 사용
- **업데이트 빈도**: 타겟이 움직이지 않았다면 매 프레임 `SetDestination()`을 호출하지 말 것
- **영역 마스크**: 경로 탐색 검색 범위를 줄이기 위해 이동 가능 영역을 제한
- **NavMesh 타일**: 대규모 월드에는 타일 기반 NavMesh 사용(NavMeshComponents 패키지)

---

## 출처
- https://docs.unity3d.com/6000.0/Documentation/Manual/Navigation.html
- https://docs.unity3d.com/Packages/com.unity.ai.navigation@2.0/manual/index.html
