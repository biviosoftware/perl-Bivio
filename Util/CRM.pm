# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::CRM;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: b-crm [options] command [args..]
commands
  setup_realm -- sets +feature_crm and EMPTY_SUBJECT_PREFIX on realm
  setup_realm_with_priority [max_priority] -- set_realm and then create b_ticket with Priority
EOF
}

sub setup_realm {
    my($self) = @_;
    $self->initialize_fully;
    $self->new_other('RealmRole')->edit_categories('+feature_crm');
    $self->model('RealmFeatureForm', {mail_want_reply_to => 1});
    $self->model('RowTag')->replace_value(
	MAIL_SUBJECT_PREFIX => b_use('Action.RealmMail')->EMPTY_SUBJECT_PREFIX,
    );
    return;
}

sub setup_realm_with_priority {
    sub SETUP_REALM_WITH_PRIORITY {[[qw(max_priority PositiveInteger 3)]]}
    my($self, $bp) = shift->parameters(\@_);
    $self->setup_realm;
    $self->model('TupleSlotType')->create_from_hash({
	Priority => {
	    type_class => 'TupleSlot',
	    choices => [1 .. $bp->{max_priority}],
	    default_value => $bp->{max_priority},
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
