import SwiftUI

// MARK: - App Icon
// 디자인 토큰 소스: DESIGN.pen (Foundation / Icons)
// - DESIGN.pen의 lucide 아이콘과 1:1 매핑되는 SF Symbols.
// - Pencil은 SF Symbols를 지원하지 않으므로 디자인은 lucide, 코드는 SF Symbol로 연결한다.
// - 에셋 파일 없이 `Image(systemName:)`을 래핑한다 (다크모드·Dynamic Type 자동 지원).
//
// 새 아이콘 추가 절차:
//   1. DESIGN.pen > Foundation / Icons 에 lucide 아이콘을 추가한다 (source of truth).
//   2. 아래 enum에 case를 추가한다. case 이름 = lucide 이름(camelCase), rawValue = 대응 SF Symbol.
//   3. 코드에서 `Image(appIcon: .house)` 또는 `AppIcon.house.image` 사용.

public enum AppIcon: String {

    // MARK: - Navigation
    case house = "house"
    case search = "magnifyingglass"
    case compass = "safari"
    case settings = "gearshape"
    case arrowLeft = "arrow.left"
    case chevronLeft = "chevron.left"
    case chevronRight = "chevron.right"
    case close = "xmark"                    // lucide: x
    case menu = "line.3.horizontal"

    // MARK: - Actions
    case plus = "plus"
    case check = "checkmark"
    case trash = "trash"                    // lucide: trash-2
    case edit = "pencil"
    case share = "square.and.arrow.up"      // lucide: share-2
    case download = "square.and.arrow.down"
    case heart = "heart"
    case star = "star"
    case bookmark = "bookmark"
    case wrench = "wrench.and.screwdriver"  // lucide: wrench

    // MARK: - Communication
    case mail = "envelope"
    case message = "message"                // lucide: message-circle
    case phone = "phone"
    case send = "paperplane"
    case link = "link"
    case at = "at"                           // lucide: at-sign
    case sparkles = "sparkles"              // lucide: sparkles

    // MARK: - Status
    case info = "info.circle"
    case alertCircle = "exclamationmark.circle"        // lucide: circle-alert
    case alertTriangle = "exclamationmark.triangle"    // lucide: triangle-alert
    case checkCircle = "checkmark.circle"              // lucide: circle-check
    case xCircle = "xmark.circle"                      // lucide: circle-x
    case loader = "arrow.2.circlepath"

    // MARK: - Media
    case play = "play.fill"
    case pause = "pause.fill"
    case skipForward = "forward.fill"
    case volume = "speaker.wave.2"          // lucide: volume-2
    case camera = "camera"
    case photo = "photo"                     // lucide: image
    case video = "video"
    case mic = "mic"

    // MARK: - People
    case user = "person"
    case users = "person.2"
    case userPlus = "person.badge.plus"
    case smile = "face.smiling"
    case userCircle = "person.circle"        // lucide: circle-user

    // MARK: - Form
    case eye = "eye"
    case eyeOff = "eye.slash"
    case calendar = "calendar"
    case clock = "clock"                     // lucide: clock-3
    case mapPin = "location.fill"            // lucide: map-pin
    case lock = "lock"
    case filter = "line.3.horizontal.decrease"  // lucide: funnel
    case hash = "number"                     // lucide: hash

    // MARK: - Commerce
    case cart = "cart"                      // lucide: shopping-cart
    case bag = "bag"                        // lucide: shopping-bag
    case card = "creditcard"                // lucide: credit-card
    case tag = "tag"
    case gift = "gift"
    case wallet = "wallet.pass"
    case receipt = "receipt"
    case percent = "percent"

    // MARK: - Files
    case file = "doc"
    case fileText = "doc.text"              // lucide: file-text
    case folder = "folder"
    case folderOpen = "folder.fill"         // lucide: folder-open
    case paperclip = "paperclip"
    case upload = "icloud.and.arrow.up"     // lucide: cloud-upload
    case save = "tray.and.arrow.down"
    case clipboard = "clipboard"

    // MARK: - Editor
    case copy = "doc.on.doc"
    case list = "list.bullet"
    case grid = "square.grid.2x2"           // lucide: layout-grid
    case ellipsis = "ellipsis"              // lucide: more-horizontal · more-vertical (세로는 .rotationEffect(.degrees(90)))
    case maximize = "arrow.up.left.and.arrow.down.right"  // lucide: maximize-2
    case scissors = "scissors"
    case undo = "arrow.uturn.backward"      // lucide: undo-2

    // MARK: - Arrows
    case arrowRight = "arrow.right"
    case arrowUp = "arrow.up"
    case arrowDown = "arrow.down"
    case chevronUp = "chevron.up"
    case chevronDown = "chevron.down"
    case refresh = "arrow.clockwise"        // lucide: refresh-cw
    case logout = "rectangle.portrait.and.arrow.right"  // lucide: log-out
    case externalLink = "arrow.up.right.square"

    // MARK: - Notify & Theme
    case bell = "bell"
    case bellOff = "bell.slash"             // lucide: bell-off
    case wifi = "wifi"
    case bluetooth = "dot.radiowaves.left.and.right"
    case toggle = "circle.lefthalf.filled"  // lucide: toggle-left
    case mute = "speaker.slash"             // lucide: volume-x
    case sun = "sun.max"
    case moon = "moon"
    case rocket = "rocket"                  // lucide: rocket

    // MARK: - 잉걸 (Ember)
    case flame = "flame"                              // lucide: flame — 스트릭 불꽃
    case snowflake = "snowflake"                      // lucide: snowflake — 프리즈
    case smoke = "smoke"                              // lucide: cigarette — 담배
    case forkKnife = "fork.knife"                     // lucide: drumstick — 야식
    case takeoutBag = "takeoutbag.and.cup.and.straw"  // lucide: utensils — 배달음식
    case wineglass = "wineglass"                      // lucide: beer — 술
    case cupAndSaucer = "cup.and.saucer"              // lucide: coffee — 카페 음료
    case popcorn = "popcorn"                          // lucide: cookie — 군것질
    case iphone = "iphone"                            // lucide: smartphone — SNS
    case playRectangle = "play.rectangle"             // lucide: youtube — 쇼츠·유튜브
    case gamecontroller = "gamecontroller"            // lucide: gamepad-2 — 게임
    case archive = "archivebox"                       // lucide: archive — 보관
    case banknote = "banknote"                        // lucide: banknote — 아낀 돈
    case medal = "medal"                              // lucide: medal — 배지
    case bookOpen = "book"                            // lucide: book-open — 독서 환산

    /// 대응하는 SF Symbol 이름.
    public var systemName: String { rawValue }

    /// SF Symbol 이미지. 색상은 `.foregroundStyle(AppColor…)`로 지정한다.
    public var image: Image {
        Image(systemName: systemName)
    }
}

public extension Image {
    /// SF Symbol 아이콘. `Image(appIcon: .house)` 형태로 사용.
    init(appIcon: AppIcon) {
        self.init(systemName: appIcon.systemName)
    }
}
