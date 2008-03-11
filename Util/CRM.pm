# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::CRM;
use strict;
use Bivio::Base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: b-crm [options] command [args..]
commands
  setup_realm -- sets +feature_crm and EMPTY_SUBJECT_PREFIX on realm
EOF
}

sub setup_realm {
    my($self) = @_;
    $self->new_other('RealmRole')->edit_categories('+feature_crm');
    $self->model('RowTag')->replace_value(
	$self->req('auth_id'), 'MAIL_SUBJECT_PREFIX',
	$self->use('Action.RealmMail')->EMPTY_SUBJECT_PREFIX,
    );
    return;
}

1;
