# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Email;
use strict;
$Bivio::Type::Email::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Email - email address

=head1 SYNOPSIS

    use Bivio::Type::Email;

=cut

=head1 EXTENDS

L<Bivio::Type::Line>

=cut

use Bivio::Type::Line;
@Bivio::Type::Email::ISA = ('Bivio::Type::Line');

=head1 DESCRIPTION

C<Bivio::Type::Email> simple syntax checking on email addresses.

=cut


=head1 CONSTANTS

=cut

=for html <a name="IGNORE_PREFIX"></a>

=head2 IGNORE_PREFIX : string

Prefix we used to indicate addresses which go into a black hole.

=cut

sub IGNORE_PREFIX {
    return 'ignore-';
}

#=IMPORTS
use Bivio::TypeError;
use Bivio::Mail::RFC822;

#=VARIABLES
my($_IGNORE) = IGNORE_PREFIX();

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : array

Returns C<undef> if the name is empty or zero length.
Checks syntax and returns L<Bivio::TypeError|Bivio::TypeError>.

=cut

sub from_literal {
    my($proto, $value) = @_;
    return undef unless defined($value);
    # Leave middle spaces, because user can't have them
    $value =~ s/^\s+|\s+$//g;
    return undef unless length($value);
    return (undef, Bivio::TypeError::TOO_LONG())
	    if length($value) > $proto->get_width;
    # We always force to lower case to ensure values get into the
    # database that can be searchable.
    $value = lc($value);

    # Domain must NOT match our local mail or server domain
    my($req) = Bivio::Agent::Request->get_current;
    my($domain);
    foreach $domain ($req->get('http_host'), $req->get('mail_host')) {
        $domain =~ s/(\W)/\\$1/g;
        $value =~ /\@$domain$/i && return (undef, Bivio::TypeError::EMAIL());
    }
    
    # Must match a simple dotted atom address and must contain at least one dot
#TODO: parse out address and try to do a DNS resolution?
#      I checked out Net::DNS, but it doesn't seem like it can
#      handle timeouts properly.  (No way to stop the query once
#      started(?)).  Anyway, we need a way to avoid entering bogus
#      addresses.  The best way would be to mail the user the password.
#      I don't know if we could sustain this in the beginning.
    my($ATOM_ONLY_ADDR) = Bivio::Mail::RFC822->ATOM_ONLY_ADDR;
    return $value if $value =~ /^$ATOM_ONLY_ADDR$/os && $value =~ /.+\..*/;
#TODO: This is weak.  Either make good, or just use general message
#    # Give a reasonable error message
#    # We don't accept domain literal addresses?
#    return (undef, Bivio::TypeError::EMAIL_DOMAIN_LITERAL())
#	    if /$_822_DOMAIN_LITERAL/os;
#    # Must be qualified
#    return (undef, Bivio::TypeError::EMAIL_UNQUALIFIED())
#	    unless /\@/;
    # Some other error
    return (undef, Bivio::TypeError::EMAIL());
}

=for html <a name="is_ignore"></a>

=head2 static is_ignore(string email) : boolean

Returns true if is L<is_valid|"is_valid"> and does not
begin with L<IGNORE_PREFIX|"IGNORE_PREFIX">.

=cut

sub is_ignore {
    my($proto, $email) = @_;
    return 1 unless $proto->is_valid($email);
    return $email =~ /^$_IGNORE/ios ? 1 : 0;
}

=for html <a name="is_valid"></a>

=head2 is_valid(string email) : boolean

Checks to see the email is a valid address.  Used to check
values stored in the database which may be invalidated by support.

=cut

sub is_valid {
    my($proto, $email) = @_;
    my($ATOM_ONLY_ADDR) = Bivio::Mail::RFC822->ATOM_ONLY_ADDR;
    return defined($email) && $email =~ /^$ATOM_ONLY_ADDR$/os ? 1 : 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
