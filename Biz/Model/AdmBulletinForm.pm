# Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::AdmBulletinForm;
use strict;
$Bivio::Biz::Model::AdmBulletinForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::AdmBulletinForm::VERSION;

=head1 NAME

Bivio::Biz::Model::AdmBulletinForm - create site bulletin

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::AdmBulletinForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::AdmBulletinForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::AdmBulletinForm>

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Die;
use Bivio::IO::ClassLoader;
use Bivio::IO::File;
use Bivio::UI::Facade;
use Bivio::Biz::Action::AdmMailBulletin;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Sets confirmed to false.

=cut

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field(confirmed_bulletin => 0);
    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Goes to the confirmation page if not confirmed.

Saves the bulletin to the database and starts a background job to
send the bulletin to the brokers.

=cut

sub execute_ok {
    my($self) = @_;
    $self->get_request->server_redirect(
        Bivio::Agent::TaskId->ADM_CREATE_BULLETIN_CONFIRM)
        unless $self->get('confirmed_bulletin') || $self->get('test_mode');
    my($bulletin) = $self->internal_create_bulletin;
    # send the email in a background task
    Bivio::IO::ClassLoader->simple_require(
        'Bivio::Agent::Job::Dispatcher');
    Bivio::Agent::Job::Dispatcher->enqueue($self->get_request,
        'ADM_MAIL_BULLETIN', {
            Bivio::Biz::Action::AdmMailBulletin->BULLETIN_ID_KEY =>
                $bulletin->get('bulletin_id'),
            Bivio::Biz::Action::AdmMailBulletin->TEST_MODE =>
                $self->get('test_mode'),
        });

    # return to the confirmation page if test_mode
    $self->get_request->server_redirect(
        Bivio::Agent::TaskId->ADM_CREATE_BULLETIN_CONFIRM)
        if $self->get('test_mode');
    return;
}

=for html <a name="execute_other"></a>

=head2 execute_other()

Responds to the attachment_button and saves the file to the cache
directory.

=cut

sub execute_other {
    my($self) = @_;
    $self->clear_errors;
    $self->internal_stay_on_page;
    _save_attachments($self);
    return;
}

=for html <a name="execute_unwind"></a>

=head2 execute_unwind()

Return from the confirmation page, save the bulletin info and start mail job.

=cut

sub execute_unwind {
    my($self) = @_;

    if ($self->get('confirmed_bulletin') || $self->get('test_mode')) {
	$self->execute_ok;
	$self->internal_redirect_next;
	# DOES NOT RETURN
    }
    return;
}

=for html <a name="internal_create_bulletin"></a>

=head2 internal_create_bulletin() : Bivio::Biz::Model::Bulletin

Creates the Bulletin model and copies the attachments.

=cut

