# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::ListModel::MailMessage;
use strict;
use Carp();
$Bivio::Biz::ListModel::MailMessage::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::ListModel::MailMessage - A list of mail messages.

=head1 SYNOPSIS

    use Bivio::Biz::ListModel::MailMessage;
    Bivio::Biz::ListModel::MailMessage->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::ListModel::MailMessage::ISA = qw(Bivio::Biz::ListModel);

=head1 DESCRIPTION

C<Bivio::Biz::ListModel::MailMessage>

=cut

#=IMPORTS
use Bivio::Biz::FieldDescriptor;
use Bivio::Biz::PropertyModel::MailMessage;
use Bivio::IO::Trace;
use Bivio::SQL::ListSupport;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_SQL_SUPPORT);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::ListModel::MailMessage

Creates a new message list model.

=cut

sub new {
    my($proto, $req) = @_;
    my($self) = &Bivio::Biz::ListModel::new($proto, $req);
    $self->{$_PACKAGE} = {
	'index' => 0,
	'size' => 0,
	'selected' => undef,
	'selected_index' => -1
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_default_sort_key"></a>

=head2 get_default_sort_key() : string

Returns the sort key to use if no other sorting is specified.

=cut

sub get_default_sort_key {
    return 'dttm desc';
}

=for html <a name="get_query_at"></a>

=head2 get_query_at(int row) : hash_ref

Returns the model query for the specified row.

=cut

sub get_query_at {
    my($self, $row) = @_;

    return undef if $row < 0 or $row >= $self->get_row_count();
    return $self->internal_get_rows()->[$row]->[0]->[0];
}

=for html <a name="get_index"></a>

=head2 get_index() : int

Overrides get_index() to returns the index of the first item into the
result set.

=cut

sub get_index {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    return $fields->{index};
}

=for html <a name="get_selected_index"></a>

=head2 get_selected_index() : int

Returns the index of the selected item, or -1 if no item is selected.

=cut

sub get_selected_index {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    return $fields->{selected_index};
}

=for html <a name="get_selected_item"></a>

=head2 get_selected_item() : Model

Returns the selected email message or undef if none was selected.

=cut

sub get_selected_item {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    return $fields->{selected};
}

=for html <a name="get_sort_key"></a>

=head2 get_sort_key(int col) : string

Returns the sorting key for the specified column index.

=cut

sub get_sort_key {
    my($self, $col) = @_;
    return ('mail_message_t.subject','from_name', 'dttm')[$col];
}

=for html <a name="get_result_set_size"></a>

=head2 get_result_set_size() : int

Returns the total number of rows in the query.

=cut

sub get_result_set_size {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{size};
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : array_ref

=cut

sub internal_initialize {
    $_SQL_SUPPORT =  Bivio::SQL::ListSupport->new('mail_message_t',
	    ['mail_message_id,subject',
		    'from_name,from_email,subject', 'dttm']);
    return [[
	    ['Subject', Bivio::Biz::FieldDescriptor->lookup('MODEL_REF')],
	    ['From', Bivio::Biz::FieldDescriptor->lookup('EMAIL_REF')],
	    ['Date', Bivio::Biz::FieldDescriptor->lookup('DATE')]],
	    $_SQL_SUPPORT,
	    ['mail_message_id', 'sort', 'index']];
}

=for html <a name="load"></a>

=head2 load(hash query) : boolean

Loads the list given the specified search parameters.

=cut

sub load {
    my($self, %query) = @_;
    my($fields) = $self->{$_PACKAGE};
    # default index to 0
    $fields->{index} = $query{index} || 0;

    my($realm, $club_id) = $self->get_request->get(
	    'auth_owner_id_field', 'auth_owner_id');
    # Sanity check doesn't hurt
    die('attempt to read messages from wrong realm')
	    unless $realm eq 'club_id';

    $fields->{size} = $_SQL_SUPPORT->get_result_set_size($self,
	    'where club_id=?', $club_id);

#TODO: 15 has to go away
    $_SQL_SUPPORT->load($self, $self->internal_get_rows(),
	    $fields->{index}, 15,
	    'where club_id=?'.$self->get_order_by(\%query),
	    $club_id);

    # set the selected message
    if ($query{mail_message_id}) {
	my($message) = Bivio::Biz::PropertyModel::MailMessage->new(
		$self->get_request);
	# load overrides club_id to that of request, so don't bother adding
	$message->load(mail_message_id => $query{mail_message_id});
	$fields->{selected} = $message;
    }
    else {
	$fields->{selected} = undef;
    }

    # iterate the rows, creating model references
    &_create_model_references($self, \%query);
    return;
}

#=PRIVATE METHODS

# _create_model_references(hash_ref query)
#
# Creates model references for the first element in each ModelRef entry.

sub _create_model_references {
    my($self, $query) = @_;
    my($fields) = $self->{$_PACKAGE};

    # iterate the results setting the first arg of the first
    # element (a model ref) to an appropriate query value

    $fields->{selected_index} = -1;
    my($rows) = $self->internal_get_rows();
    my($search_id) = defined($query->{mail_message_id})
	    ? $query->{mail_message_id} : -1;
    for (my($i) = 0; $i < int(@$rows); $i++) {
	my($row) = $rows->[$i];
	my($index) = $i + $fields->{index} - 1;
	$index = 0 if $index < 0;

	# col 0, part 0
	my($id) = $row->[0]->[0];

	if ($id eq $search_id) {
	    $fields->{selected_index} = $i;
	}
	my($q) = {%$query};
	delete($q->{club_id});
	$q->{mail_message_id} = $id;
	$q->{index} = $index;
#TODO: HACK for now.  Need to get this to model_ref render
	$q->{task_id} = Bivio::Agent::TaskId::CLUB_MESSAGE_DETAIL;
	$row->[0]->[0] = $q;
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
