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
  realm_id NUMERIC(18),
  cart_id NUMERIC(18) NOT NULL,
  ec_payment_id NUMERIC(18) NOT NULL,
  bill_to_name VARCHAR(100) NOT NULL,
  ship_to_name VARCHAR(100) NOT NULL,
  CONSTRAINT order_t1 PRIMARY KEY(realm_id)
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

CREATE TABLE user_account_t (
  user_id NUMERIC(18),
  status NUMERIC(2) NOT NULL,
  user_type NUMERIC(2) NOT NULL,
  CONSTRAINT user_account_t1 PRIMARY KEY(user_id)
)
/

