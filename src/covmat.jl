struct CovMat{TM <: AbstractMatrix}
    cov::TM
end

CovMat(; kwargs...) = CovMat(values(kwargs))

Base.zero(x::CovMat) = CovMat(zero(x.cov))

Base.:*(mul::Number, e::CovMat) = CovMat(mul^2 * e.cov)
Base.:*(e::CovMat, mul::Number) = CovMat(e.cov * mul^2)
Base.:/(e::CovMat, mul::Number) = CovMat(e.cov / mul^2)
Base.isapprox(x::CovMat, y::CovMat; kwargs...) = isapprox(x.cov, y.cov; kwargs...)

propagate(::typeof(+), a::AbstractVector, aunc::CovMat, b::AbstractVector, bunc::CovMat) = Value(a + b, CovMat(aunc.cov + bunc.cov))
propagate(::typeof(-), a::AbstractVector, aunc::CovMat, b::AbstractVector, bunc::CovMat) = Value(a - b, CovMat(aunc.cov + bunc.cov))
