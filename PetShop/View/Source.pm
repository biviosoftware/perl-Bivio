# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::View::Source;
use strict;
use Bivio::Base 'View.Base';
b_use('UI.ViewLanguageAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub show_module {
    return shift->internal_body(SourceCode({uri => 'src'}));
}

1;
