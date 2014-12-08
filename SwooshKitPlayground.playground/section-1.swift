
import SwooshKit

func tupEq<T>(lhs: T, rhs: T) -> Bool {
    return equal(TupleCollectionView(lhs), TupleCollectionView(rhs))
}