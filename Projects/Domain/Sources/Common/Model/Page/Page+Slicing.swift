import Foundation

extension Page {
    /// 목록을 `request` 의 한 페이지로 자른다. `*PreviewData` 의 가짜 목록이 쓴다.
    /// 남은 항목이 있으면 `next` 는 같은 `size` 의 다음 페이지다.
    /// 범위 밖 페이지, 음수 페이지, `size` 0 이하는 빈 `items` 와 `nil` 을 돌려준다.
    static func slicing(_ items: [Item], by request: PageRequest) -> Page {
        guard request.page >= 0, request.size > 0 else {
            return Page(items: [], next: nil)
        }
        // page * size 를 그냥 곱하면 넘칠 때 크래시한다. 넘치면 범위 밖이다.
        let (start, overflow) = request.page.multipliedReportingOverflow(by: request.size)
        guard !overflow, start < items.count else {
            return Page(items: [], next: nil)
        }
        let end = start + min(request.size, items.count - start)
        let next = end < items.count ? PageRequest(page: request.page + 1, size: request.size) : nil
        return Page(items: Array(items[start..<end]), next: next)
    }
}
