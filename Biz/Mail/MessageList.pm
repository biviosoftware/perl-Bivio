# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Mail::MessageList;
use strict;
use Carp();
$Bivio::Biz::Mail::MessageList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

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

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::FieldDescriptor;
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

=head2 find(hash find_params) : boolean

Loads the list given the specified search parameters.

=cut

sub find {
    my($self, $fp) = @_;
    my($fields) = $self->{$_PACKAGE};

    # clear the status from previous invocations
    $self->get_status()->clear();

    $fields->{index} = $fp->{index} || 0;

    #TODO: remove hard-coded 15s
    if ($fp->{club}) {
	$fields->{size} = $_SQL_SUPPORT->get_result_set_size($self,
		'where club=?', $fp->{'club'});
	$_SQL_SUPPORT->find($self, $self->internal_get_rows(),
		$fields->{index}, 15, 'where club=?', $fp->{'club'});
    }

    # set the selected message
    if (defined($fp->{id}) && $fp->{club}) {

	my($message) = Bivio::Biz::Mail::Message->new();
	$message->find({id => $fp->{id}, club => $fp->{club}});

	$fields->{selected} = $message->get_status()->is_OK()
		? $message : undef;
    }
    else {
	$fields->{selected} = undef;
    }

    $fields->{prev} = '';
    $fields->{next} = '';
    my($rows) = $self->internal_get_rows();

    #TODO: needs revisiting
    for (my($i) = 0; $i < scalar(@$rows); $i++) {
	my($row) = $rows->[$i];
	my($index) = $i + $fp->{index} - 1;
	$index = 0 if $index < 0;
	# col 0, part 0
	my($id) = $row->[0]->[0];

	if (defined($fp->{id}) and $fp->{id} eq $id) {
	    $fields->{prev} = $i > 0 ? $rows->[$i-1]->[0]->[0] : undef;
	    $fields->{next} = $i < scalar(@$rows) - 1
		    ? 'index('.($index == 0 ? $index : $index + 1)
			    .'),id('.$rows->[$i+1]->[0]->[0].')'
		    : undef;
	}
	#TODO: need to get the rest of the fp params into this
	$row->[0]->[0] = 'index('.($index >= 0 ? $index : 0).'),id('.$id.')';
    }

    return $self->get_status()->is_OK();
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

Returns the index of the first item into the result set.

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
    return $fields->{next} || '';
}

=for html <a name="get_prev_message_id"></a>

=head2 get_prev_message_id() : string

Returns the find-params for the previous-to-the-selected message.

=cut

sub get_prev_message_id {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{prev} || '';
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

my($list) = Bivio::Biz::Mail::MessageList->new();
$list->find({});

print(Dumper($list));

=cut
