module LibPQEx

using LibPQ
using LibPQ: PQValue
using Tables

export getTypeOid, registerType, getRegisterOid, register

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

function register(conn::LibPQ.Connection, typname::Symbol, type::Type, func_from::Function, func_to::Function)
    oid = getTypeOid(conn, typname)
    registerType(typname, oid, type)
    @eval function Base.parse(::Type{$type}, pqv::PQValue{$oid})
              $func_from(pqv)
          end
    # fromfunc = """function Base.parse(::Type{$type}, pqv::PQValue{getRegisterOid(:$typname)})
    #     ($func_from)(pqv)
    # end"""
    # Base.eval(Main, Meta.parse(fromfunc))
    @eval function Base.string(obj::$type)
        $func_to(obj)
    end
    nothing
end

end  # module LibPQEx
