# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
# Generated by ../generate.PL on Wed Aug 18  7:57:50 1999
# from tables.sql,v 1.13 1999/08/13 17:06:21 moeller Exp 
package Bivio::Biz::PropertyModel::ClubPref;
use strict;
$Bivio::Biz::PropertyModel::ClubPref::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel::ClubPref - interface to club_pref_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel::ClubPref;
    Bivio::Biz::PropertyModel::ClubPref->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::PropertyModel::ClubPref::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel::ClubPref> is the create, read, update,
and delete interface to the C<club_pref_t> table.

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
	table_name => 'club_pref_t',
	columns => {
            club_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
            description_file => ['Bivio::Type::Text',
    		Bivio::SQL::Constraint::NONE()],
            description_url => ['Bivio::Type::Text',
    		Bivio::SQL::Constraint::NONE()],
            max_mail_message_kbytes => ['Bivio::Type::Integer',
    		Bivio::SQL::Constraint::NOT_NULL()],
        },
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
