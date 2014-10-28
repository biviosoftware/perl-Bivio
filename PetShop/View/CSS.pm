# Copyright (c) 2007-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::View::CSS;
use strict;
use Bivio::Base 'View';
b_use('UI.ViewLanguageAUTOLOAD');


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
td.header_right .task_menu a {
  white-space: nowrap;
}
div.b_source_code_title {
  Font('title');
  margin-bottom: .5ex;
}
div.pet_task_info {
  margin-top: .5ex;
}
If(view_widget_value('is_petshop'),
    vs_petshop_css(),
    vs_groupware_css(),
);
EOF
}

sub site_css {
    my($self) = @_;
    view_unsafe_put(
	is_petshop => ['->ureq', b_use('View.Base')->IS_PETSHOP_KEY],
    );
    return shift->SUPER::site_css(@_);
}

1;
