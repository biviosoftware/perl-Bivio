# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade::InvestmentExpo::LeftMenu;
use strict;
$Bivio::UI::Facade::InvestmentExpo::LeftMenu::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Facade::InvestmentExpo::LeftMenu::VERSION;

=head1 NAME

Bivio::UI::Facade::InvestmentExpo::LeftMenu - implements left navigation

=head1 SYNOPSIS

    use Bivio::UI::Facade::InvestmentExpo::LeftMenu;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::Facade::InvestmentExpo::LeftMenu::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::Facade::InvestmentExpo::LeftMenu> implements left navigation
menu for www.investmentexpo.com.  We have some fixed parts and some
variable parts.  The variable parts are tricky, because we have to figure
out where we "are".

=cut

#=IMPORTS
use Bivio::Biz::Action::DemoClub;
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_PACKAGE) = __PACKAGE__;
my($_URI) = 'investmentexpo_left_menu_uri';
my($_STRING) = 'investmentexpo_left_menu_string';


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::Facade::InvestmentExpo::LeftMenu

Returns a new instance of LeftMenu.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Configures the standard parts.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{main_list};

    my(@list);
    foreach my $x (
       'Home:/',
       'About Us:/about.html',
       'Attendee:/attendee.html',
       'Exhibitors:/exhibitors.html',
       'Expo Hall:/expohall.html',
       'Register:/register.html',
       'Shows:/shows.html',
       'Speakers:/nyspeakers.html',
       'Sponsorships:/sponsorship.html',
       'Miami Espa&ntilde;ol:/espanol.html',
       # No URI which _render_main() treats specially
       "Investment<br>Expo Clubs",
       # No label (handled by _render_sublist, can't be first in this list)
       \&_render_sublist,
	   ) {
	my($w) = $x;
	unless (ref($x) eq 'CODE') {
	    my($label, $uri) = split(/:/, $x, 2);
	    $w = $_VS->vs_string($label)->put(
		    escape_html => 0);
	    if (defined($uri)) {
		$w->put(string_font => 'left_menu_normal');
		$w = $_VS->vs_link($w,
			'http://www.investmentexpo.com'.$uri);
	    }
	    else {
		$w->put(string_font => 'left_menu_selected');
	    }
	    $w->put_and_initialize(parent => $self);
	}
    	push(@list, $w);
    }
    $fields->{main_list} = \@list;

    my($sep) = "</td>\n<td>".$_VS->vs_clear_dot_as_html(8);
    $fields->{selected} = $_VS->vs_join(
	    '<tr><td align=right>',
	    $_VS->vs_image('arrow', ''),
	    $sep,
	    $_VS->vs_string([$_STRING], 'left_menu_selected'),
	    "</td>\n</tr>",
	   )->put_and_initialize(parent => $self);

    $fields->{normal} = $_VS->vs_join(
	    '<tr><td>'.$sep,
	    $_VS->vs_link(
		    $_VS->vs_string([$_STRING],
			    'left_menu_normal'),
		    [$_URI]),
	    "</td>\n</tr>",
	   )->put_and_initialize(parent => $self);

    # Fixed size to match investmentexpo.com.  The menu doesn't jump
    # around with this.
    $fields->{prefix} = "<table cellpadding=2 border=0>\n"
	    .'<tr><td width=14>'
	    .$_VS->vs_clear_dot_as_html(14, 1)
	    ."</td>\n<td></td></tr>\n";
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Renders the main_list in a table.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};

    $$buffer .= $fields->{prefix};
    foreach my $link (@{$fields->{main_list}}) {
	if (ref($link) eq 'CODE') {
	    &$link($fields, $source, $buffer);
	    next;
	}

	# Normal labels
        $$buffer .= "<tr><td></td>\n<td>";
	$link->render($source, $buffer);
	$$buffer .= "</td></tr>";
    }
    $$buffer .= "</table>";
    return;
}

#=PRIVATE METHODS

# _render_item(hash_ref state, string label, any uri, string realm_name)
#
# Renders the list
#
sub _render_item {
    my($state, $uri, $label, $realm_name) = @_;
    if (ref($uri)) {
	$label = Bivio::UI::Label->get_simple($uri->get_name);
	$uri = $state->{req}->format_stateless_uri($uri);
    }
    $state->{req}->put($_STRING => $label, $_URI => $uri);

    # Make sure we only select one.  If it is 
    my($selected) = !$state->{selected_one} &&
	    (defined($realm_name) && defined($state->{realm_name})
		    ? $realm_name eq $state->{realm_name}
		    : defined($realm_name) eq defined($state->{realm_name})
		    && $uri eq $state->{uri});
    $state->{selected_one} = 1 if $selected;
    $state->{$selected ? 'selected' : 'normal'}
	    ->render($state->{source}, $state->{buffer});
    return;
}

# _render_sublist(any source, string_ref buffer)
#
# Renders a list of _render_items.
#
sub _render_sublist {
    my($fields, $source, $buffer) = @_;
    my($req) = $source->get_request;

    my($state) = {
	source => $source,
	buffer => $buffer,
	req => $req,
	realm_name => $req->get('auth_realm')->unsafe_get('owner_name'),
	uri => $req->get('initial_uri'),
	selected => $fields->{selected},
	normal => $fields->{normal},
	# Have we already selected one?
	selected_one => 0,
    };

    _render_item($state,
	    $req->format_stateless_uri(Bivio::Agent::TaskId::HTTP_DOCUMENT()),
	    'Introduction');

    my($user) = $source->get('auth_user');
    if ($user) {
	_render_item($state, Bivio::Agent::TaskId::MY_SITE(), undef,
		$user->get('name'));
	foreach my $club (@{Bivio::UI::HTML::Widget::RealmChooser
		    ->get_clubs_to_render($req)}) {
	    _render_item($state,
		    $req->format_uri(Bivio::Agent::TaskId::CLUB_INTRO(),
			    undef, $club, undef),
		    $club, $club);
	}
    }
    else {
	_render_item($state, Bivio::Agent::TaskId::MY_SITE());
	_render_item($state, Bivio::Agent::TaskId::MY_CLUB_SITE());
    }


    foreach my $cc (@{Bivio::UI::HTML::Widget::RealmChooser
		->get_celebrity_columns()}) {
	_render_item($state, $cc->{uri}, $cc->{display_name}, $cc->{name});
    }

    _render_item($state, Bivio::Agent::TaskId::DEMO_REDIRECT(),
	   undef, $user ? (Bivio::Biz::Action::DemoClub
		   ->format_demo_club_name($user))[0]
	    : Bivio::Type::RealmName::DEMO_CLUB()
	   );

    _render_item($state, Bivio::Agent::TaskId::LOGOUT(),
	    undef, '**no match**') if $user;
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
