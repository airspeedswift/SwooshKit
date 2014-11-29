
// Unfortunately none of these extensions to the lazy collections will 
// be visible outside the library since you can't publicly extend other
// module's types.
//
// But the free functions can be used.

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

public extension LazySequence {
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

// TODO: Versions of these that return map view collections not sequences

extension LazySequence {
    /// Map only those values if their index in the sequence matches a predicate,
    /// leaving other elements untransformed
    func mapIfIndex(transform: (S.Generator.Element) -> S.Generator.Element, ifIndex: Int -> Bool) -> LazySequence<MapSequenceView<EnumerateSequence<LazySequence<S>>,S.Generator.Element>> {
        return lazy(enumerate(self)).map { (pair: (index: Int, elem: S.Generator.Element)) -> S.Generator.Element in
            ifIndex(pair.index)
                ? transform(pair.elem)
                : pair.elem
        }
    }
    
    /// Map only every nth element of a sequence, leaving other elements untransformed
    func mapEveryNth(n: Int, _ transform: (S.Generator.Element) -> S.Generator.Element) -> LazySequence<MapSequenceView<EnumerateSequence<LazySequence<S>>,S.Generator.Element>> {
        return self.mapIfIndex(transform, isMultipleOf(n) • successor)
    }
}

extension LazyForwardCollection {
    /// Map only those values if their index in the sequence matches a predicate,
    /// leaving other elements untransformed
    func mapIfIndex(transform: (S.Generator.Element) -> S.Generator.Element, ifIndex: Int -> Bool) -> LazySequence<MapSequenceView<EnumerateSequence<LazyForwardCollection<S>>,S.Generator.Element>> {
        return lazy(enumerate(self)).map { (pair: (index: Int, elem: S.Generator.Element)) -> S.Generator.Element in
            ifIndex(pair.index)
                ? transform(pair.elem)
                : pair.elem
        }
    }
    
    /// Map only every nth element of a sequence, leaving other elements untransformed
    func mapEveryNth(n: Int, _ transform: (S.Generator.Element) -> S.Generator.Element) -> LazySequence<MapSequenceView<EnumerateSequence<LazyForwardCollection<S>>,S.Generator.Element>> {
        return self.mapIfIndex(transform, isMultipleOf(n) • successor)
    }
}

extension LazyBidirectionalCollection {
    /// Map only those values if their index in the sequence matches a predicate,
    /// leaving other elements untransformed
    func mapIfIndex(transform: (S.Generator.Element) -> S.Generator.Element, ifIndex: Int -> Bool) -> LazySequence<MapSequenceView<EnumerateSequence<LazyBidirectionalCollection<S>>,S.Generator.Element>> {
        return lazy(enumerate(self)).map { (pair: (index: Int, elem: S.Generator.Element)) -> S.Generator.Element in
            ifIndex(pair.index)
                ? transform(pair.elem)
                : pair.elem
        }
    }
    
    /// Map only every nth element of a sequence, leaving other elements untransformed
    func mapEveryNth(n: Int, _ transform: (S.Generator.Element) -> S.Generator.Element) -> LazySequence<MapSequenceView<EnumerateSequence<LazyBidirectionalCollection<S>>,S.Generator.Element>> {
        return self.mapIfIndex(transform, isMultipleOf(n) • successor )
    }
}


extension LazyRandomAccessCollection {
    /// Map only those values if their index in the sequence matches a predicate,
    /// leaving other elements untransformed
    func mapIfIndex(transform: (S.Generator.Element) -> S.Generator.Element, ifIndex: Int -> Bool) -> LazySequence<MapSequenceView<EnumerateSequence<LazyRandomAccessCollection<S>>,S.Generator.Element>> {
        return lazy(enumerate(self)).map { (pair: (index: Int, elem: S.Generator.Element)) -> S.Generator.Element in
            ifIndex(pair.index)
                ? transform(pair.elem)
                : pair.elem
        }
    }
    
