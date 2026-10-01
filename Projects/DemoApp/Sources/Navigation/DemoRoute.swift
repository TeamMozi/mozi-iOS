/// 첫 화면에서 쌓는 화면.
enum DemoRoute: Hashable {
    case flow(DemoFlow)
    case screen(DemoScreen)
    case gallery
}
