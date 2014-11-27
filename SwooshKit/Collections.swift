
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
public func mapSome<S: SequenceType, T>(source: S, transform: S.Generator.Element -> T?) -> [T] {
    return mapSome(source, transform)
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
