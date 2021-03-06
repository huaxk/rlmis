using Bukdu
import Bukdu.Actions: index, show, new, edit, create, delete, update
using Octo.Adapters.PostgreSQL
using JSON2
using LibGEOS
using GeoJSON
using HTTP.Messages: setheader

include("exts/GeoJSONEx.jl")
include("exts/OctoEx.jl")
include("models.jl")

# ==================================
struct WelcomeController <: ApplicationController
    conn::Conn
end

function index(c::WelcomeController)
    render(JSON, "你好中国!")
end

routes() do
    get("/", WelcomeController, index)
end

# ==================================
struct UserController <: ApplicationController
    conn::Conn
end

function index(c::UserController)
    us = Repo.query(users)
    render(JSON, us)
end

function show(c::UserController)
    id = c.params.id
    user = Repo.get(User, id)
    render(JSON, user)
end

function create(c::UserController)
    user = c.params.json
    Repo.insert!(User, (email=user.email, name=user.name))
    render(JSON, user)
end

# ==================================
struct RoleController <: ApplicationController
    conn::Conn
end

function index(c::RoleController)
    rs = Repo.query(roles)
    render(JSON, rs)
end

function show(c::RoleController)
    id = c.params.id
    role = Repo.get(Role, id)
    render(JSON, role)
end

function create(c::RoleController)
    role = c.params.json
    Repo.insert!(Role, (name=role.name,))
    render(JSON, role)
end

# ==================================
struct HereController <: ApplicationController
    conn::Conn
end

function index(c::HereController)
    q = [SELECT (heres.id, heres.name, as(ST_AsGeoJSON(heres.lnglat), :lnglat)) FROM heres]
    hs = Repo.query(q)
    # q = [SELECT (heres.id, heres.name, heres.lnglat) FROM heres]
    # hs = Repo.query(q)
    render(JSON, hs)
    # render(JSON, to_features(hs, :lnglat))
    # render(JSON, to_featurecollection(hs, :lnglat))
end

function show(c::HereController)
    id = c.params.id
    q = [SELECT (heres.id, heres.name, heres.lnglat) FROM heres WHERE heres.id==id]
    h = Repo.query(q)
    # render(JSON, to_feature(h[1], :lnglat))
    render(JSON, h[1])
end

"""
{
    "name": "testone",
    "lnglat": {"coordinates":[66,45.32],"type":"Point"}
}
"""
function create(c::HereController)
    json = c.params.json
    p = tuple2geo(json.lnglat)
    setSRID(p, 4326)
    Repo.insert!(Here, [(name="testtwo", lnglat=p)])
    # name = json.name
    # lnglat = JSON2.write(json.lnglat)
    # Repo.execute(Raw("""
    #     insert into heres (name, lnglat)
    #     values(
    #         '$name',
    #         ST_SetSRID(ST_GeomFromGeoJSON('$lnglat'), 4326)
    #     )
    #     """))
end

# ==================================
struct ProvinceController <: ApplicationController
    conn::Conn
end

function index(c::ProvinceController)
    # q = [SELECT (provinces.id, provinces.name1, provinces.geom) FROM provinces]
    q = [SELECT (provinces.id, provinces.name1, as(ST_AsGeoJSON(provinces.geom), :geom)) FROM provinces]
    rs = Repo.query(q)
    render(JSON, rs)
end

# ==================================
struct CityController <: ApplicationController
    conn::Conn
end

function index(c::CityController)
    # q = [SELECT (cities.id, cities.name1, cities.geom) FROM cities]
    q = [SELECT (cities.id, cities.name1, as(ST_AsGeoJSON(cities.geom), :geom)) FROM cities]
    rs = Repo.query(q)
    fs = GeoJSONEx.to_featurecollection(rs, :geom)
    render(JSON, fs)
end

# ==================================
struct CountryController <: ApplicationController
    conn::Conn
end

function index(c::CountryController)
    # q = [SELECT (countries.id, countries.name1, countries.geom) FROM countries]
    q = [SELECT (countries.id, countries.name1, as(ST_AsGeoJSON(countries.geom), :geom)) FROM countries]
    rs = Repo.query(q)
    render(JSON, rs)
end

# ==================================
pipeline(:api) do conn::Conn
    setheader(conn.request.response, "Access-Control-Allow-Origin" => "*")
end

routes(:api) do
    resources("/users", UserController)
    resources("/roles", RoleController)
    resources("/heres", HereController)
    resources("/provs", ProvinceController)
    resources("/cities", CityController)
    resources("/couns", CountryController)
    plug(Plug.Parsers, :json => Plug.ContentParsers.JSONDecoder, parsers=[:json])
end
