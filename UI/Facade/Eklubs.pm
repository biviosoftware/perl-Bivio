# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade::Eklubs;
use strict;
$Bivio::UI::Facade::Eklubs::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Facade::Eklubs::VERSION;

=head1 NAME

Bivio::UI::Facade::Eklubs - www.eklubs.com

=head1 SYNOPSIS

    use Bivio::UI::Facade::Eklubs;

=cut

=head1 EXTENDS

L<Bivio::UI::Facade>

=cut

use Bivio::UI::Facade;
@Bivio::UI::Facade::Eklubs::ISA = ('Bivio::UI::Facade');

=head1 DESCRIPTION

C<Bivio::UI::Facade::Eklubs> is a full co-brand for
www.eklubs.com.

=cut

#=IMPORTS
use Bivio::UI::Facade::Eklubs::Home;
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

__PACKAGE__->new({
    clone => 'Prod',
    is_production => 1,
    uri => 'eklubs',
    'Bivio::UI::HTML' => {
	clone => undef,
	initialize => sub {
	    my($fc) = @_;

	    # Some required strings and values
	    $fc->group(logo_icon => 'dot');
	    $fc->group(site_name => 'Eklubs');
	    $fc->group(home_alt_text => 'Eklubs - '
		    .'Real Investors, Real Investments, Real Returns');

	    $fc->initialize_standard_support;
	    $fc->value(want_secure => 0);
	    # Home page is special
	    $fc->value(home_page =>
		    Bivio::UI::Facade::Eklubs::Home->new);

	    # These are required names, which are checked by page.
	    _header($fc);
	    _footer($fc);
	    $fc->group(logo_widget => $fc->get_standard_logo);
	    $fc->group(head_widget => $fc->get_standard_head);
	    $fc->group(page_widget => $fc->get_standard_page);
	    return;
	},
    },
});

=head1 METHODS

=cut

#=PRIVATE METHODS

# _footer(Bivio::UI::HTML html) : Bivio::UI::Widget
#
# Sets footer_widget.
#
sub _footer {
    my($html) = @_;
    # Create list of links
    my($links) = [];
    foreach my $t (
	    'HOME:http://www.eklubs.com/eklubs.htm',
	    'ABOUT EKLUBS:http://www.eklubs.com/eklubs.htm',
	    'SAFE & PRIVATE:http://www.eklubs.com/safe.htm',
	    'REGISTER:/pub/register',
	    'START A CLUB:http://www.eklubs.com/start.htm',
	   ) {
	my($label, $task) = split(/:/, $t, 2);
	push(@$links, $_VS->vs_link($label, $task, 'footer_menu'),
		'&nbsp;|&nbsp;');
    }
    # Delete last separator
    pop(@$links);

    # Create grid
    $_VS->vs_load_class('Grid');
    $html->group(footer_widget => Bivio::UI::HTML::Widget::Grid->new({
	expand => 1,
	values => [
	    [
		$_VS->vs_clear_dot(1, 10),
		],
	    [
		$_VS->vs_clear_dot(undef, 1)->put(
			cell_expand => 1,
			cell_bgcolor => 'footer_line',
		       ),
	    ],
	    [
		# Match the top
		'&nbsp;&nbsp;&nbsp;',
		Bivio::UI::HTML::Widget::Grid->new({
		    cell_align => 'center',
		    cell_expand => 1,
		    values => [
			$links,
		    ],
		}),
		$_VS->vs_link('top', '#top', 'footer_menu'),
	    ],
	    [
		' ',
	    ],
	    [
		Bivio::UI::HTML::Widget::Grid->new({
		    expand => 1,
		    cell_expand => 1,
		    values => [
			[
			    $_VS->vs_link($_VS->vs_image('bivio_power'),
				    'http://www.bivio.com')
				    ->put(cell_align => 'sw'),
			    $html->get_standard_copyright->put(
				    cell_align => 'right',
				    cell_expand => 1,
				   ),
			],
		    ],
		}),
	    ],
	],
    }));
    return;
}

# _header(Bivio::UI::HTML html) : Bivio::UI::Widget
#
# Sets header_widget and header_height.
#
sub _header {
    my($html) = @_;
    my($hdr) = $html->get_standard_header();
    # Insert before <a name=top>...
    splice(@{$hdr->get('values')}, 1, 0, _logo($html));
    $html->group(header_widget => $hdr);
    $html->group(header_height =>
	    $html->get_standard_header_height
	    + $html->get_facade->get('Bivio::UI::Icon')
	    ->get_height('eklubs_header'));
    return;
}

# _logo(Bivio::UI::HTML html) : Bivio::UI::Widget
#
# Returns the logo widget which points to eklubs home page.
#
sub _logo {
    my($html) = @_;
    return $_VS->vs_link(
	    $_VS->vs_image('eklubs_header', $html->get_value('home_alt_text')),
	        'http://www.eklubs.com');

}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
