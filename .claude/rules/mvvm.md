---
description: MVVM 패턴 규칙 — View·ViewModel 역할 분리와 데이터 바인딩
globs:
  - "Sources/Feature/**/*.swift"
always: true
---

# MVVM 규칙

## 역할 분리

### View
- UI 선언만 담당한다. 비즈니스 로직을 직접 수행하지 않는다.
- 데이터는 ViewModel 프로퍼티에서 읽고, 액션은 ViewModel 메서드로 전달한다.

```swift
// ✅
struct HomeView: View {
    let viewModel: HomeViewModel

    var body: some View {
        List(viewModel.items) { item in ... }
            .onAppear { viewModel.loadData() }
    }
}

// ❌ View에서 직접 데이터 처리
List(networkClient.fetchItems()) { ... }
```

### ViewModel
- `@Observable` 매크로를 사용한다.
- 데이터를 가공해 View에 제공한다.
- Repository 프로토콜을 통해 데이터를 가져온다.

```swift
// ✅
@Observable
final class HomeViewModel {
    var items: [Item] = []
    var state: ViewState<[Item]> = .idle

    private let repository: ItemRepository

    func loadData() async { ... }
    func didSelectItem(_ id: Item.ID) { ... }
}
```

## 데이터 바인딩

### 정방향 (ViewModel → View)
- ViewModel의 프로퍼티를 View에서 직접 읽는다.
- `@Observable` 객체는 **한 곳에서만 소유**하고, 자식 View는 `let`으로 전달한다.

```swift
// ✅ 소유권은 상위 View
struct HomeNavigationView: View {
    let viewModel: HomeViewModel
    let router: HomeRouter

    var body: some View {
        HomeView(viewModel: viewModel)
    }
}
```

- 바인딩이 필요하면 body에서 `@Bindable`을 만든다.

```swift
// ✅
var body: some View {
    @Bindable var viewModel = viewModel
    TextField("입력", text: $viewModel.searchText)
}
```

### 역방향 (View → ViewModel)
- 사용자 액션은 ViewModel의 메서드 호출로 전달한다.
- 클로저 캡처 대신 메서드를 사용한다.

```swift
// ✅
Button { viewModel.didTapSubmit() }
.onAppear { viewModel.loadData() }
.onChange(of: search) { viewModel.search($0) }

// ❌ 클로저로 로직 인라인
Button { networkClient.send(request) }
```

## 금지 사항

- View에서 Repository, NetworkClient 등 데이터 소스에 직접 접근 금지
- ViewModel에서 UIKit 참조 (`UIColor`, `UIFont` 등) 사용 금지
- ViewModel 간 직접 참조 금지 — 필요시 Router나 상위 객체가 중재
