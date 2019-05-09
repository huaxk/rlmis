module LibGEOSEx
using LibGEOS
using LibGEOS: libgeos,
               GEOSContext, _context, GEOSGeom, GEOSGeometry,
               GEOSContextHandle_t, GEOSWKBWriter, _writegeom,
               WKBReader, WKBWriter, geomFromGEOS,
               GEOSSetSRID_r, GEOSWKBWriter_setIncludeSRID_r
using GeoInterface: AbstractGeometry

import LibGEOS: GEOSWKBReader_readHEX_r, GEOSWKBWriter_writeHEX_r,
                GEOSWKBWriter_write_r,
                setSRID

export readwkb, readwkb_hex, writewkb, writewkb_hex, getSRID, setSRID, setIncludeSRID

# overwrite LibGEOS method
function _readwkb_hex(wkbstring::String, wkbreader::WKBReader, context::GEOSContext=_context)
    result = GEOSWKBReader_readHEX_r(context.ptr, wkbreader.ptr, pointer(wkbstring), length(wkbstring))
    if result == C_NULL
        error("LibGEOS: Error in GEOSWKBReader_readHEX_r")
    end
    result
end

# _readwkb_hex(wkbstring::String, context::GEOSContext=_context) =
#     _readwkb_hex(wkbstring, WKBReader(context), context)

function GEOSWKBWriter_write_r(handle, writer, g, size)
    ccall((:GEOSWKBWriter_write_r, libgeos), Ptr{Cuchar}, (GEOSContextHandle_t, Ptr{GEOSWKBWriter}, Ptr{GEOSGeometry}, Ptr{Csize_t}), handle, writer, g, size)
end

function GEOSWKBWriter_writeHEX_r(handle, writer, g, size)
    ccall((:GEOSWKBWriter_writeHEX_r, libgeos), Ptr{Cuchar}, (GEOSContextHandle_t, Ptr{GEOSWKBWriter}, Ptr{GEOSGeometry}, Ptr{Csize_t}), handle, writer, g, size)
end

setSRID(ptr::GEOSGeom, SRID::Integer, context::GEOSContext = _context) =
    GEOSSetSRID_r(context.ptr, ptr, SRID)

# end of overwrite LibGEOS

# function _writegeom(geom::GEOSGeom, wkbwriter::WKBWriter, context::GEOSContext = _context)
#      wkbsize = Ref{Csize_t}()
#      # p_wkbsize = Ptr{Csize_t}(pointer_from_objref(wkbsize))
#      result = GEOSWKBWriter_write_r(context.ptr, wkbwriter.ptr, geom, wkbsize )
#      unsafe_wrap(Array, result, wkbsize[], own=true)
# end

readwkb_hex(wkbstring::String, wkbreader::WKBReader, context::GEOSContext=_context) =
    geomFromGEOS(_readwkb_hex(wkbstring, wkbreader, context))
readwkb_hex(wkbstring::String, context::GEOSContext=_context) =
    readwkb_hex(wkbstring, WKBReader(context), context)

readwkb(wkbstring::String, context::GEOSContext=_context; hex=false) =
    hex ? readwkb_hex(wkbstring, context) :
          readgeom(Vector{UInt8}(wkbstring), context)

function _writewkb_hex(geom::GEOSGeom, wkbwriter::WKBWriter, context::GEOSContext=_context)
    wkbsize = Ref{Csize_t}()
    # p_wkbsize = Ptr{Csize_t}(pointer_from_objref(wkbsize))
    result = GEOSWKBWriter_writeHEX_r(context.ptr, wkbwriter.ptr, geom, wkbsize)
    unsafe_wrap(Array, result, wkbsize[], own=true)
end

function setIncludeSRID(writer::WKBWriter, writeSRID::Bool, context::GEOSContext=_context)
    GEOSWKBWriter_setIncludeSRID_r(context.ptr, writer.ptr, UInt8(writeSRID))
end


# _writewkb_hex(geom::GEOSGeom, context::GEOSContext=_context) =
#     _writewkb_hex(geom, WKBWriter(context), context)

for geom in (:Point, :MultiPoint, :LineString, :MultiLineString, :LinearRing, :Polygon, :MultiPolygon, :GeometryCollection)
    @eval writewkb(obj::$geom, wkbwriter::WKBWriter, context::GEOSContext=_context; hex=false) =
         (hex ? _writewkb_hex(obj.ptr, wkbwriter, context) : writegeom(obj, wkbwriter, context)) |> String
    @eval writewkb(obj::$geom, context::GEOSContext=_context; hex=false) = writewkb(obj, WKBWriter(context), context; hex=hex) |> String
    @eval writewkb(obj::$geom, SRID::Integer, context::GEOSContext=_context; hex=false) = begin
        writer = WKBWriter(context)
        setIncludeSRID(writer, true)
        setSRID(obj, SRID)
        writewkb(obj, writer, context; hex=hex) |> String
    end
    @eval getSRID(obj::$geom, context::GEOSContext=_context) = LibGEOS.getSRID(obj.ptr, context)
    @eval setSRID(obj::$geom, SRID::Integer, context::GEOSContext=_context) = setSRID(obj.ptr, SRID, context)
end

end  # module LibGEOSEx
