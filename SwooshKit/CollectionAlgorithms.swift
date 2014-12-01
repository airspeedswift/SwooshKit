
/// Return an collection containing the results of mapping `transform`
/// over `source`, when transform does not return nil.
public func mapSome<S: SequenceType, C: ExtensibleCollectionType>(source: S, transform: S.Generator.Element -> C.Generator.Element?) -> C {
    var result = C()
    for x in source {
        if let y = transform(x) {
            result.append(y)
        }
    }
    return result
}

/// Return an collection containing the results of mapping `transform`
/// over `source`, when transform does not return nil.
// Specialized version to default to returning an array
public func mapSome<S: SequenceType, T>(source: S, transform: S.Generator.Element -> T?) -> [T] {
    return mapSome(source, transform)
}

// unlike with mapSome, mapIfIndex and mapEveryNth functions don't use the second template in
// their arguments, only in their return type, so the "overload to default to []"
// approach doesn't work unfortunately.  debtatable whether this means they should
// return an ExtensibleCollection (more useful) or an Array (like in the Swift std lib)
//
// as a compromise, here are versions that map from/to the same collection type, so
// e.g. [T] -> [T] defaults, though T...T -> [T] doesn't

// private implementation, to be called by public versions, to avoid recursion
private func _mapIfIndex<S: SequenceType, C: ExtensibleCollectionType where S.Generator.Element == C.Generator.Element>(source: S, transform: S.Generator.Element -> S.Generator.Element, ifIndex: Int -> Bool) -> C {
    var result = C()
    for (index,value) in enumerate(source) {
        if ifIndex(index) {
            result.append(transform(value))
        }
        else {
            result.append(value)
        }
    }
    return result
}

/// Map only those values if their index in the sequence matches a predicate,
/// leaving other elements untransformed
public func mapIfIndex<S: SequenceType, C: ExtensibleCollectionType where S.Generator.Element == C.Generator.Element>(source: S, transform: S.Generator.Element -> S.Generator.Element, ifIndex: Int -> Bool) -> C {
        return _mapIfIndex(source,transform,ifIndex)
}

/// Map only those values if their index in the sequence matches a predicate,
/// leaving other elements untransformed
public func mapIfIndex<C: ExtensibleCollectionType>(source: C, transform: C.Generator.Element -> C.Generator.Element, ifIndex: Int -> Bool) -> C {
    return _mapIfIndex(source, transform, ifIndex)
}

// private implementation, to be called by public versions, to avoid recursion
private func _mapEveryNth<S: SequenceType, C: ExtensibleCollectionType where S.Generator.Element == C.Generator.Element>(source: S, n: Int, transform: S.Generator.Element -> C.Generator.Element) -> C {
    let isNth = isMultipleOf(n) • successor
    return mapIfIndex(source, transform, isNth)
}

/// Map only every nth element of a sequence, leaving other elements untransformed
public func mapEveryNth<S: SequenceType, C: ExtensibleCollectionType where S.Generator.Element == C.Generator.Element>(source: S, n: Int, transform: S.Generator.Element -> C.Generator.Element) -> C {
        return _mapEveryNth(source, n, transform)
}

/// Map only every nth element of a sequence, leaving other elements untransformed
public func mapEveryNth<C: ExtensibleCollectionType>(source: C, n: Int, transform: C.Generator.Element -> C.Generator.Element) -> C {
    return _mapEveryNth(source, n, transform)
}

/// Return an collection containing the results of mapping `combine`
/// over each element of `source`, carrying the result forward to combine
/// with the next element.  `initial` becomes the first element of the result.
///
/// e.g. `combine([1,2,3],0,+)` returns `[0,1,3,6]`
public func accumulate
  <S: SequenceType, C: ExtensibleCollectionType>
  (source: S, var initial: C.Generator.Element, combine: (C.Generator.Element, S.Generator.Element) -> C.Generator.Element)
  -> C {
    var result = C()
    result.append(initial)
    for x in source {
        initial = combine(initial, x)
        result.append(initial)
    }
    return result
}

/// Return an collection containing the results of mapping `combine`
/// over each element of `source`, carrying the result forward to combine
/// with the next element.  `initial` becomes the first element of the result.
///
/// e.g. `combine([1,2,3],0,+)` returns `[0,1,3,6]`
public func accumulate<S: SequenceType, U>
  (source: S, initial: U, combine: (U, S.Generator.Element)->U)
  -> [U] {
    return accumulate(source, initial, combine)
}

