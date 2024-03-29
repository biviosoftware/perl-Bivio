# Copyright (c) 2008 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Util::TestCRM;
use strict;
use Bivio::Base 'ShellUtil.SQL';

my($_DT) = b_use('Type.DateTime');
my($_EA) = b_use('Type.EmailArray');
my($_CTS) = b_use('Type.CRMThreadStatus');

sub create_thread {
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
        attachment3 => undef,
        crm_thread_status => $self->type(CRMThreadStatus => 'NEW'),
        owner_user_id => undef,
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

sub update_thread {
    my($self, $args, $thread_id) = @_;
    my($req) = $self->req;
    $thread_id ||= $self->req(qw(Model.CRMThread thread_root_id));
    foreach my $m (map($req->unsafe_get($_),
                       qw(Model.CRMThread Model.RealmMail))) {
        $m->delete_from_request
            if defined($m);
    }
    $req->put(query => {this => $thread_id});
    my($m) = $self->model('CRMForm');
    $m->process;
    my($x) = $m->get_visible_field_names;
    $self->model(CRMForm => {
        map(($_ => $m->unsafe_get($_)), @$x),
        to => $self->type(EmailArray => $req->get('auth_realm')->format_email),
        cc => $self->type(EmailArray => ''),
        body => b_use('Biz.Random')->string,
        attachment1 => undef,
        attachment2 => undef,
        attachment3 => undef,
        action_id => -$self->type(CRMThreadStatus => 'OPEN')->as_int,
        %$args,
    });
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
        $self->new_other('CRM')->setup_realm(undef, undef);
        if ($forum eq 'CRM_FORUM') {
            my($last_alias);
            foreach my $name (qw(acrm crm)) {
                $self->model('EmailAlias')->create({
                    incoming => $last_alias = $self->req->format_email($name),
                    outgoing => $self->req(qw(auth_realm owner name)),
                });
            }
            $self->model('RowTag')->create_value(
                $self->req('auth_id'), 'CANONICAL_EMAIL_ALIAS',
                $last_alias);
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
                        is_required => 1,
                    },
                    {
                        label => 'Deadline',
                        type => 'Date',
                    },
                ],
            });
            $self->model('TupleUse')->create_from_label('Ticket');
            # Left out on purpose.  Good test for UI checking for Select()
            # See View.CRM->thread_root_list
            # CRMQueryForm,Priority
            $self->realm_file_create('/Settings/TupleTag.csv', <<'EOF');
Model,b_ticket
CRMThreadRootList,Priority
CRMForm,
,Product;Priority;Deadline;
EOF
        }
    }
    return;
}

sub _init_bunit {
    my($self) = @_;
    $self->top_level_forum(
        'crm_tuple_bunit',
        [$self->CRM_TECH(1)], [$self->CRM_TECH(2)],
    );
    $self->new_other('CRM')->setup_realm(undef, undef);
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
                $self->create_thread({
                    'b_ticket.TupleTag.slot1' => $priority,
                });
            }
        }
    }
    $_DT->set_test_now(undef, $req);
    return;
}

1;
