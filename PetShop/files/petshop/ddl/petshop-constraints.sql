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
----------------------------------------------------------------

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

--
-- cart_item_t
--
ALTER TABLE cart_item_t
  add constraint cart_item_t2
  check (cart_item_id > 0)
/
ALTER TABLE cart_item_t
  ADD CONSTRAINT cart_item_t3
  FOREIGN KEY (cart_id)
  REFERENCES cart_t(cart_id)
/
ALTER TABLE cart_item_t
  add constraint cart_item_t4
  check (quantity > 0)
/
ALTER TABLE cart_item_t
  add constraint cart_item_t5
  check (unit_price >= 0)
/

--
-- entity_address_t
--
ALTER TABLE entity_address_t
  ADD CONSTRAINT entity_address_t2
  FOREIGN KEY (entity_id)
  REFERENCES entity_t(entity_id)
/
ALTER TABLE entity_address_t
  ADD CONSTRAINT entity_address_t3
  CHECK (location BETWEEN 1 AND 3)
/

--
-- entity_phone_t
--
ALTER TABLE entity_phone_t
  ADD CONSTRAINT entity_phone_t2
  FOREIGN KEY (entity_id)
  REFERENCES entity_t(entity_id)
/
ALTER TABLE entity_phone_t
  ADD CONSTRAINT entity_phone_t3
  CHECK (location BETWEEN 1 AND 3)
/

--
-- inventory_t
--
ALTER TABLE inventory_t
  ADD CONSTRAINT inventory_t2
  FOREIGN KEY (item_id)
  REFERENCES item_t(item_id)
/

--
-- item_t
--
ALTER TABLE item_t
  ADD CONSTRAINT item_t2
  FOREIGN KEY (product_id)
  REFERENCES product_t(product_id)
/
ALTER TABLE item_t
  add constraint item_t3
  check (list_price >= 0)
/
ALTER TABLE item_t
  add constraint item_t4
  check (unit_cost >= 0)
/
ALTER TABLE item_t
  ADD CONSTRAINT item_t5
  FOREIGN KEY (supplier_id)
  REFERENCES supplier_t(supplier_id)
/
ALTER TABLE item_t
  ADD CONSTRAINT item_t6
  CHECK (status BETWEEN 1 AND 2)
/

--
-- order_t
--
ALTER TABLE order_t
  ADD CONSTRAINT order_t2
  FOREIGN KEY (order_id)
  REFERENCES entity_t(entity_id)
/
ALTER TABLE order_t
  ADD CONSTRAINT order_t3
  FOREIGN KEY (cart_id)
  REFERENCES cart_t(cart_id)
/
ALTER TABLE order_t
  ADD CONSTRAINT order_t4
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
ALTER TABLE order_t
  ADD CONSTRAINT order_t5
  CHECK (card_type BETWEEN 1 AND 3)
/

--
-- order_status
--
ALTER TABLE order_status_t
  ADD CONSTRAINT order_status_t2
  FOREIGN KEY (order_id)
  REFERENCES order_t(order_id)
/
ALTER TABLE order_status_t
  ADD CONSTRAINT order_status_t4
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
ALTER TABLE order_status_t
  ADD CONSTRAINT order_status_t5
  CHECK (status BETWEEN 1 AND 2)
/

--
-- product_t
--
ALTER TABLE product_t
  ADD CONSTRAINT product_t2
  FOREIGN KEY (category_id)
  REFERENCES category_t(category_id)
/

--
-- supplier_t
--
ALTER TABLE supplier_t
  ADD CONSTRAINT supplier_t2
  FOREIGN KEY (supplier_id)
  REFERENCES entity_t(entity_id)
/
CREATE UNIQUE INDEX supplier_t3 ON supplier_t (
  name
)
/
ALTER TABLE supplier_t
  ADD CONSTRAINT supplier_t4
  CHECK (status BETWEEN 1 AND 4)
/

--
-- user_account_t
--
ALTER TABLE user_account_t
  ADD CONSTRAINT user_account_t2
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
ALTER TABLE user_account_t
  ADD CONSTRAINT user_account_t3
  FOREIGN KEY (entity_id)
  REFERENCES entity_t(entity_id)
/
ALTER TABLE user_account_t
  ADD CONSTRAINT user_account_t4
  CHECK (status BETWEEN 1 AND 2)
/
ALTER TABLE user_account_t
  ADD CONSTRAINT user_account_t5
  CHECK (user_type BETWEEN 1 AND 2)
/
