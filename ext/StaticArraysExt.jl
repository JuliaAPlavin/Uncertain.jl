module StaticArraysExt

using StaticArrays
using StaticArrays.LinearAlgebra: Symmetric, Diagonal, cholesky
using Uncertain

function Uncertain.CovMat(kwargs::NamedTuple{(:σ,)})
    (; σ) = kwargs
    Uncertain.CovMat(Diagonal(@SMatrix([σ^2])))
end

function Uncertain.CovMat(kwargs::NamedTuple{(:σx, :σy, :ρ)})
    (; σx, σy, ρ) = kwargs
    Uncertain.CovMat(Symmetric(@SMatrix([σx^2  σx*σy*ρ; σx*σy*ρ  σy^2])))
end

function Uncertain.boundary(x::StaticVector, xerr::Uncertain.CovMat; mul=1, npoints=100)
    L = cholesky(xerr.cov).L
    map(range(0, 2π; length=npoints + 1)[1:end-1]) do θ
        circ_p = SVector(sincos(θ))
        ell_p = mul * L * circ_p
        return x + ell_p
    end
end


# XXX: piracy, should be upstreamed
StaticArrays.pinv(A::Symmetric{<:Any, <:SMatrix{N,M}}; kwargs...) where {N,M} = Symmetric(StaticArrays.pinv(SMatrix{N,M}(A); kwargs...))
Base.zero(A::Symmetric{<:Any, <:SMatrix{N,M}}) where {N,M} = Symmetric(zero(A.data))

end
