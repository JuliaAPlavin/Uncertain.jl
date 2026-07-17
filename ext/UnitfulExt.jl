module UnitfulExt

using Unitful
using Uncertain

Uncertain._ustrip(x::U.Value{<:Union{Quantity, AbstractArray{<:Quantity}}}) = ustrip(x)
Unitful.unit(x::U.Value) = unit(U.value(x))
Unitful.ustrip(x::U.Value) = ustrip(unit(x), x)
Unitful.ustrip(u::Unitful.Units, x::U.Value) = U.Value(ustrip(u, U.value(x)), ustrip(u, U.uncertainty(x)))
Unitful.uconvert(u::Unitful.FreeUnits, x::U.Value) = U.Value(Unitful.uconvert(u, U.value(x)), Unitful.uconvert(u, U.uncertainty(x)))

Base.promote_rule(::Type{Quantity{S,D,U_}}, ::Type{<:U.ValueNumber{T,TE}}) where {S, D, U_, T, TE} =
    return U.ValueNumber{promote_type(Quantity{S,D,U_}, T), promote_type(Quantity{S,D,U_}, TE)}
Base.promote_rule(::Type{Quantity{S,D,U_}}, ::Type{<:U.ValueReal{T,TE}}) where {S, D, U_, T, TE} =
    return U.ValueReal{promote_type(Quantity{S,D,U_}, T), promote_type(Quantity{S,D,U_}, TE)}

function Base.:*(x::U.Value, y::Unitful.Units, z::Unitful.Units...)
    u = *(y, z...)
    U.Value(U.value(x) * u, U.uncertainty(x) * u)
end

for f in [:*, :/]
    # `x/y` and `x*y` (uncertain ÷/× exact) both scale the uncertainty by `abs(y)`, so
    # reusing `$f` on the uncertainty component is correct here.
    @eval Base.$f(x::U.Value, y::Unitful.Quantity) = U.Value($f(U.value(x), y), $f(U.uncertainty(x), abs(y)))
    @eval Base.$f(x::U.Value, y::Unitful.FreeUnits) = U.Value($f(U.value(x), y), $f(U.uncertainty(x), y))
end

# `y * x` (exact × uncertain) scales the uncertainty by `abs(y)`.
Base.:*(y::Unitful.Quantity, x::U.Value) = U.Value(y * U.value(x), abs(y) * U.uncertainty(x))
# `y / x` (exact ÷ uncertain): the uncertainty follows the reciprocal rule
# `|y| * σ / value(x)^2` (= `|f'(value(x))| * σ` for `f(x) = y/x`). Route through `inv`,
# which applies exactly this propagation (maths.jl) and handles σ = 0 without producing NaN.
Base.:/(y::Unitful.Quantity, x::U.Value) = y * inv(x)


Unitful.ustrip(u::Unitful.Units, e::U.CovMat) = U.CovMat(ustrip.(u^2, e.cov))
Unitful.uconvert(u, e::U.CovMat) = U.CovMat(uconvert.(u^2, e.cov))

Base.:*(mul::Unitful.FreeUnits, e::U.CovMat) = U.CovMat(mul^2 * e.cov)
Base.:*(e::U.CovMat, mul::Unitful.FreeUnits) = U.CovMat(e.cov * mul^2)
Base.:/(e::U.CovMat, mul::Unitful.FreeUnits) = U.CovMat(e.cov / mul^2)


# XXX: piracy, should be upstreamed
Unitful.unit(x::AbstractVector) = unit(eltype(x))
Unitful.uconvert(u::Unitful.Units, x::AbstractVector) = uconvert.(u, x)

end
