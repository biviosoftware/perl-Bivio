# Copyright (c) 2005-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::RealmMail;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_O) = __PACKAGE__->use('Mail.Outgoing');
my($_A) = b_use('Mail.Address');
my($_T) = b_use('Agent.Task');
my($_WRT) = b_use('Type.WantReplyTo');
my($_RFC) = b_use('Mail.RFC822');

sub EMPTY_SUBJECT_PREFIX {
    return '!';
}

sub execute_receive {
    my($proto, $req, $rfc822, $reflector_task) = @_;
    $rfc822 ||= $req->get('Model.MailReceiveDispatchForm')
	->get('message')->{content};
    my($rm) = Bivio::Biz::Model->new($req, 'RealmMail');
    my($in) = $rm->create_from_rfc822($rfc822);
    my($ea) = $rm->new_other('EmailAlias');
    my($email) = $ea->format_realm_as_incoming;
    my($out) = $_O->new($in)->set_headers_for_list_send({
	list_email => $email,
	sender => $ea->format_realm_as_sender($email),
	reply_to_list => $_WRT->is_set_for_realm($req),
#TODO: This should be configurable
	keep_to_cc => 1,
	subject_prefix => $proto->internal_subject_prefix($rm),
	req => $req,
    });
    $proto->use('AgentJob.Dispatcher')->enqueue(
	$req,
	$reflector_task
	    || $req->get('task')->get_attr_as_id('mail_reflector_task'),
	{
	    $proto->package_name => $proto->new({
		outgoing => $out,
		realm_file_id => $rm->get('realm_file_id'),
	    }),
	},
    );
    return;
}

sub execute_reflector {
    my($proto, $req) = @_;
    my($self) = $req->get($proto->package_name);
    my($out, $rfid) = $self->get(qw(outgoing realm_file_id));
    my($rmb) = Bivio::Biz::Model->new($req, 'RealmMailBounce');
    my($bulletin) = $rmb->new_other('RowTag')->get_value(
        $req->get('auth_id'), 'BULLETIN_MAIL_MODE');
    my $f = ($_A->parse($out->unsafe_get_header('From')))[1]
	if $bulletin;
    $rmb->new_other('RealmEmailList')->get_recipients(sub {
	my($it) = @_;
	return Bivio::Die->catch(sub {
	    my($rp) = $rmb->return_path(
	        $it->get(qw(RealmUser.user_id Email.email)),
	        $rfid,
	    );
	    my($msg) = $out->new($out)
		->set_recipients($it->get('Email.email'), $req)
		->set_header('Return-Path' =>
		    $_RFC->format_angle_brackets($rp));
	    if ($bulletin) {
		$msg->set_header(To => $it->get('Email.email'));
		$msg->set_header(From => $_RFC->format_mailbox($rp, $f));
	    }
            $msg->send($req);
        });
    });
    return;
}

sub internal_subject_prefix {
    my($proto, $rm) = @_;
    return '[' . $rm->req(qw(auth_realm owner name)) . ']'
	unless defined(my $res = $rm->new_other('RowTag')->get_value(
	    $rm->req('auth_id'), 'MAIL_SUBJECT_PREFIX',
	));
    return ''
	if $res eq $proto->EMPTY_SUBJECT_PREFIX;
    $res .= ' '
	unless $res =~ /\s$/s;
    return $res;
}

1;
