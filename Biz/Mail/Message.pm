# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Mail::Message;
use strict;
$Bivio::Biz::Mail::Message::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Mail::Message - an email message

=head1 SYNOPSIS

    use Bivio::Biz::Mail::Message;
    Bivio::Biz::Mail::Message->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Mail::Message::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Mail::Message> holds information about an email message,
the body of which is stored in the file server.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::Error;
use Bivio::Biz::FieldDescriptor;
use Bivio::File::Client;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::SQL::Support;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_PROPERTY_INFO) = {
    'club' => ['Internal Club ID',
	    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
    'id' => ['Internal ID',
	    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
    'ok' => ['OK',
	    Bivio::Biz::FieldDescriptor->lookup('BOOLEAN', 1)],
    'rfc822_id' => ['RFC822 ID',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 128)],
    'dttm' => ['Date',
	    Bivio::Biz::FieldDescriptor->lookup('DATE')],
    'from_name' => ['From',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 64)],
    'from_email' => ['Email',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 256)],
    'subject' => ['Subject',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 256)],
    'synopsis' => ['Synopsis',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 256)],
    'bytes' => ['Number of Bytes',
	    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 10)]
    };

my($_SQL_SUPPORT) = Bivio::SQL::Support->new('email_message',
	keys(%$_PROPERTY_INFO));

Bivio::IO::Config->register({
    'file_server' => Bivio::IO::Config->REQUIRED,
});

my($_FILE_CLIENT);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::Mail::Message

Creates a new email message. Use load() or create() to populate this
instance with data.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::Biz::PropertyModel::new($proto, 'email_message',
	    $_PROPERTY_INFO);

    $self->{$_PACKAGE} = {};
    $_SQL_SUPPORT->initialize();

    return $self;
}

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash new_values) : boolean

=head2 create(Bivio::Mail::Incoming msg, Bivio::Biz::Club club) : boolean

Creates a new email message in the database with the specified values. After
creation, this instance will have the same values. Returns 1 if successful,
0 otherwise.

The message body should be located at new_values->{body} and should be
a string reference. The body will be stored on the file server in the
path "club-id/messages/message-id".

=cut

sub create {
    my($self, $new_values, $club) = @_;
    my($fields) = $self->{$_PACKAGE};

    # clear the status from previous invocations
    $self->get_status()->clear();

    if (ref($new_values) eq 'Bivio::Mail::Incoming') {
	return &_create_from_incoming($self, $new_values, $club);
    }
    my($body) = $new_values->{body};
    # not part of sql, remove it from values
    delete($new_values->{body});

    # first do sql commit, it is possible to rollback if the file server fails
    my($ok) = $_SQL_SUPPORT->create($self, $self->internal_get_fields(),
	    $new_values);

    if ($ok) {
	$_FILE_CLIENT->create('/'.$new_values->{club}.'/messages/'
		.$new_values->{id}, $body)
		|| die("file server failed");
    }
    return $ok;
}

=for html <a name="configure"></a>

=head2 static configure(hash cfg)

=over 4

=item file_server : string (required)

Where are the messages stored.

=back

=cut

sub configure {
    my(undef, $cfg) = @_;
    $_FILE_CLIENT = Bivio::File::Client->new($cfg->{file_server});
    return;
}

=for html <a name="delete"></a>

=head2 delete() : boolean

Deletes the current model from the database. Returns 1 if successful,
0 otherwise.

=cut

sub delete {
    my($self) = @_;

    # can't delete it, not supported by file server

#    return $_SQL_SUPPORT->delete($self, 'where id=? and club=?',
#	    $self->get('id'), $self->get('club'));

    die("not implemented");
}

=for html <a name="find"></a>

=head2 load(FindParams fp) : boolean

Finds the message given the specified search parameters. Valid find keys
are 'id'.

=cut

sub load {
    my($self, $fp) = @_;

    # clear the status from previous invocations
    $self->get_status()->clear();

    if (defined($fp->get('id')) && $fp->get('club')) {
	return $_SQL_SUPPORT->load($self, $self->internal_get_fields(),
		'where id=? and club=?', $fp->get('id'), $fp->get('club'));
    }

    $self->get_status()->add_error(
	    Bivio::Biz::Error->new("Message not found"));
    return 0;
}

=for html <a name="get_body"></a>

=head2 get_body() : string_ref

Returns the htmlized body of the mail message. This is retrieved from the
file server using the path "club-id/messages/message-id".

=cut

sub get_body {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($body);
    $_FILE_CLIENT->get('/'.$self->get('club').'/messages/'.$self->get('id'),
	    \$body) || die("couldn't get mail body");
    return \$body;
}

=for html <a name="get_heading"></a>

