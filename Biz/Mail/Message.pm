# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Mail::Message;
use strict;
$Bivio::Biz::Mail::Message::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

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
use Bivio::Biz::SqlSupport;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_PROPERTY_INFO) = {
    id => ['Internal ID',
	    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
    club => ['Internal Club ID',
	    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
    ok => ['OK',
	    Bivio::Biz::FieldDescriptor->lookup('BOOLEAN', 1)],
    rfc822_id => ['RFC822 ID',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 128)],
    date => ['Date',
	    Bivio::Biz::FieldDescriptor->lookup('DATE')],
    receive_date => ['Receive Date',
	    Bivio::Biz::FieldDescriptor->lookup('DATE')],
    from_name => ['From',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 64)],
    from_email => ['Email',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 256)],
    from_user => ['Inernal User ID',
	    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
    subject => ['Subject',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 256)],
    synopsis => ['Synopsis',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 256)],
    bytes => ['Number of Bytes',
	    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 10)]
    };

my($_SQL_SUPPORT) = Bivio::Biz::SqlSupport->new('email_message', {
    id => 'id',
    club => 'club',
    ok => 'ok',
    rfc822_id => 'rfc822_id',
    date => 'dttm',
    receive_date => 'recv_dttm',
    from_name => 'from_name',
    from_email => 'from_email',
    from_user => 'from_user',
    subject => 'subject',
    synopsis => 'synopsis',
    bytes => 'bytes'
    });


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::Mail::Message

Creates a new email message. Use find() or create() to populate this
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

Creates a new email message in the database with the specified values. After
creation, this instance will have the same values. Returns 1 if successful,
0 otherwise.

=cut

sub create {
    my($self, $new_values) = @_;
    my($fields) = $self->{$_PACKAGE};

    #TODO: don't send non-sql fields to SqlSupport
    return $_SQL_SUPPORT->create($self, $self->internal_get_fields(),
	    $new_values);
}

=for html <a name="delete"></a>

=head2 delete() : boolean

Deletes the current model from the database. Returns 1 if successful,
0 otherwise.

=cut

sub delete {
    my($self) = @_;

    return $_SQL_SUPPORT->delete($self, 'where id=?', $self->get('id'));
}

=for html <a name="find"></a>

=head2 find(hash find_params) : boolean

Finds the message given the specified search parameters. Valid find keys
are 'id'.

=cut

sub find {
    my($self, $fp) = @_;

    # clear the status from previous invocations
    $self->get_status()->clear();

    if ($fp->{'id'}) {
	return $_SQL_SUPPORT->find($self, $self->internal_get_fields(),
		'where id=?', $fp->{'id'});
    }

    $self->get_status()->add_error(
	    Bivio::Biz::Error->new("Message not found"));
    return 0;
}

=for html <a name="get_heading"></a>

=head2 get_heading() : string

Returns a string composed of 'from_name' 'date' 'subject'

=cut

sub get_heading {
    my($self) = @_;
    return $self->get('from_name').' '.$self->get('date').' '
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

=for html <a name="update"></a>

=head2 update(hash new_values) : boolean

Updates the current model's values and data store.

=cut

sub update {
    my($self, $new_values) = @_;

    #TODO: if 'id' is in new_values, make sure it is the same

    return $_SQL_SUPPORT->update($self, $self->internal_get_fields(),
	    $new_values, 'where id=?', $self->get('id'));
}

#=PRIVATE METHODS

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
    'Bivio::Ext::DBI' => {
	ORACLE_HOME => '/usr/local/oracle/product/8.0.5',
	database => 'surf_test',
	user => 'moeller',
	password => 'bivio,ho'
        },

    'Bivio::IO::Trace' => {
	'package_filter' => '/Bivio/'
        },
    });

my($mail) = Bivio::Biz::Mail::Message->new();
$mail->find({id => 10});
$mail->delete();
$mail->create({
    club => 6601425497792660,
    id => 10,
    ok => 1,
    rfc822_id => 'a1',
    date => '6/7/1995',
    receive_date => '8/9/1996',
    from_name => 'moeller',
    from_email => 'moeller@bivio.com',
    from_user => 0,
    subject => 'test subject',
    synopsis => 'the quick brown fox jumps over the lazy dog',
    bytes => 150
    });
$mail->update({date => '5/6/1955'});
$Data::Dumper::Indent = 1;
print(Dumper($mail));

Bivio::Biz::SqlConnection->get_connection()->commit();

=cut

