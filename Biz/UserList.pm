# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::UserList;
use strict;
$Bivio::Biz::UserList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::UserList - a list of user information

=head1 SYNOPSIS

    use Bivio::Biz::UserList;
    Bivio::Biz::UserList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::UserList::ISA = qw(Bivio::Biz::ListModel);

=head1 DESCRIPTION

C<Bivio::Biz::UserList>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::FieldDescriptor;
use Bivio::Biz::SqlListSupport;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_COLUMN_INFO) = [
    ['Internal ID', Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
    ['User ID', Bivio::Biz::FieldDescriptor->lookup('STRING', 32)],
    ['Password', Bivio::Biz::FieldDescriptor->lookup('PASSWORD', 32)]
    ];

my($_SQL_SUPPORT) = Bivio::Biz::SqlListSupport->new('user_',
	['id', 'name', 'password']);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::UserList

Creates an empty user list.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::Biz::ListModel::new($proto, 'userlist',
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

    # clear the status from previous invocations
    $self->get_status()->clear();

    # userlist doesn't use a where clause yet
    return $_SQL_SUPPORT->find($self, $self->internal_get_rows(), 100, '');
}

=for html <a name="get_heading"></a>

=head2 abstract get_heading() : string

Returns a suitable heading for the model.

=cut

sub get_heading {
    return "User List";
}

=for html <a name="get_title"></a>

=head2 abstract get_title() : string

Returns a suitable title of the model.

=cut

sub get_title {
    return "User List";
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
