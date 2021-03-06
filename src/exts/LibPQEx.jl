module LibPQEx

export register

using LibPQ
using Tables
using GeoInterface

include("GDALEx.jl")

"""
    Base.get(tm::PQTypeMap, key, default)

From PQTypeMap get value by key, if key is not exist return default value.
"""
Base.get(tm::LibPQ.PQTypeMap, key, default) = get(tm.type_map, key, default)

"""
    getTypeOid(conn::LibPQ.Connection, typname::Symbol)
Query oid by typname from LibPQ connection.
"""
function getTypeOid(conn::LibPQ.Connection, typname::Symbol)
    result = LibPQ.execute(conn, "select oid from pg_type where typname='$typname'")
    data = Tables.columntable(result)
    LibPQ.close(result)
    isempty(data.oid) ? nothing : data.oid[1]
end

"""
    register(conn::LibPQ.Connection, typname::Symbol, type::Type, func_from::Function, func_to::Function)
Register database type, julia type and function to transform each other.
#Arguments
- `conn::LibPQ.Connection`: database connection.
- `typname::Symbol`: database type symbol.
- `type::Type`: julia type.
- `func_from::Function`: function transform type from database to julia, function argument must be the type of LibPQ.PQValue, the return value of the function must be the julia type previously registered.
- `func_to::Function`: function transform type from julia to database, function argument must be of the julia type previously registered, the return value of the function must be a string.

# Example
```julia
# function transform type from database to julia
funcfrom = (pqv::LibPQ.PQValue) -> readwkb(LibPQ.string_view(pqv), hex=true)
# transform type from julia to database
functo = (geo::AbstractGeometry) -> writewkb(geo, 4326, hex=true)
LibPQ.register(conn, :geometry, AbstractGeometry, funcfrom, functo)
```
"""
function register(conn::LibPQ.Connection, typname::Symbol, type::Type, func_from::Function, func_to::Function)
    oid = getTypeOid(conn, typname)
    oid == nothing && error("database is not support type: $typname")

    # registerType(typname, oid, type)
    _type = get(LibPQ.LIBPQ_TYPE_MAP, oid, nothing)
    if _type == nothing
        LibPQ.LIBPQ_TYPE_MAP[oid] = type
    elseif _type != type
        error("type: $type already register and type:$_type is not same type:$type.")
    else
        @info "type: $type already register."
    end

    LibPQ.LIBPQ_CONVERSIONS[(oid, type)] = func_from

    # @eval function Base.parse(::Type{$type}, pqv::PQValue{$oid})
    #     $func_from(pqv)
    # end

    @eval function Base.string(obj::$type)
        $func_to(obj)
    end

    nothing
end

function register(conn::LibPQ.Connection, mod::Symbol)
    if mod == :ArchGDAL
        register(conn, :geometry, GeoInterface.AbstractGeometry,
            (pqv::LibPQ.PQValue) -> GDALExt.fromEWKB(hex2bytes(LibPQ.string_view(pqv))),
            (geo::AbstractGeometry) -> bytes2hex(GDALExt.toEWKB(geo)))
    # elseif mod == :LibGEOS
    #     register(conn, :geometry, GeoInterface.GeoInterface.AbstractGeometry,
    #         (pqv::LibPQ.PQValue) -> readwkb(LibPQ.string_view(pqv), hex=true),
    #         (geo::AbstractGeometry) -> writewkb(geo, hex=true))
    end
end

end  # module LibPQEx
