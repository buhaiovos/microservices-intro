-- Hibernate @GeneratedValue (AUTO) uses sequence "songs_seq" with allocationSize 50
CREATE SEQUENCE songs_seq START WITH 1 INCREMENT BY 50;

CREATE TABLE songs (
    id          INTEGER      NOT NULL PRIMARY KEY,
    name        VARCHAR(255),
    artist      VARCHAR(255),
    album       VARCHAR(255),
    length      VARCHAR(255),
    resource_id INTEGER      NOT NULL UNIQUE,
    year        VARCHAR(255)
);
