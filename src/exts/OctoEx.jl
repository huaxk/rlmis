module OctoEx

using Octo: Field, Predicate, SQLFunction
using Octo.Adapters.PostgreSQL
using Octo.Queryable: Structured
using Octo.Backends
using LibPQ

Backends.backend(Octo.Adapters.PostgreSQL)
import Main.PostgreSQLLoader
import Octo.Queryable.as
import Octo.Repo

function build_alias(field::Union{Field, Predicate, SQLFunction})
    clause = string(field.clause.__octo_model) |> lowercase
    name = field.name
    Symbol("$(clause)_$(name)")
end

as(field::Union{Field, Predicate, SQLFunction}) = as(field, build_alias(field))

PostgreSQLLoader.query(sql::String, transforms::Dict) = begin
    conn = PostgreSQLLoader.current_conn()
    sink = PostgreSQLLoader.current_sink()
    stmt = LibPQ.prepare(conn, sql)
    result = LibPQ.execute(stmt)
    df = LibPQ.fetch!(sink, result, transforms=transforms)
    LibPQ.close(result)
    df
end

PostgreSQLLoader.query(prepared::String, vals::Vector, transforms::Dict) = begin
    conn = PostgreSQLLoader.current_conn()
    sink = PostgreSQLLoader.current_sink()
    stmt = LibPQ.prepare(conn, prepared)
    result = LibPQ.execute(stmt, vals)
    df = LibPQ.fetch!(sink, result,  transforms=transforms)
    LibPQ.close(result)
    df
end

Repo.query(stmt::Structured, transforms::Dict) = begin
    a = Repo.current_adapter()
    sql = a.to_sql(stmt)
    Repo.print_debug_sql(stmt)
    loader = Repo.current_loader()
    loader.query(sql, transforms)
end

end  # module OtcoEx

@sql_functions(ST_AsText,
               ST_AsGeoJSON,
               ST_GeomFromEWKT,
               ST_GeomFromGeoJSON)
