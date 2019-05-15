module LibPQEx

using LibPQ
using LibPQ: PQValue
using Tables

export getTypeOid, registerType, getRegisterOid

function getTypeOid(conn::LibPQ.Connection, typname::Symbol)
    result = LibPQ.execute(conn, "select oid from pg_type where typname='$typname'")
    data = Tables.columntable(result)
    LibPQ.close(result)
    return data.oid[1]
end

getTypeOid(conn::LibPQ.Connection, typname::String) = getTypeOid(conn, Symbol(typname))

function registerType(typname::Symbol, oid::LibPQ.Oid, type::Type)
    LibPQ.PQ_SYSTEM_TYPES[typname] = oid
    LibPQ.LIBPQ_TYPE_MAP[typname] = type
    nothing
end

function getRegisterOid(typname::Symbol)
    LibPQ.PQ_SYSTEM_TYPES[typname]
end

function register(conn::LibPQ.Connection, typname::Symbol, type::Type, func::Function)
    oid = getTypeOid(conn, typname)
    registerType(typname, oid, type)
    # @eval function Base.parse(::Type{$type}, pqv::PQValue{:($oid)})
    #           func(pqv)
    #       end
    parse_func = """function Base.parse(::Type{$type}, pqv::PQValue{getRegisterOid(:$typname)})
        func(pqv)
    end"""
    Base.eval(Main, Meta.parse(parse_func))
end

end  # module LibPQEx
