# Copyright (c) 2003-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::AdmBulletinForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_T) = b_use('MIME.Type');
my($_IOF) = b_use('IO.File');
my($_LFT) = b_use('UI.LocalFileType');
my($_DT) = b_use('Type.DateTime');
my($_UIF) = b_use('UI.Facade');

sub execute_empty {
    # (self) : undef
    # Sets confirmed to false.
    my($self) = @_;
    $self->internal_put_field(confirmed_bulletin => 0);
    return;
}

sub execute_ok {
    my($self) = @_;
    return {
	method => 'server_redirect',
	task_id => 'ADM_CREATE_BULLETIN_CONFIRM',
	query => undef,
    } unless $self->get('confirmed_bulletin') || $self->get('test_mode');
    my($bulletin) = $self->internal_create_bulletin;
    b_use('AgentJob.Dispatcher')->enqueue($self->get_request,
        'ADM_MAIL_BULLETIN', {
            b_use('Action.AdmMailBulletin')->BULLETIN_ID_KEY =>
                $bulletin->get('bulletin_id'),
            b_use('Action.AdmMailBulletin')->TEST_MODE =>
                $self->get('test_mode'),
        });
    return {
	method => 'server_redirect',
	task_id => 'ADM_CREATE_BULLETIN_CONFIRM',
	query => undef,
    } if $self->get('test_mode');
    return;
}

sub execute_other {
    # (self) : undef
    # Responds to the attachment_button and saves the file to the cache
    # directory.
    my($self) = @_;
    $self->clear_errors;
    $self->internal_stay_on_page;
    _save_attachments($self);
    return;
}

sub execute_unwind {
    # (self) : undef
    # Return from the confirmation page, save the bulletin info and start mail job.
    my($self) = @_;

    if ($self->get('confirmed_bulletin') || $self->get('test_mode')) {
	$self->execute_ok;
	$self->internal_redirect_next;
	# DOES NOT RETURN
    }
    return;
}

sub internal_create_bulletin {
    # (self) : Model.Bulletin
    # Creates the Bulletin model and copies the attachments.
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

sub internal_initialize {
    # (self) : hash_ref;
    # B<FOR INTERNAL USE ONLY>
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

sub read_body {
    # (self) : string_ref
    # (proto, string) : string_ref
    # Returns the current message body.
    my($self, $body_file) = @_;
    return $_IOF->read($_UIF->get_local_file_name(
	$_LFT->CACHE, 'bulletin/' . ($body_file || $self->get('body_file'))));
}

sub validate {
    # (self) : undef
    # Ensure the message body exists.
    my($self) = @_;
    _save_attachments($self);
    $self->internal_put_error(body => 'NULL')
        unless $self->get('body_file') || $self->get('body');
    return;
}

sub _append_field {
    # (self, string, string) : undef
    # Appends the value to the named field.
    my($self, $field, $value) = @_;
    $self->internal_put_field($field =>
        ($self->get($field) ? $self->get($field) . "\t" : '')
        . $value);
    return;
}

sub _copy_attachments {
    # (self, string) : undef
    # Copy attachments to the REALM_DATA file space.
    my($self, $bulletin_id) = @_;

    foreach my $file (split("\t", $self->get('attachment_files'))) {
        _write_file($self, $_UIF->get_local_file_name(
            $_LFT->REALM_DATA, 'bulletin/'
            . $bulletin_id . '/' . $file),
            $_IOF->read($_UIF->get_local_file_name(
                $_LFT->CACHE, 'bulletin/' . $file)));
    }
    return;
}

sub _save_attachments {
    # (self) : undef
    # Stores body file and attachments in the cache directory
    # until bulletin is created during execute_ok().
    my($self) = @_;

    if ($self->get('body')) {
        my($content_type) = lc($self->get('body')->{content_type});

        # MSIE always uploads with application/octet-stream...
        if ($content_type =~ /application/) {
            $content_type = $_T->from_extension($self->get('body')->{filename});
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

sub _write_cache_file {
    # (self, string) : string
    # Writes the contents of the specified file field into the cache directory.
    # Returns the full path of the file.
    my($self, $field) = @_;
    # fixup the filename, removing directories
    $self->get($field)->{filename} =~ s/^.*?([^\\\/]+)$/$1/;
    my($name) = $_DT->local_now_as_file_name
        . "-$$-" . $self->get($field)->{filename};
    my($file) = $_UIF->get_local_file_name(
        $_LFT->CACHE, 'bulletin/' . $name);
    _write_file($self, $file, $self->get($field)->{content});
    return $name;
}

sub _write_file {
    # (self, string, string_ref) : undef
    # Writes the contents to the named file.
    my($self, $file, $content) = @_;
    $_IOF->mkdir_parent_only($file, 02770);
    $_IOF->write($file, $content);
    return;
}

1;
