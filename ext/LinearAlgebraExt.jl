module LinearAlgebraExt

using LinearAlgebra
using Uncertain

LinearAlgebra.dot(x::U.Value{<:AbstractVector}, y::AbstractVector) = propagate(dot, U.value(x), U.uncertainty(x), y, nothing)
LinearAlgebra.norm(x::U.Value{<:AbstractVector}) = propagate(norm, U.value(x), U.uncertainty(x))

propagate(::typeof(dot), x::AbstractVector, xunc::U.CovMat, y::AbstractVector, yunc::Nothing) =
    dot(x, y) ±ᵤ √dot(y, xunc.cov, y)

function propagate(::typeof(norm), x::AbstractVector, xunc::U.CovMat)
    n = norm(x)
    unc = √dot(x, xunc.cov, x) / n
    return n ±ᵤ unc
end

end
