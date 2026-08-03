import Foundation

public extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else {
            return []
        }

        var result: [[Element]] = []
        let capacity = count / size + (count % size == 0 ? 0 : 1)
        result.reserveCapacity(capacity)

        var index = startIndex
        while index < endIndex {
            let next = self.index(index, offsetBy: size, limitedBy: endIndex) ?? endIndex
            result.append(Array(self[index..<next]))
            index = next
        }
        return result
    }

    func unique<Key: Hashable>(by keyPath: KeyPath<Element, Key>) -> [Element] {
        var seen = Set<Key>()
        var result: [Element] = []
        result.reserveCapacity(count)

        for element in self {
            let key = element[keyPath: keyPath]
            if seen.insert(key).inserted {
                result.append(element)
            }
        }
        return result
    }
}

public extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        unique(by: \.self)
    }
}
