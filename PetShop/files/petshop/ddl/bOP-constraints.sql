-- Copyright (c) 2001 bivio Inc.  All rights reserved.
-- $Id$
--
-- Constraints & Indexes for common bOP Models
--
-- * This file is sorted alphabetically by table
-- * The only "NOT NULL" values are for things which are optional.
--   There should be very few optional things.  For example, there
--   is no such thing as an optional enum value.  0 should be used
--   for the UNKNOWN enum value.
-- * Booleans are: <name> NUMBER(1) CHECK (<name> BETWEEN 0 AND 1) NOT NULL,
-- * How to number all constraints sequentially:
--   perl -pi -e 's/(\w+_t)\d+/$1.++$n{$1}/e' bOP-constraints.sql
--   Make sure there is a table_tN ON each constraint--random N.
--
----------------------------------------------------------------
-- All the primary keys need to be first, so we can use them in
-- FOREIGN KEY constraints.
--
ALTER TABLE club_t
  ADD CONSTRAINT club_t1
  PRIMARY KEY(club_id)
/
ALTER TABLE db_upgrade_t
  ADD CONSTRAINT db_upgrade_t1
  PRIMARY KEY(version)
/
ALTER TABLE email_t
  ADD CONSTRAINT email_t1
  PRIMARY KEY(realm_id, location)
/
ALTER TABLE realm_owner_t
  ADD CONSTRAINT realm_owner_t1
  PRIMARY KEY(realm_id)
/
ALTER TABLE realm_role_t
  ADD CONSTRAINT realm_role_t1
  PRIMARY KEY(realm_id, role)
/
ALTER TABLE realm_user_t
  ADD CONSTRAINT realm_user_t1
  PRIMARY KEY(realm_id, user_id)
/
ALTER TABLE user_t
  ADD CONSTRAINT user_t1
  PRIMARY KEY(user_id)
/

----------------------------------------------------------------
-- Non-PRIMARY KEY Constraints
----------------------------------------------------------------
--
-- club_t
--

--
-- db_upgrade_t
--
ALTER TABLE db_upgrade_t MODIFY run_date_time NOT NULL
/

--
-- email_t
--
ALTER TABLE email_t MODIFY realm_id NOT NULL
/
ALTER TABLE email_t
  ADD CONSTRAINT email_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX email_t3 ON email_t (
  realm_id
)
/
ALTER TABLE email_t MODIFY location NOT NULL
/
ALTER TABLE email_t
  ADD CONSTRAINT email_t4
  CHECK (location BETWEEN 1 AND 2)
/
ALTER TABLE email_t MODIFY email NOT NULL
/
CREATE UNIQUE INDEX email_t5 ON email_t (
  email
)
/
ALTER TABLE email_t MODIFY want_bulletin NOT NULL
/
ALTER TABLE email_t
  ADD CONSTRAINT email_t6
  CHECK (want_bulletin BETWEEN 0 AND 1)
/

--
-- lock_t
--
-- These constraints intentionally left blank.

--
-- realm_owner_t
--
ALTER TABLE realm_owner_t
  ADD CONSTRAINT realm_owner_t2
  CHECK (realm_id > 0)
/
ALTER TABLE realm_owner_t MODIFY name NOT NULL
/
CREATE UNIQUE INDEX realm_owner_t3 ON realm_owner_t (
  name
)
/
ALTER TABLE realm_owner_t MODIFY password NOT NULL
/
ALTER TABLE realm_owner_t MODIFY realm_type NOT NULL
/
ALTER TABLE realm_owner_t
  ADD CONSTRAINT realm_owner_t4
  CHECK (realm_type BETWEEN 1 AND 3)
/
ALTER TABLE realm_owner_t MODIFY display_name NOT NULL
/
ALTER TABLE realm_owner_t MODIFY creation_date_time NOT NULL
/
CREATE INDEX realm_owner_t5 ON realm_owner_t (
  creation_date_time
)
/

--
-- realm_role_t
--
ALTER TABLE realm_role_t MODIFY realm_id NOT NULL
/
ALTER TABLE realm_role_t
  ADD CONSTRAINT realm_role_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX realm_role_t3 ON realm_role_t (
  realm_id
)
/
ALTER TABLE realm_role_t MODIFY role NOT NULL
/
ALTER TABLE realm_role_t
  ADD CONSTRAINT realm_role_t4
  CHECK (role BETWEEN 1 AND 7)
/
ALTER TABLE realm_role_t MODIFY permission_set NOT NULL
/

--
-- realm_user_t
--
ALTER TABLE realm_user_t MODIFY realm_id NOT NULL
/
ALTER TABLE realm_user_t
  ADD CONSTRAINT realm_user_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX realm_user_t3 ON realm_user_t (
  realm_id
)
/
ALTER TABLE realm_user_t MODIFY user_id NOT NULL
/
ALTER TABLE realm_user_t
  ADD CONSTRAINT realm_user_t4
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX realm_user_t5 ON realm_user_t (
  user_id
)
/
ALTER TABLE realm_user_t MODIFY role NOT NULL
/
ALTER TABLE realm_user_t
  ADD CONSTRAINT realm_user_t6
 CHECK (role BETWEEN 1 AND 7)
/
ALTER TABLE realm_user_t
  ADD CONSTRAINT realm_user_t7
  CHECK (honorific BETWEEN 1 AND 9)
/
ALTER TABLE realm_user_t MODIFY honorific NOT NULL
/
ALTER TABLE realm_user_t MODIFY creation_date_time NOT NULL
/
CREATE INDEX realm_user_t8 ON realm_user_t (
  creation_date_time
)
/

--
-- user_t
--
ALTER TABLE user_t MODIFY gender NOT NULL
/
ALTER TABLE user_t
  ADD CONSTRAINT user_t2
  CHECK (gender BETWEEN 0 AND 2)
/
