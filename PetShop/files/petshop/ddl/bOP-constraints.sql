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
-- address_t
--
ALTER TABLE address_t
  add constraint address_t2
  foreign key (realm_id)
  references realm_owner_t(realm_id)
/
CREATE INDEX address_t3 on address_t (
  realm_id
)
/

--
-- ec_check_payment_t
--

ALTER TABLE ec_check_payment_t
  ADD CONSTRAINT ec_check_payment_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
ALTER TABLE ec_check_payment_t
  ADD CONSTRAINT ec_check_payment_t3
  FOREIGN KEY (ec_payment_id)
  REFERENCES ec_payment_t(ec_payment_id)
/
CREATE INDEX ec_check_payment_t4 ON ec_check_payment_t (
  realm_id
)
/

--
-- ec_credit_card_payment_t
--

ALTER TABLE ec_credit_card_payment_t
  ADD CONSTRAINT ec_credit_card_payment_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
ALTER TABLE ec_credit_card_payment_t
  ADD CONSTRAINT ec_credit_card_payment_t3
  FOREIGN KEY (ec_payment_id)
  REFERENCES ec_payment_t(ec_payment_id)
/
CREATE INDEX ec_credit_card_payment_t4 ON ec_credit_card_payment_t (
  realm_id
)
/

--
-- ec_payment_t
--

ALTER TABLE ec_payment_t
  ADD CONSTRAINT ec_payment_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
ALTER TABLE ec_payment_t
  ADD CONSTRAINT ec_payment_t3
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
ALTER TABLE ec_payment_t
  ADD CONSTRAINT ec_payment_t5
  CHECK (method between 1 and 4)
/
ALTER TABLE ec_payment_t
  ADD CONSTRAINT ec_payment_t7
  FOREIGN KEY (salesperson_id)
  REFERENCES user_t(user_id)
/
ALTER TABLE ec_payment_t
  ADD CONSTRAINT ec_payment_t8
  CHECK (status between 0 and 9)
/
ALTER TABLE ec_payment_t
  ADD CONSTRAINT ec_payment_t9
  CHECK (point_of_sale between 0 and 5)
/
CREATE INDEX ec_payment_t10 ON ec_payment_t (
  realm_id
)
/
CREATE INDEX ec_payment_t11 ON ec_payment_t (
  user_id
)
/
CREATE INDEX ec_payment_t12 ON ec_payment_t (
  salesperson_id
)
/

--
-- ec_subscription_t
--

ALTER TABLE ec_subscription_t
  ADD CONSTRAINT ec_subscription_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
ALTER TABLE ec_subscription_t
  ADD CONSTRAINT ec_subscription_t3
  FOREIGN KEY (ec_payment_id)
  REFERENCES ec_payment_t(ec_payment_id)
/
ALTER TABLE ec_subscription_t
  ADD CONSTRAINT ec_subscription_t4
  CHECK (renewal_state between 1 and 4)
/
CREATE INDEX ec_subscription_t5 ON ec_subscription_t (
  realm_id
)
/

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
CREATE UNIQUE INDEX email_t5 ON email_t (
  email
)
/
ALTER TABLE email_t
  ADD CONSTRAINT email_t6
  CHECK (want_bulletin BETWEEN 0 AND 1)
/

--
-- forum_t
--
ALTER TABLE forum_t
  add constraint forum_t2
  foreign key (realm_id)
  references realm_owner_t(realm_id)
/
CREATE INDEX forum_t3 on forum_t (
  realm_id
)
/
CREATE UNIQUE INDEX forum_t4 on forum_t (
  realm_id,
  name_lc
)
/
CREATE INDEX forum_t5 on forum_t (
  name
)
/
CREATE INDEX forum_t6 on forum_t (
  name_lc
)
/

--
-- lock_t
--
-- These constraints intentionally left blank.

--
-- phone_t
--
ALTER TABLE phone_t
  add constraint phone_t2
  foreign key (realm_id)
  references realm_owner_t(realm_id)
/
CREATE INDEX phone_t3 on phone_t (
  realm_id
)
/

--
-- realm_file_t
--
ALTER TABLE realm_file_t
  ADD CONSTRAINT realm_file_t2
  foreign key (realm_id)
  references realm_owner_t(realm_id)
/
CREATE INDEX realm_file_t3 ON realm_file_t (
  realm_id
)
/
CREATE INDEX realm_file_t4 ON realm_file_t (
  creation_date_time
)
/
CREATE INDEX realm_file_t5 ON realm_file_t (
  path
)
/
CREATE UNIQUE INDEX realm_file_t6 ON realm_file_t (
  realm_id,
  volume,
  path
)
/
ALTER TABLE realm_file_t
  ADD CONSTRAINT realm_file_t7
  CHECK (is_folder BETWEEN 0 AND 1)
/

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
