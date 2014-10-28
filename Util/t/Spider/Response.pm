# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::t::Spider::Response;
use strict;
use Bivio::Base 'Collection.Attributes';


sub is_success {1}
sub header {shift->get('type')}
sub content_ref {shift->get('content_ref')}

1;
