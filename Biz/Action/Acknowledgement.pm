# Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::Acknowledgement;
use strict;
$Bivio::Biz::Action::Acknowledgement::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::Acknowledgement::VERSION;

=head1 NAME

Bivio::Biz::Action::Acknowledgement - confirmation message management

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Action::Acknowledgement;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::Acknowledgement::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::Acknowledgement>

=cut

#=IMPORTS
my($_QUERY) = 'ack';

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req) : boolean

L<extract_label|"extract_label">

=cut

sub execute {
    shift->extract_label(@_);
    return 0;
}

=for html <a name="extract_label"></a>

=head2 static extract_label(Bivio::Agent::Request req) : string

Pulls label off query if it exists.  If length is non-zero, puts
I<label> attribute on self.

=cut

sub extract_label {
    my($proto, $req) = @_;
    return my($l) = delete(($req->unsafe_get('query') || {})->{$_QUERY});
    $proto->new($req)->put_on_request($req)->put(label => $l)
	if $l;
    return $l;
}

=for html <a name="save_label"></a>

=head2 static save_label(string label, Bivio::Agent::Request req)

Saves I<label> in query.

=cut

sub save_label {
    my(undef, $label, $req) = @_;
    my($q) = $req->unsafe_get('query');
    $req->put(query => $q = {})
	unless $q;
    $q->{$_QUERY} = $label;
    return;
}

=for html <a name="save_label_and_execute"></a>

=head2 static save_label_and_execute(string label, Bivio::Agent::Request req)

Saves I<label> on an action instance.

=cut

sub save_label_and_execute {
    my($proto, $label, $req) = @_;
    $proto->save_label($label, $req);
    $proto->execute($req);
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
