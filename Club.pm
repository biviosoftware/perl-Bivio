# Copyright (c) 1999 bivio, LLC.  All Rights Reserved.
#
# $Id$
#
package Bivio::Club;

use strict;
use Bivio::Request;
use Bivio::Data;
use Bivio::User;
use Bivio::Club::Members;

$Bivio::Club::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my $_HOME = 'clubs/';

sub handler ($) {
    return Bivio::Request->execute(shift, \&_request);
}

sub init ($$) {
    my($proto, $self, $br) = @_;
    bless($self, ref($proto) || $proto);
#    $self->{template} = new Bivio::Club::Page($self);
    Bivio::Club::Members->init($self->{members}, $br);
#    $self->{messages} = new Bivio::Club::Messages($self);
#    $self->{distributions} = new Bivio::Club::Distributions($self);
#    $self->{securities} = new Bivio::Club::Securities($self);
    return $self;
}

sub _request ($) {
    my($br) = @_;
    my($user) = Bivio::User->authenticate($br);
    my($r) = $br->r;
    my($path);
    ($path = $r->uri()) =~ s<^/([^/]+)/?><>;
    my($name) = $1;
    my($self) = &Bivio::Data::lookup($_HOME . $name, Bivio::Club::, $br);
    defined($self) || $br->not_found($name, ': no such club');
    $br->set_club($self);
    $self->{members}->authenticate($br);
    $r->content_type(&_content_type($path, $br));
    $r->send_http_header();
    open('Bivio::Club::IN', $r->document_root . '/' . $path)
	|| $br->not_found("file not found");
    $r->send_fd('Bivio::Club::IN');
    close('Bivio::Club::IN');
    return &Apache::Constants::OK;
}

sub _content_type ($)
{
    local($_) = shift;
    /.gif$/ && return "image/gif";
    /.html$/ && return "text/html";
    shift->not_found("bad suffix");
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
