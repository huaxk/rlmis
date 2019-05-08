using LibPQ: PQ_SYSTEM_TYPES, LIBPQ_TYPE_MAP, PQValue
using GeoInterface
using LibGEOS
using GeoJSON
using JSON2

PQ_SYSTEM_TYPES[:geometry] = 16392
LIBPQ_TYPE_MAP[:geometry] = AbstractGeometry

function Base.parse(::Type{AbstractGeometry}, pqv::PQValue{PQ_SYSTEM_TYPES[:geometry]})
    hexwkb = LibPQ.string_view(pqv)
    return readwkb(hexwkb)
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
