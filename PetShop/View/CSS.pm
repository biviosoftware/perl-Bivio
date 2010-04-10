# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::View::CSS;
use strict;
use Bivio::Base 'Bivio::UI::View::CSS';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_site_css {
    return shift->SUPER::internal_site_css(@_) . <<'EOF';
body {
  Color('example-background');
}
img {
  border: none;
}
a {
  text-decoration: none;
}
td.main_left {
  width: 3em;
}
td.header_center .task_menu {
  text-align: center;
}
div.b_source_code_title {
  Font('title');
  margin-bottom: .5ex;
}
div.pet_task_info {
  margin-top: .5ex;
}
EOF
}

1;
