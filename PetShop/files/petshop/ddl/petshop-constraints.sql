-- Copyright (c) 2001 bivio Inc.  All rights reserved.
-- $Id$
--
-- Constraints & Indexes for PetShop Models
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
--
----------------------------------------------------------------
-- All the primary keys need to be first, so we can use them in
-- FOREIGN KEY constraints.
--
ALTER TABLE cart_t
  ADD constraint cart_t1
  PRIMARY KEY(cart_id)
/
ALTER TABLE cart_item_t
  ADD constraint cart_item_t1
  PRIMARY KEY(cart_id, cart_item_id)
/
ALTER TABLE category_t
  ADD constraint category_t1
  PRIMARY KEY(category_id)
/
ALTER TABLE entity_t
  ADD constraint entity_t1
  PRIMARY KEY(entity_id)
/
ALTER TABLE entity_address_t
  ADD constraint entity_address_t1
  PRIMARY KEY(entity_id, location)
/
ALTER TABLE entity_phone_t
  ADD constraint entity_phone_t1
  PRIMARY KEY(entity_id, location)
/
ALTER TABLE inventory_t
  ADD constraint inventory_t1
  PRIMARY KEY(item_id)
/
ALTER TABLE item_t
  ADD constraint item_t1
  PRIMARY KEY(item_id)
/
ALTER TABLE order_t
  ADD constraint order_t1
  PRIMARY KEY(order_id)
/
ALTER TABLE order_status_t
  ADD constraint order_status_t1
  PRIMARY KEY(order_id)
/
ALTER TABLE product_t
  ADD constraint product_t1
  PRIMARY KEY(product_id)
/
ALTER TABLE supplier_t
  ADD constraint supplier_t1
  PRIMARY KEY(supplier_id)
/
ALTER TABLE user_account_t
  ADD constraint user_account_t1
  PRIMARY KEY(user_id)
/

----------------------------------------------------------------
-- Non-PRIMARY KEY Constraints
----------------------------------------------------------------

--
-- cart_t
--
ALTER TABLE cart_t
  add constraint cart_t2
  check (cart_id > 0)
/
ALTER TABLE cart_t MODIFY creation_date NOT NULL
/

--
-- cart_item_t
--
ALTER TABLE cart_item_t
  add constraint cart_item_t2
  check (cart_item_id > 0)
/
ALTER TABLE cart_item_t MODIFY cart_id NOT NULL
/
ALTER TABLE cart_item_t
  ADD CONSTRAINT cart_item_t3
  FOREIGN KEY (cart_id)
  REFERENCES cart_t(cart_id)
/
ALTER TABLE cart_item_t MODIFY item_id NOT NULL
/
ALTER TABLE cart_item_t MODIFY quantity NOT NULL
/
ALTER TABLE cart_item_t
  add constraint cart_item_t4
  check (quantity > 0)
/
ALTER TABLE cart_item_t MODIFY unit_price NOT NULL
/
ALTER TABLE cart_item_t
  add constraint cart_item_t5
  check (unit_price >= 0)
/

--
-- category_t
--
ALTER TABLE category_t MODIFY name NOT NULL
/
ALTER TABLE category_t MODIFY description NOT NULL
/

--
-- entity_address_t
--
ALTER TABLE entity_address_t MODIFY entity_id NOT NULL
/
ALTER TABLE entity_address_t
  ADD CONSTRAINT entity_address_t2
  FOREIGN KEY (entity_id)
  REFERENCES entity_t(entity_id)
/
ALTER TABLE entity_address_t MODIFY location NOT NULL
/
ALTER TABLE entity_address_t
  ADD CONSTRAINT entity_address_t3
  CHECK (location BETWEEN 1 AND 3)
/

--
-- entity_phone_t
--
ALTER TABLE entity_phone_t MODIFY entity_id NOT NULL
/
ALTER TABLE entity_phone_t
  ADD CONSTRAINT entity_phone_t2
  FOREIGN KEY (entity_id)
  REFERENCES entity_t(entity_id)
/
ALTER TABLE entity_phone_t MODIFY location NOT NULL
/
ALTER TABLE entity_phone_t
  ADD CONSTRAINT entity_phone_t3
  CHECK (location BETWEEN 1 AND 3)
/

--
-- inventory_t
--
ALTER TABLE inventory_t MODIFY item_id NOT NULL
/
ALTER TABLE inventory_t
  ADD CONSTRAINT inventory_t2
  FOREIGN KEY (item_id)
  REFERENCES item_t(item_id)
/

--
-- item_t
--
ALTER TABLE item_t MODIFY product_id NOT NULL
/
ALTER TABLE item_t
  ADD CONSTRAINT item_t2
  FOREIGN KEY (product_id)
  REFERENCES product_t(product_id)
/
ALTER TABLE item_t MODIFY list_price NOT NULL
/
ALTER TABLE item_t
  add constraint item_t3
  check (list_price >= 0)
