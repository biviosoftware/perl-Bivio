# Copyright (c) 1999 bivio, LLC.  All Rights Reserved.
#
# $Id$
#
package Bivio::Club;

use strict;
use Bivio::Request;
use Bivio::Data;
use Bivio::User;
use Bivio::Club::Page;
use Bivio::Club::Page::Agreement;
use Bivio::Club::Page::Distributions;
use Bivio::Club::Page::Members;
#use Bivio::Club::Page::Messages;
use Bivio::Club::Page::Watchlist;

$Bivio::Club::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

BEGIN {
    use Bivio::Util;
    &Bivio::Util::compile_attribute_accessors(
	[qw(title full_name watchlist name members guests data_dir main_pages)],
	'no_set');
}

my($_HOME) = 'clubs/';

my($_DEFAULT_PAGE);
# Order is important
my(@_PAGES) = (
    Bivio::Club::Page::Agreement->new(),
    Bivio::Club::Page::Distributions->new(),
    Bivio::Club::Page::Members->new(),
#    Bivio::Club::Page::Messages->new(),
    $_DEFAULT_PAGE = Bivio::Club::Page::Watchlist->new(),
);

my(%_URI_TO_PAGE_MAP) = map {($_->URI, $_)} @_PAGES;

sub handler ($) {
    return Bivio::Request->execute(shift, \&_request);
}

sub init ($$) {
    my($proto, $self, $br) = @_;
    bless($self, ref($proto) || $proto);
    $self->{main_pages} = \@_PAGES;
    return $self;
}

# _request $br
#
#   Authenticates the user for the club and passes on to one of @_PAGES.
#
sub _request ($) {
    my($br) = @_;
    my($user) = Bivio::User->authenticate($br);
    my($path);
    ($path = $br->r->uri) =~ s,^/([^/]+),,;
    my($name) = $1;
    my($data) = $_HOME . $name;
    my($self) = &Bivio::Data::lookup($data, Bivio::Club::, $br);
    defined($self) || $br->not_found($name, ': no such club');
    $self->{data_dir} = $data . '/';
    $self->authenticate($br);
    my($page);
    $path =~ s,^/([^/]+),, && ($page = $1); # NOTE: $1 not reset if match fails
    $page = !defined($page) ? $_DEFAULT_PAGE
	: defined($_URI_TO_PAGE_MAP{$page}) ? $_URI_TO_PAGE_MAP{$page}
	    : $br->not_found("no such page");
    $br->set_path_info($path);
    return $page->request($br);
}

# authenticate $self $br
#   	Validates the current user is a member or guest of the club.  Guests
#	are not allowed to modify the club, but may browse so set_read_only.
sub authenticate ($$)
{
    my($self, $br) = @_;
    $br->set_club($self);
    defined($self->members->{$br->user->name}) && return; 	  # club member
    defined($self->guests) &&
	defined($self->guests->{$self->name}) ||
	    $br->forbidden('not a club member'); 		  # not a guest
    $br->make_read_only;				  # guest, limit access
}

sub member_attr ($$$) {
    my($self, $member, $attr) = @_;
    my($m) = $self->members->{$member};
    return defined($m) && defined($m->{$attr}) ? $m->{$attr} : undef;
}

1;
__END__

=head1 NAME

Bivio::Club - Configure a club for an incoming request.

=head1 SYNOPSIS

  use Bivio::Club;

=head1 DESCRIPTION

=head1 AUTHOR

Rob Nagler <nagler@bivio.com>

=head1 SEE ALSO

Bivio::User

=cut
