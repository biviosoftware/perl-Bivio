-- Copyright (c) 2001 bivio Inc.  All rights reserved.
-- $Id$
--
-- Data Definition Language for common bOP Models
--
-- * Tables are named after their models, but have underscores where
--   the case changes.  
-- * Make sure the type sizes match the Model field types--yes, this file 
--   should be generated from the Models...
-- * Don't put any constraints or indices here.  Put them in *-constraints.sql
--   It makes it much easier to manage the constraints and indices this way.
--
----------------------------------------------------------------
CREATE TABLE club_t (
  club_id NUMERIC(18),
  start_date DATE,
  CONSTRAINT club_t1 PRIMARY KEY(club_id)
)
/

CREATE TABLE db_upgrade_t (
  version VARCHAR(30),
  run_date_time DATE NOT NULL,
  CONSTRAINT db_upgrade_t1 PRIMARY KEY(version)
)
/

CREATE TABLE email_t (
  realm_id NUMERIC(18) NOT NULL,
  location NUMERIC(2) NOT NULL,
  email VARCHAR(100) NOT NULL,
  want_bulletin NUMERIC(1) NOT NULL,
  CONSTRAINT email_t1 PRIMARY KEY(realm_id, location)
)
/

CREATE TABLE lock_t (
  realm_id NUMERIC(18) primary key
)
/

CREATE TABLE realm_owner_t (
  realm_id NUMERIC(18),
  name VARCHAR(30) NOT NULL,
  password VARCHAR(30) NOT NULL,
  realm_type NUMERIC(2) NOT NULL,
  display_name VARCHAR(100) NOT NULL,
  creation_date_time DATE NOT NULL,
  CONSTRAINT realm_owner_t1 PRIMARY KEY(realm_id)
)
/

CREATE TABLE realm_role_t (
  realm_id NUMERIC(18) NOT NULL,
  role NUMERIC(2) NOT NULL,
  permission_set CHAR(30) NOT NULL,
  CONSTRAINT realm_role_t1 PRIMARY KEY(realm_id, role)
)
/

CREATE TABLE realm_user_t (
  realm_id NUMERIC(18) NOT NULL,
  user_id NUMERIC(18) NOT NULL,
  role NUMERIC(2) NOT NULL,
  honorific NUMERIC(2) NOT NULL,
  creation_date_time DATE NOT NULL,
  CONSTRAINT realm_user_t1 PRIMARY KEY(realm_id, user_id)
)
/

CREATE TABLE user_t (
  user_id NUMERIC(18),
  first_name VARCHAR(30),
  first_name_sort VARCHAR(30),
  middle_name VARCHAR(30),
  middle_name_sort VARCHAR(30),
  last_name VARCHAR(30),
  last_name_sort VARCHAR(30),
  gender NUMERIC(1) NOT NULL,
  birth_date DATE,
  CONSTRAINT user_t1 PRIMARY KEY(user_id)
)
/
