# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade::Cool;
use strict;
$Bivio::UI::Facade::Cool::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Facade::Cool - totally cool facade

=head1 SYNOPSIS

    use Bivio::UI::Facade::Cool;
    Bivio::UI::Facade::Cool->new();

=cut

=head1 EXTENDS

L<Bivio::UI::Facade>

=cut

use Bivio::UI::Facade;
@Bivio::UI::Facade::Cool::ISA = ('Bivio::UI::Facade');

=head1 DESCRIPTION

C<Bivio::UI::Facade::Cool>

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->new({
    clone => 'Prod',
    'Bivio::UI::Color' => {
	initialize => sub {
	    my($comp) = @_;
	    $comp->set_group_value('page_bg', 0x000000);
	    $comp->set_group_value('error', 0x000099);
	    $comp->set_group_value('page_text', 0xFFFFFF);
	    $comp->set_group_value('footer_menu', 0x660066);
            $comp->set_group_value('summary_line', 0xFF0000);
            $comp->set_group_value('table_even_row_bg', 0x330033);
            $comp->set_group_value('realm_name', 0x3366FF);
	    return;
	},
    },
});

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
