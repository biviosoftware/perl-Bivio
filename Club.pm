# Copyright (c) 1999 bivio, LLC.  All Rights Reserved.
#
# $Id$
#
package Bivio::Club;

use strict;
use Bivio::Request;
use Bivio::Data;
use Bivio::Util;
use Bivio::Mail;
use Bivio::User;
use Bivio::Club::Page::Motions;

$Bivio::Club::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

BEGIN {
    use Bivio::Util;
    &Bivio::Util::compile_attribute_accessors(
	[qw(title full_name watchlist name members
            guests data_dir time_limit allow_vote_by_mail)],
	'no_set');
}

my($_HOME) = 'clubs/';

my($_DEFAULT_PAGE);
my($_MESSAGE_PAGE);
my(@_PAGES, $_PAGE_MENU, %_URI_TO_PAGE_MAP,
   $_MAILINGLIST_PAGE_MENU, %_MAILINGLIST_URI_TO_PAGE_MAP);
if (defined($ENV{MOD_PERL})) {
    eval '
	use Bivio::Club::Page::Documents;
	use Bivio::Club::Page::Distributions;
	use Bivio::Club::Page::Members;
	use Bivio::Club::Page::Messages;
	use Bivio::Club::Page::Motions;
	use Bivio::Club::Page::Watchlist;
    ';
    $@ && die($@);
    # Order defines the order in the top menu.
    my($docs) = Bivio::Club::Page::Documents->new();
    @_PAGES = (
	$docs,
	Bivio::Club::Page::Distributions->new(),
	Bivio::Club::Page::Members->new(),
	$_MESSAGE_PAGE = $_DEFAULT_PAGE = Bivio::Club::Page::Messages->new(),
	Bivio::Club::Page::Motions->new(),
	Bivio::Club::Page::Watchlist->new(),
    );
    $_PAGE_MENU = Bivio::Club::Menu->new(\@_PAGES);
    %_URI_TO_PAGE_MAP = map {($_->URI, $_)} @_PAGES;
    %_MAILINGLIST_URI_TO_PAGE_MAP = map {($_->URI, $_)} (
	    $docs, $_MESSAGE_PAGE);
    $_MAILINGLIST_PAGE_MENU = Bivio::Club::Menu->new([
	    $docs, $_MESSAGE_PAGE]);
}

sub message_page { $_MESSAGE_PAGE }

sub page_menu { shift->{page_menu} }

# Handler called by mod_perl
sub handler ($) {
    my($r) = @_;
    return Bivio::Request->process_http($r, \&_process_http);
}

#
sub init ($$$) {
    my($proto, $self, $br) = @_;
    bless($self, ref($proto) || $proto);
    return $self;
}

# mhonarc_addhook $mhonarc_index $file
#
#   Called by mhamain.pl:output_mail (MHonArc/lib) after the message has been
#   written in html format.  $file is the file name and $mhonarc_index is used
#   to find subject, etc. in mhonarc package variables.
#
#   If the document_root can't be found, it is passed as "undef" to
#   Bivio::Request::process_email.
#
#   ASSUMES: the format of the MHonArc file is well-defined.
sub mhonarc_addhook ($$) {
    my($mhonarc_index, $filename) = @_;
    my($document_root, $name, $msg_num);
    if (defined($filename)) {
	$document_root = $filename; 
	if ($document_root
	        =~ s,data/clubs/(\w+)/messages/msg(\d+).html$,html,) {
	    $name = $1;
	    $msg_num = $2;
	}
	else {
	    $document_root = undef;
	}
    }
    my($callback) = sub {
	my($br) = @_;
	return &_process_mhonarc_addhook($name, $mhonarc_index, $msg_num, $br);
    };
    return Bivio::Request->process_email($document_root,
					 $mhonarc::Headers{$mhonarc_index},
					 $callback);
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
	defined($self->guests->{$br->user->name}) ||
	    $br->forbidden('not a club member'); 		  # not a guest
    $self->{mailinglist_only} && return; 	  # mailinglists aren't limited
    $br->make_read_only;				  # guest, limit access
}

