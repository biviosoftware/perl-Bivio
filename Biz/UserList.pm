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
    ['Login Name', Bivio::Biz::FieldDescriptor->lookup('STRING', 32)],
    ['Full Name', Bivio::Biz::FieldDescriptor->lookup('USER_FULL_NAME', 3)]
    ];

my($_SQL_SUPPORT) = Bivio::Biz::SqlListSupport->new('user_, club_user',
	['user_.name', 'user_.first_name,user_.middle_name,user_.last_name']);

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

    # clear the status from previous invocations
    $self->get_status()->clear();

    if ($fp->get('club')) {

	# default order to user name
	my ($order_by) = $self->get_order_by($fp) || ' order by user_.name';

	# club users, max 1000?
	return $_SQL_SUPPORT->find($self, $self->internal_get_rows(), 0, 1000,
		'where club_user.club=? and club_user.user_=user_.id'
		.$order_by, $fp->get('club'));
    }

    return 1;
}

=for html <a name="get_heading"></a>

=head2 abstract get_heading() : string

Returns a suitable heading for the model.

=cut

sub get_heading {
    return "User List";
}

=for html <a name="get_sort_key"></a>

=head2 get_sort_key(int col) : string

Returns the sorting key for the specified column index.

=cut

sub get_sort_key {
    my($self, $col) = @_;

    return ('name', 'first_name')[$col];
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
