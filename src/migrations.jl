include("db.jl")

Repo.execute(Raw("""
    CREATE TABLE provinces (
        id serial,
        name1 varchar(255),
        geom geometry(multipolygon),
        primary key(id)
    );
    CREATE TABLE cities (
        id serial,
        name1 varchar(255),
        name2 varchar(255),
        geom geometry(multipolygon),
        primary key(id)
    );
    CREATE TABLE countries (
        id serial,
        name1 varchar(255),
        name2 varchar(255),
        name3 varchar(255),
        geom geometry(multipolygon),
        primary key(id)
    )
"""))
