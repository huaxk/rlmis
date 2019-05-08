using LibPQ: PQ_SYSTEM_TYPES, LIBPQ_TYPE_MAP, PQValue, Connection, execute, fetch!
using GeoInterface
using LibGEOS
using GeoJSON
using JSON2

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
        return readwkb(hexwkb)
    end"""
    Meta.parse(func) |> eval
end

JSON2.write(io::IO, obj::T; kwargs...) where {T <: AbstractGeometry} = begin
    JSON2.write(io, geo2dict(obj); kwargs...)
end

readwkb(hexwkb::AbstractString) = readgeom(hex2bytes(hexwkb), LibGEOS._context)

function writewkb(geo::AbstractGeometry)
    writegeom(geo, LibGEOS.WKBWriter(LibGEOS._context))
end

# function _writegeom(geom::GEOSGeom, wkbwriter::WKBWriter, context::GEOSContext = _context)
#     wkbsize = Ref{Csize_t}()
#     p_wkbsize = Ptr{Csize_t}(pointer_from_objref(wkbsize))
#     result = GEOSWKBWriter_write_r(context.ptr, wkbwriter.ptr, geom, p_wkbsize )
#     unsafe_wrap(Array, result, wkbsize[], own=true)
#  end
