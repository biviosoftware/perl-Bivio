# Copyright (c) 2005-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::RealmMail;
use strict;
use Bivio::Base 'Action.RealmMailBase';

my($_O) = b_use('Mail.Outgoing');
my($_A) = b_use('Mail.Address');
my($_T) = b_use('Agent.Task');
my($_MWRT) = b_use('Type.MailWantReplyTo');
my($_RFC) = b_use('Mail.RFC822');
my($_I) = b_use('Mail.Incoming');
my($_M) = b_use('Biz.Model');
my($_BMM) = b_use('Type.BulletinMailMode');
my($_BBT) = b_use('Type.BulletinBodyTemplate');
my($_UA) = b_use('Type.UserAgent');

sub EMAIL_LIST {
    return 'RealmEmailList';
}

sub EMPTY_SUBJECT_PREFIX {
    return '!';
}

sub TASK_URI {
    return '';
}

sub execute_receive {
    my($proto, $req, $rfc822, $reflector_task) = @_;
    $rfc822 ||= $req->get('Model.MailReceiveDispatchForm')
        ->get('message')->{content};
    $reflector_task
        ||= $req->get('task')->get_attr_as_id('mail_reflector_task');
    my($rm) = Bivio::Biz::Model->new($req, 'RealmMail');
    my($in) = $proto->want_realm_mail_created($req)
        ? $rm->create_from_rfc822($rfc822)
        : $_I->new($rfc822);
    my($ea) = $rm->new_other('EmailAlias');
    my($email) = $ea->format_realm_as_incoming;
    my($out) = $_O->new($in)->set_headers_for_list_send({
        req => $req,
        list_email => $email,
        sender => $ea->format_realm_as_sender($email),
        reply_to_list => $proto->want_reply_to($req)
            && $_MWRT->is_set_for_realm($req),
        subject_prefix => $proto->internal_subject_prefix($rm),
    });
    my($attrs) = {
        $proto->package_name => $proto->new({
            outgoing => $out,
            realm_file_id => $rm->unsafe_get('realm_file_id'),
        }),
    };
    if ($_UA->is_mail_agent($req)) {
        $req->put_durable(%$attrs);
        return {
            method => 'server_redirect',
            task_id => $reflector_task,
        };
    }
    b_use('AgentJob.Dispatcher')->enqueue($req, $reflector_task, $attrs);
    return;
}

sub execute_reflector {
    my($proto, $req) = @_;
    my($self) = $req->get($proto->package_name);
    my($out, $rfid) = $self->get(qw(outgoing realm_file_id));
    my($rmb) = $_M->new($req, 'RealmMailBounce');
    my($bulletin) = $_BMM->row_tag_get($req);
    my($muf) = $rmb->new_other('MailUnsubscribeForm');
    my($f);
    $f = ($_A->parse($out->unsafe_get_header('From')))[1]
        if $bulletin;
    $rmb->new_other($self->EMAIL_LIST)->get_recipients(sub {
        my($it) = @_;
        return Bivio::Die->catch(sub {
            my($rp) = $rfid && $rmb->return_path(
                $it->get(qw(RealmUser.user_id Email.email)),
                $rfid,
            );
            my($msg) = $out->new($out)
                ->set_recipients($it->get('Email.email'), $req);
            $msg->set_header(
                'Return-Path' => $_RFC->format_angle_brackets($rp),
            ) if $rp;
            if ($bulletin) {
                $msg->set_header(To => $it->get('Email.email'));
                $msg->set_header(From => $_RFC->format_mailbox($rp, $f));
                $msg->edit_body({
                    email => $it->get('Email.email'),
                    unsubscribe => $req->format_http({
                        uri => $muf->format_uri_for_user(
                            $it->get('RealmOwner.name'),
                            $rfid,
                        ),
                    }),
                }) if $_BBT->row_tag_get($req);
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
