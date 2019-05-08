module LibGEOSEx
using LibGEOS
using LibGEOS: GEOSContext, _context, GEOSGeom,
               WKBReader, WKBWriter, geomFromGEOS,
               GEOSWKBReader_readHEX_r, GEOSWKBWriter_writeHEX_r,
               GEOSWKBWriter_write_r
using GeoInterface: AbstractGeometry

export readwkb, readwkb_hex, writewkb, writewkb_hex

function _readwkb_hex(wkbstring::String, wkbreader::WKBReader, context::GEOSContext=_context)
    result = GEOSWKBReader_readHEX_r(context.ptr, wkbreader.ptr, pointer(wkbstring), length(wkbstring))
    if result == C_NULL
        error("LibGEOS: Error in GEOSWKBReader_readHEX_r")
    end
    result
end

# _readwkb_hex(wkbstring::String, context::GEOSContext=_context) =
#     _readwkb_hex(wkbstring, WKBReader(context), context)

readwkb_hex(wkbstring::String, wkbreader::WKBReader, context::GEOSContext=_context) =
    geomFromGEOS(_readwkb_hex(wkbstring, wkbreader, context))
readwkb_hex(wkbstring::String, context::GEOSContext=_context) =
    readwkb_hex(wkbstring, WKBReader(context), context)

readwkb(wkbstring::String, context::GEOSContext=_context; hex=false) =
    hex ? readwkb_hex(wkbstring, context) :
          readgeom(Vector{UInt8}(wkbstring), context)

function LibGEOS._writegeom(geom::GEOSGeom, wkbwriter::WKBWriter, context::GEOSContext = _context)
     wkbsize = Ref{Csize_t}()
     p_wkbsize = Ptr{Csize_t}(pointer_from_objref(wkbsize))
     result = GEOSWKBWriter_write_r(context.ptr, wkbwriter.ptr, geom, p_wkbsize )
     unsafe_wrap(Array, result, wkbsize[], own=true)
end

function _writewkb_hex(geom::GEOSGeom, wkbwriter::WKBWriter, context::GEOSContext=_context)
    wkbsize = Ref{Csize_t}()
    p_wkbsize = Ptr{Csize_t}(pointer_from_objref(wkbsize))
    result = GEOSWKBWriter_writeHEX_r(context.ptr, wkbwriter.ptr, geom, p_wkbsize)
    unsafe_wrap(Array, result, wkbsize[], own=true)
end

# _writewkb_hex(geom::GEOSGeom, context::GEOSContext=_context) =
#     _writewkb_hex(geom, WKBWriter(context), context)

for geom in (:Point, :MultiPoint, :LineString, :MultiLineString, :LinearRing, :Polygon, :MultiPolygon, :GeometryCollection)
    @eval writewkb(obj::$geom, wkbwriter::WKBWriter, context::GEOSContext=_context; hex=false) =
        hex ? _writewkb_hex(obj.ptr, wkbwriter, context) : writegeom(obj, wkbwriter, context)
    # @eval writewkb_hex(obj::$geom, context::GEOSContext=_context) = _writewkb_hex(obj.ptr, WKBWriter(context), context)
    @eval writewkb(obj::$geom, context::GEOSContext=_context; hex=false) = writewkb(obj, WKBWriter(context), context; hex=hex)
end

end  # module LibGEOSEx
