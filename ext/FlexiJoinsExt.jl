module FlexiJoinsExt

using FlexiJoins: FlexiJoins
using Uncertain

struct ByUncertainty{TL, TR, TFL, TFR, TT} <: FlexiJoins.JoinCondition
    f_L::TFL
    f_R::TFR
    unc_tform::TT
end

ByUncertainty{TL, TR}(f_L, f_R, unc_tform) where {TL, TR} =
    ByUncertainty{TL, TR, typeof(f_L), typeof(f_R), typeof(unc_tform)}(f_L, f_R, unc_tform)

Uncertain.by_uncertainty(f_L, f_R; tform=identity) =
    ByUncertainty{Any,Any}(f_L, f_R, tform isa Function ? U.UncertaintyTransformationF(tform) : tform)


function FlexiJoins.normalize_arg(cond::ByUncertainty{Any,Any}, datas)
    @assert length(datas) == 2
    TL = Base.promote_op(cond.f_L, eltype(first(datas)))
    TR = Base.promote_op(cond.f_R, eltype(last(datas)))
    return ByUncertainty{TL, TR}(cond.f_L, cond.f_R, cond.unc_tform)
end

FlexiJoins.swap_sides(cond::ByUncertainty{TL, TR}) where {TL, TR} =
    ByUncertainty{TR, TL}(cond.f_R, cond.f_L, cond.unc_tform)

FlexiJoins.supports_mode(::FlexiJoins.Mode.NestedLoop, ::ByUncertainty, datas) = true

FlexiJoins.is_match(by::ByUncertainty, a::Number, b::U.Value) = abs(a - U.value(b)) ≤ by.unc_tform(U.uncertainty(b))
FlexiJoins.is_match(by::ByUncertainty, a::U.Value, b::Number) = abs(U.value(a) - b) ≤ by.unc_tform(U.uncertainty(a))
FlexiJoins.is_match(by::ByUncertainty, a::Union{U.ValueNumber, U.ValueReal}, b::Union{U.ValueNumber, U.ValueReal}) = error("Cannot join by values with uncertainty on both sides")
    

end
