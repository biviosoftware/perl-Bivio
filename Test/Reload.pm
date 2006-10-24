# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Reload;
use strict;
$Bivio::Test::Reload::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Reload::VERSION;

=head1 NAME

Bivio::Test::Reload - x

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
use Bivio::IO::Alert;
use Bivio::IO::ClassLoader;
use Bivio::IO::Trace;

#=VARIABLES
my($_CONF) = map({chomp($_); $_} `ls httpd*.conf`);
my($_WATCH) = [
    map({$_ =~ s{/BConf.pm$}{}; $_}
        map({$INC{$_}}
	     grep({$_ =~ /BConf.pm$/} keys(%INC))))
];

_trace('httpd.conf: ', $_CONF);
_trace('watched directories: ', $_WATCH);

=head1 METHODS

=cut

=for html <a name="handler"></a>

=head2 handler(??) : boolean

Always returns true.

=cut

sub handler {

    my($unload) = [_modified()];
    return 1
        unless @$unload;

    foreach my $module (@$unload) {
	Bivio::IO::Alert->warn('Unloading: ', $module);
	Bivio::IO::ClassLoader->delete_require($module);
    }

    foreach my $module (@$unload) {
	Bivio::IO::Alert->warn('Loading: ', $module);
	Bivio::IO::ClassLoader->simple_require($module);
    }

    system('touch', "$_CONF");
    return 1;
}

#=PRIVATE SUBROUTINES

# _modified() : ...
sub _modified {
    return _to_module(map({
        _trace("Searching $_ for changed files...");
	`find $_ -name 'Test' -prune -o -name 'files' -prune -o -name '.*' -prune -o \\( -name '*pm' -a -newer $_CONF \\) -print`;
    } @$_WATCH));
}

# _to_module() : 
sub _to_module {
    my(@paths) = @_;
    return map({
        my($path) = $_;
        grep({$_ =~ s{/}{::}g if $_; $_}
            map({$path =~ m{^$_/(.*)\.pm$}; $1} @INC));
    } @paths);
}

=head1 COPYRIGHT

Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
