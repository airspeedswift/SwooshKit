// Unfortunately none of the extensions to the std lib types will
// be visible outside the library since you can't publicly extend other
// module's types.


extension Dictionary {
    /// Construct from an arbitrary sequence with elements of the tupe `(Key,Value)`
    init<S: SequenceType
        where S.Generator.Element == Element>
        (_ seq: S) {
            self.init()
            self.merge(seq)
    }

    /// Merge a sequence of `(Key,Value)` tuples into the dictionary
    mutating func merge<S: SequenceType
        where S.Generator.Element == Element>
        (seq: S) {
            var gen = seq.generate()
            while let (k: Key, v: Value) = gen.next() {
                self[k] = v
            }
    }
}

/// View that allows you to treate a tuple as a read-only collection
struct TupleCollectionView<T>: CollectionType {
    private let _mirror: MirrorType
    init(_ tuple: T) {
        _mirror = reflect(tuple)
    }
    
    var startIndex: Int { return 0 }
    
    var endIndex: Int {
        switch _mirror.disposition {
        case .Tuple:
            return _mirror.count
        default:
            return 1
        }
    }
    
    subscript(idx: Int) -> Any {
        switch _mirror.disposition {
        case .Tuple:
            let (_, val) = _mirror[idx]
            return val.value
        default:
            return _mirror.value
        }
    }
    
    typealias GeneratorType
        = IndexingGenerator<TupleCollectionView>
    
    func generate() -> GeneratorType {
        return IndexingGenerator(self)
    }
}

/// View that presents a collection of a subrange of another collection
struct SubrangeCollectionView<Base: CollectionType>: CollectionType {
    private let _base: Base
    private let _range: Range<Base.Index>
    init(_ base: Base, subrange: Range<Base.Index>) {
        _base = base
        _range = subrange
    }
    
    var startIndex: Base.Index {
        return _range.startIndex
    }
    var endIndex: Base.Index {
        return _range.endIndex
    }
    
    subscript(idx: Base.Index)
        -> Base.Generator.Element {
            return _base[idx]
    }
    
    typealias Generator
        = IndexingGenerator<SubrangeCollectionView>
    func generate() -> Generator {
        return IndexingGenerator(self)
    }
}
