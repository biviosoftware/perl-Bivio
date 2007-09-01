-- Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
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
CREATE TABLE address_t (
  realm_id NUMERIC(18) NOT NULL,
  location NUMERIC(2) NOT NULL,
  street1 VARCHAR(100),
  street2 VARCHAR(100),
  city VARCHAR(30),
  state VARCHAR(30),
  zip VARCHAR(30),
  country CHAR(2),
  CONSTRAINT address_t1 primary key(realm_id, location)
)
/

CREATE TABLE bulletin_t (
  bulletin_id NUMERIC(18) NOT NULL,
  date_time DATE NOT NULL,
  subject VARCHAR(100) NOT NULL,
  body TEXT64K NOT NULL,
  body_content_type VARCHAR(100) NOT NULL,
  CONSTRAINT bulletin_t1 PRIMARY KEY(bulletin_id)
)
/

CREATE TABLE calendar_event_t (
  calendar_event_id NUMERIC(18) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  modified_date_time DATE NOT NULL,
  dtstart DATE NOT NULL,
  dtend DATE NOT NULL,
  location VARCHAR(500),
  description VARCHAR(4000),
  url VARCHAR(255),
  time_zone NUMERIC(4),
  CONSTRAINT calendar_event_t1 PRIMARY KEY(calendar_event_id)
)
/

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

CREATE TABLE ec_check_payment_t (
  ec_payment_id NUMERIC(18),
  realm_id NUMERIC(18) NOT NULL,
  check_number VARCHAR(100) NOT NULL,
  institution VARCHAR(100),
  CONSTRAINT ec_check_payment_t1 PRIMARY KEY(ec_payment_id)
)
/

CREATE TABLE ec_credit_card_payment_t (
  ec_payment_id NUMERIC(18),
  realm_id NUMERIC(18) NOT NULL,
  processed_date_time DATE,
  processor_response VARCHAR(500),
  processor_transaction_number VARCHAR(30),
  card_number VARCHAR(4000) NOT NULL,
  card_expiration_date DATE NOT NULL,
  card_name VARCHAR(100) NOT NULL,
  card_zip VARCHAR(30) NOT NULL,
  CONSTRAINT ec_credit_card_payment_t1 PRIMARY KEY(ec_payment_id)
)
/

CREATE TABLE ec_payment_t (
  ec_payment_id NUMERIC(18),
  realm_id NUMERIC(18) NOT NULL,
  user_id NUMERIC(18) NOT NULL,
  creation_date_time DATE NOT NULL,
  amount NUMERIC(20,6) NOT NULL,
  method NUMERIC(2) NOT NULL,
  status NUMERIC(2) NOT NULL,
  description VARCHAR(100) NOT NULL,
  remark VARCHAR(500),
  salesperson_id NUMERIC(18),
  service NUMERIC(2) NOT NULL,
  point_of_sale NUMERIC(2) NOT NULL,
  CONSTRAINT ec_payment_t1 PRIMARY KEY(ec_payment_id)
)
/

CREATE TABLE ec_subscription_t (
  ec_payment_id NUMERIC(18),
  realm_id NUMERIC(18),
  start_date DATE,
  end_date DATE,
  renewal_state NUMERIC(2),
  CONSTRAINT ec_subscription_t1 PRIMARY KEY(ec_payment_id)
)
/

