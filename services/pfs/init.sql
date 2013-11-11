CREATE TYPE FTYPE AS ENUM ('-', 'd');

CREATE TABLE files (
  path    VARCHAR(1024) PRIMARY KEY,
  level   SMALLSERIAL NOT NULL,
  type    FTYPE NOT NULL,
  size    SERIAL NOT NULL,
  mode    SMALLSERIAL NOT NULL,
  atime   TIMESTAMP NOT NULL,
  mtime   TIMESTAMP NOT NULL,
  ctime   TIMESTAMP NOT NULL
);

CREATE TABLE chunks (
  path     VARCHAR(1024) REFERENCES files(path) ON DELETE CASCADE ON UPDATE CASCADE,
  data    BYTEA
);