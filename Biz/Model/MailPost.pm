# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MailPost;
use strict;
$Bivio::MailPost::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::MailPost - base class for posting messages via a form

=head1 SYNOPSIS

    use Bivio::Biz::Model::MailPost;
    Bivio::Biz::Model::MailPost->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::MailPost::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MailPost>

=cut

#=IMPORTS
use Bivio::Mail::Message;
use Bivio::Util;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;

# Allow up to 3 attachments
my($_NUM_ATTACHMENTS) = 3;

=head1 METHODS

=cut

=for html <a name="SUBMIT_OK"></a>

=head2 SUBMIT_OK() : 

Returns OK button value.

=cut

sub SUBMIT_OK {
    return ' Send ';
}

=for html <a name="execute_input"></a>

=head2 execute_input() : 

Handles posting a mail message

=cut

sub execute_input {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($req) = $self->get_request;
    my($user) = $req->get('auth_user');

    my($msg) = Bivio::Mail::Message->new;
    $msg->create_message_id($req);
    $req->put(mail => $msg);
    my($entity) = $msg->get_entity;
    my($header) = $msg->get_head;
    my($body) = $msg->get_body;

    # Create a mail message from the form input
    $header->add('From',
            defined($user) ? $user->format_email : $self->get('from'));
    $header->add('Subject', $self->get('subject'));

    # Write the mail body
    my($body_out) = $body->open('w');
    $body_out->print(${$self->get('text')});
    $body_out->close;

    # Allow subclasses to modify header or body
    $self->internal_modify_mail($req, $msg);

    my($att, $att_name);
    # Handle a number of attachments
    foreach my $i (1..$_NUM_ATTACHMENTS) {
        $att = $self->get('att'.$i);
        defined($att) || next;
        # Don't allow attachments for non-users
        defined($user)
                || $self->internal_put_error($att, Bivio::TypeError::EMAIL());

        my($ct) = $att->{content_type} || 'application/octet-stream';
        my($att_name) = $att->{filename}
                || 'file'.$i.'.'.Bivio::MIME::Type->to_extension($ct);
        my($content) = $att->{content};
        my($encoding) = Bivio::MIME::Type->suggest_encoding($ct, $content);
        # Attaching a part will convert message to multipart/mixed
        $entity->attach(Type => $ct, Data => $$content,
                Encoding => $encoding, Name => $att_name);
    }

    # Add message recipients based on the To: and Cc: form fields
    # Note: The fields were split and validated in validate()
    my($addrs);
    foreach my $field ('to_any', 'cc') {
        $addrs = $fields->{$field};
        next unless defined(@$addrs);
        $header->add($field, join(',', @$addrs));
        $msg->add_recipients($addrs);
        $msg->enqueue_send;
    }

    # Dispatch to proper action(s) based on the To: selection
    my($to) = $self->get('to');
    if (defined($to)) {
        if ( $to == Bivio::Type::MailTo::USER()) {
            # Send to author of the original message
            my($list) = $req->get('Bivio::Biz::Model::MailList');
            $list->set_cursor_or_not_found(0);
            my($mail) = $list->get_model('Mail');
            $msg->add_recipients($mail->get('from_email'));
            $msg->enqueue_send;
       }
        else {
            Bivio::Biz::Model::MailReceiveForm->dispatch($req, $to);
        }
    }
    return 0;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

Describe the form fields available to build the post forms

=cut

sub internal_initialize {
    my($fields) = {
	version => 1,
	visible => [
	    {
		name => 'from',
		type => 'Line',
		constraint => 'NONE',
	    },
	    {
		name => 'to',
		type => 'MailTo',
		constraint => 'NONE',
	    },
	    {
		name => 'to_any',
		type => 'Line',
		constraint => 'NONE',
	    },
 	    {
		name => 'cc',
		type => 'Line',
		constraint => 'NONE',
	    },
	    {
		name => 'subject',
		type => 'Line',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'text',
		type => 'BLOB',
		constraint => 'NONE',
	    },
	],
    };
    for my $i (1..$_NUM_ATTACHMENTS) {
        push(@{$fields->{visible}}, {
            name => 'att'.$i, type => 'FileField', constraint => 'NONE'});
    }
    return $fields;
}

=for html <a name="internal_modify_mail"></a>

=head2 internal_modify_mail() : 

No-op for base class

=cut

sub internal_modify_mail {
    my($self) = @_;
    return 0;
}

=for html <a name="validate"></a>

=head2 validate() : 

Do extra validation on the Cc: field contents.
Remember the array of Cc: addresses for use in execute_input

Make sure a non-user provides a reasonable From: address

=cut

sub validate {
    my($self) = @_;
    my($req) = $self->get_request;
    # No state maintained across validations
    my($fields) = $self->{$_PACKAGE} = {};

    my($email, $v, @addr, $att);
    foreach my $field ('to_any', 'cc') {
        $v = $self->get($field);
        next unless defined($v);
        @addr = ();
        foreach my $a (split(/[;,]+/, $v)) {
            # Is it a valid address?
            ($email) = Bivio::Mail::Address::parse($a);
            next if defined($email) && push(@addr, $email);
            $self->internal_put_error($field, Bivio::TypeError::EMAIL());
            return 0;
        }
        # Save for use in execute_input()
        $fields->{$field} = [@addr];
    }

    # Enforce limited interface for non-users
    unless (defined($req->get('auth_user'))) {
        # Don't allow any attachments
        foreach my $i (1..$_NUM_ATTACHMENTS) {
            $att = $self->get('att'.$i);
            $self->die('DIE', { entity => $att,
                message => 'field not allowed as anonymous user'})
                    if defined($att);
        }

        # Require a "valid" From: address if not a registered user
        my($from) = $self->get('from');
        if (defined($from)) {
            ($email) = Bivio::Mail::Address::parse($from);
            $self->internal_put_error('from', Bivio::TypeError::EMAIL())
                    unless defined($email);
        }
        else {
            $self->internal_put_error('from', Bivio::TypeError::NULL());
        }
    }
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
