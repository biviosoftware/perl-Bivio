# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::TableRowClass;
use strict;
$Bivio::UI::TableRowClass::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::TableRowClass::VERSION;

=head1 NAME

Bivio::UI::TableRowClass - controls rendering of widget table rows

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::TableRowClass;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::UI::TableRowClass::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::UI::TableRowClass> controls rendering of widget table rows.
This is used internally by
L<Bivio::UI::HTML::Widget::Table|Bivio::UI::HTML::Widget::Table>.

=over 4

=item HEADING

=item DATA

=item FOOTER

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    HEADING => [1],
    DATA => [2],
    FOOTER => [3],
]);

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
