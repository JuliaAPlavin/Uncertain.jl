"""    TwoSided{T}(lo::T, hi::T)

Asymmetric two-sided uncertainty: `lo` is the uncertainty in the lower direction, and `hi` in the upper direction.
Both `lo` and `hi` should be positive.

Uncertainty of `TwoSided(x, x)` should behave like just `x`. Only makes sense for numbers with a natural order.
"""
struct TwoSided{T}
    lo::T
    hi::T
end

Base.show(io::IO, u::TwoSided) = print(io, "TwoSided(", u.lo, ", ", u.hi, ")")

Base.float(::Type{TwoSided{T}}) where {T} = TwoSided{float(T)}

Base.:*(a::TwoSided, b) = @modify(p -> p * b, a[∗ₚ])
Base.:*(a, b::TwoSided) = @modify(p -> a * p, b[∗ₚ])

for f in [:rad2deg, :deg2rad]
    @eval Base.$f(a::TwoSided) = @modify($f, a[∗ₚ])
end

width(a::TwoSided) = a.lo + a.hi
maxdiff(a::TwoSided) = max(a.lo, a.hi)

Base.convert(::Type{T}, u::Number) where {T <: TwoSided} = T(u, u)
