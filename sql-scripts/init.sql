CREATE DATABASE stefandb;
CREATE USER stefanuser WITH ENCRYPTED PASSWORD 'stefanpassword';
GRANT ALL PRIVILEGES ON DATABASE stefandb TO stefanuser;
GRANT ALL ON SCHEMA public TO stefanuser;
GRANT USAGE ON SCHEMA public TO stefanuser;
ALTER DATABASE stefandb OWNER TO stefanuser;