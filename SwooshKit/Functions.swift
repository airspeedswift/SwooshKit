
// Some of these (like isVowel) are of limited benefit other than
// for quick one-line tests of higher-order functions, but then again
// I do a lot of that.

/// Free a member function to make it a stand-alone version for pipelining
public func freeMemberFunc<O, T>(member: O->()->T) -> O->T {
    return { (o: O) ->T in member(o)() }
}

public func toInt(s: String) -> Int? {
    return s.toInt()
}

public func toString(c: Character) -> String {
  return String(c)
}

let digits: [Character] = ["0","1","2","3","4","5","6","7","8","9"]

public func toInt(c: Character) -> Int? {
    // this may not be the most efficient method but
    // it's the most entertaining one
    return find(digits, c)
}

public func isMultipleOf<T: IntegerType>(of: T)->T->Bool {
    return { $0 % of == 0 }
}

public func successor<I: _Incrementable>(i: I) -> I {
    return i.successor()
}

public func double<I: IntegerType>(i: I) -> I {
    return i * 2
}

public func sum<S: SequenceType where S.Generator.Element: IntegerType>(nums: S) -> S.Generator.Element {
    return reduce(nums, 0) { $0.0 + $0.1 }
}

// thoroughly non-internationalized
public let isVowel = { contains("eaoiu", $0) }
public let isConsonant = { !contains("eaoiu", $0) }
