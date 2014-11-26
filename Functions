
/// Free a member function to make it a stand-alone version for pipelining 
func freeMemberFunc<O, T>(member: O->()->T) -> O->T {
    return { (o: O) ->T in member(o)() }
}
