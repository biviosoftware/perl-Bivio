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
-- cart_item_t
--
ALTER TABLE cart_item_t
  ADD CONSTRAINT cart_item_t2
  FOREIGN KEY (cart_id)
  REFERENCES cart_t(cart_id)
/
CREATE INDEX cart_item_t3 on cart_item_t (
  cart_id
)
/
ALTER TABLE cart_item_t
  ADD CONSTRAINT cart_item_t4
  FOREIGN KEY (item_id)
  REFERENCES item_t(item_id)
/
CREATE INDEX cart_item_t5 on cart_item_t (
  item_id
)
/
ALTER TABLE cart_item_t
  add constraint cart_item_t6
  check (quantity > 0)
/
ALTER TABLE cart_item_t
  add constraint cart_item_t7
  check (unit_price >= 0)
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
CREATE INDEX item_t3 on item_t (
  product_id
)
/
ALTER TABLE item_t
  add constraint item_t4
  check (list_price >= 0)
/
ALTER TABLE item_t
  add constraint item_t5
  check (unit_cost >= 0)
/

--
-- order_t
--
ALTER TABLE order_t
  add constraint order_t2
  foreign key (realm_id)
  references realm_owner_t(realm_id)
/
ALTER TABLE order_t
  ADD CONSTRAINT order_t3
  FOREIGN KEY (cart_id)
  REFERENCES cart_t(cart_id)
/
CREATE INDEX order_t4 on order_t (
  cart_id
)
/
ALTER TABLE order_t
  add constraint order_t5
  foreign key (ec_payment_id)
  references ec_payment_t(ec_payment_id)
/
CREATE INDEX order_t6 on order_t (
  ec_payment_id
)
/

--
-- product_t
--
ALTER TABLE product_t
  ADD CONSTRAINT product_t2
  FOREIGN KEY (category_id)
  REFERENCES category_t(category_id)
/
CREATE INDEX product_t3 on product_t (
  category_id
)
/

--
-- user_account_t
--
ALTER TABLE user_account_t
  ADD CONSTRAINT user_account_t2
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
