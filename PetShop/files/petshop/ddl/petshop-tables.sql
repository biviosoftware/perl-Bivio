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
  cart_id NUMERIC(18),
  creation_date DATE NOT NULL,
  CONSTRAINT cart_t1 PRIMARY KEY(cart_id)
)
/

CREATE TABLE cart_item_t (
  cart_item_id NUMERIC(18),
  cart_id NUMERIC(18),
  item_id VARCHAR(30) NOT NULL,
  quantity NUMERIC(10) NOT NULL,
  unit_price NUMERIC(10,2) NOT NULL,
  CONSTRAINT cart_item_t1 PRIMARY KEY(cart_id, cart_item_id)
)
/

CREATE TABLE category_t (
  category_id VARCHAR(30),
  name VARCHAR(100) NOT NULL,
  description VARCHAR(500) NOT NULL,
  CONSTRAINT category_t1 PRIMARY KEY(category_id)
)
/

CREATE TABLE entity_t (
  entity_id NUMERIC(18),
  CONSTRAINT entity_t1 PRIMARY KEY(entity_id)
) 
/

CREATE TABLE entity_address_t (
  entity_id NUMERIC(18) NOT NULL,
  location NUMERIC(2) NOT NULL,
  addr1 VARCHAR(100),
  addr2 VARCHAR(100),
  city VARCHAR(30),
  state VARCHAR(30),
  zip VARCHAR(30),
  country CHAR(2),
  CONSTRAINT entity_address_t1 PRIMARY KEY(entity_id, location)
)
/

CREATE TABLE entity_phone_t (
  entity_id NUMERIC(18) NOT NULL,
  location NUMERIC(2) NOT NULL,
  phone VARCHAR(30),
  CONSTRAINT entity_phone_t1 PRIMARY KEY(entity_id, location)
)
/

CREATE TABLE inventory_t (
  item_id VARCHAR(30),
  quantity NUMERIC(10) NOT NULL,
  CONSTRAINT inventory_t1 PRIMARY KEY(item_id)
)
/

CREATE TABLE item_t (
  item_id VARCHAR(30),
  product_id VARCHAR(30) NOT NULL,
  list_price NUMERIC(10,2) NOT NULL,
  unit_cost NUMERIC(10,2) NOT NULL,
  supplier_id NUMERIC(18) NOT NULL,
  status NUMERIC(2) NOT NULL,
  attr1 VARCHAR(100) NOT NULL,
  attr2 VARCHAR(100),      
  attr3 VARCHAR(100),      
  attr4 VARCHAR(100),      
  attr5 VARCHAR(100),
  CONSTRAINT item_t1 PRIMARY KEY(item_id)
)
/

CREATE TABLE order_t (
  order_id NUMERIC(18),
  cart_id NUMERIC(18) NOT NULL,
  user_id NUMERIC(18) NOT NULL,
  order_date DATE NOT NULL,
  courier VARCHAR(100) NOT NULL,
  total_price NUMERIC(10,2) NOT NULL,
  bill_to_first_name VARCHAR(100) NOT NULL,
  bill_to_last_name VARCHAR(100) NOT NULL,
  ship_to_first_name VARCHAR(100) NOT NULL,
  ship_to_last_name VARCHAR(100) NOT NULL,
  credit_card VARCHAR(100) NOT NULL,
  expiration_date DATE NOT NULL,
  card_type NUMERIC(2) NOT NULL,
  bonus_miles NUMERIC(18),
  CONSTRAINT order_t1 PRIMARY KEY(order_id)
)
/

CREATE TABLE order_status_t (
  order_id NUMERIC(18),
  user_id NUMERIC(18) NOT NULL,
  time_stamp DATE NOT NULL,
  status NUMERIC(2) NOT NULL,
  CONSTRAINT order_status_t1 PRIMARY KEY(order_id)
)
/

CREATE TABLE product_t (
  product_id VARCHAR(30),
  category_id VARCHAR(30) NOT NULL,
  name VARCHAR(100) NOT NULL,
  image_name VARCHAR(30) NOT NULL,
  description VARCHAR(500) NOT NULL,
  CONSTRAINT product_t1 PRIMARY KEY(product_id)
)    
/

CREATE TABLE supplier_t (
  supplier_id NUMERIC(18),
  name VARCHAR(100) NOT NULL,
  status NUMERIC(2) NOT NULL,
  CONSTRAINT supplier_t1 PRIMARY KEY(supplier_id)
)
/

CREATE TABLE user_account_t (
  user_id NUMERIC(18),
  entity_id NUMERIC(18) NOT NULL,
  status NUMERIC(2) NOT NULL,
  last_cart_id NUMERIC(18),
  user_type NUMERIC(2) NOT NULL,
  CONSTRAINT user_account_t1 PRIMARY KEY(user_id)
)
/

