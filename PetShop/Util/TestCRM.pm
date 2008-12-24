# Copyright (c) 2008 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Util::TestCRM;
use strict;
use Bivio::Base 'ShellUtil.SQL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_EA) = b_use('Type.EmailArray');
my($_CTS) = b_use('Type.CRMThreadStatus');

sub create_ticket_and_thread {
    my($self, $args) = @_;
    my($req) = $self->req;
    foreach my $m (map($req->unsafe_get($_),
                       qw(Model.CRMThread Model.RealmMail))) {
        $m->delete_from_request
            if defined($m);
    }
    $self->model(CRMForm => {
        to => $self->type(EmailArray => $req->get('auth_realm')
                              ->format_email),
        cc => $self->type(EmailArray => ''),
        subject => b_use('Biz.Random')->string,
        body => b_use('Biz.Random')->string,
        attachment1 => undef,
        attachment2 => undef,
        action_id => -$self->type(CRMThreadStatus => 'NEW')->as_int,
        attachment3 => undef,
        %$args,
    });
    return;
}

sub init {
    my($self) = @_;
    $self->initialize_fully;
    _init_bunit($self);
    _init_btest($self);
    return;
}

sub _init_btest {
    my($self) = @_;
    foreach my $forum (qw(CRM_TUPLE_FORUM CRM_FORUM)) {
	$self->top_level_forum(
	    $self->$forum(),
	    [$self->CRM_TECH(1)], [$self->CRM_TECH(2)],
	);
	$self->req->with_realm($self->CRM_TECH(1), sub {
	    $self->model('Email')->create({
		location => $self->use('Type.Location')->BILL_TO,
		email => $self->format_test_email($self->CRM_TECH(1) . 'a'),
	    });
	    return;
	}) if $forum eq 'CRM_TUPLE_FORUM';
	$self->new_other('CRM')->setup_realm;
	if ($forum eq 'CRM_FORUM') {
	    my($alias);
	    foreach my $a (qw(acrm crm)) {
		$self->model('EmailAlias')->create({
		    incoming => $alias = $self->use('TestLanguage.HTTP')
			    ->generate_remote_email($a),
		    outgoing => $self->req(qw(auth_realm owner name)),
		});
	    }
	    $self->model('RowTag')->create_value(
		$self->req('auth_id'), 'CANONICAL_EMAIL_ALIAS',
		$alias);
	    $self->req(qw(auth_realm owner))->update({
		display_name => 'PetShop Support',
	    });
	}
	elsif ($forum eq 'CRM_TUPLE_FORUM') {
	    $self->model('TupleSlotType')->create_from_hash({
		Priority => {
		    type_class => 'TupleSlot',
		    choices => [qw(Low Medium High)],
		    default_value => 'Low',
		},
	    });
	    $self->model('RowTag')->create_value(
		$self->req('auth_id'), 'CRM_SUBJECT_PREFIX', 'tuple');
	    $self->model('TupleDef')->create_from_hash({
		'b_ticket#Ticket' => [
		    {
			label => 'Product',
			type => 'String',
		    },
		    {
			label => 'Priority',
			type => 'Priority',
		    },
		],
	    });
	    $self->model('TupleUse')->create_from_label('Ticket');
	}
    }
    return;
}

sub _init_bunit {
    my($self) = @_;
    $self->top_level_forum('crm_tuple_bunit',
                           [$self->CRM_TECH(1)], [$self->CRM_TECH(2)]);
    $self->new_other('CRM')->setup_realm;
    $self->model('TupleDef')->create_from_hash({
        'b_ticket#Ticket' => [
            {
                label => 'Priority',
                type => 'Integer',
            },
        ],
    });
    $self->model('TupleUse')->create_from_label('Ticket');

    my($t) = $_DT->from_literal_or_die('10/10/2008 10:10:10');
    my($req) = $self->req;
    $req->initialize_fully('FORUM_CRM_FORM');
    foreach my $month (0..2) {
        $_DT->set_test_now($t, $req);
        $t = $_DT->add_days($t, -31);
        foreach my $priority (1..3) {
            foreach my $n (1..(2**$priority - $month)) {
                $self->create_ticket_and_thread({
                    'b_ticket.TupleTag.slot1' => $priority,
                });
            }
        }
    }
    $_DT->set_test_now(undef, $req);
    return;
}

1;
