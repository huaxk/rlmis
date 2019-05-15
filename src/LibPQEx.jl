module LibPQEx

using LibPQ
using Tables

export getTypeOid, registerType

function getTypeOid(conn::LibPQ.Connection, typname::String)
    result = LibPQ.execute(conn, "select oid from pg_type where typname='$typname'")
    data = Tables.columntable(result)
    LibPQ.close(result)
    oid = data.oid[1]
    Symbol(typname), oid
end

function registerType(typname::Symbol, oid::LibPQ.Oid, type::Type)
    LibPQ.PQ_SYSTEM_TYPES[typname] = oid
    LibPQ.LIBPQ_TYPE_MAP[typname] = type
    nothing
end

# function register_type(conn::Connection, typname::Symbol, type)
#     result = execute(conn, "select oid from pg_type where typname='$typname'")
#     data = fetch!(NamedTuple, result)
#     oid = data.oid[1]
#     PQ_SYSTEM_TYPES[typname] = oid
#     LIBPQ_TYPE_MAP[typname] = type
#     parse_func = """function Base.parse(::Type{$type}, pqv::PQValue{PQ_SYSTEM_TYPES[:$typname]})
#         hexwkb = LibPQ.string_view(pqv)
#         return readwkb(hexwkb, hex=true)
#     end"""
#     Meta.parse(parse_func) |> eval
#     # @eval function Base.parse(::Type{$type}, pqv::PQValue{PQ_SYSTEM_TYPES[:($typname)]})
#     #         hexwkb = LibPQ.string_view(pqv)
#     #         return readwkb(hexwkb)
#     #     end
# end

end  # module LibPQEx
