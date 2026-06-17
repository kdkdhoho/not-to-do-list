---
description: Navigation 3계층 규칙 — Route, Router, DeepLink 작성 시 준수사항
globs:
  - "Sources/Feature/**/Navigation/**/*.swift"
  - "Sources/Feature/**/*Router*.swift"
  - "Sources/Feature/**/*Route*.swift"
  - "Sources/Feature/**/*NavigationView*.swift"
  - "Sources/Feature/Tab/**/*.swift"
  - "Sources/ServiceApp/**/*Router*.swift"
  - "Sources/ServiceApp/**/*AppState*.swift"
always: true
---

# Navigation 규칙

## 3계층 정책

계층마다 도구가 고정 — 섞지 않는다.

| 계층 | 소유자 | 도구 |
|------|--------|------|
| ① 앱 단계 | `AppState.currentPhase` | `switch`로 화면 교체 |
| ② 탭 / 딥링크 | `AppRouter` | `selectedTab` + 탭 라우터 소유 |
| ③ 탭 내부 | 각 탭 Router | `NavigationPath` + sheet |

## Route

- `Hashable` enum으로 정의한다.
- associated value는 식별값(ID 등)만 담는다. **클로저·ViewModel·View는 넣지 않는다.**

```swift
// ✅
enum HomeRoute: Hashable {
    case detail(itemId: String)
    case settings
}

// ❌
enum HomeRoute {
    case detail(viewModel: DetailViewModel)
    case action(() -> Void)
}
```

## Router

- `@Observable` class로 만든다.
- `NavigationPath`를 소유하고 push/pop/popToRoot/sheet 메서드를 제공한다.
- Router는 직접 생성하지 않고 `AppRouter`가 주입한다.

```swift
// ✅
@Observable
final class HomeRouter {
    var path = NavigationPath()
    var sheet: HomeRoute?

    func push(_ route: HomeRoute) { path.append(route) }
    func pop() { path.removeLast() }
    func popToRoot() { path.removeLast(path.count) }
    func presentSheet(_ route: HomeRoute) { sheet = route }
}
```

## 데이터 전달

### 정방향 (앞 → 뒤)
Route의 associated value로 ID를 넘기고, Router의 `make…ViewModel` factory에서 ViewModel을 조립한다.

### 역방향 (뒤 → 앞)
기본은 **공유 Repository**로 자동 동기화. 휘발성 단발 선택만 예외적으로 콜백 주입.

## DeepLink

- 교차 탭 이동은 `AppRouter.handle(DeepLink)`가 유일한 진입점.
- 메인 진입 전 도착한 링크는 `enqueue(_:)` → `flushPendingLink()`로 지연 처리.

## 금지 사항

- `NavigationLink(value: someView)` 처럼 View를 직접 넘기지 않는다.
- `UIScreen`·`UIWindow`·`present()` 등 UIKit 네비게이션 사용 금지.
- 탭 내부 Router에서 다른 탭의 path를 직접 조작 금지 — 반드시 `AppRouter` 경유.
