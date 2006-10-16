# Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Format::Dollar;
use strict;
$Bivio::UI::HTML::Format::Dollar::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Format::Dollar::VERSION;

=head1 NAME

Bivio::UI::HTML::Format::Dollar - formats dollars with dollar prefix

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Format::Dollar;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Format::Amount>

=cut

use Bivio::UI::HTML::Format::Amount;
@Bivio::UI::HTML::Format::Dollar::ISA = ('Bivio::UI::HTML::Format::Amount');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Format::Dollar>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_widget_value"></a>

=head2 static get_widget_value(string amount, int round, boolean want_parens, boolean zero_as_blank) : string

Formats like Amount but with leading $.  See
L<Bivio::UI::HTML::Format::Amount|Bivio::UI::HTML::Format::Amount>
for arguments.

=cut

sub get_widget_value {
    my($self, $amount) = @_;
    return '$' . shift->SUPER::get_widget_value(@_);
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
