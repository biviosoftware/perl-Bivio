# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Mail::MessageList;
use strict;
use Carp();
$Bivio::Biz::Mail::MessageList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Mail::MessageList - A list of mail messages.

=head1 SYNOPSIS

    use Bivio::Biz::Mail::MessageList;
    Bivio::Biz::Mail::MessageList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Mail::MessageList::ISA = qw(Bivio::Biz::ListModel);

=head1 DESCRIPTION

C<Bivio::Biz::Mail::MessageList>

=cut

#=IMPORTS
use Bivio::Biz::FieldDescriptor;
use Bivio::Biz::FindParams;
use Bivio::Biz::Mail::Message;
use Bivio::IO::Trace;
use Bivio::SQL::ListSupport;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_COLUMN_INFO) = [
	['Subject', Bivio::Biz::FieldDescriptor->lookup('MODEL_REF')],
	['From', Bivio::Biz::FieldDescriptor->lookup('EMAIL_REF')],
	['Date', Bivio::Biz::FieldDescriptor->lookup('DATE')]
       ];

my($_SQL_SUPPORT) = Bivio::SQL::ListSupport->new('email_message',
	['id,subject', 'from_name,from_email,subject', 'dttm']);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::Mail::MessageList

Creates a new message list model.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::Biz::ListModel::new($proto, 'messagelist',
	    $_COLUMN_INFO);

    $self->{$_PACKAGE} = {
	'index' => 0,
	'size' => 0,
	'selected' => undef,
	'selected_index' => -1
    };
    $_SQL_SUPPORT->initialize();
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

=for html <a name="get_heading"></a>

=head2 get_heading() : string

Returns a suitable heading for the model.

=cut

sub get_heading {
    my($self) = @_;

    return $self->get_title();
}

=for html <a name="get_finder_at"></a>

=head2 get_finder_at(int row) : string

Returns the model finder for the specified row. This should be the string
format of a L<Bivio::Biz::FindParams>.

=cut

sub get_finder_at {
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
    my($self, $fp) = @_;
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

    return ('email_message.subject','from_name', 'dttm')[$col];
}

=for html <a name="get_title"></a>

=head2 get_title() : string

Returns a suitable title of the model.

=cut

sub get_title {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    # detail view of the selected message
    if ($fields->{selected}) {
	return $fields->{selected}->get('subject');
    }

    return 'No Messages' if $self->get_row_count() == 0;

    # otherwise show the range of messages displayed
    my($index) = $self->get_index();
    return 'Messages '.($index + 1)
	    .' - '.($index + $self->get_row_count())
	    .' / '.$self->get_result_set_size();
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

=for html <a name="find"></a>

=head2 load(FindParams fp) : boolean

Loads the list given the specified search parameters.

=cut

sub load {
    my($self, $fp) = @_;
    my($fields) = $self->{$_PACKAGE};

    # clear the status from previous invocations
    $self->get_status()->clear();

    # default index to 0
    $fields->{index} = $fp->get('index') || 0;

#TODO: remove hard-coded 15s
    if ($fp->get('club')) {

	$fields->{size} = $_SQL_SUPPORT->get_result_set_size($self,
		'where club=?', $fp->get('club'));

	$_SQL_SUPPORT->load($self, $self->internal_get_rows(),
		$fields->{index}, 15, 'where club=?'.$self->get_order_by($fp),
		$fp->get('club'));
    }

    # set the selected message
    if ($fp->has_keys('id', 'club')) {

	my($message) = Bivio::Biz::Mail::Message->new();
	$fields->{selected} = $message->load($fp) ? $message : undef;
    }
    else {
	$fields->{selected} = undef;
    }

    # iterate the rows, creating model references
    &_create_model_references($self, $fp);

    return $self->get_status()->is_ok();
}

#=PRIVATE METHODS

# _create_model_references(FindParams fp)
#
# Creates model references for the first element in each ModelRef entry.

sub _create_model_references {
    my($self, $fp) = @_;
    my($fields) = $self->{$_PACKAGE};

    # iterate the results setting the first arg of the first
    # element (a model ref) to an appropriate finder value

    $fields->{selected_index} = -1;
    my($rows) = $self->internal_get_rows();
    my($search_id) = defined($fp->get('id')) ? $fp->get('id') : -1;
    my($fp2) = $fp->clone();
    $fp2->remove('club');

    for (my($i) = 0; $i < int(@$rows); $i++) {
	my($row) = $rows->[$i];
	my($index) = $i + $fields->{index} - 1;
	$index = 0 if $index < 0;

	# col 0, part 0
	my($id) = $row->[0]->[0];

	if ($id eq $search_id) {
	    $fields->{selected_index} = $i;
	}
	$fp2->put('id', $id);
	$fp2->put('index', $index);
	$row->[0]->[0] = $fp2->as_string();
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
