# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::UI::Search;
use strict;
$Bivio::PetShop::UI::Search::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::UI::Search::VERSION;

=head1 NAME

Bivio::PetShop::UI::Search - search box and button

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::UI::Search;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::PetShop::UI::Search::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::PetShop::UI::Search>

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::UI::Font;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Does nothing.  Widget is entirely dynamic.

=cut

sub initialize {
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the input field.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;

    my($field_prefix, $field_suffix) = Bivio::UI::Font->format_html(
	    'input_field', $req);

    $$buffer .= '<br><form method=get action="'
	    .$req->format_stateless_uri(Bivio::Agent::TaskId->PRODUCT_SEARCH)
	    .'">'
	    .$field_prefix.'<input type=text size=14 name=s>'.$field_suffix
	    .' '
	    .'<input type=image border=0 alt="Search" '
		    .'src="/i/search.gif">'
	    .'</form>';
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
