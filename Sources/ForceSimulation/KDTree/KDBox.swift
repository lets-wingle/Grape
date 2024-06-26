//
//  KDBox.swift
//
//
//  Created by li3zhen1 on 10/14/23.
//
import simd

/// A box in N-dimensional space.
///
/// - Note: `p0` is the minimum point of the box, `p1` is the maximum point of the box.
public struct KDBox<V>: Equatable
where V: SIMD, V.Scalar: FloatingPoint & ExpressibleByFloatLiteral {
    /// the minimum anchor of the box
    public var p0: V

    /// the maximum anchor of the box
    public var p1: V

    /// Create a box with 2 anchors.
    ///
    /// - Parameters:
    ///   - p0: anchor
    ///   - p1: another anchor in the diagonal position of `p0`
    /// - Note: `p0` you pass does not have to be minimum point of the box.
    ///         `p1` does not have to be maximum point of the box. The initializer will
    ///         automatically adjust the order of `p0` and `p1` to make sure `p0` is the
    ///        minimum point of the box and `p1` is the maximum point of the box.
    @inlinable
    public init(p0: V, p1: V) {
        // #if DEBUG
        assert(p0 != p1, "NdBox was initialized with 2 same anchor")
        // #endif
        // var p0 = p0
        // var p1 = p1

        // for i in p0.indices {
        //     if p1[i] < p0[i] {
        //         swap(&p0[i], &p1[i])
        //     }
        // }
        // let mask = p0 .< p1
        // self.p0 = p1.replacing(with: p0, where: mask)
        // self.p1 = p0.replacing(with: p1, where: mask)
        self.p0 = pointwiseMin(p0, p1)
        self.p1 = pointwiseMax(p0, p1)
        // TODO: use Mask
    }

    /// Create a box with 2 anchors.
    ///
    /// - Parameters:
    ///   - pMin: minimum anchor of the box
    ///   - pMax: maximum anchor of the box
    /// - Note: Please make sure `pMin` is the minimum point of the box and `pMax` is the
    ///        maximum point of the box.
    @inlinable
    @available(*, deprecated, renamed: "init(uncheckedP0:uncheckedP1:)")
    internal init(pMin: V, pMax: V) {
        assert(pMin != pMax, "NdBox was initialized with 2 same anchor")
        self.p0 = pMin
        self.p1 = pMax
    }

    @inlinable
    internal init(uncheckedP0: V, uncheckedP1: V) {
        self.p0 = uncheckedP0
        self.p1 = uncheckedP1
    }

    /// Create a box with 2 zero anchors.
    @inlinable
    @available(*, deprecated, renamed: "zero")
    public init() {
        p0 = .zero
        p1 = .zero
    }

    /// Create a box with 2 anchors.
    /// - Parameters:
    ///   - p0: anchor
    ///   - p1: another anchor in the diagonal position of `p0`
    /// - Note: `p0` you pass does not have to be minimum point of the box.
    ///         `p1` does not have to be maximum point of the box. The initializer will
    ///         automatically adjust the order of `p0` and `p1` to make sure `p0` is the
    ///        minimum point of the box and `p1` is the maximum point of the box.
    @inlinable
    public init(_ p0: V, _ p1: V) {
        self.init(p0: p0, p1: p1)
    }

}

extension KDBox {
    @inlinable
    @inline(__always)
    var diagnalVector: V {
        return p1 - p0
    }

    @inlinable
    static var zero: Self {
        return Self(uncheckedP0: .zero, uncheckedP1: .zero)
    }

    @inlinable 
    @inline(__always)
    var center: V { (p1 + p0) / 2.0 }

    /// Test if the box contains a point.
    /// - Parameter point: N dimensional point
    /// - Returns: `true` if the box contains the point, `false` otherwise.
    ///            The boundary test is similar to ..< operator.
    @inlinable 
    @inline(__always)
    func contains(_ point: V) -> Bool {
        // let mask = 
        return !any((p0 .> point) .| (point .>= p1))
        //mask == .init(repeating: false)

        // equivalent to:
        // for i in point.indices {
        //     if p0[i] > point[i] || point[i] >= p1[i] {
        //         return false
        //     }
        // }
        // return true
    }
}

extension KDBox {

    @inlinable func getCorner(of direction: Int) -> V {
        var mask = SIMDMask<V.MaskStorage>()

        for i in 0..<V.scalarCount {
            mask[i] = ((direction >> i) & 0b1) == 1
        }
        return p0.replacing(with: p1, where: mask)

        // equivalent to:
        // var corner = V.zero
        // for i in 0..<V.scalarCount {
        //     corner[i] = ((direction >> i) & 0b1) == 1 ? p1[i] : p0[i]
        // }
        // return p0.replacing(with: p1, where: mask)  //corner
    }

    // @inlinable public var debugDescription: String {
    //     return "[\(p0), \(p1)]"
    // }
}

extension KDBox {

    /// Get the small box that contains a list points and guarantees the box's size is at least 1x..x1.
    ///
    /// - Parameter points: The points to be covered.
    /// - Returns: The box that contains all the points.
    @inlinable public static func cover(of points: [V]) -> Self {

        var _p0 = points[0]
        var _p1 = points[0]

        for p in points {
            // let mask1 = p .< _p0
            // let mask2 = p .>= _p1

            // _p0 = _p0.replacing(with: p, where: mask1)
            // _p1 = _p1.replacing(with: p + 1, where: mask2)

            _p0 = pointwiseMin(p, _p0)
            _p1 = pointwiseMax(p, _p1)

            // for i in p.indices {
            //     if p[i] < _p0[i] {
            //         _p0[i] = p[i]
            //     }
            //     if p[i] >= _p1[i] {
            //         _p1[i] = p[i] + 1
            //     }
            // }
        }

        #if DEBUG
            let _box = Self(_p0, _p1)
            assert(
                points.allSatisfy { p in
                    _box.contains(p)
                })
        #endif

        return Self(_p0, _p1)
    }

    @inlinable public static func cover(of points: UnsafeArray<V>) -> Self {

        var _p0 = points[0]
        var _p1 = points[0]

        for pi in 0..<points.header {
            let p = points[pi]

            _p0 = pointwiseMin(p, _p0)
            _p1 = pointwiseMax(p, _p1)

            // for i in points[pi].indices {
            //     if p[i] < _p0[i] {
            //         _p0[i] = p[i]
            //     }
            //     if p[i] > _p1[i] {
            //         _p1[i] = p[i] + 1
            //     }
            // }
        }

        #if DEBUG
            let testBox = Self(_p0, _p1 + 1)
            for i in points.range {
                assert(testBox.contains(points[i]))
            }
        #endif

        return Self(_p0, _p1 + 1)
    }

}
