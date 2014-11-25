/// A `SequenceType` whose elements consist of those in a `Base`
/// `SequenceType` passed through a transform function returning `T?`,
/// where the result of the transform is not nil.
/// These elements are computed lazily, each time they're read, by
/// calling the transform function on a base element.
public struct MapSomeSequenceView<Base: SequenceType, T> {
    private let _base: Base
    private let _transform: (Base.Generator.Element) -> T?
    
    private init(base: Base, transform: (Base.Generator.Element) -> T?) {
        _base = base
        _transform = transform
    }
}

public extension MapSomeSequenceView: SequenceType {
    public typealias Generator = GeneratorOf<T>

    /// Return a *generator* over the elements of this *sequence*.
    ///
    /// Complexity: O(1)
    public func generate() -> Generator {
        var g = _base.generate()
        // GeneratorOf is a helper that takes a
        // closure and calls it to generate each
        // element
        return GeneratorOf {
            while let element = g.next() {
                if let some = self._transform(element) {
                    return some
                }
            }
            return nil
        }
    }
}

extension LazyBidirectionalCollection {
    func mapSome<U>(transform: (S.Generator.Element) -> U?) -> LazySequence<MapSomeSequenceView<LazyBidirectionalCollection<S>,U>> {
        return lazy(MapSomeSequenceView(_base: self, _transform: transform))
    }
}