/// Returns the first index where matche `match(element)` returns `true`, or `nil` if
/// `value` is not found.
///
/// Complexity: O(\ `countElements(domain)`\ )
public func find<C : CollectionType>(domain: C, match: C.Generator.Element->Bool) -> C.Index? {
    for idx in indices(domain) {
        if match(domain[idx]) {
            return idx
        }
    }
    return nil
}

/// A sequence of pairs of optionals built out of two underlying sequences,
/// where the elements of the `i`\ th pair are the `i`\ th elements of each
/// underlying sequence.  Where one sequence is longer than the other, the 
/// other half of the pair will be padded with nil.
public struct ZipLonger2<S1: SequenceType, S2: SequenceType>: SequenceType {
    private let _s1: S1
    private let _s2: S2
    init(_ s1: S1, _ s2: S2) {
        _s1 = s1
        _s2 = s2
    }
    
    public typealias Generator = GeneratorOf<(S1.Generator.Element?, S2.Generator.Element?)>
    
    public func generate() -> Generator {
        // the requirement to never call .next() a second time
        // complicates this quite a lot
        var g1: S1.Generator? = _s1.generate()
        var g2: S2.Generator? = _s2.generate()
        return GeneratorOf {
            switch(g1?.next(),g2?.next()) {
            case (.None,.None): return nil // both generators are exhausted
            case let (.Some(x),.None): g2 = nil; return (x,nil)
            case let (.None,.Some(y)): g1 = nil; return (nil,y)
            case (let x, let y): return (x,y)
            }
        }
    }
}


/// Return true iff `a1` and `a2` contain equivalent elements, using
/// `isEquivalent` as the equivalence test.  Requires: `isEquivalent`
/// is an `equivalence relation
/// <http://en.wikipedia.org/wiki/Equivalence_relation>`_
//
// Only here because the std lib version of equal requires the two
// sequence's element types be the same when really they don't have to be
// the std lib equal that takes a comparator requires the sequences contain the same
// type, which shouldn't be necessary since the comparator could cater for that
public func equal<S1: SequenceType, S2: SequenceType>(a1: S1, a2: S2, isEquivalent: (S1.Generator.Element, S2.Generator.Element) -> Bool) -> Bool {
    for pair in ZipLonger2(a1, a2) {
        switch pair {
        case (.None,.None): assertionFailure("should never happen")
        case (.None, .Some): return false
        case (.Some, .None): return false
        case let (.Some(x),.Some(y)): if !isEquivalent(x,y) { return false }
        }
    }
    return true
}


/// Removes an element from a collection if `removeElement` returns `true`
public func remove
    <C: protocol<RangeReplaceableCollectionType, MutableCollectionType>>
    (inout col: C, removeElement: C.Generator.Element -> Bool) {
        // find the first entry to remove
        if var advance = find(col, removeElement) {
            // advance points to next element to test,
            // rear points to where to copy it to
            // if it's a keeper
            var rear = advance++
            while advance != col.endIndex {
                if !removeElement(col[advance]) {
                    col[rear] = col[advance]
                    ++rear
                }
                ++advance
            }
            col.removeRange(rear..<col.endIndex)
        }
}

/// Removes an equatable element from a collection
public func remove
    <C: protocol<RangeReplaceableCollectionType,
                 MutableCollectionType>,
     E: Equatable
     where C.Generator.Element == E>
    (inout col: C, value: E) {
        // find the first entry to remove
        if var advance = find(col, value) {
            // advance points to next element to test,
            // rear points to where to copy it to
            // if it's a keeper
            var rear = advance++
            while advance != col.endIndex {
                if col[advance] != value {
                    col[rear] = col[advance]
                    ++rear
                }
                ++advance
            }
            col.removeRange(rear..<col.endIndex)
        }
}

/// A version of dropFirst that works on any sequence.  Note if the passed-in
/// sequence is not multi-pass, using a sequence vis this will consume the sequence.
public func dropFirst<S: SequenceType>(seq: S) -> SequenceOf<S.Generator.Element> {
    return SequenceOf { ()->GeneratorOf<S.Generator.Element> in
        var g = seq.generate()
        let first = g.next()
        // if you prefer your dropFirst to explodinate on empty
        // sequences, add an assert(first != nil) here...
        return GeneratorOf {
            // shouldn't call GeneratorType.next()
            // after it's returned nil the first time
            first == nil ? nil : g.next()
        }
    }
}


