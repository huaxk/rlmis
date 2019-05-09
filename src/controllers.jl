using Bukdu
import Bukdu.Actions: index, show, new, edit, create, delete, update
using Octo.Adapters.PostgreSQL
using JSON2
using LibGEOS
using LibGEOS: WKBWriter
using GeoJSON

include("LibGEOSEx.jl")
using .LibGEOSEx
include("GeoJSON.jl")
include("OctoEx.jl")
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

# ==================================s
# geometrytransforms = Dict(3=>g->JSON2.read(g, GeoJSON.GeometryTuple))

struct HereController <: ApplicationController
    conn::Conn
end

function index(c::HereController)
    # q = [SELECT (heres.id, heres.name, as(ST_AsGeoJSON(heres.lnglat), :lnglat)) FROM heres]
    # hs = Repo.query(q, geometrytransforms)
    q = [SELECT (heres.id, heres.name, heres.lnglat) FROM heres]
    hs = Repo.query(q)
    render(JSON, hs)
    # render(JSON, to_features(hs, :lnglat))
    # render(JSON, to_featurecollection(hs, :lnglat))
end

function show(c::HereController)
    id = c.params.id
    # q = [SELECT (heres.id, heres.name, as(ST_AsGeoJSON(heres.lnglat), :lnglat)) FROM heres WHERE heres.id==id]
    q = [SELECT (heres.id, heres.name, heres.lnglat) FROM heres WHERE heres.id==id]
    h = Repo.query(q)
    # render(JSON, to_feature(h[1], :lnglat))
    render(JSON, h[1])
    # render(JSON, Repo.query(q, geometrytransforms))
end

"""
{
    "name": "testone",
    "lnglat": {"coordinates":[66,45.32],"type":"Point"}
}
"""
function create(c::HereController)
    geojson = c.params.json
    @show geojson
    # Repo.execute([INSERT INTO heres VALUES (h.name, "SRID=4326;POINT(12 34)")])
    p = LibGEOS.Point(10, 20)
    # p1 = GeoJSON.parse(geojson)
    # @show p1
    # p = LibGEOS.Point(dict2geo(geojson))
    lnglat = writewkb(p, 4326, hex=true)
    Repo.insert!(Here, [(name="good", lnglat=lnglat)])
end

# ==================================
struct RoadController <: ApplicationController
    conn::Conn
end

function index(c::RoadController)
    q = [SELECT (roads.id, roads.name, as(ST_AsGeoJSON(roads.roadline), :roadline)) FROM roads]
    rs = Repo.query(q, geometrytransforms)
    render(JSON, rs)
end

# ==================================
pipeline(:api) do conn::Conn
end

routes(:api) do
    resources("/users", UserController)
    resources("/roles", RoleController)
    resources("/heres", HereController)
    resources("/roads", RoadController)
    plug(Plug.Parsers, :json => Plug.ContentParsers.JSONDecoder, parsers=[:json])
end
