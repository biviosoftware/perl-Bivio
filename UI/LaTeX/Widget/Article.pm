# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::LaTeX::Widget::Article;
use strict;
$Bivio::UI::LaTeX::Widget::Article::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::LaTeX::Widget::Article::VERSION;

=head1 NAME

Bivio::UI::LaTeX::Widget::Article - LaTeX article

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::LaTeX::Widget::Article;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget::Join>

=cut

use Bivio::UI::Widget::Join;
@Bivio::UI::LaTeX::Widget::Article::ISA = ('Bivio::UI::Widget::Join');

=head1 DESCRIPTION

C<Bivio::UI::LaTeX::Widget::Article>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Sets content type to text/plain.

=cut

sub execute {
    my($self, $req) = @_;
    return $self->execute_with_content_type($req, 'text/plain');
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
