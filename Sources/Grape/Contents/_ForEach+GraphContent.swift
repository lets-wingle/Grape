import SwiftUI

public struct GraphContentWrapper<InnerGraphContent>: GraphContent
where InnerGraphContent: GraphContent {
    public typealias NodeID = InnerGraphContent.NodeID

    @usableFromInline
    let storage: InnerGraphContent

    @inlinable
    init(_ content: InnerGraphContent) {
        self.storage = content
    }

    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        storage._attachToGraphRenderingContext(&context)
    }
}

extension GraphContentWrapper: View {
    public var body: some View {
        EmptyView()
    }

    @inlinable
    static func pullback<T>(_ content: @escaping (T) -> InnerGraphContent) -> (T) -> Self {
        return { element in
            return .init(content(element))
        }
    }

    @inlinable
    static func pullback<T, ID>(id: KeyPath<T, ID>, _ content: @escaping (ID) -> InnerGraphContent) -> (T) -> Self where ID: Hashable {
        return { element in
            return .init(content(element[keyPath: id]))
        }
    }
}

extension ForEach: GraphContent where Content: GraphContent {
    public typealias NodeID = Content.NodeID

    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        self.data.forEach { element in
            self.content(element)._attachToGraphRenderingContext(&context)
        }
    }
}

extension ForEach where ID == Data.Element.ID, Content: View, Data.Element: Identifiable {

    public init<NodeID, IG>(
        _ data: Data,
        @GraphContentBuilder<NodeID> graphContent: @escaping (Data.Element) -> IG
    )
    where
        IG: GraphContent<NodeID>,
        NodeID: Hashable,
        Content == GraphContentWrapper<IG>
    {
        let pb = GraphContentWrapper.pullback(graphContent)
        self.init(data, content: pb)
    }

}

extension ForEach where Content: View {

    public init<NodeID, IG>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @GraphContentBuilder<NodeID> graphContent: @escaping (ID) -> IG
    )
    where
        IG: GraphContent<NodeID>,
        NodeID: Hashable,
        Content == GraphContentWrapper<IG>,
        ID: Hashable
    {
        let pb = GraphContentWrapper.pullback(id: id, graphContent)
        self.init(data, id: id, content: pb)
    }

}
