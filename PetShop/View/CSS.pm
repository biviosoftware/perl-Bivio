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
td.main_left {
  width: 3em;
}
EOF
}

1;
