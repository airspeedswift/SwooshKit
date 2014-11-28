
// It's arguable these don't belong here and should be part of some 
// other minimalist library such as  


infix operator |> {
    associativity left
}

func |><T,U>(t: T, f: (T)->U) -> U {
    return f(t)
}

infix operator • {
    associativity left
}

func • <T, U, V> (g: U -> V, f: T -> U) -> T -> V {
    return { x in g(f(x)) }
}
