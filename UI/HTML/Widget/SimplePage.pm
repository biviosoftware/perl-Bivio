# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::SimplePage;
use strict;
$Bivio::UI::HTML::Widget::SimplePage::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::SimplePage::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::SimplePage - executable text/html widget

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::SimplePage;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget::Simple>

=cut

use Bivio::UI::Widget::Simple;
@Bivio::UI::HTML::Widget::SimplePage::ISA = ('Bivio::UI::Widget::Simple');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::SimplePage> renders I<value>.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Calls
L<Bivio::UI::Widget::execute_with_content_type|Bivio::UI::Widget/"execute_with_content_type">
as text/html.

=cut

sub execute {
    my($self, $req) = @_;
    return $self->execute_with_content_type($req, 'text/html');
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
