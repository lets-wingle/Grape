//
//  VectorLike.swift
//
//
//  Created by li3zhen1 on 10/13/23.
//



/// A vector-like type that can be used in a `ForceSimulation`.
/// The members required by `VectorLike` are basically the same as `simd`'s `SIMD` protocol.
/// `NDTree` only rely on this protocol so that you can implement your structure on the platforms
/// that do not support `simd`.
public protocol VectorLike: CustomStringConvertible, Decodable, Encodable, ExpressibleByArrayLiteral, Hashable {
    
    /// The children count of a node in NDTree.
    /// Should be equal to the 2^(dimension of the vector). 
    /// For example, a 2D vector should have 4 children, a 3D vector should have 8 children.
    /// This property should be implemented even if you are using `simd`.
    static var directionCount: Int { get }
    
    
    associatedtype Scalar: FloatingPoint, Decodable, Encodable, Hashable, CustomDebugStringConvertible
    
    /// The length of the vector squared.
    /// This property should be implemented even if you are using `simd`.
    @inlinable func lengthSquared() -> Scalar

    /// The length of the vector.
    /// This property should be implemented even if you are using `simd`.
    @inlinable func length() -> Scalar

    /// The distance to another vector, squared.
    /// This property should be implemented even if you are using `simd`.
    @inlinable func distanceSquared(to: Self) -> Scalar

    /// The distance to another vector.
    /// This property should be implemented even if you are using `simd`.
    @inlinable func distance(to: Self) -> Scalar
    

    @inlinable static func * (a: Self, b: Double) -> Self
    @inlinable static func / (a: Self, b: Double) -> Self
    
    @inlinable static func * (a: Self, b: Scalar) -> Self
    @inlinable static func / (a: Self, b: Scalar) -> Self
    @inlinable static func - (a: Self, b: Self) -> Self
    @inlinable static func + (a: Self, b: Self) -> Self


    @inlinable static func + (a: Self, b: Scalar) -> Self
    
    @inlinable static func += (a: inout Self, b: Self)
    @inlinable static func -= (a: inout Self, b: Self)
    @inlinable static func *= (a: inout Self, b: Scalar)
    @inlinable static func /= (a: inout Self, b: Scalar)
    
    @inlinable static var scalarCount: Int { get }
    @inlinable static var zero: Self { get }

    init()

    subscript(index: Int) -> Self.Scalar { get set }
    
    var indices: Range<Int> { get }

    
    
    
//    mutating func replace<M>(with other: Self, where mask: M) where M:MaskLike, M.Storage.Scalar==Scalar.SIMDMaskScalar
//    public static func .< (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>
//
//    /// Returns a vector mask with the result of a pointwise less than or equal
//    /// comparison.
//    public static func .<= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>
//
//    /// The least element in the vector.
//    public func min() -> Scalar
//
//    /// The greatest element in the vector.
//    public func max() -> Scalar
//
//    /// Returns a vector mask with the result of a pointwise greater than or
//    /// equal comparison.
//    public static func .>= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>
//
//    /// Returns a vector mask with the result of a pointwise greater than
//    /// comparison.
//    public static func .> (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>
    

}
