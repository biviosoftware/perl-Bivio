# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade::NetworkInvestments;
use strict;
$Bivio::UI::Facade::NetworkInvestments::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Facade::NetworkInvestments::VERSION;

=head1 NAME

Bivio::UI::Facade::NetworkInvestments - www.networkinvestments.com

=head1 SYNOPSIS

    use Bivio::UI::Facade::NetworkInvestments;

=cut

=head1 EXTENDS

L<Bivio::UI::Facade>

=cut

use Bivio::UI::Facade;
@Bivio::UI::Facade::NetworkInvestments::ISA = ('Bivio::UI::Facade');

=head1 DESCRIPTION

C<Bivio::UI::Facade::NetworkInvestments> is a full co-brand for
www.networkinvestments.com.

=cut

#=IMPORTS
use Bivio::Biz::Action::ClientRedirect;

#=VARIABLES
my($_W) = 'Bivio::UI::HTML::Widget';
my($_SELF) = __PACKAGE__->new({
    clone => 'Prod',
    is_production => 1,
    uri => 'networkinvestments',
    'Bivio::UI::HTML' => {
	clone => undef,
	initialize => sub {
	    my($fc) = @_;

	    # Some required strings and values
	    $fc->group(logo_icon => 'network');
	    $fc->group(site_name => 'Network LP');
	    $fc->group(home_alt_text => 'Network, A Limited Partnership');

	    $fc->initialize_standard_support;

	    # Only override on production system
	    $fc->value(request_attrs => {
		http_host => 'www.networkinvestments.com',
		mail_host => 'networkinvestments.com',
	    }) if Bivio::Agent::Request->is_production;
	    my($ra) = $fc->get_value('request_attrs');
	    $ra->{support_email} = 'network@networkinvestments.com';
	    $ra->{support_phone} = '+1 (858) 638-7245';

	    $fc->value(want_secure => 1);
	    $fc->value(want_help => 0);
	    $fc->value(want_bulletin => 0);
	    $fc->value(want_tos => 0);
	    $fc->value(club_or_fund => 'fund');

	    # To force the gradients to be packed.  Have push the
	    # realm_chooser height.
	    my($icon) = $fc->get_facade->get('Bivio::UI::Icon');
	    $fc->value(realm_chooser => $_W->clear_dot(1,
		    20 + $icon->get_height($fc->get_value('logo_icon'))
		    - $icon->get_height('bivio')));

	    # Home page is special
	    $fc->value(home_page => Bivio::Biz::Action::ClientRedirect->new(
		    '/networkinvestments/files/index.htm'));

	    # These are required names, which are checked by page.
	    _footer($fc);
	    _head($fc);
	    $fc->group(header_widget => $fc->get_standard_header);
	    $fc->group(page_widget => $fc->get_standard_page);
	    $fc->group(logo_widget => $fc->get_standard_logo);
	    $fc->group(header_height => $fc->get_standard_header_height);
	    return;
	},
    },
});

Bivio::UI::Font->initialize_children($_SELF);

=head1 METHODS

=cut

#=PRIVATE METHODS

# _footer(Bivio::UI::HTML html)
#
# Sets footer_widget.
#
sub _footer {
    my($html) = @_;
    my($spacer) = $_W->join(['&nbsp;'])->put(
	cell_width => 20,
    );

    # Create list of links
    my($links) = [];
    foreach my $t ('Home:HTTP_DOCUMENT') {
	my($label, $task) = split(/:/, $t);
	push(@$links, $_W->link(
		$label, $task, 'footer_menu'),
		$spacer);
    }
    push(@$links, $_W->mailto(['support_email'])->put(
	    string_font => 'footer_menu',
	   ));

    # Create grid
    $_W->load_class('Grid', 'EditPreferences');
    $html->group(footer_widget => Bivio::UI::HTML::Widget::Grid->new({
	expand => 1,
	values => [
	    [
		' ',
	    ],
	    [
		$_W->clear_dot(undef, 1)->put(
			cell_expand => 1,
			cell_bgcolor => 'footer_line',
		       ),
	    ],
	    [
		Bivio::UI::HTML::Widget::EditPreferences->new->put(
			cell_expand => 1,
		),
	    ],
	    [
		# Only render second line if the the EditPreferences
		# widget actually rendered something.
		$_W->director(
			['edit_preferences_rendered'],
			{
			    0 => 0,
			    1 => $_W->clear_dot(undef, 1),
			})->put(
				cell_expand => 1,
				cell_bgcolor => 'footer_line',
			       ),
	    ],
	    [
		$_W->toggle_secure(),
		Bivio::UI::HTML::Widget::Grid->new({
		    cell_align => 'center',
		    cell_expand => 1,
		    values => [
			$links,
		    ],
		}),
		$_W->link('top', '#top', 'footer_menu'),
	    ],
	],
    }));
    return;
}

# _head(Bivio::UI::HTML html)
#
# Sets "head_widget".
#
sub _head {
    my($html) = @_;
    $html->group(head_widget => $_W->load_and_new('Title', {
	values => [
	    $html->get_value('site_name'),
	    ['page_subtopic'],
	    ['page_topic'],
	],
    }));
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
