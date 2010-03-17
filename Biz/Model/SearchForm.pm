# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SearchForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CLEAR_ON_FOCUS_HINT {
    return 'Search';
}

sub internal_query_fields {
    my($self) = @_;
    return [
	[qw(search Line), {
	    form_name => b_use('SQL.ListQuery')->to_char('search'),
	}],
	[qw(b_realm_only NullBoolean)],
    ];
}

1;