    /// Map only every nth element of a sequence, leaving other elements untransformed
    func mapEveryNth(n: Int, _ transform: (S.Generator.Element) -> S.Generator.Element) -> LazySequence<MapSequenceView<EnumerateSequence<LazyRandomAccessCollection<S>>,S.Generator.Element>> {
        return self.mapIfIndex(transform, isMultipleOf(n) • successor )
    }
}



// Free versions of lazy member functions:

public func reverse<C: CollectionType where C.Index: BidirectionalIndexType>(source: LazyBidirectionalCollection<C>) -> LazyBidirectionalCollection<BidirectionalReverseView<C>> {
    return source.reverse()
}

// note, LazyRandomAccessCollection.reverse returns a LazyBidirectionalCollection NOT another LazyRandomAccessCollection
public func reverse<C: CollectionType where C.Index: RandomAccessIndexType>(source: LazyRandomAccessCollection<C>) -> LazyBidirectionalCollection<RandomAccessReverseView<C>> {
    return source.reverse()
}

public func map<S: SequenceType, U>(source: LazySequence<S>, transform: (S.Generator.Element)->U) -> LazySequence<MapSequenceView<S,U>> {
    return source.map(transform)
}

public func map<C: CollectionType, U>(source: LazyForwardCollection<C>, transform: (C.Generator.Element)->U) -> LazyForwardCollection<MapCollectionView<C,U>> {
    return source.map(transform)
}

public func map<C: CollectionType, U where C.Index: BidirectionalIndexType>(source: LazyBidirectionalCollection<C>, transform: (C.Generator.Element)->U) -> LazyBidirectionalCollection<MapCollectionView<C,U>> {
    return source.map(transform)
}

public func map<C: CollectionType, U where C.Index: RandomAccessIndexType>(source: LazyRandomAccessCollection<C>, transform: (C.Generator.Element)->U) -> LazyRandomAccessCollection<MapCollectionView<C,U>> {
    return source.map(transform)
}

public func mapSome<S: SequenceType,U>(source: LazySequence<S>, transform: (S.Generator.Element)->U?) -> LazySequence<MapSomeSequenceView<LazySequence<S>, U>> {
    return source.mapSome(transform)
}

public func mapSome<C: CollectionType,U>(source: LazyForwardCollection<C>, transform: (C.Generator.Element)->U?) -> LazySequence<MapSomeSequenceView<LazyForwardCollection<C>, U>> {
    return source.mapSome(transform)
}

public func mapSome<C: CollectionType,U where C.Index: BidirectionalIndexType>(source: LazyBidirectionalCollection<C>, transform: (C.Generator.Element)->U?) -> LazySequence<MapSomeSequenceView<LazyBidirectionalCollection<C>, U>> {
    return source.mapSome(transform)
}

public func mapSome<C: CollectionType,U where C.Index: RandomAccessIndexType>(source: LazyRandomAccessCollection<C>, transform: (C.Generator.Element)->U?) -> LazySequence<MapSomeSequenceView<LazyRandomAccessCollection<C>, U>> {
    return source.mapSome(transform)
}

public func mapEveryNth<S: SequenceType>(source: LazySequence<S>, n: Int, transform: (S.Generator.Element)->S.Generator.Element) -> LazySequence<MapSequenceView<EnumerateSequence<LazySequence<S>>,S.Generator.Element>> {
    return source.mapEveryNth(n, transform)
}

public func mapEveryNth<C: CollectionType>(source: LazyForwardCollection<C>, n: Int, transform: (C.Generator.Element)->C.Generator.Element) -> LazySequence<MapSequenceView<EnumerateSequence<LazyForwardCollection<C>>,C.Generator.Element>> {
    return source.mapEveryNth(n, transform)
}

public func mapEveryNth<C: CollectionType where C.Index: BidirectionalIndexType>(source: LazyBidirectionalCollection<C>, n: Int, transform: (C.Generator.Element)->C.Generator.Element) -> LazySequence<MapSequenceView<EnumerateSequence<LazyBidirectionalCollection<C>>,C.Generator.Element>> {
    return source.mapEveryNth(n, transform)
}

public func mapEveryNth<C: CollectionType where C.Index: RandomAccessIndexType>(source: LazyRandomAccessCollection<C>, n: Int, transform: (C.Generator.Element)->C.Generator.Element) -> LazySequence<MapSequenceView<EnumerateSequence<LazyRandomAccessCollection<C>>,C.Generator.Element>> {
    return source.mapEveryNth(n, transform)
}

public func mapIfIndex<S: SequenceType>(source: LazySequence<S>, transform: (S.Generator.Element)->S.Generator.Element, ifIndex: Int -> Bool) -> LazySequence<MapSequenceView<EnumerateSequence<LazySequence<S>>,S.Generator.Element>> {
    return source.mapIfIndex(transform, ifIndex)
}

public func mapEveryNth<C: CollectionType>(source: LazyForwardCollection<C>, transform: (C.Generator.Element)->C.Generator.Element, ifIndex: Int -> Bool) -> LazySequence<MapSequenceView<EnumerateSequence<LazyForwardCollection<C>>,C.Generator.Element>> {
    return source.mapIfIndex(transform, ifIndex)
}

public func mapEveryNth<C: CollectionType where C.Index: BidirectionalIndexType>(source: LazyBidirectionalCollection<C>, transform: (C.Generator.Element)->C.Generator.Element, ifIndex: Int -> Bool) -> LazySequence<MapSequenceView<EnumerateSequence<LazyBidirectionalCollection<C>>,C.Generator.Element>> {
    return source.mapIfIndex(transform, ifIndex)
}

public func mapEveryNth<C: CollectionType where C.Index: RandomAccessIndexType>(source: LazyRandomAccessCollection<C>, transform: (C.Generator.Element)->C.Generator.Element, ifIndex: Int -> Bool) -> LazySequence<MapSequenceView<EnumerateSequence<LazyRandomAccessCollection<C>>,C.Generator.Element>> {
    return source.mapIfIndex(transform, ifIndex)
}

