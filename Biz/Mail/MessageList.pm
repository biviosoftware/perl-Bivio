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
use Bivio::Biz::SqlListSupport;
use Bivio::IO::Trace;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_COLUMN_INFO) = [
	['Subject', Bivio::Biz::FieldDescriptor->lookup('MODEL_REF')],
	['From', Bivio::Biz::FieldDescriptor->lookup('EMAIL_REF')],
	['Date', Bivio::Biz::FieldDescriptor->lookup('DATE')]
       ];

my($_SQL_SUPPORT) = Bivio::Biz::SqlListSupport->new('email_message',
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
	index => 0,
	size => 0,
	selected => undef,
	next => '',
	prev => ''
    };
    $_SQL_SUPPORT->initialize();
    return $self;
}

=head1 METHODS

=cut

=for html <a name="find"></a>

=head2 find(FindParams fp) : boolean

Loads the list given the specified search parameters.

=cut

sub find {
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

	$_SQL_SUPPORT->find($self, $self->internal_get_rows(),
		$fields->{index}, 15, 'where club=?'.$self->get_order_by($fp),
		$fp->get('club'));
    }

    # set the selected message
    if ($fp->has_keys('id', 'club')) {

	my($message) = Bivio::Biz::Mail::Message->new();
	$fields->{selected} = $message->find($fp) ? $message : undef;
    }
    else {
	$fields->{selected} = undef;
    }

    # iterate the rows, creating model references
    &_create_model_references($self, $fp);

    return $self->get_status()->is_OK();
}

=for html <a name="get_default_sort_key"></a>

=head2 get_default_sort_key() : string

Returns the sort key to use if no other sorting is specified.

=cut

sub get_default_sort_key {
    return 'dttm desc';
}

=for html <a name="get_heading"></a>

=head2 abstract get_heading() : string

Returns a suitable heading for the model.

=cut

sub get_heading {
    my($self) = @_;

    return $self->get_title();
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

=for html <a name="get_next_message_id"></a>

=head2 get_next_message_id() : 

Returns the find-params for the next-to-the-selected message.

=cut

sub get_next_message_id {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{next};
}

=for html <a name="get_prev_message_id"></a>

=head2 get_prev_message_id() : string

Returns the find-params for the previous-to-the-selected message.

=cut

sub get_prev_message_id {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{prev};
}

=for html <a name="get_selected_message"></a>

=head2 get_selected_message() : Message

Returns the selected email message or undef if none was selected.

=cut

sub get_selected_message {
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

=head2 abstract get_title() : string

Returns a suitable title of the model.

=cut

sub get_title {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    if ($fields->{selected}) {
	return $fields->{selected}->get('subject');
    }

    #TODO: need better title
    return 'Messages '.&_get_date_range($self);
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

#=PRIVATE METHODS

# _create_model_references(FindParams fp)
#
# Creates model references for the first element in each ModelRef entry.

sub _create_model_references {
    my($self, $fp) = @_;
    my($fields) = $self->{$_PACKAGE};

    # iterate the results setting the first arg of the first
    # element (a model ref) to an appropriate finder value

    my($rows) = $self->internal_get_rows();
    my($search_id) = defined($fp->get('id')) ? $fp->get('id') : -1;
    my($search_index) = -1;
    my($fp2) = $fp->clone();
    $fp2->remove('club');

    for (my($i) = 0; $i < scalar(@$rows); $i++) {
	my($row) = $rows->[$i];
	my($index) = $i + $fields->{index} - 1;
	$index = 0 if $index < 0;

	# col 0, part 0
	my($id) = $row->[0]->[0];

	if ($id eq $search_id) {
	    $search_index = $i;
	}
	$fp2->put('id', $id);
	$fp2->put('index', $index);
	$row->[0]->[0] = $fp2->to_string();
    }

    # set the prev and next into the search list if appropriate
    $fields->{prev} = '';
    $fields->{next} = '';

    if ($search_index != -1) {
	if ($search_index > 0) {
	    $fields->{prev} = $rows->[$search_index-1]->[0]->[0];
	}
	if ($search_index < scalar(@$rows)) {
	    $fields->{next} = $rows->[$search_index+1]->[0]->[0];
	}
    }
}

# _get_date_range() : string
#
# Returns the range of dates shown in the list as a string.

sub _get_date_range {
    my($self) = @_;

    my($count) = $self->get_row_count();
    return '' if $count == 0;
    return $self->get_value_at(0, 2).' - '
	    .$self->get_value_at($count - 1, 2);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
