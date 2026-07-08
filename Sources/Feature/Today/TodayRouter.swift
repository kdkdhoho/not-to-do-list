import Observation
import SwiftUI

@Observable
public final class TodayRouter {
    public var path = NavigationPath()
    public var sheet: TodaySheet?

    public init() {}

    public func navigate(to route: TodayRoute) { path.append(route) }
    public func pop() { path.removeLast() }
    public func popToRoot() { path.removeLast(path.count) }
    public func presentSheet(_ sheet: TodaySheet) { self.sheet = sheet }
    public func dismissSheet() { sheet = nil }
}
