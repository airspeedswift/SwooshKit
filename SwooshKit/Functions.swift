
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
    return find(digits, c)
}

public func isMultipleOf<T: IntegerType>(of: T)->T->Bool {
    return { $0 % of == 0 }
}

public func inc<I: IntegerType>(i: I) -> I {
    return i.successor()
}

public func double<I: IntegerType>(i: I) -> I {
    return i * 2
}


