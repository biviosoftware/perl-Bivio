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

    $self->{$_PACKAGE} = {};
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

    #TODO: remove hard-coded 20s
    if ($fp->{'club'}) {
	$fields->{size} = $_SQL_SUPPORT->get_result_set_size($self,
		'where club=?', $fp->{'club'});
	$_SQL_SUPPORT->find($self, $self->internal_get_rows(),
		20, 'where club=?', $fp->{'club'});
    }
    else {
	$fields->{size} = $_SQL_SUPPORT->get_result_set_size($self, '');
	$_SQL_SUPPORT->find($self, $self->internal_get_rows(), 20, '');
    }
    return $self->get_status()->is_OK();
}

=for html <a name="get_heading"></a>

=head2 abstract get_heading() : string

Returns a suitable heading for the model.

=cut

sub get_heading {
    #TODO: need better heading
    return "Messages List";
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

=for html <a name="get_title"></a>

=head2 abstract get_title() : string

Returns a suitable title of the model.

=cut

sub get_title {
    my($self) = @_;

    #TODO: need better title
    return 'Message List / '.$self->get_result_set_size();
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

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;

=for comment

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
