# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
# Generated by ../generate.PL on Wed Aug 18  7:57:50 1999
# from tables.sql,v 1.13 1999/08/13 17:06:21 moeller Exp 
package Bivio::Biz::PropertyModel::UserPref;
use strict;
$Bivio::Biz::PropertyModel::UserPref::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel::UserPref - interface to user_pref_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel::UserPref;
    Bivio::Biz::PropertyModel::UserPref->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::PropertyModel::UserPref::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel::UserPref> is the create, read, update,
and delete interface to the C<user_pref_t> table.

=cut

#=IMPORTS
use Bivio::SQL::Constraint;
use Bivio::Type::Integer;
use Bivio::Type::PrimaryId;
use Bivio::Type::Text;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'user_pref_t',
	columns => {
            user_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
            list_display_size => ['Bivio::Type::Integer',
    		Bivio::SQL::Constraint::NONE()],
            avatar_file => ['Bivio::Type::Text',
    		Bivio::SQL::Constraint::NONE()],
        },
	auth_id => 'user_id',
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
