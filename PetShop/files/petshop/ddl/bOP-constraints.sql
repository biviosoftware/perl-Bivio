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

----------------------------------------------------------------
-- Non-PRIMARY KEY Constraints
----------------------------------------------------------------

--
-- email_t
--
ALTER TABLE email_t
  ADD CONSTRAINT email_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX email_t3 ON email_t (
  realm_id
)
/
ALTER TABLE email_t
  ADD CONSTRAINT email_t4
  CHECK (location BETWEEN 1 AND 2)
/
CREATE UNIQUE INDEX email_t5 ON email_t (
  email
)
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
CREATE UNIQUE INDEX realm_owner_t3 ON realm_owner_t (
  name
)
/
ALTER TABLE realm_owner_t
  ADD CONSTRAINT realm_owner_t4
  CHECK (realm_type BETWEEN 1 AND 3)
/
CREATE INDEX realm_owner_t5 ON realm_owner_t (
  creation_date_time
)
/

--
-- realm_role_t
--
ALTER TABLE realm_role_t
  ADD CONSTRAINT realm_role_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX realm_role_t3 ON realm_role_t (
  realm_id
)
/
ALTER TABLE realm_role_t
  ADD CONSTRAINT realm_role_t4
  CHECK (role BETWEEN 1 AND 7)
/

--
-- realm_user_t
--
ALTER TABLE realm_user_t
  ADD CONSTRAINT realm_user_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX realm_user_t3 ON realm_user_t (
  realm_id
)
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
ALTER TABLE realm_user_t
  ADD CONSTRAINT realm_user_t6
 CHECK (role BETWEEN 1 AND 7)
/
ALTER TABLE realm_user_t
  ADD CONSTRAINT realm_user_t7
  CHECK (honorific BETWEEN 1 AND 9)
/
CREATE INDEX realm_user_t8 ON realm_user_t (
  creation_date_time
)
/

--
-- user_t
--
ALTER TABLE user_t
  ADD CONSTRAINT user_t2
  CHECK (gender BETWEEN 0 AND 2)
/
