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
CREATE sequence user_s
  MINVALUE 100001
  CACHE 1 INCREMENT BY 100000
/

CREATE SEQUENCE club_s
  MINVALUE 100002
  CACHE 1 INCREMENT BY 100000
/
