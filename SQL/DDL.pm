# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::SQL::DDL;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_F) = __PACKAGE__->use('IO.File');

sub write_files {
    my($self) = @_;
    my($header) = '-- Copyright (c) 1999-2008 bivio Software, Inc.  '
	. "All rights reserved.\n"
	. '-- Generated '
	. $self->use('Type.DateTime')->local_now_as_file_name
	. ' by $Id$'
	. "\n-- DO NOT EDIT THIS FILE\n--\n";
    foreach my $x (qw(constraints sequences tables)) {
	my($sub) = \&{"_file_$x"};
	my($f) = "bOP-$x.sql";
	unlink($f);
	$_F->write($f, $header . $sub->());
    }
    return;
}

sub _file_constraints {
    return <<'EOF';
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
-- crm_thread_t
--
ALTER TABLE crm_thread_t
  ADD CONSTRAINT crm_thread_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX crm_thread_t3 ON crm_thread_t (
  realm_id
)
/
CREATE INDEX crm_thread_t4 ON crm_thread_t (
  modified_date_time
)
/
CREATE UNIQUE INDEX crm_thread_t5 ON crm_thread_t (
  thread_root_id
)
/
ALTER TABLE crm_thread_t
  ADD CONSTRAINT crm_thread_t6
  FOREIGN KEY (thread_root_id)
  REFERENCES realm_file_t(realm_file_id)
/
ALTER TABLE crm_thread_t
  ADD CONSTRAINT crm_thread_t7
  CHECK (crm_thread_status > 0)
/
ALTER TABLE crm_thread_t
  ADD CONSTRAINT crm_thread_t8
  FOREIGN KEY (owner_user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX crm_thread_t9 ON crm_thread_t (
  owner_user_id
)
/
CREATE INDEX crm_thread_t10 ON crm_thread_t (
  subject_lc
)
/
ALTER TABLE crm_thread_t
  ADD CONSTRAINT crm_thread_t11
  FOREIGN KEY (modified_by_user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX crm_thread_t12 ON crm_thread_t (
  modified_by_user_id
)
/
ALTER TABLE crm_thread_t
  ADD CONSTRAINT crm_thread_t13
  FOREIGN KEY (lock_user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX crm_thread_t14 ON crm_thread_t (
  lock_user_id
)
/
ALTER TABLE crm_thread_t
  ADD CONSTRAINT crm_thread_t15
  FOREIGN KEY (customer_realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX crm_thread_t16 ON crm_thread_t (
  customer_realm_id
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
--
-- nonunique_email_t
--
ALTER TABLE nonunique_email_t
  ADD CONSTRAINT nonunique_email_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX nonunique_email_t3 ON nonunique_email_t (
  realm_id
)
/
CREATE INDEX nonunique_email_t5 ON nonunique_email_t (
  email
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
-- realm_file_lock_t
--
ALTER TABLE realm_file_lock_t
  ADD CONSTRAINT realm_file_lock_t2
  FOREIGN KEY (realm_file_id)
  REFERENCES realm_file_t(realm_file_id)
/
CREATE INDEX realm_file_lock_t3 ON realm_file_lock_t (
  realm_file_id
)
/
ALTER TABLE realm_file_lock_t
  ADD CONSTRAINT realm_file_lock_t4
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX realm_file_lock_t5 ON realm_file_lock_t (
  realm_id
)
/
ALTER TABLE realm_file_lock_t
  ADD CONSTRAINT realm_file_lock_t6
  FOREIGN KEY (user_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX realm_file_lock_t7 ON realm_file_lock_t (
  user_id
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
-- tuple_tag_t
--
ALTER TABLE tuple_tag_t
  ADD CONSTRAINT tuple_tag_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX tuple_tag_t3 on tuple_tag_t (
  realm_id
)
/
ALTER TABLE tuple_tag_t
  ADD CONSTRAINT tuple_tag_t4
  FOREIGN KEY (tuple_def_id)
  REFERENCES tuple_def_t(tuple_def_id)
/
CREATE INDEX tuple_tag_t5 on tuple_tag_t (
  tuple_def_id
)
/
CREATE INDEX tuple_tag_t6 on tuple_tag_t (
  primary_id
)
/
ALTER TABLE tuple_tag_t
  ADD CONSTRAINT tuple_tag_t7
  FOREIGN KEY (realm_id, tuple_def_id)
  REFERENCES tuple_use_t(realm_id, tuple_def_id)
/
CREATE INDEX tuple_tag_t8 on tuple_tag_t (
  realm_id,
  tuple_def_id
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
EOF
}

sub _file_sequences {
    return <<'EOF';
-- Sequences for common bOP Models
-- 
-- * All sequences are unique for all sites.
-- * The five lower order digits are reserved for site and type.
-- * For now, we only have one site, so the lowest order digits are
--   reserved for type and the site is 0.
-- * CACHE 1 is required, because postgres keeps the cache on the
--   client side
--
----------------------------------------------------------------
--
-- 1-20 are reserved for bOP common Models.
--
CREATE SEQUENCE user_s
  MINVALUE 100001
  CACHE 1 INCREMENT BY 100000
/

CREATE SEQUENCE club_s
  MINVALUE 100002
  CACHE 1 INCREMENT BY 100000
/

CREATE SEQUENCE realm_file_s
  MINVALUE 100003
  CACHE 1 INCREMENT BY 100000
/

CREATE SEQUENCE forum_s
  MINVALUE 100004
  CACHE 1 INCREMENT BY 100000
/

CREATE SEQUENCE calendar_event_s
  MINVALUE 100005
  CACHE 1 INCREMENT BY 100000
/

CREATE SEQUENCE tuple_def_s
  MINVALUE 100006
  CACHE 1 INCREMENT BY 100000
/

CREATE SEQUENCE tuple_slot_type_s
  MINVALUE 100007
  CACHE 1 INCREMENT BY 100000
/

CREATE SEQUENCE motion_s
  MINVALUE 100008
  CACHE 1 INCREMENT BY 100000
/

CREATE SEQUENCE realm_file_lock_s
  MINVALUE 100009
  CACHE 1 INCREMENT BY 100000
/

--
-- 100010-14 available
--

CREATE SEQUENCE ec_payment_s
  MINVALUE 100015
  CACHE 1 INCREMENT BY 100000
/

CREATE SEQUENCE bulletin_s
  MINVALUE 100016
  CACHE 1 INCREMENT BY 100000
/

EOF
}

sub _file_tables {
    return <<'EOF';
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

CREATE TABLE crm_thread_t (
  realm_id NUMERIC(18) NOT NULL,
  crm_thread_num NUMERIC(9) NOT NULL,
  modified_date_time DATE NOT NULL,
  modified_by_user_id NUMERIC(18),
  thread_root_id NUMERIC(18) NOT NULL,
  crm_thread_status NUMERIC(2) NOT NULL,
  subject VARCHAR(100) NOT NULL,
  subject_lc VARCHAR(100) NOT NULL,
  owner_user_id NUMERIC(18),
  lock_user_id NUMERIC(18),
  customer_realm_id NUMERIC(18),
  CONSTRAINT crm_thread_t1 PRIMARY KEY(realm_id, crm_thread_num)
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
  comment VARCHAR(500),
  CONSTRAINT motion_vote_t1 PRIMARY KEY(motion_id, user_id)
)
/

CREATE TABLE nonunique_email_t (
  realm_id NUMERIC(18) NOT NULL,
  location NUMERIC(2) NOT NULL,
  email VARCHAR(100),
  CONSTRAINT nonunique_email_t1 PRIMARY KEY(realm_id, location)
)
/

CREATE TABLE otp_t (
  user_id NUMERIC(18) NOT NULL,
  otp_md5 VARCHAR(16) NOT NULL,
  seed VARCHAR(8) NOT NULL,
  sequence NUMERIC(3) NOT NULL,
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

CREATE TABLE row_tag_t (
  primary_id NUMERIC(18) NOT NULL,
  key NUMERIC(3) NOT NULL,
  value VARCHAR(500) NOT NULL,
  CONSTRAINT row_tag_t1 primary key(primary_id, key)
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

CREATE TABLE tuple_tag_t  (
  realm_id NUMERIC(18) NOT NULL,
  tuple_def_id NUMERIC(18) NOT NULL,
  primary_id NUMERIC(18) NOT NULL,
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
  CONSTRAINT tuple_tag_t1 PRIMARY KEY(realm_id, tuple_def_id, primary_id)
)
/

CREATE TABLE realm_dag_t (
  parent_id NUMERIC(18) NOT NULL,
  child_id NUMERIC(18) NOT NULL,
  realm_dag_type NUMERIC(2) NOT NULL,
  constraint realm_dag_t1 primary key (parent_id, child_id, realm_dag_type)
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

CREATE TABLE realm_file_lock_t (
  realm_file_lock_id NUMERIC(18),
  realm_file_id NUMERIC(18) NOT NULL,
  modified_date_time DATE NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  user_id NUMERIC(18) NOT NULL,
  comment VARCHAR(500),
  CONSTRAINT realm_file_lock_t1 PRIMARY KEY(realm_file_lock_id)
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
EOF
}

1;
