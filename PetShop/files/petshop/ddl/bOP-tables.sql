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
  club_id NUMBER(18),
  start_date DATE
)
/

CREATE TABLE db_upgrade_t (
  version VARCHAR2(30),
  run_date_time DATE
)
/

CREATE TABLE email_t (
  realm_id NUMBER(18),
  location NUMBER(2),
  email VARCHAR2(100),
  want_bulletin NUMBER(1)
)
/

CREATE TABLE lock_t (
  realm_id NUMBER(18) primary key
)
/

CREATE TABLE realm_owner_t (
  realm_id NUMBER(18),
  name VARCHAR2(30),
  password VARCHAR2(30),
  realm_type NUMBER(2),
  display_name VARCHAR2(100),
  creation_date_time DATE
)
/

CREATE TABLE realm_role_t (
  realm_id NUMBER(18),
  role NUMBER(2),
  permission_set CHAR(30)
)
/

CREATE TABLE realm_user_t (
  realm_id NUMBER(18),
  user_id NUMBER(18),
  role NUMBER(2),
  honorific NUMBER(2),
  creation_date_time DATE
)
/

CREATE TABLE user_t (
  user_id NUMBER(18),
  first_name VARCHAR2(30),
  first_name_sort VARCHAR2(30),
  middle_name VARCHAR2(30),
  middle_name_sort VARCHAR2(30),
  last_name VARCHAR2(30),
  last_name_sort VARCHAR2(30),
  gender NUMBER(1),
  birth_date DATE
)
/
