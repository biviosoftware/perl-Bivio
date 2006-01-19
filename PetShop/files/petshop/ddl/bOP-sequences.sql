-- Copyright (c) 2001 bivio Inc.  All rights reserved.
-- $Id$
--
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

--
-- 100006-14 available
--

CREATE SEQUENCE ec_payment_s
  MINVALUE 100015
  CACHE 1 INCREMENT BY 100000
/

CREATE SEQUENCE bulletin_s
  MINVALUE 100016
  CACHE 1 INCREMENT BY 100000
/

