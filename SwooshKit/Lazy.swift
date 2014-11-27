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

extension MapSomeSequenceView: SequenceType {
    public typealias Generator = GeneratorOf<T>
    
    /// Return a *generator* over the elements of this *sequence*.
    ///
    /// Complexity: O(1)
    public func generate() -> Generator {
        var g = _base.generate()
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

extension LazySequence {
    /// Return an collection containing the results of mapping `transform`
    /// over `source`, when transform does not return nil.
    func mapSome<U>(transform: (S.Generator.Element) -> U?) -> LazySequence<MapSomeSequenceView<LazySequence<S>,U>> {
        return lazy(MapSomeSequenceView(base: self, transform: transform))
    }
}

extension LazyForwardCollection {
    /// Return an collection containing the results of mapping `transform`
    /// over `source`, when transform does not return nil.
    func mapSome<U>(transform: (S.Generator.Element) -> U?) -> LazySequence<MapSomeSequenceView<LazyForwardCollection<S>,U>> {
        return lazy(MapSomeSequenceView(base: self, transform: transform))
    }
}

extension LazyBidirectionalCollection {
    /// Return an collection containing the results of mapping `transform`
    /// over `source`, when transform does not return nil.
    func mapSome<U>(transform: (S.Generator.Element) -> U?) -> LazySequence<MapSomeSequenceView<LazyBidirectionalCollection<S>,U>> {
        return lazy(MapSomeSequenceView(base: self, transform: transform))
    }
}

extension LazyRandomAccessCollection {
    /// Return an collection containing the results of mapping `transform`
    /// over `source`, when transform does not return nil.
    func mapSome<U>(transform: (S.Generator.Element) -> U?) -> LazySequence<MapSomeSequenceView<LazyRandomAccessCollection<S>,U>> {
        return lazy(MapSomeSequenceView(base: self, transform: transform))
    }
}

public struct AccumulateSequenceView<Base: SequenceType, T> {
    private let _base: Base
    private let _initial: T
    private let _combine: (T, Base.Generator.Element) -> T
    
    private init(base: Base, initial: T, combine: (T, Base.Generator.Element) -> T) {
        _base = base
        _initial = initial
        _combine = combine
    }
}

extension AccumulateSequenceView: SequenceType {
    public typealias Generator = GeneratorOf<T>
    
    /// Return a *generator* over the elements of this *sequence*.
    ///
    /// Complexity: O(1)
    public func generate() -> Generator {
        var g = _base.generate()
        var prev = _initial
        return GeneratorOf {
            if let next = g.next() {
                prev = self._combine(prev,next)
                return prev
            }
            else {
                return nil
            }
        }
    }
}

extension LazySequence {
    /// Return an collection containing the results of mapping `combine`
    /// over each element of `source`, carrying the result forward to combine
    /// with the next element.  `initial` becomes the first element of the result.
    ///
    /// e.g. `combine([1,2,3],0,+)` returns `[0,1,3,6]`
    func accumulate<U>(initial: U, combine: (U, S.Generator.Element) -> U) -> LazySequence<AccumulateSequenceView<LazySequence<S>,U>> {
        return lazy(AccumulateSequenceView(base: self, initial: initial, combine: combine))
    }
}

extension LazyForwardCollection {
    /// Return an collection containing the results of mapping `combine`
    /// over each element of `source`, carrying the result forward to combine
    /// with the next element.  `initial` becomes the first element of the result.
    ///
    /// e.g. `combine([1,2,3],0,+)` returns `[0,1,3,6]`
    func accumulate<U>(initial: U, combine: (U, S.Generator.Element) -> U) -> LazySequence<AccumulateSequenceView<LazyForwardCollection<S>,U>> {
        return lazy(AccumulateSequenceView(base: self, initial: initial, combine: combine))
    }
}

extension LazyBidirectionalCollection {
    /// Return an collection containing the results of mapping `combine`
    /// over each element of `source`, carrying the result forward to combine
    /// with the next element.  `initial` becomes the first element of the result.
    ///
    /// e.g. `combine([1,2,3],0,+)` returns `[0,1,3,6]`
    func accumulate<U>(initial: U, combine: (U, S.Generator.Element) -> U) -> LazySequence<AccumulateSequenceView<LazyBidirectionalCollection<S>,U>> {
        return lazy(AccumulateSequenceView(base: self, initial: initial, combine: combine))
    }
}

extension LazyRandomAccessCollection {
    /// Return an collection containing the results of mapping `combine`
    /// over each element of `source`, carrying the result forward to combine
    /// with the next element.  `initial` becomes the first element of the result.
    ///
    /// e.g. `combine([1,2,3],0,+)` returns `[0,1,3,6]`
    func accumulate<U>(initial: U, combine: (U, S.Generator.Element) -> U) -> LazySequence<AccumulateSequenceView<LazyRandomAccessCollection<S>,U>> {
        return lazy(AccumulateSequenceView(base: self, initial: initial, combine: combine))
    }
}
