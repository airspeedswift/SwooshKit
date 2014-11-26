
/// Return an collection containing the results of mapping `transform`
/// over `source`, when transform does not return nil.
func mapSome<S: SequenceType, C: ExtensibleCollectionType>(source: S, transform: S.Generator.Element -> C.Generator.Element?) -> C {
    var result = C()
    for x in source {
        if let y = transform(x) {
            result.append(y)
        }
    }
    return result
}

func mapSome<S: SequenceType, T>(source: S, transform: S.Generator.Element -> T?) -> [T] {
    return mapSome(source, transform)
}
