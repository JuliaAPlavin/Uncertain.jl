module FlexiJoinsExt

using FlexiJoins: FlexiJoins
using Uncertain
using Uncertain.Accessors: ConstructionBase

struct ByUncertainty{TL, TR, TFL, TFR} <: FlexiJoins.JoinCondition
    f_L::TFL
    f_R::TFR
end

ByUncertainty{TL, TR}(f_L, f_R) where {TL, TR} = ByUncertainty{TL, TR, typeof(f_L), typeof(f_R)}(f_L, f_R)

ConstructionBase.constructorof(::Type{<:ByUncertainty{TL,TR}}) where {TL, TR} = ByUncertainty{TL,TR}

Uncertain.by_uncertainty(f_L, f_R) = ByUncertainty{Any,Any}(f_L, f_R)


function FlexiJoins.normalize_arg(cond::ByUncertainty{Any,Any}, datas)
    @assert length(datas) == 2
    TL = Base.promote_op(cond.f_L, eltype(first(datas)))
    TR = Base.promote_op(cond.f_R, eltype(last(datas)))
    return ByUncertainty{TL, TR}(cond.f_L, cond.f_R)
end

FlexiJoins.swap_sides(cond::ByUncertainty{TL, TR}) where {TL, TR} = ByUncertainty{TR, TL}(cond.f_R, cond.f_L)

FlexiJoins.supports_mode(::FlexiJoins.Mode.NestedLoop, ::ByUncertainty, datas) = true

FlexiJoins.is_match(by::ByUncertainty, a, b) = FlexiJoins.is_match(by, by.f_L(a), by.f_R(b))

FlexiJoins.is_match(by::ByUncertainty, a::Number, b::U.Value) = abs(a - U.value(b)) ≤ U.uncertainty(b)
FlexiJoins.is_match(by::ByUncertainty, a::U.Value, b::Number) = abs(U.value(a) - b) ≤ U.uncertainty(a)
FlexiJoins.is_match(by::ByUncertainty, a::Union{U.ValueNumber, U.ValueReal}, b::Union{U.ValueNumber, U.ValueReal}) = error("Cannot join by values with uncertainty on both sides")
    

end
