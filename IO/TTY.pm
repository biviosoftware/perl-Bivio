# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::IO::TTY;
use strict;
$Bivio::IO::TTY::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::IO::TTY::VERSION;

=head1 NAME

Bivio::IO::TTY - perform actions on a tty

=head1 SYNOPSIS

    use Bivio::IO::TTY;

=cut

use Bivio::UNIVERSAL;
@Bivio::IO::TTY::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::IO::TTY> performs operations on a TTY.

=cut

#=IMPORTS
use Term::ReadKey ();

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="read_password"></a>

=head2 static read_password() : string

=head2 static read_password(string prompt) : string

Reads a password with I<prompt> from /dev/tty.   If it cannot open
/dev/tty, returns undef.

=cut

sub read_password {
    my($proto, $prompt) = @_;
    $prompt = 'Enter password: ' unless defined($prompt);
    return undef unless _open();
    print TTY $prompt;
    Term::ReadKey::ReadMode('noecho', \*TTY);
    my $password = <TTY>;
    Term::ReadKey::ReadMode(0, \*TTY);
    close(TTY);
    chomp($password);
    return $password;
}

#=PRIVATE METHODS

# _open() : boolean
#
# Returns true if it can open /dev/tty.
#
sub _open {
    return open(TTY, '+</dev/tty') ? 1 : 0;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
