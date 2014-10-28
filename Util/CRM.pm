# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::CRM;
use strict;
use Bivio::Base 'Bivio.ShellUtil';


sub USAGE {
    return <<'EOF';
usage: b-crm [options] command [args..]
commands
  setup_realm [prefix] [priority]-- sets up tickets for realm
EOF
}

sub setup_realm {
    sub SETUP_REALM {[
	[qw(?prefix Line)],
	[qw(?max_priority NonNegativeInteger 3)],
    ]}
    my($self, $bp) = shift->parameters(\@_);
    $self->initialize_fully;
    $self->new_other('RealmRole')->edit_categories('+feature_crm');
    $self->model('RealmFeatureForm', {mail_want_reply_to => 1});
    $self->model('RowTag')->replace_value(
	MAIL_SUBJECT_PREFIX => b_use('Action.RealmMail')->EMPTY_SUBJECT_PREFIX,
    );
    _prefix($self, $bp->{prefix});
    _priority($self, $bp->{priority});
    return;
}

sub _prefix {
    my($self, $prefix) = @_;
    return
	unless $prefix;
    $self->model('RowTag')->replace_value(
	CRM_SUBJECT_PREFIX => $prefix,
    );
    return;
}

sub _priority {
    my($self, $max_priority) = @_;
    return
	unless $max_priority;
    $self->model('TupleSlotType')->create_from_hash({
	Priority => {
	    type_class => 'TupleSlot',
	    choices => [1 .. $max_priority],
	    default_value => $max_priority,
	},
    });
    $self->model('TupleDef')->create_from_hash({
	'b_ticket#Ticket' => [
	    {
		label => 'Priority',
		type => 'Priority',
		is_required => 1,
	    },
	],
    });
    $self->model('TupleUse')->create_from_label('Ticket');
    return;
}

1;
