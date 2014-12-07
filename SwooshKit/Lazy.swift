
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







/// A re-implementation of Swift.ReverseRandomAccessIndex, which currently only has
/// private constructor, so cannot be used to fix the issue that LazyRandomAccessCollection.reverse
/// returns a bidirectional collection not a random-access one
public struct SWKReverseRandomAccessIndex<I : RandomAccessIndexType> : RandomAccessIndexType {
    
    private let _base: I
    private init(_ base: I) {
        _base = base
    }
    
    public typealias Distance = I.Distance
    
    /// Returns the next consecutive value after `self`.
    ///
    /// Requires: the next value is representable.
    public func successor() -> SWKReverseRandomAccessIndex<I> {
        return SWKReverseRandomAccessIndex(_base.predecessor())
    }
    
    /// Returns the previous consecutive value before `self`.
    ///
    /// Requires: the previous value is representable.
    public func predecessor() -> SWKReverseRandomAccessIndex<I> {
        return SWKReverseRandomAccessIndex(_base.successor())
    }
    
    /// Return the minimum number of applications of `successor` or
    /// `predecessor` required to reach `other` from `self`.
    ///
    /// Complexity: O(1).
    public func distanceTo(other: SWKReverseRandomAccessIndex<I>) -> I.Distance {
        return _base.distanceTo(other._base) * -1
    }
    
    /// Return `self` offset by `n` steps.
    ///
    /// :returns: If `n > 0`, the result of applying `successor` to
    /// `self` `n` times.  If `n < 0`, the result of applying
    /// `predecessor` to `self` `-n` times. Otherwise, `self`.
    ///
    /// Complexity: O(1)
    public func advancedBy(amount: I.Distance) -> SWKReverseRandomAccessIndex<I> {
        let inverse = amount * -1
        return SWKReverseRandomAccessIndex(_base.advancedBy(inverse))
    }
}


public func ==<I>(lhs: SWKReverseRandomAccessIndex<I>, rhs: SWKReverseRandomAccessIndex<I>) -> Bool {
    return true
}

/// A re-implementation of Swift.RandomAccessReverseView, which currently only has
/// private constructor, so cannot be used to fix the issue that LazyRandomAccessCollection.reverse
/// returns a bidirectional collection not a random-access one
public struct SWKRandomAccessReverseView<T : CollectionType where T.Index : RandomAccessIndexType> : CollectionType {
    
    private let _base: T
    
    private init(_ base: T) {
        _base = base
    }
    
    /// A type that represents a valid position in the collection.
    ///
    /// Valid indices consist of the position of every element and a
    /// "past the end" position that's not valid for use as a subscript.
    public typealias Index = SWKReverseRandomAccessIndex<T.Index>
    
    /// A type whose instances can produce the elements of this
    /// sequence, in order.
    typealias Generator = IndexingGenerator<SWKRandomAccessReverseView<T>>
    
    /// Return a *generator* over the elements of this *sequence*.
    ///
    /// Complexity: O(1)
    public func generate() -> IndexingGenerator<SWKRandomAccessReverseView<T>> {
        return IndexingGenerator(self)
    }
    
    /// The position of the first element in a non-empty collection.
    ///
    /// Identical to `endIndex` in an empty collection.
    public var startIndex: Index {
        return Index(_base.endIndex.predecessor())
    }
    
    /// The collection's "past the end" position.
    ///
    /// `endIndex` is not a valid argument to `subscript`, and is always
    /// reachable from `startIndex` by zero or more applications of
    /// `successor()`.
    public var endIndex: Index {
        // this is probably no good as an implementation, since
        // certain implementations of indices might not cope
        // with going backwards one from the start.
        return Index(_base.startIndex.predecessor())
    }
    
    public subscript (position: Index) -> T.Generator.Element {
        return _base[position._base]
    }
}

extension LazyRandomAccessCollection {
    /// A version of reverse that returns a random-access colleciton
    func rreverse() -> LazyRandomAccessCollection<SWKRandomAccessReverseView<LazyRandomAccessCollection<S>>> {
        return lazy(SWKRandomAccessReverseView(self))
    }
}

// note, LazyRandomAccessCollection.reverse returns a LazyBidirectionalCollection NOT another LazyRandomAccessCollection, so here we call rreverse instead
public func reverse<C: CollectionType where C.Index: RandomAccessIndexType>(source: LazyRandomAccessCollection<C>) -> LazyRandomAccessCollection<SWKRandomAccessReverseView<LazyRandomAccessCollection<C>>> {
    return source.rreverse()
}



