# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::FacadeClassList;
use strict;
$Bivio::Biz::Model::FacadeClassList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::FacadeClassList::VERSION;

=head1 NAME

Bivio::Biz::Model::FacadeClassList - list of all facades suitable for rendering

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::FacadeClassList;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::FacadeClassList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::FacadeClassList>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Returns model config.

=cut

sub internal_initialize {
    return {
	version => 1,
	can_iterate => 0,
	other => [
	    {
		name => 'simple_name',
		type => 'FacadeClass',
		constraint => 'NOT_NULL',
	    },
	],
    };
}

=for html <a name="internal_load_rows"></a>

=head2 internal_load_rows() : array_ref

Returns list of rows.

=cut

sub internal_load_rows {
    my($self) = @_;
    return [map({{simple_name => $_}} @{Bivio::UI::Facade->get_all_classes})];
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
