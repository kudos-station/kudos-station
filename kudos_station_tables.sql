CREATE TABLE "user"
(
    user_id    SERIAL,
    first_name VARCHAR(50)  NOT NULL,
    last_name  VARCHAR(50)  NOT NULL,
    username   VARCHAR(50)  NOT NULL UNIQUE,
    password   VARCHAR(100) NOT NULL,
    enabled    BOOLEAN      NOT NULL,
    PRIMARY KEY (user_id)
);

CREATE TABLE authority
(
    username  VARCHAR(50) NOT NULL
        CONSTRAINT fk_authorities_users
            REFERENCES "user" (username),
    authority VARCHAR(50) NOT NULL
);

CREATE UNIQUE INDEX ix_auth_username
    ON authority (username, authority);

CREATE TABLE department
(
    department_id   SERIAL,
    department_name VARCHAR(50) NOT NULL UNIQUE,
    manager_id      INTEGER,
    PRIMARY KEY (department_id),
    FOREIGN KEY (manager_id) REFERENCES "user" (user_id)
);

CREATE TABLE kudos
(
    kudos_id           SERIAL,
    created_at         TIMESTAMP   NOT NULL,
    recipient_username VARCHAR(50) NOT NULL,
    sender_username    VARCHAR(50) NOT NULL,
    PRIMARY KEY (kudos_id),
    FOREIGN KEY (recipient_username) REFERENCES "user" (username),
    FOREIGN KEY (sender_username) REFERENCES "user" (username)
);

CREATE TABLE project
(
    project_id    SERIAL,
    project_name  VARCHAR(50) NOT NULL UNIQUE,
    department_id INTEGER,
    PRIMARY KEY (project_id, department_id),
    FOREIGN KEY (department_id) REFERENCES department (department_id)
);

CREATE TABLE works_on
(
    user_id       INTEGER,
    department_id INTEGER,
    project_id    INTEGER,
    work_hours    INTEGER NOT NULL,
    PRIMARY KEY (user_id, project_id),
    FOREIGN KEY (user_id) REFERENCES "user" (user_id),
    FOREIGN KEY (project_id, department_id) REFERENCES project (project_id, department_id)
);

CREATE TABLE works_in
(
    user_id       INTEGER,
    department_id INTEGER,
    PRIMARY KEY (user_id, department_id),
    FOREIGN KEY (user_id) REFERENCES "user" (user_id),
    FOREIGN KEY (department_id) REFERENCES department (department_id)
);

CREATE TABLE kudos_variation
(
    kudos_variation_id SERIAL,
    kudos_variation_name VARCHAR(50),
    PRIMARY KEY (kudos_variation_id)
);

CREATE TABLE has_variation
(
    kudos_id   INTEGER,
    kudos_variation_id INTEGER NOT NULL,
    PRIMARY KEY (kudos_id),
    FOREIGN KEY (kudos_id) REFERENCES kudos (kudos_id),
    FOREIGN KEY (kudos_variation_id) REFERENCES kudos_variation(kudos_variation_id)
);