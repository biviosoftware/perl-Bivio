-- Copyright (c) 2001 bivio Inc.  All rights reserved.
-- $Id$
--
-- Sequences for bOP PetShop Models
--
--
-- * All sequences are unique for all sites.
--
-- * The five lower order digits are reserved for site and type.
-- * For now, we only have one site, so the lowest order digits are
--   reserved for type and the site is 0.
--
----------------------------------------------------------------
--
-- Starting at 21.  1-20 is reserved for bOP common Models.
--
CREATE SEQUENCE cart_s
  MINVALUE 100021 MAXVALUE 999999999999999999
  NOCYCLE CACHE 10 INCREMENT BY 100000
/

CREATE SEQUENCE cart_item_s
  MINVALUE 100022 MAXVALUE 999999999999999999
  NOCYCLE CACHE 10 INCREMENT BY 100000
/

CREATE SEQUENCE entity_s
  MINVALUE 100023 MAXVALUE 999999999999999999
  NOCYCLE CACHE 10 INCREMENT by 100000
/
