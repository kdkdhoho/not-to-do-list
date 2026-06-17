---
description: 다국어 문자열 사용 규칙 — AppStrings enum으로 타입-세이프 접근 강제
globs:
  - "Sources/Feature/**/*.swift"
  - "Sources/Shared/**/*.swift"
  - "Sources/ServiceApp/**/*.swift"
always: true
---

# 다국어 문자열 규칙

사용자에게 보이는 모든 문자열은 `AppStrings` enum에서 가져온다.
문자열 리터럴로 `Text("...")`, `.navigationTitle("...")`, `Label("...")` 직접 호출을 금지한다.
SwiftUI의 자동 현지화(`Text("Hello")`)에 의존하지 않는다.

## 사용법

```swift
// ✅
Text(AppStrings.Tab.home)
Text(AppStrings.Onboarding.welcome)
.navigationTitle(AppStrings.Home.navigationTitle)

// ❌ 금지
Text("홈")
Text("Hello")
.navigationTitle("Application")
Label("ID: \(id)", systemImage: "number")
```

## 새 문자열 추가 절차

1. `Sources/Shared/Resources/Localizable.xcstrings` 에 키-값 추가 (예: `profile.name`)
2. `Sources/Shared/Core/DesignSystem/AppStrings.swift` 에 static property 추가

```swift
// Localizable.xcstrings
"profile.name" → ko: "이름", en: "Name"

// AppStrings.swift
public enum Profile {
    public static var name: String {
        String(localized: "profile.name", bundle: .module)
    }
}
```

## 키 이름 규칙

`{화면}.{용도}` 형식의 점 구분 키를 사용한다.
`AppStrings` enum의 중첩 enum과 1:1로 매핑한다.

```
tab.home          → AppStrings.Tab.home
explore.title     → AppStrings.Explore.title
onboarding.welcome → AppStrings.Onboarding.welcome
error.retry       → AppStrings.Error.retry
```

## 참조 파일

- 문자열 enum: `Sources/Shared/Core/DesignSystem/AppStrings.swift`
- String Catalog: `Sources/Shared/Resources/Localizable.xcstrings`

## 예외

동적 데이터 포맷팅(날짜, 숫자 등)은 `String(localized:)` 또는 `LocalizedStringKey`로 처리한다.
에러 메시지 등 시스템 생성 문자열은 `error.localizedDescription`를 그대로 사용한다.
