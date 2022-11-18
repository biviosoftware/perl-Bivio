# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SearchForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';


sub CLEAR_ON_FOCUS_HINT {
    return 'Search';
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        visible => [
            {
                name => 'ok_button',
                type => 'OKButton',
                form_name => 'b_ok',
            },
        ],
    });
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
