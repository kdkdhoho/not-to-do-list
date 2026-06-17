---
description: SwiftUI View 작성 시 디자인 시스템 토큰 사용 규칙
globs:
  - "Sources/Feature/**/*.swift"
  - "Sources/ServiceApp/**/*.swift"
  - "Sources/Shared/Core/DesignSystem/**/*.swift"
always: true
---

# View 디자인 시스템 규칙

SwiftUI View를 작성하거나 수정할 때 반드시 프로젝트 디자인 시스템 토큰을 사용한다.

## 토큰의 출처 (Source of Truth)

디자인 토큰의 단일 진실은 **`DESIGN.pen`**이다.
`AppColor`·`AppTypography`·`Theme`의 토큰 **값**(색 hex, 폰트 size/weight, spacing·radius 수치)은
`DESIGN.pen`에서 정의하고, Swift 파일은 그 값을 옮겨둔 사본이다.

- 토큰 **값을 코드에서 직접 바꾸지 않는다.** 먼저 Pencil에서 `DESIGN.pen`을 수정한 뒤 코드에 반영한다 (`.pen` → 코드 단방향).
- 새 토큰도 `DESIGN.pen`에 먼저 추가하고 Swift 토큰으로 옮긴다.
- View에서 토큰을 **소비**하는 규칙(아래)은 그대로다 — 하드코딩 금지.

## 색상

색상은 항상 `AppColor` enum에서 가져온다.
`Color.red`, `.blue`, `Color(hex:)`, `Color(UIColor.system...)` 등 하드코딩을 금지한다.

```swift
// ✅
.foregroundStyle(AppColor.Text.primary)
.background(AppColor.Background.secondary)

// ❌
.foregroundStyle(Color.black)
.background(Color(hex: "F9FAFB"))
```

## 타이포그래피

폰트는 항상 `AppTypography`에서 가져온다.
`.font(.title)`, `.font(.system(...))`, `Font.custom(...)` 직접 호출을 금지한다.

```swift
// ✅
.font(AppTypography.title1)
.font(AppTypography.body1)

// ❌
.font(.title)
.font(.system(size: 16, weight: .semibold))
```

## 간격 & 코너

여백과 라운딩은 `Theme.Spacing`, `Theme.CornerRadius`를 사용한다.
정수 리터럴 매직넘버를 금지한다.

```swift
// ✅
.padding(Theme.Spacing.md)
.clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))

// ❌
.padding(16)
.cornerRadius(12)
```

## 참조 파일

- 색상 토큰: `Sources/Shared/Core/DesignSystem/AppColor.swift`
- 타이포그래피: `Sources/Shared/Core/DesignSystem/AppTypography.swift`
- 간격·코너: `Sources/Shared/Core/DesignSystem/Theme.swift`
