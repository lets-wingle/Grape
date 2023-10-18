//
//  Simulation.swift
//
//
//  Created by li3zhen1 on 10/16/23.
//

import NDTree

enum SimulationError: Error {
    case subscriptionToNonexistentNode
}

/// An N-Dimensional force simulation.
public final class Simulation<NodeID, V> where NodeID: Hashable, V: VectorLike, V.Scalar == Double {

    /// The type of the vector used in the simulation.
    /// Usually this is `Double` if you are on Apple platforms.
    public typealias Scalar = V.Scalar


    public let initializedAlpha: Double

    public var alpha: Double
    public var alphaMin: Double
    public var alphaDecay: Double
    public var alphaTarget: Double
    public var velocityDecay: V.Scalar

    public internal(set) var forces: [any ForceLike] = []


    public internal(set) var nodePositions: [V]
    public internal(set) var nodeVelocities: [V]
    public internal(set) var nodeFixations: [V?]

    public private(set) var nodeIds: [NodeID]

    @usableFromInline internal private(set) var nodeIdToIndexLookup: [NodeID: Int] = [:]

    /// Create a new simulation.
    /// - Parameters:
    ///   - nodeIds: Hashable identifiers for the nodes. Force simulation calculate them by order once created.
    ///   - alpha: 
    ///   - alphaMin: 
    ///   - alphaDecay: The larger the value, the faster the simulation converges to the final result.
    ///   - alphaTarget: 
    ///   - velocityDecay: 
    ///   - getInitialPosition: The closure to set the initial position of the node. If not provided, the initial position is set to zero.
    public init(
        nodeIds: [NodeID],
        alpha: Double = 1,
        alphaMin: Double = 1e-3,
        alphaDecay: Double = 2e-3,
        alphaTarget: Double = 0.0,
        velocityDecay: Double = 0.6,

        setInitialStatus getInitialPosition: (
            (NodeID) -> V
        )? = nil

    ) {

        self.alpha = alpha
        self.initializedAlpha = alpha  // record and reload this when restarted

        self.alphaMin = alphaMin
        self.alphaDecay = alphaDecay
        self.alphaTarget = alphaTarget

        self.velocityDecay = velocityDecay

        if let getInitialPosition {
            self.nodePositions = nodeIds.map(getInitialPosition)
        } else {
            self.nodePositions = Array(repeating: .zero, count: nodeIds.count)
        }

        self.nodeVelocities = Array(repeating: .zero, count: nodeIds.count)
        self.nodeFixations = Array(repeating: nil, count: nodeIds.count)
        
        
        self.nodeIdToIndexLookup.reserveCapacity(nodeIds.count)
        for i in nodeIds.indices {
            self.nodeIdToIndexLookup[nodeIds[i]] = i
        }
        self.nodeIds = nodeIds

    }

    @inlinable internal func getIndex(of nodeId: NodeID) -> Int {
        return nodeIdToIndexLookup[nodeId]!
    }

    /// Run the simulation for a number of iterations.
    /// - Parameter iterationCount: Default to 1.
    public func tick(iterationCount: UInt = 1) {
        for _ in 0..<iterationCount {
            alpha += (alphaTarget - alpha) * alphaDecay

            for f in forces {
                f.apply(alpha: alpha)
            }

            for i in nodePositions.indices {
                if let fixation = nodeFixations[i] {
                    nodePositions[i] = fixation
                } else {
                    nodeVelocities[i] *= velocityDecay
                    nodePositions[i] += nodeVelocities[i]
                }
            }

        }
    }
}


#if canImport(simd)

public typealias Simulation2D<NodeID> = Simulation<NodeID, Vector2d> where NodeID: Hashable

public typealias Simulation3D<NodeID> = Simulation<NodeID, Vector3d> where NodeID: Hashable

#endif
