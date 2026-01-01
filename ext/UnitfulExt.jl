module UnitfulExt

using Unitful
using Uncertain

Unitful.unit(x::U.Value) = unit(U.value(x))
Unitful.ustrip(x::U.Value) = ustrip(unit(x), x)
Unitful.ustrip(u::Unitful.Units, x::U.Value) = U.Value(ustrip(u, U.value(x)), ustrip(u, U.uncertainty(x)))
Unitful.uconvert(u::Unitful.FreeUnits, x::U.Value) = U.Value(Unitful.uconvert(u, U.value(x)), Unitful.uconvert(u, U.uncertainty(x)))

Base.promote_rule(::Type{Quantity{S,D,U_}}, ::Type{<:U.ValueNumber{T,TE}}) where {S, D, U_, T, TE} =
    return U.ValueNumber{promote_type(Quantity{S,D,U_}, T), promote_type(Quantity{S,D,U_}, TE)}
Base.promote_rule(::Type{Quantity{S,D,U_}}, ::Type{<:U.ValueReal{T,TE}}) where {S, D, U_, T, TE} =
    return U.ValueReal{promote_type(Quantity{S,D,U_}, T), promote_type(Quantity{S,D,U_}, TE)}

function Base.:*(x::Union{U.ValueNumber,U.ValueReal}, y::Unitful.Units, z::Unitful.Units...)
    u = *(y, z...)
    U.Value(U.value(x) * u, U.uncertainty(x) * u)
end

for f in [:*, :/]
    @eval Base.$f(x::Union{U.ValueNumber,U.ValueReal}, y::Unitful.Quantity) = U.Value($f(U.value(x), y), $f(U.uncertainty(x), y))
    @eval Base.$f(x::Union{U.ValueNumber,U.ValueReal}, y::Unitful.FreeUnits) = U.Value($f(U.value(x), y), $f(U.uncertainty(x), y))
    @eval Base.$f(y::Unitful.Quantity, x::Union{U.ValueNumber,U.ValueReal}) = U.Value($f(y, U.value(x)), $f(y, U.uncertainty(x)))
end

end
