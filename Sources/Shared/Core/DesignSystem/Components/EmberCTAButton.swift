import SwiftUI

/// 하루 마무리 전용 CTA — 잉걸이 허락된 유일한 버튼 (design.md checkin-cta)
public struct EmberCTAButton: View {
    private let title: String
    private let action: () -> Void

    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColor.Text.inverse)
                .frame(maxWidth: .infinity, minHeight: 56)
        }
        .buttonStyle(EmberCTAButtonStyle())
    }
}

/// 잉걸 CTA 프레스 피드백: pressed 색 전환 + scale 0.97.
/// `onLongPressGesture`가 탭을 삼키는 문제를 피하려 ButtonStyle로 프레스 상태를 다룬다.
private struct EmberCTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed ? AppColor.Brand.primaryPressed : AppColor.Brand.primary,
                in: RoundedRectangle(cornerRadius: Theme.CornerRadius.lg, style: .continuous)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}