CREATE TABLE email_alias_t (
  incoming VARCHAR(100) NOT NULL,
  outgoing VARCHAR(100) NOT NULL,
  CONSTRAINT email_alias_t1 PRIMARY KEY(incoming)
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

CREATE TABLE forum_t (
  forum_id NUMERIC(18) NOT NULL,
  parent_realm_id NUMERIC(18) NOT NULL,
  want_reply_to NUMERIC(1) NOT NULL,
  is_public_email NUMERIC(1) NOT NULL,
  require_otp NUMERIC(1) NOT NULL,
  CONSTRAINT forum_t1 PRIMARY KEY(forum_id)
)
/

CREATE TABLE job_lock_t (
  realm_id NUMERIC(18) NOT NULL,
  task_id NUMERIC(9) NOT NULL,
  modified_date_time DATE NOT NULL,
  hostname VARCHAR(100) NOT NULL,
  pid NUMERIC(9) NOT NULL,
  percent_complete NUMERIC(20,6),
  message VARCHAR(500),
  die_code NUMERIC(9),
  constraint job_lock_t1 PRIMARY key(realm_id, task_id)
)
/  

CREATE TABLE lock_t (
  realm_id NUMERIC(18) primary key
)
/

CREATE TABLE motion_t (
  motion_id NUMERIC(18),
  realm_id NUMERIC(18) NOT NULL,
  name VARCHAR(100) NOT NULL,
  name_lc VARCHAR(100) NOT NULL,
  question VARCHAR(500) NOT NULL,
  status NUMERIC(2) NOT NULL,
  type NUMERIC(2) NOT NULL,
  CONSTRAINT motion_t1 PRIMARY KEY(motion_id)
)
/

CREATE TABLE motion_vote_t (
  motion_id NUMERIC(18),
  user_id NUMERIC(18) NOT NULL,
  affiliated_realm_id NUMERIC(18) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  vote NUMERIC(2) NOT NULL,
  creation_date_time DATE NOT NULL,
  CONSTRAINT motion_vote_t1 PRIMARY KEY(motion_id, user_id)
)
/

CREATE TABLE otp_t (
  user_id NUMERIC(18) NOT NULL,
  otp_md5 VARCHAR(16) NOT NULL,
  seed VARCHAR(8) NOT NULL,
  count NUMERIC(3) NOT NULL,
  last_login DATE NOT NULL,
  CONSTRAINT otp_t1 primary key(user_id)
)
/

CREATE TABLE phone_t (
  realm_id NUMERIC(18) NOT NULL,
  location NUMERIC(2) NOT NULL,
  phone VARCHAR(30),
  CONSTRAINT phone_t1 primary key(realm_id, location)
)
/

CREATE TABLE tuple_t (
  realm_id NUMERIC(18) NOT NULL,
  tuple_def_id NUMERIC(18) NOT NULL,
  tuple_num NUMERIC(9) NOT NULL,
  modified_date_time DATE NOT NULL,
  thread_root_id NUMERIC(18),
  slot1 VARCHAR(500),
  slot2 VARCHAR(500),
  slot3 VARCHAR(500),
  slot4 VARCHAR(500),
  slot5 VARCHAR(500),
  slot6 VARCHAR(500),
  slot7 VARCHAR(500),
  slot8 VARCHAR(500),
  slot9 VARCHAR(500),
  slot10 VARCHAR(500),
  slot11 VARCHAR(500),
  slot12 VARCHAR(500),
  slot13 VARCHAR(500),
  slot14 VARCHAR(500),
  slot15 VARCHAR(500),
  slot16 VARCHAR(500),
  slot17 VARCHAR(500),
  slot18 VARCHAR(500),
  slot19 VARCHAR(500),
  slot20 VARCHAR(500),
  CONSTRAINT tuple_t1 PRIMARY KEY(realm_id, tuple_def_id, tuple_num)
)
/

CREATE TABLE tuple_def_t (
  tuple_def_id NUMERIC(18) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  label VARCHAR(100) NOT NULL,
  moniker VARCHAR(100) NOT NULL,
  CONSTRAINT tuple_def_t1 PRIMARY KEY(tuple_def_id)
)
/

CREATE TABLE tuple_slot_def_t (
  tuple_def_id NUMERIC(18) NOT NULL,
  tuple_slot_num NUMERIC(2) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  label VARCHAR(100) NOT NULL,
  tuple_slot_type_id NUMERIC(18) NOT NULL,
  is_required NUMERIC(1) NOT NULL,
  CONSTRAINT tuple_slot_t1 PRIMARY KEY(tuple_def_id, tuple_slot_num)
)
/

CREATE TABLE tuple_slot_type_t (
  tuple_slot_type_id NUMERIC(18) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  label VARCHAR(100) NOT NULL,
  type_class VARCHAR(100) NOT NULL,
  choices VARCHAR(65535),
  default_value VARCHAR(500),
  CONSTRAINT tuple_slot_type_t1 PRIMARY KEY(tuple_slot_type_id)
)
/

CREATE TABLE tuple_use_t  (
  realm_id NUMERIC(18) NOT NULL,
  tuple_def_id NUMERIC(18) NOT NULL,
  label VARCHAR(100) NOT NULL,
  moniker VARCHAR(100) NOT NULL,
  CONSTRAINT tuple_use_t1 PRIMARY KEY(realm_id, tuple_def_id)
)
/

CREATE TABLE realm_dag_t (
  parent_id NUMERIC(18) NOT NULL,
  child_id NUMERIC(18) NOT NULL,
  constraint realm_dag_t1 primary key (parent_id, child_id)
)
/

CREATE TABLE realm_file_t (
  realm_file_id NUMERIC(18),
  realm_id NUMERIC(18) NOT NULL,
  user_id NUMERIC(18) NOT NULL,
  folder_id NUMERIC(18),
  modified_date_time DATE NOT NULL,
  path VARCHAR(500) NOT NULL,
  path_lc VARCHAR(500) NOT NULL,
  is_folder NUMERIC(1) NOT NULL,
  is_public NUMERIC(1) NOT NULL,
  is_read_only NUMERIC(1) NOT NULL,
  CONSTRAINT realm_file_t1 PRIMARY KEY(realm_file_id)
)
/

CREATE TABLE realm_mail_t (
  realm_file_id NUMERIC(18),
  realm_id NUMERIC(18) NOT NULL,
  message_id VARCHAR(100) NOT NULL,
  thread_root_id NUMERIC(18) NOT NULL,
  thread_parent_id NUMERIC(18),
  from_email VARCHAR(100) NOT NULL,
  subject VARCHAR(100) NOT NULL,
  subject_lc VARCHAR(100) NOT NULL,
  CONSTRAINT realm_mail_t1 PRIMARY KEY(realm_file_id)
)
/

CREATE TABLE realm_mail_bounce_t (
  realm_file_id NUMERIC(18) NOT NULL,
  email VARCHAR(100) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  user_id NUMERIC(18) NOT NULL,
  modified_date_time DATE NOT NULL,
  reason VARCHAR(100) NOT NULL,
  CONSTRAINT realm_mail_bounce_t1 PRIMARY KEY(realm_file_id, email)
)
/

CREATE TABLE realm_owner_t (
  realm_id NUMERIC(18),
  name VARCHAR(30) NOT NULL,
  password VARCHAR(30) NOT NULL,
  realm_type NUMERIC(2) NOT NULL,
  display_name VARCHAR(500) NOT NULL,
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
  creation_date_time DATE NOT NULL,
  CONSTRAINT realm_user_t1 PRIMARY KEY(realm_id, user_id, role)
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

CREATE TABLE website_t (
  realm_id NUMERIC(18) NOT NULL,
  location NUMERIC(2) NOT NULL,
  url VARCHAR(255),
  CONSTRAINT website_t1 primary key(realm_id, location)
)
/
