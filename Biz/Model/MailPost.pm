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

=for html <a name="dispatch_action"></a>

=head2 dispatch_action(Bivio::Agent::Request req, Bivio::Type::MailTo mailto)

Based on where the mail goes to, execute the necessary
actions.

TODO: BAD: These actions really are part of tasks and copied here!

=cut

sub dispatch_action {
    my($self, $req, $mailto) = @_;
    $self->die('DIE', { message => 'undefined mailto value'})
            unless defined($mailto);
    _trace('mailto=', $mailto) if $_TRACE;
    if( $mailto eq Bivio::Type::MailTo::CLUB() ) {
        Bivio::Biz::Action::ClubMailBoard->execute($req);
        Bivio::Biz::Action::ClubMailMembers->execute($req);
    }
    elsif( $mailto eq Bivio::Type::MailTo::MEMBERS() ) {
        Bivio::Biz::Action::ClubMailMembers->execute($req);
    }
    elsif( $mailto eq Bivio::Type::MailTo::BOARD() ) {
        Bivio::Biz::Action::ClubMailBoard->execute($req);
    }
    elsif( $mailto eq Bivio::Type::MailTo::ADMINISTRATOR() ) {
        Bivio::Biz::Action::ClubMailAdmin->execute($req);
    }
    else {
        $self->die(Bivio::DieCode::CORRUPT_QUERY(), { entity => $mailto,
            message => 'unknown mailto value'});
    }
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

    # Create a mail header and message body from the form input
    if (defined($user)) {
#TODO: Should move into Mail::Message
        $header->add('From', $user->get('display_name')
                .' <'. $user->format_email . '>');
    }
    else {
        $header->add('From', $self->get('from'));
    }
    $header->add('Subject', $self->get('subject'));

    # Write the mail body
    my($body_out) = $msg->get_body->open('w');
    $body_out->print(${$self->get('text')});
    $body_out->close;

    # Allow subclasses to modify header or body
    $self->internal_modify_mail($req, $msg);

    $self->_process_attachments($entity);
    # Get header handle again, might have changed
    $header = $msg->get_head;

    # Add message recipients based on the To: and Cc: form fields
    # Note: The fields were split and validated in validate()
    my($addrs);
    foreach my $field ('to_any', 'cc') {
        $addrs = $fields->{$field};
        next unless defined(@$addrs);
        $header->add($field eq 'to_any' ? 'To' : $field, join(',', @$addrs));
        $msg->add_recipients($addrs);
        $msg->enqueue_send;
    }

    # Dispatch to proper action(s) based on the To: selection
    my($to) = $self->get('to');
    return 0 unless defined($to);

    if ($to == Bivio::Type::MailTo::USER()) {
	# Send to author of the original message
	my($list) = $req->get('Bivio::Biz::Model::MailList');
	$list->set_cursor_or_not_found(0);
	my($mail) = $list->get_model('Mail');
	my($author) = $mail->get('from_email');
	$header->add('To', $author);
	$msg->add_recipients($author);
	$msg->enqueue_send;
	return 0;
    }

    my($realm) = $req->get('auth_realm');
    my($name) = $realm->get('owner_name');
    my($suffix) =  $to->get_long_desc;
    $name .= '-' . $suffix if $suffix;
    $header->add('To', $name);
    if ($realm->get('type') == Bivio::Auth::RealmType::PROXY()) {
        $self->_dispatch_proxy($req, $to);
        return 0;
    }
    $self->dispatch_action($req, $to);
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

=for html <a name="SUBMIT_OK"></a>

=head2 SUBMIT_OK() : 

Returns OK button value.

=cut

sub SUBMIT_OK {
    return ' Send ';
}

=for html <a name="validate"></a>

=head2 validate() : 

Split and validate the To: and Cc: field contents.
Remember the array of addresses for those fields.

Make sure a non-user provides a reasonable From: address

=cut

sub validate {
    my($self) = @_;
    my($req) = $self->get_request;
    # No state maintained across validations
    my($fields) = $self->{$_PACKAGE} = {};

    $self->die('DIE', { message => 'both to and to_any defined'})
            if defined($self->get('to')) && defined($self->get('to_any'));

    # Only allow limited fields for non-users
    my($email, $att);
    unless (defined($req->get('auth_user'))) {
        # Don't allow Cc: or any attachments
        $self->die('DIE', { entity => 'cc',
            message => 'field not allowed as anonymous user'})
                if defined($self->get('cc'));
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

    # 'to_any' and 'cc' can contain list of ,-separated addresses
    my($v, @addr);
    foreach my $field ('to_any', 'cc') {
        $v = $self->get($field);
        next unless defined($v);
        @addr = ();
        foreach my $a (split(/[,]+/, $v)) {
            # Is it a valid address?
            ($email) = Bivio::Mail::Address::parse($a);
            next if defined($email) && push(@addr, $email);
            $self->internal_put_error($field, Bivio::TypeError::EMAIL());
        }
        # Save for use in execute_input()
        $fields->{$field} = [@addr];
    }

    return 0;
}

#=PRIVATE METHODS

# _dispatch_proxy(Bivio::Agent::Request req, Bivio::Type::MailTo to)
#
# Proxies are broken.  We must change the realm, so it gets dispatched to
# the "fake" realm (ask_candis).  Right now we are operating in the
# proxy realm (really, ask_candis_publish).
#
sub _dispatch_proxy {
    my($self, $req, $to) = @_;

    my($real_realm) = $req->get('auth_realm');
    my($fake_realm) = Bivio::Biz::Model::RealmOwner->new($req);
    # This returns the fake realm owner name (ask_candis) from the
    # proxy realm (ask_candis_publish) which causes a *real* realm
    # (ask_candis, aka Ask Candis Inbox) to be loaded.
    $fake_realm->unauth_load_or_die(name => $real_realm->get('owner_name'));
    $req->set_realm(Bivio::Auth::Realm->new($fake_realm));
    $self->dispatch_action($req, $to);
    $req->set_realm($real_realm);
    return;
}

# _process_attachments(MIME::Entity entity)
#
# Create message attachments if att? form fields exist
# The content type is automatically changed to multipart/mixed
#
sub _process_attachments {
    my($self, $entity) = @_;
    my($att, $att_name);
    foreach my $i (1..$_NUM_ATTACHMENTS) {
        $att = $self->get('att'.$i);
        defined($att) || next;
        my($ct) = $att->{content_type} || 'application/octet-stream';
        my($att_name) = $att->{filename}
                || 'file'.$i.'.'.Bivio::MIME::Type->to_extension($ct);
        my($content) = $att->{content};
        my($encoding) = Bivio::MIME::Type->suggest_encoding($ct, $content);
        # Attaching a part will convert message to multipart/mixed
        $entity->attach(Type => $ct, Data => $$content,
                Encoding => $encoding, Filename => $att_name);
    }
    return 0;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
