using Octo.Adapters.SQL

struct User
end

Schema.model(User, table_name="users", primary_key="id")
users = from(User, :users)

struct Role
end

Schema.model(Role, table_name="roles", primary_key="id")
roles = from(Role, :roles)

struct Here
end

Schema.model(Here, table_name="heres", primary_key="id")
heres = from(Here, :heres)

struct Road
end

Schema.model(Road, table_name="roads", primary_key="id")
roads = from(Road, :roads)
