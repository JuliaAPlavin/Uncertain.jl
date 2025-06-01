function weightedmean(xs)
    isempty(xs) && return convert(eltype(xs), Value(NaN, Inf)*oneunit(eltype(xs)))
    # XXX: using .+ instead of map() fails inference
    agg = mapreduce((a, b) -> map(+, a, b), xs) do x::Value
        w = uncertainty(x)^(-2)
        value(x) * w, w
    end
    return U.Value(agg[1] * inv(agg[2]), sqrt(inv(agg[2])))
end
