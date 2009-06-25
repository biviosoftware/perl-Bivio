# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::BulletinForm;
use strict;
use Bivio::Base 'Model.MailForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RFC) = b_use('Mail.RFC822');
my($_I) = b_use('Mail.Incoming');
my($_O) = b_use('Mail.Outgoing');

sub execute_empty {
    my($self, @args) = @_;
    return _do($self, sub {$self->SUPER::execute_empty(@args)});
}

sub execute_ok {
    my($self, @args) = @_;
    $self->internal_put_field(
	subject => $self->req(qw(Model.RealmMail subject)));
    return _do($self, sub {$self->SUPER::execute_ok(@args)});
}

sub internal_format_from {
    my($self, $realm_email) = @_;
    return $_RFC->format_mailbox(
	$realm_email,
	$self->req(qw(auth_realm owner display_name)),
    );
}

sub internal_format_incoming {
    my($self) = @_;
    my($o) = $_O->new($self->req('Model.RealmMail')->get_rfc822);
    $o->set_header(From => $self->mail_header_from);
    $o->remove_headers(qw(References In-Reply-To Cc));
    $o->map_invoke(set_header => $self->mail_headers);
    return \($o->as_string);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_context => 0,
    });
}

sub internal_return_value {
    return {
	method => 'server_redirect',
    };
}

sub internal_pre_execute {
    my($self) = @_;
    $self->new_other('RealmMail')->load_this_from_request;
    return shift->SUPER::internal_pre_execute(@_);
}

sub validate {
    my($self) = @_;
    foreach my $f (qw(subject body)) {
	$self->internal_clear_error($f);
    }
    return;
}

sub _do {
    my($self, $op) = @_;
    my($req) = $self->req;
    return $req->with_realm(
	$self->new_other('Forum')->get_parent_id,
	sub {
	    $req->throw_die('FORBIDDEN')
		unless $req->can_user_execute_task($req->get('task_id'));
	    return $op->();
	},
    );
}

1;
