protocol GraphQLQuery {
    associatedtype Q: Encodable
    associatedtype V: Encodable

    var query: GraphQLRequestContainer<Q, V> { get }
}

struct GraphQLRequestContainer<Q: Encodable, V: Encodable>: Encodable {
    let query: Q
    let variables: V
}
