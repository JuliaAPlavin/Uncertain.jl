"""    TwoSided{T}(lo::T, hi::T)

Asymmetric two-sided uncertainty: `lo` is the uncertainty in the lower direction, and `hi` in the upper direction.
Both `lo` and `hi` should be positive.

Uncertainty of `TwoSided(x, x)` should behave like just `x`. Only makes sense for numbers with a natural order.
"""
struct TwoSided{T}
    lo::T
    hi::T

    function TwoSided(lo, hi)
        lohi_p = promote(lo, hi)
        return TwoSided{typeof(first(lohi_p))}(lohi_p...)
    end

    TwoSided{T}(lo, hi) where {T} = TwoSided{T}(convert(T, lo), convert(T, hi))

    function TwoSided{T}(lo::T, hi::T) where {T}
        if lo < zero(lo) || hi < zero(hi)
            throw(ArgumentError("lo and hi should be positive, got $lo and $hi"))
        end
        return new{T}(lo, hi)
    end
end

Base.show(io::IO, u::TwoSided) = print(io, "TwoSided(", u.lo, ", ", u.hi, ")")

Base.float(::Type{TwoSided{T}}) where {T} = TwoSided{float(T)}

Base.:*(a::TwoSided, b) = @modify(p -> p * b, a[∗ₚ])
Base.:*(a, b::TwoSided) = @modify(p -> a * p, b[∗ₚ])
Base.:/(a::TwoSided, b) = @modify(p -> p / b, a[∗ₚ])
Base.:/(a, b::TwoSided) = @modify(p -> a / p, b[∗ₚ])

for f in [:rad2deg, :deg2rad]
    @eval Base.$f(a::TwoSided) = @modify($f, a[∗ₚ])
end

width(a::TwoSided) = a.lo + a.hi
maxdiff(a::TwoSided) = max(a.lo, a.hi)

Base.convert(::Type{T}, u::Number) where {T <: TwoSided} = T(u, u)


_u_lo(u::Number) = u
_u_lo(u::TwoSided) = u.lo
_u_hi(u::Number) = u
_u_hi(u::TwoSided) = u.hi
_u_lohi(u, sign::Int) =
    sign == +1 ? _u_hi(u) :
    sign == -1 ? _u_lo(u) :
    throw(ArgumentError("sign should be +1 or -1, got $sign"))
