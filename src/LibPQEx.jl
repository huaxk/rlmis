using LibPQ: PQ_SYSTEM_TYPES, LIBPQ_TYPE_MAP, PQValue, Connection, execute, fetch!
using GeoInterface
using GeoJSON
using JSON2

include("LibGEOSEx.jl")
using .LibGEOSEx

# result = execute(conn, "select oid from pg_type where typname='geometry'")
# data = fetch!(NamedTuple, result)
# oid = data.oid[1]
# PQ_SYSTEM_TYPES[:geometry] = oid #16392
# LIBPQ_TYPE_MAP[:geometry] = AbstractGeometry
#
# function Base.parse(::Type{AbstractGeometry}, pqv::PQValue{PQ_SYSTEM_TYPES[:geometry]})
#     hexwkb = LibPQ.string_view(pqv)
#     return readwkb(hexwkb)
# end

function register_type(conn::Connection, typname::Symbol, type)
    result = execute(conn, "select oid from pg_type where typname='$typname'")
    data = fetch!(NamedTuple, result)
    oid = data.oid[1]
    PQ_SYSTEM_TYPES[typname] = oid
    LIBPQ_TYPE_MAP[typname] = type
    func = """function Base.parse(::Type{$type}, pqv::PQValue{PQ_SYSTEM_TYPES[:$typname]})
        hexwkb = LibPQ.string_view(pqv)
        return readwkb(hexwkb, hex=true)
    end"""
    Meta.parse(func) |> eval
    # @eval function Base.parse(::Type{$type}, pqv::PQValue{PQ_SYSTEM_TYPES[:($typname)]})
    #         hexwkb = LibPQ.string_view(pqv)
    #         return readwkb(hexwkb)
    #     end
end

JSON2.write(io::IO, obj::T; kwargs...) where {T <: AbstractGeometry} = begin
    JSON2.write(io, geo2dict(obj); kwargs...)
end