=head2 get_heading() : string

Returns a string composed of 'from_name' 'dttm' 'subject'

=cut

sub get_heading {
    my($self) = @_;
    return $self->get('from_name').' '.$self->get('dttm').' '
	    .$self->get('subject');
}

=for html <a name="get_title"></a>

=head2 get_title() : string

Returns the mail subject.

=cut

sub get_title {
    my($self) = @_;
    return $self->get('subject');
}

=for html <a name="setup_club"></a>

=head2 setup_club(Bivio::Biz::Club club)

Creates the club message storage area.

=cut

sub setup_club {
    my($self, $club) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($res);
    my($id) = $club->get('id');
    my($dir);
    foreach $dir ($id, "$id/mbox", "$id/messages") {
	$_FILE_CLIENT->mkdir($dir, \$res) || die("mkdir $dir: $res");
    }
    return;
}

=for html <a name="update"></a>

=head2 update(hash new_values) : boolean

Updates the current model's values and data store.

=cut

sub update {
    my($self, $new_values) = @_;

    # can't update message body, not supported by file server
    if ($new_values->{body}) {
	die("not implemented");
    }

#TODO: if 'id' is in new_values, make sure it is the same

    return $_SQL_SUPPORT->update($self, $self->internal_get_fields(),
	    $new_values, 'where id=? and club=?',
	    $self->get('id'), $self->get('club'));
}

#=PRIVATE METHODS

sub _create_from_incoming {
    my($self, $bmi, $club) = @_;
    # Archive mail message first
    my($mbox) = $bmi->get_unix_mailbox;
#TODO: Get id from sequence
    my($id) = int(rand(999999)) + 1;
    # $dttm is always valid
    my($dttm) = $bmi->get_dttm() || time;
    my($mon, $year) = (gmtime($dttm))[4,5];
    $year < 1900 && ($year += 1900);
    $_FILE_CLIENT->append('/'. $club->get('id') . '/mbox/'
	    . sprintf("%04d%02d", $year, ++$mon), \$mbox)
	    || die("mbox append failed: $mbox");
    my($from_email, $from_name) = $bmi->get_from();
    my($reply_to_email) = $bmi->get_reply_to();
    my($body) = $bmi->get_body();
    my($values) = {
	'club' => $club->get('id'),
	'id' => $id,
#TODO: Does the ok bit make sense?
	'ok' => 1,
	'rfc822_id' => $bmi->get_message_id,
	'dttm' => $dttm,
	'from_name' => $from_name,
	'from_email' => $from_email,
	'reply_to_email' => $reply_to_email,
	'subject' => $bmi->get_subject || '',
#TODO: Do a real synopsis here
	'synopsis' => $bmi->get_subject || '',
#TODO: Measure real size (all unpacked files)
	'bytes' => length($body),
    };
    # first do sql commit, it is possible to rollback if the file server fails
    my($ok) = $_SQL_SUPPORT->create($self, $self->internal_get_fields(),
	    $values);
    if ($ok) {
	$_FILE_CLIENT->create('/' . $club->get('id') . '/messages/'
		. $id, \$body)
		|| die("file server failed: $body");
    }
    return $ok;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;

=begin comment

use Data::Dumper;

$Data::Dumper::Indent = 1;
Bivio::IO::Config->initialize({
    'Bivio::IPC::Client' => {
	'addr' => 'localhost',
	'port' => 9876
    },

    'Bivio::Ext::DBI' => {
	'ORACLE_HOME' => '/usr/local/oracle/product/8.0.5',
	'database' => 'surf_test',
	'user' => 'moeller',
	'password' => 'bivio,ho'
        },

    'Bivio::IO::Trace' => {
	'package_filter' => '/Bivio/'
        },
    });

my($mail) = Bivio::Biz::Mail::Message->new();
my($body) = "message body ... not very exciting\n";
my($id) = int(rand(9999998)) + 1;

$mail->create({
    'club' => '7957448535598810',
    'id' => $id,
    'ok' => 1,
    'rfc822_id' => $id,
    'dttm' => '6/7/1995',
    'from_name' => 'moeller',
    'from_email' => 'moeller@bivio.com',
    'subject' => 'test subject',
    'synopsis' => 'the quick brown fox jumps over the lazy dog',
    'bytes' => 150,
    'body' => \$body,
    });
$mail->update({'dttm' => '5/6/1955'});
$mail->load(Bivio::Biz::FindParams->new(
        {'id' => $id, 'club' => '7957448535598810'}));
print($mail->get_body());
#$Data::Dumper::Indent = 1;
#print(Dumper($mail));

Bivio::SQL::Connection->get_connection()->commit();

=cut
