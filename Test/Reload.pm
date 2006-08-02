# Copyright (c) 2006 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Reload;
use strict;
$Bivio::Test::Reload::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Reload::VERSION;

=head1 NAME

Bivio::Test::Reload - 

=head1 RELEASE SCOPE

Artisans

=head1 SYNOPSIS

    use Bivio::Test::Reload;

=cut

=head1 EXTENDS

L<Bivio::UNIVERSAL>

=cut

use Bivio::UNIVERSAL;
@Bivio::Test::Reload::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Test::Reload>

=cut

#=IMPORTS
use Bivio::IO::ClassLoader;
use Bivio::IO::Trace;

#=VARIABLES
my($_CONF) = `ls httpd*.conf`;
chomp($_CONF);
my($_PRJ) = `pwd`;
$_PRJ =~ s{.*/}{};
chomp($_PRJ);

=head1 METHODS

=cut

=for html <a name="handler"></a>

=head2 handler(??) : boolean

Always returns true.

=cut

sub handler {

    foreach my $module (_modified()) {
	_trace('Modified: ', $module);
	_reload($module);
    }

    `touch $_CONF`;
    return 1;
}

#=PRIVATE SUBROUTINES

# _modified() : ...
#
#
#
sub _modified {
   return
       `(cd ..; find $_PRJ -name 'Test' -prune -o -name 'files' -prune -o -name '.*' -prune -o \\( -name '*pm' -a -newer $_PRJ/$_CONF \\) -print)`;
}

# _reload(string module)
#
#
#
sub _reload {
    my($module) = @_;
    chomp($module);
    $module =~ s{/}{::}g;
    $module =~ s/\.pm$//;
    Bivio::IO::ClassLoader->delete_require($module);
    Bivio::IO::ClassLoader->simple_require($module);
    return;
}

=head1 COPYRIGHT

Copyright (c) 2006 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
