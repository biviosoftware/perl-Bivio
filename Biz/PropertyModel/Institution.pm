# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::PropertyModel::Institution;
use strict;
$Bivio::Biz::PropertyModel::Institution::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel::Institution - an account's institution

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel::Institution;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::PropertyModel::Institution::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel::Institution> represents the institutional owner of
an account.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::FieldDescriptor;
use Bivio::IO::Trace;
use Bivio::SQL::Support;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : array_ref

=cut

sub internal_initialize {
    my($property_info) = {
	'institution_id' => ['Internal ID',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	'club_id' => ['Internal Club ID',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	'name' => ['Name',
		Bivio::Biz::FieldDescriptor->lookup('STRING', 256)],
    };
    return [$property_info,
	    Bivio::SQL::Support->new('institution_t', keys(%$property_info)),
	    ['institution_id']];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
