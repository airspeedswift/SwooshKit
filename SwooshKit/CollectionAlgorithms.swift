
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

/// Map only those values if their index in the sequence matches a predicate,
/// leaving other elements untransformed
func mapIfIndex<S: SequenceType, C: ExtensibleCollectionType where S.Generator.Element == C.Generator.Element>(source: S, transform: S.Generator.Element -> S.Generator.Element, ifIndex: Int -> Bool) -> C {
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

/// Map only every nth element of a sequence, leaving other elements untransformed
public func mapEveryNth<S: SequenceType, C: ExtensibleCollectionType where S.Generator.Element == C.Generator.Element>(source: S, n: Int, transform: S.Generator.Element -> C.Generator.Element) -> C {
    let isNth = isMultipleOf(n) • successor
    return mapIfIndex(source, transform, isNth)
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

/// Removes an equatable element from a collection
func remove
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