sub internal_create_bulletin {
    my($self) = @_;
    my($bulletin) = $self->new_other('Bulletin')->create({
        body => ${$self->read_body},
        body_content_type => $self->get('body_content_type'),
        %{$self->get_model_properties('Bulletin')},
    });
    _copy_attachments($self, $bulletin->get('bulletin_id'))
        if $self->get('attachment_files');
    return $bulletin;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	version => 2,
	visible => [
            'Bulletin.subject',
	    {
		name => 'body',
		type => 'FileField',
		constraint => 'NONE',
	    },
            {
                name => 'body_button',
                type => 'FormButton',
                constraint => 'NONE',
            },
	    {
		name => 'attachment',
		type => 'FileField',
		constraint => 'NONE',
	    },
            {
                name => 'attachment_button',
                type => 'FormButton',
                constraint => 'NONE',
            },
	],
	hidden => [
            {
                name => 'body_content_type',
                type => 'String',
                constraint => 'NONE',
            },
            {
                name => 'body_file',
                type => 'String',
                constraint => 'NONE',
            },
            {
                name => 'attachment_files',
                type => 'String',
                constraint => 'NONE',
            },
	    {
		name => 'confirmed_bulletin',
		type => 'Boolean',
	        constraint => 'NOT_NULL',
	    },
            {
                name => 'test_mode',
                type => 'Boolean',
                constraint => 'NONE',
            },
	],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

=for html <a name="read_body"></a>

=head2 read_body() : string_ref

=head2 static read_body(string body_file) : string_ref

Returns the current message body.

=cut

sub read_body {
    my($self, $body_file) = @_;
    return Bivio::IO::File->read(Bivio::UI::Facade->get_local_file_name(
        Bivio::UI::LocalFileType->CACHE, 'bulletin/'
        . ($body_file || $self->get('body_file'))));
}

=for html <a name="validate"></a>

=head2 validate()

Ensure the message body exists.

=cut

sub validate {
    my($self) = @_;
    _save_attachments($self);
    $self->internal_put_error(body => 'NULL')
        unless $self->get('body_file') || $self->get('body');
    return;
}

#=PRIVATE SUBROUTINES

# _append_field(self, string field, string value)
#
# Appends the value to the named field.
#
sub _append_field {
    my($self, $field, $value) = @_;
    $self->internal_put_field($field =>
        ($self->get($field) ? $self->get($field) . "\t" : '')
        . $value);
    return;
}

# _copy_attachments(self, string bulletin_id)
#
# Copy attachments to the REALM_DATA file space.
#
sub _copy_attachments {
    my($self, $bulletin_id) = @_;

    foreach my $file (split("\t", $self->get('attachment_files'))) {
        _write_file($self, Bivio::UI::Facade->get_local_file_name(
            Bivio::UI::LocalFileType->REALM_DATA, 'bulletin/'
            . $bulletin_id . '/' . $file),
            Bivio::IO::File->read(Bivio::UI::Facade->get_local_file_name(
                Bivio::UI::LocalFileType->CACHE, 'bulletin/' . $file)));
    }
    return;
}

# _save_attachments(self)
#
# Stores body file and attachments in the cache directory
# until bulletin is created during execute_ok().
#
sub _save_attachments {
    my($self) = @_;

    if ($self->get('body')) {
        my($content_type) = lc($self->get('body')->{content_type});

        # MSIE always uploads with application/octet-stream...
        if ($content_type =~ /application/) {
            $content_type = Bivio::MIME::Type->from_extension(
                $self->get('body')->{filename});
        }

        unless ($content_type eq 'text/plain'
            || $content_type eq 'text/html') {
            $self->internal_put_error(body => 'INVALID_MESSAGE_BODY');
            return;
        }
        $self->internal_put_field(body_content_type => $content_type);
        $self->internal_put_field(body_file =>
            _write_cache_file($self, 'body'));
    }

    if ($self->get('attachment')) {
        _append_field($self, 'attachment_files',
            _write_cache_file($self, 'attachment'));
    }
    return;
}

# _write_cache_file(self, string field) : string
#
# Writes the contents of the specified file field into the cache directory.
# Returns the full path of the file.
#
sub _write_cache_file {
    my($self, $field) = @_;
    # fixup the filename, removing directories
    $self->get($field)->{filename} =~ s/^.*?([^\\\/]+)$/$1/;
    my($name) = Bivio::Type::DateTime->local_now_as_file_name
        . "-$$-" . $self->get($field)->{filename};
    my($file) = Bivio::UI::Facade->get_local_file_name(
        Bivio::UI::LocalFileType->CACHE, 'bulletin/' . $name);
    _write_file($self, $file, $self->get($field)->{content});
    return $name;
}

# _write_file(self, string file, string_ref content)
#
# Writes the contents to the named file.
#
sub _write_file {
    my($self, $file, $content) = @_;
    Bivio::IO::File->mkdir_parent_only($file, 02770);
    Bivio::IO::File->write($file, $content);
    return;
}

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
