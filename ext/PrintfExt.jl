module PrintfExt

using Printf
using Uncertain

const VAL_UNC_SEPARATOR = " ± "

Printf.plength(f::Printf.Spec{<:Printf.Ints}, x::U.Value) = ncodeunits(VAL_UNC_SEPARATOR) + Printf.plength(f, U.value(x)) + Printf.plength(f, U.uncertainty(x))

function Printf.fmt(buf, pos, arg::U.Value, spec::Printf.Spec{<:Printf.Ints})
    pos = Printf.fmt(buf, pos, U.value(arg), spec)
    buf[pos:pos+ncodeunits(VAL_UNC_SEPARATOR)-1] .= codeunits(VAL_UNC_SEPARATOR)
    pos += ncodeunits(VAL_UNC_SEPARATOR)
    pos = Printf.fmt(buf, pos, U.uncertainty(arg), spec)
    return pos
end

function Printf.fmt(buf, pos, arg::U.Value, spec::Printf.Spec{<:Printf.Floats})
    pos = Printf.fmt(buf, pos, U.value(arg), spec)
    buf[pos:pos+ncodeunits(VAL_UNC_SEPARATOR)-1] .= codeunits(VAL_UNC_SEPARATOR)
    pos += ncodeunits(VAL_UNC_SEPARATOR)
    pos = Printf.fmt(buf, pos, U.uncertainty(arg), spec)
    return pos
end

end
