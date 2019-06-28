using Octo.Adapters.SQL

struct User
end

Schema.model(User, table_name="users", primary_key="id")
users = from(User, :users)

struct Here
end

Schema.model(Here, table_name="heres", primary_key="id")
heres = from(Here, :heres)

struct Road
end

Schema.model(Road, table_name="roads", primary_key="id")
roads = from(Road, :roads)

struct Province
end

Schema.model(Province, table_name="provinces", primary_key="id")
provinces = from(Province, :provinces)

struct City
end

Schema.model(City, table_name="cities", primary_key="id")
cities = from(City, :cities)

struct Country
end

Schema.model(Country, table_name="countries", primary_key="id")
countries = from(Country, :countries)
