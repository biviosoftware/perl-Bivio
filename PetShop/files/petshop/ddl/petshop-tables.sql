-- Copyright (c) 2001 bivio Inc.  All rights reserved.
-- $Id$
--
-- Data Definition Language for bOP PetShop Models
--
-- * Tables are named after their models, but have underscores where
--   the case changes.  
-- * Make sure the type sizes match the Model field types--yes, this file 
--   should be generated from the Models...
-- * Don't put any constraints or indices here.  Put them in *-constraints.sql.
--   It makes it much easier to manage the constraints and indices this way.
--
CREATE TABLE cart_t (
  cart_id NUMBER(18),
  creation_date DATE
)
/

CREATE TABLE cart_item_t (
  cart_item_id NUMBER(18),
  cart_id NUMBER(18),
  item_id VARCHAR(30),
  quantity NUMBER(10),
  unit_price NUMBER(10,2)
)
/

CREATE TABLE category_t (
  category_id VARCHAR(30),
  name VARCHAR(100),
  description VARCHAR(500)
)
/

CREATE TABLE entity_t (
  entity_id NUMBER(18)
) 
/

CREATE TABLE entity_address_t (
  entity_id NUMBER(18),
  location NUMBER(2),
  addr1 VARCHAR2(100),
  addr2 VARCHAR2(100),
  city VARCHAR2(30),
  state VARCHAR2(30),
  zip VARCHAR2(30),
  country CHAR(2)
)
/

CREATE TABLE entity_phone_t (
  entity_id NUMBER(18),
  location NUMBER(2),
  phone VARCHAR2(30)
)
/

CREATE TABLE inventory_t (
  item_id VARCHAR(30),
  quantity NUMBER(10)
)
/

CREATE TABLE item_t (
  item_id VARCHAR(30),
  product_id VARCHAR(30),
  list_price NUMBER(10,2),
  unit_cost NUMBER(10,2),
  supplier_id NUMBER(18),
  status NUMBER(2),
  attr1 VARCHAR(100),
  attr2 VARCHAR(100),      
  attr3 VARCHAR(100),      
  attr4 VARCHAR(100),      
  attr5 VARCHAR(100)   
)
/

CREATE TABLE order_t (
  order_id NUMBER(18),
  cart_id NUMBER(18),
  user_id NUMBER(18),
  order_date DATE,
  courier VARCHAR2(100),
  total_price NUMBER(10,2),
  bill_to_first_name VARCHAR2(100),
  bill_to_last_name VARCHAR2(100),
  ship_to_first_name VARCHAR2(100),
  ship_to_last_name VARCHAR2(100),
  credit_card VARCHAR2(100),
  expiration_date DATE,
  card_type NUMBER(2),
  bonus_miles NUMBER(18)
)
/

CREATE TABLE order_status_t (
  order_id NUMBER(18),
  user_id NUMBER(18),
  time_stamp DATE,
  status NUMBER(2)
)
/

CREATE TABLE product_t (
  product_id VARCHAR(30),
  category_id VARCHAR(30),
  name VARCHAR(100),
  image_name VARCHAR(30),
  description VARCHAR(500)
)    
/

CREATE TABLE supplier_t (
  supplier_id NUMBER(18),
  name VARCHAR2(100),
  status NUMBER(2)
)
/

CREATE TABLE user_account_t (
  user_id NUMBER(18),
  entity_id NUMBER(18),
  status NUMBER(2),
  last_cart_id NUMBER(18),
  user_type NUMBER(2)
)
/

