---
description: 이미지·아이콘 리소스 사용 규칙 — AppImage(raster)·AppIcon(SF Symbols) enum으로 타입-세이프 접근 강제
globs:
  - "Sources/Feature/**/*.swift"
  - "Sources/ServiceApp/**/*.swift"
always: true
---

# 이미지·아이콘 리소스 규칙

리소스 종류에 따라 enum이 정해져 있다 — 섞지 않는다.

| 종류 | Enum | 도구 | 출처 |
|------|------|------|------|
| Raster 이미지 | `AppImage` | `Assets.xcassets` `.imageset` | 별도 에셋 파일 |
| 시스템 아이콘 | `AppIcon` | SF Symbols | 시스템 내장 (에셋 불필요) |

문자열 리터럴로 `Image("name")`, `Image(systemName:)` 직접 호출과 `Label(_:systemImage:)` 사용을 금지한다.

## 이미지 (AppImage — raster)

```swift
// ✅
Image(appImage: .logo)
AppImage.logo.image

// ❌
Image("logo")
Image(uiImage: UIImage(named: "logo")!)
```

### 새 이미지 추가 절차

1. `Resources/Assets.xcassets` 에 `.imageset` 폴더 추가 (예: `icon-home.imageset`)
2. `Sources/Shared/Core/DesignSystem/AppImage.swift` 에 동일한 이름의 case 추가

```swift
// AppImage.swift
public enum AppImage: String {
    case iconHome    // icon-home.imageset (case 이름 = imageset 폴더 이름)
}
```

## 아이콘 (AppIcon — SF Symbols)

SF Symbols를 쓴다. `DESIGN.pen > Foundation / Icons`의 lucide 아이콘과 1:1 매핑된다.
Pencil이 SF Symbols를 지원하지 않기 때문에 디자인은 lucide, 코드는 SF Symbol로 연결한다.

```swift
// ✅
Image(appIcon: .house)
AppIcon.search.image

// ❌
Image(systemName: "house")
Label("홈", systemImage: "house")
```

### 새 아이콘 추가 절차

1. `DESIGN.pen > Foundation / Icons` 에 lucide 아이콘을 추가한다 (source of truth).
2. `Sources/Shared/Core/DesignSystem/AppIcon.swift` 에 case 추가 — case 이름 = lucide 이름(camelCase), rawValue = 대응 SF Symbol.

```swift
// AppIcon.swift
public enum AppIcon: String {
    case share = "square.and.arrow.up"  // lucide: share-2
}
```

## 참조 파일

- 이미지 enum: `Sources/Shared/Core/DesignSystem/AppImage.swift`
- 아이콘 enum: `Sources/Shared/Core/DesignSystem/AppIcon.swift`
- 에셋 카탈로그: `Resources/Assets.xcassets`
- 디자인 소스: `DESIGN.pen > Foundation / Icons`