sub member_attr ($$$) {
    my($self, $member, $attr) = @_;
    my($m) = $self->members->{$member};
    return defined($m) && defined($m->{$attr}) ? $m->{$attr} : undef;
}

sub email ($) {
    my($self) = @_;
    defined($self->{email}) && return $self->{email};
    return $self->{email} = &Bivio::Util::email($self->name);
}

sub lookup_data ($$$$;$) {
    my($self, $file, $proto_or_sub, $br, $type) = @_;
    &Bivio::Data::lookup($self->data_dir . $file, $proto_or_sub, $br, $type);
}

sub begin_txn ($$$$) {
    my($self, $file, $proto_or_sub, $br) = @_;
    &Bivio::Data::begin_txn($self->data_dir . $file, $proto_or_sub, $br);
}

# abs_uri $page $rel_uri -> $uri
#   Returns the absolute URI for a uri relative to this club
sub abs_uri ($$) {
    my($self, $rel_uri) = @_;
    return $self->uri . (defined($rel_uri) ? ('/' . $rel_uri) : '');
}

sub uri ($) {
    my($self) = @_;
    return '/' . $self->name;
}

# queue_mail_as_user $self $subject $body $uri $br
sub queue_mail_as_user ($$$@) {
    my($self, $subject, $body, $uri, $br) = @_;
    my($to) = '"' . $self->full_name . '" <' . $self->email . '>';
    my($from) = '"' . $br->user->full_name . '" <' . $br->user->email . '>';
    &Bivio::Mail::queue($from, [$self->email, $to],
			$subject, $body, ["X-URL: $uri"]);
}

# lookup $proto $name $br -> $club
sub lookup ($$) {
    my($proto, $name, $br) = @_;
    my($data) = $_HOME . $name;
    my($self) = &Bivio::Data::lookup($data, $proto, $br);
    defined($self) || return undef;
    $self->{data_dir} = $data . '/';
    if ($self->{mailinglist_only}) {
	$self->{page_map} = \%_MAILINGLIST_URI_TO_PAGE_MAP;
	$self->{page_menu} = $_MAILINGLIST_PAGE_MENU;
    }
    else {
	$self->{page_map} = \%_URI_TO_PAGE_MAP;
	$self->{page_menu} = $_PAGE_MENU;
    }
    return $self;
}
# _process_http $br
#
#   Authenticates the user for the club and passes on to one of @_PAGES.
#
sub _process_http ($) {
    my($br) = @_;
    my($user) = Bivio::User->authenticate_http($br);
    my($path);
    ($path = $br->r->uri) =~ s,^/+([^/]+)/*,,;
    my($name) = $1;
    my($self) = Bivio::Club->lookup($name, $br);
    defined($self) || $br->not_found($name, ': no such club');
    $self->authenticate($br);
    my($page);
    # NOTE: $1 not reset if match fails
    $path =~ s,^([^/]+)/*,, && ($page = $1);
    $page = !defined($page) ? $_DEFAULT_PAGE
	: defined($self->{page_map}->{$page}) ? $self->{page_map}->{$page}
	    : $br->not_found("no such page");
    $br->set_path_info($path);
    return $page->request($br);
}

# _process_mhonarc_addhook $name $mhonarc_index $msg_num $br
#
#   Implements the processing required by addhook.  Looks at the message
#   in order to know how to route it.
sub _process_mhonarc_addhook ($$$$) {
    my($name, $mhonarc_index, $msg_num, $br) = @_;
    my($self) = Bivio::Club->lookup($name, $br);
    # If this happens, it is an /etc/aliases problem.
    defined($self) || $br->not_found($name,
				     ': no such club (config problem?)');
    $br->set_club($self);
    my($subject) = $mhonarc::Subject{$mhonarc_index};
    $subject =~ s/\b$self->{name}:\s*//i; 		  # eliminate club name
    $subject =~ s/\bRe://ig;
    # Each data model will have to look to see where the messages are linked.
    &Bivio::Club::Page::Motions::process_mhonarc_addhook(
	    $mhonarc_index, $msg_num, $subject, $br);
    return 1;
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