/
ALTER TABLE item_t MODIFY unit_cost NOT NULL
/
ALTER TABLE item_t
  add constraint item_t4
  check (unit_cost >= 0)
/
ALTER TABLE item_t MODIFY supplier_id NOT NULL
/
ALTER TABLE item_t
  ADD CONSTRAINT item_t5
  FOREIGN KEY (supplier_id)
  REFERENCES supplier_t(supplier_id)
/
ALTER TABLE item_t MODIFY status NOT NULL
/
ALTER TABLE item_t
  ADD CONSTRAINT item_t6
  CHECK (status BETWEEN 1 AND 2)
/
ALTER TABLE item_t MODIFY attr1 NOT NULL
/

--
-- order_t
--
ALTER TABLE order_t MODIFY order_id NOT NULL
/
ALTER TABLE order_t
  ADD CONSTRAINT order_t2
  FOREIGN KEY (order_id)
  REFERENCES entity_t(entity_id)
/
ALTER TABLE order_t MODIFY cart_id NOT NULL
/
ALTER TABLE order_t
  ADD CONSTRAINT order_t3
  FOREIGN KEY (cart_id)
  REFERENCES cart_t(cart_id)
/
ALTER TABLE order_t MODIFY user_id NOT NULL
/
ALTER TABLE order_t
  ADD CONSTRAINT order_t4
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
ALTER TABLE order_t MODIFY order_date NOT NULL
/
ALTER TABLE order_t MODIFY courier NOT NULL
/
ALTER TABLE order_t MODIFY total_price NOT NULL
/
ALTER TABLE order_t MODIFY bill_to_first_name NOT NULL
/
ALTER TABLE order_t MODIFY bill_to_last_name NOT NULL
/
ALTER TABLE order_t MODIFY ship_to_first_name NOT NULL
/
ALTER TABLE order_t MODIFY ship_to_last_name NOT NULL
/
ALTER TABLE order_t MODIFY credit_card NOT NULL
/
ALTER TABLE order_t MODIFY expiration_date NOT NULL
/
ALTER TABLE order_t MODIFY card_type NOT NULL
/
ALTER TABLE order_t
  ADD CONSTRAINT order_t5
  CHECK (card_type BETWEEN 1 AND 3)
/

--
-- order_status
--
ALTER TABLE order_status_t MODIFY order_id NOT NULL
/
ALTER TABLE order_status_t
  ADD CONSTRAINT order_status_t2
  FOREIGN KEY (order_id)
  REFERENCES order_t(order_id)
/
ALTER TABLE order_status_t MODIFY user_id NOT NULL
/
ALTER TABLE order_status_t
  ADD CONSTRAINT order_status_t4
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
ALTER TABLE order_status_t MODIFY time_stamp NOT NULL
/
ALTER TABLE order_status_t MODIFY status NOT NULL
/
ALTER TABLE order_status_t
  ADD CONSTRAINT order_status_t5
  CHECK (status BETWEEN 1 AND 2)
/

--
-- product_t
--
ALTER TABLE product_t MODIFY category_id NOT NULL
/
ALTER TABLE product_t
  ADD CONSTRAINT product_t2
  FOREIGN KEY (category_id)
  REFERENCES category_t(category_id)
/
ALTER TABLE product_t MODIFY name NOT NULL
/
ALTER TABLE product_t MODIFY image_name NOT NULL
/
ALTER TABLE product_t MODIFY description NOT NULL
/

--
-- supplier_t
--
ALTER TABLE supplier_t MODIFY supplier_id NOT NULL
/
ALTER TABLE supplier_t
  ADD CONSTRAINT supplier_t2
  FOREIGN KEY (supplier_id)
  REFERENCES entity_t(entity_id)
/
ALTER TABLE supplier_t MODIFY name NOT NULL
/
CREATE UNIQUE INDEX supplier_t3 ON supplier_t (
  name
)
/
ALTER TABLE supplier_t MODIFY status NOT NULL
/
ALTER TABLE supplier_t
  ADD CONSTRAINT supplier_t4
  CHECK (status BETWEEN 1 AND 4)
/

--
-- user_account_t
--
ALTER TABLE user_account_t MODIFY user_id NOT NULL
/
ALTER TABLE user_account_t
  ADD CONSTRAINT user_account_t2
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
ALTER TABLE user_account_t MODIFY entity_id NOT NULL
/
ALTER TABLE user_account_t
  ADD CONSTRAINT user_account_t3
  FOREIGN KEY (entity_id)
  REFERENCES entity_t(entity_id)
/
ALTER TABLE user_account_t MODIFY status NOT NULL
/
ALTER TABLE user_account_t
  ADD CONSTRAINT user_account_t4
  CHECK (status BETWEEN 1 AND 2)
/
ALTER TABLE user_account_t MODIFY user_type NOT NULL
/
ALTER TABLE user_account_t
  ADD CONSTRAINT user_account_t5
  CHECK (user_type BETWEEN 1 AND 2)
/
