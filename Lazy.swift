struct MapSomeSequenceView<Base: SequenceType, T> {
    private let _base: Base
    private let _transform: (Base.Generator.Element) -> T?
}

extension MapSomeSequenceView: SequenceType {
    typealias Generator = GeneratorOf<T>

    func generate() -> Generator {
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
