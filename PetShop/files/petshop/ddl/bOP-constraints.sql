-- Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
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
  ADD CONSTRAINT address_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX address_t3 on address_t (
  realm_id
)
/

--
-- calendar_event_t
--
ALTER TABLE calendar_event_t
  ADD CONSTRAINT calendar_event_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX calendar_event_t3 ON calendar_event_t (
  realm_id
)
/
CREATE INDEX calendar_event_t4 ON calendar_event_t (
  modified_date_time
)
/
CREATE INDEX calendar_event_t5 ON calendar_event_t (
  dtstart
)
/
CREATE INDEX calendar_event_t6 ON calendar_event_t (
  dtend
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
-- email_alias_t
--
CREATE INDEX email_alias_t2 ON email_alias_t (
  outgoing
)
/

--
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
  ADD CONSTRAINT forum_t2
  FOREIGN KEY (parent_realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX forum_t3 on forum_t (
  parent_realm_id
)
/
ALTER TABLE forum_t
  ADD CONSTRAINT forum_t4
  CHECK (want_reply_to BETWEEN 0 AND 1)
/
ALTER TABLE forum_t
  ADD CONSTRAINT forum_t5
  CHECK (is_public_email BETWEEN 0 AND 1)
/
ALTER TABLE forum_t
  ADD CONSTRAINT forum_t6
  CHECK (require_otp BETWEEN 0 AND 1)
/

--
-- job_lock_t
--
ALTER TABLE job_lock_t
  ADD CONSTRAINT job_lock_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX job_lock_t3 on job_lock_t (
  realm_id
)
/

--
-- lock_t
--
-- These constraints intentionally left blank.

--
-- motion_t
--
ALTER TABLE motion_t
  add constraint motion_t2
  foreign key (realm_id)
  references realm_owner_t(realm_id)
/
CREATE INDEX motion_t3 on motion_t (
  realm_id
)
/
CREATE UNIQUE INDEX motion_t4 ON motion_t (
  realm_id,
  name_lc
)
/

--
-- motion_vote_t
--
ALTER TABLE motion_vote_t
  add constraint motion_vote_t2
  foreign key (motion_id)
  references motion_t(motion_id)
/
CREATE INDEX motion_vote_t3 on motion_vote_t (
  motion_id
)
/
ALTER TABLE motion_vote_t
  add constraint motion_vote_t4
  foreign key (user_id)
  references user_t(user_id)
/
CREATE INDEX motion_vote_t5 on motion_vote_t (
  user_id
)
/
ALTER TABLE motion_vote_t
  add constraint motion_vote_t6
  foreign key (affiliated_realm_id)
  references realm_owner_t(realm_id)
/
CREATE INDEX motion_vote_t7 on motion_vote_t (
  affiliated_realm_id
)
/
ALTER TABLE motion_vote_t
  add constraint motion_vote_t8
  foreign key (realm_id)
  references realm_owner_t(realm_id)
/
CREATE INDEX motion_vote_t9 on motion_vote_t (
  realm_id
)
/

--
-- otp_t
--
ALTER TABLE otp_t
  ADD CONSTRAINT otp_t2
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX otp_t3 ON otp_t (
  user_id
)
/

--
-- phone_t
--
ALTER TABLE phone_t
  ADD CONSTRAINT phone_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX phone_t3 on phone_t (
  realm_id
)
/

--
-- realm_dag_t
--

ALTER TABLE realm_dag_t
  ADD CONSTRAINT realm_dag_t2
  FOREIGN KEY (parent_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX realm_dag_t3 ON realm_dag_t (
  parent_id
)
/
ALTER TABLE realm_dag_t
  ADD CONSTRAINT realm_dag_t4
  FOREIGN KEY (child_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX realm_dag_t5 ON realm_dag_t (
  child_id
)
/

--
-- realm_file_t
--
ALTER TABLE realm_file_t
  ADD CONSTRAINT realm_file_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX realm_file_t3 ON realm_file_t (
  realm_id
)
/
CREATE INDEX realm_file_t4 ON realm_file_t (
  modified_date_time
)
/
CREATE INDEX realm_file_t5 ON realm_file_t (
  path_lc
)
/
CREATE UNIQUE INDEX realm_file_t6 ON realm_file_t (
  realm_id,
  path_lc
)
/
ALTER TABLE realm_file_t
  ADD CONSTRAINT realm_file_t7
  CHECK (is_folder BETWEEN 0 AND 1)
/
ALTER TABLE realm_file_t
  ADD CONSTRAINT realm_file_t8
  CHECK (is_public BETWEEN 0 AND 1)
/
ALTER TABLE realm_file_t
  ADD CONSTRAINT realm_file_t9
  CHECK (is_read_only BETWEEN 0 AND 1)
/
ALTER TABLE realm_file_t
  ADD CONSTRAINT realm_file_t10
  FOREIGN KEY (user_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX realm_file_t11 ON realm_file_t (
  user_id
)
/
CREATE INDEX realm_file_t12 ON realm_file_t (
  folder_id
)
/

--
-- realm_mail_t
--
ALTER TABLE realm_mail_t
  ADD CONSTRAINT realm_mail_t2
  FOREIGN KEY (realm_file_id)
  REFERENCES realm_file_t(realm_file_id)
/
ALTER TABLE realm_mail_t
  ADD CONSTRAINT realm_mail_t3
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX realm_mail_t4 ON realm_mail_t (
  realm_id
)
/
CREATE INDEX realm_mail_t5 ON realm_mail_t (
  message_id
)
/
ALTER TABLE realm_mail_t
  ADD CONSTRAINT realm_mail_t6
  FOREIGN KEY (thread_root_id)
  REFERENCES realm_file_t(realm_file_id)
/
CREATE INDEX realm_mail_t7 ON realm_mail_t (
  thread_root_id
)
/
ALTER TABLE realm_mail_t
  ADD CONSTRAINT realm_mail_t8
  FOREIGN KEY (thread_parent_id)
  REFERENCES realm_file_t(realm_file_id)
/
CREATE INDEX realm_mail_t9 ON realm_mail_t (
  thread_parent_id
)
/
CREATE INDEX realm_mail_t10 ON realm_mail_t (
  from_email
)
/
CREATE INDEX realm_mail_t11 ON realm_mail_t (
  subject_lc
)
/

--
-- realm_mail_bounce_t
--
ALTER TABLE realm_mail_bounce_t
  ADD CONSTRAINT realm_mail_bounce_t2
  FOREIGN KEY (realm_file_id)
  REFERENCES realm_file_t(realm_file_id)
/
CREATE INDEX realm_mail_bounce_t3 ON realm_mail_bounce_t (
  realm_file_id
)
/
ALTER TABLE realm_mail_bounce_t
  ADD CONSTRAINT realm_mail_bounce_t4
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX realm_mail_bounce_t5 ON realm_mail_bounce_t (
  realm_id
)
/
ALTER TABLE realm_mail_bounce_t
  ADD CONSTRAINT realm_mail_bounce_t6
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX realm_mail_bounce_t7 ON realm_mail_bounce_t (
  user_id
)
/
CREATE INDEX realm_mail_bounce_t8 ON realm_mail_bounce_t (
  modified_date_time
)
/
CREATE INDEX realm_mail_bounce_t9 ON realm_mail_bounce_t (
  reason
)
/
CREATE INDEX realm_mail_bounce_t10 ON realm_mail_bounce_t (
  email
)
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
ALTER TABLE realm_user_t
  ADD CONSTRAINT realm_user_t6
  CHECK (role > 0)
/
CREATE INDEX realm_user_t8 ON realm_user_t (
  creation_date_time
)
/

--
-- tuple_t
--
ALTER TABLE tuple_t
  ADD CONSTRAINT tuple_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX tuple_t3 on tuple_t (
  realm_id
)
/
ALTER TABLE tuple_t
  ADD CONSTRAINT tuple_t4
  FOREIGN KEY (tuple_def_id)
  REFERENCES tuple_def_t(tuple_def_id)
/
CREATE INDEX tuple_t5 on tuple_t (
  tuple_def_id
)
/
CREATE INDEX tuple_t6 on tuple_t (
  modified_date_time
)
/
ALTER TABLE tuple_t
  ADD CONSTRAINT tuple_t7
  FOREIGN KEY (thread_root_id)
  REFERENCES realm_mail_t(realm_file_id)
/
CREATE INDEX tuple_t8 on tuple_t (
  thread_root_id
)
/
ALTER TABLE tuple_t
  ADD CONSTRAINT tuple_t9
  FOREIGN KEY (realm_id, tuple_def_id)
  REFERENCES tuple_use_t(realm_id, tuple_def_id)
/
CREATE INDEX tuple_t10 on tuple_t (
  realm_id,
  tuple_def_id
)
/

--
-- tuple_def_t
--
ALTER TABLE tuple_def_t
  ADD CONSTRAINT tuple_def_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX tuple_def_t3 on tuple_def_t (
  realm_id
)
/
CREATE UNIQUE INDEX tuple_def_t4 on tuple_def_t (
  realm_id,
  label
)
/
CREATE UNIQUE INDEX tuple_def_t5 on tuple_def_t (
  realm_id,
  moniker
)
/

--
-- tuple_slot_def_t
--
ALTER TABLE tuple_slot_def_t
  ADD CONSTRAINT tuple_slot_def_t2
  FOREIGN KEY (tuple_def_id)
  REFERENCES tuple_def_t(tuple_def_id)
/
CREATE INDEX tuple_slot_def_t3 on tuple_slot_def_t (
  tuple_def_id
)
/
ALTER TABLE tuple_slot_def_t
  ADD CONSTRAINT tuple_slot_def_t4
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX tuple_slot_def_t5 on tuple_slot_def_t (
  realm_id
)
/
CREATE UNIQUE INDEX tuple_slot_def_t6 on tuple_slot_def_t (
  tuple_def_id,
  label
)
/
ALTER TABLE tuple_slot_def_t
  ADD CONSTRAINT tuple_slot_def_t7
  FOREIGN KEY (tuple_slot_type_id)
  REFERENCES tuple_slot_type_t(tuple_slot_type_id)
/
CREATE INDEX tuple_slot_def_t8 on tuple_slot_def_t (
  tuple_slot_type_id
)
/
ALTER TABLE tuple_slot_def_t
  ADD CONSTRAINT tuple_slot_def_t9
  CHECK (is_required BETWEEN 0 AND 1)
/

--
-- tuple_slot_type_t
--
ALTER TABLE tuple_slot_type_t
  ADD CONSTRAINT tuple_slot_type_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX tuple_slot_type_t3 on tuple_slot_type_t (
  realm_id
)
/
CREATE UNIQUE INDEX tuple_slot_type_t4 on tuple_slot_type_t (
  realm_id,
  label
)
/

--
-- tuple_use_t
--
ALTER TABLE tuple_use_t
  ADD CONSTRAINT tuple_use_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX tuple_use_t3 on tuple_use_t (
  realm_id
)
/
ALTER TABLE tuple_use_t
  ADD CONSTRAINT tuple_use_t4
  FOREIGN KEY (tuple_def_id)
  REFERENCES tuple_def_t(tuple_def_id)
/
CREATE INDEX tuple_use_t5 on tuple_use_t (
  tuple_def_id
)
/
CREATE UNIQUE INDEX tuple_use_t6 on tuple_use_t (
  realm_id,
  label
)
/
CREATE UNIQUE INDEX tuple_use_t7 on tuple_use_t (
  realm_id,
  moniker
)
/

--
-- user_t
--
ALTER TABLE user_t
  ADD CONSTRAINT user_t2
  CHECK (gender BETWEEN 0 AND 2)
/

--
-- website_t
--
ALTER TABLE website_t
  ADD CONSTRAINT website_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX website_t3 on website_t (
  realm_id
)
/
