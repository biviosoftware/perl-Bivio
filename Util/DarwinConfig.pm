# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::DarwinConfig;
use strict;
use base 'Bivio::Util::LinuxConfig';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF' . shift->SUPER::USAGE(@_);
usage: b-darwin-config [options] command [args..]
commands:
    add_launch_daemon - Add enable a launch daemon
EOF
}

sub add_launch_daemon {
    my($self, $vars) = shift->name_parameters([qw(Label ProgramArguments)], \@_);
    $self->usage_error(
	$vars->{Label}, ': label must be of the form com.company.daemon'
    ) unless $vars->{Label} =~ /^[a-z0-9]+\.[a-z0-9]+\.[a-z0-9]+$/;
    return $self->replace_file(
	"/Library/LaunchDaemons/$vars->{Label}.plist",
	qw(root wheel), 0644,
	_map_xml_vars(<<'EOF', $vars),
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>ServiceIPC</key>
	<false/>
	<key>OnDemand</key>
	<false/>
	<key>Label</key>
	<string>$Label</string>
	<key>ProgramArguments</key>
	<array>
		<string>@ProgramArguments</string>
	</array>
</dict>
</plist>
EOF
    );
}

sub _map_xml_vars {
    my($text, $vars) = @_;
    return join('', map({
	my($line) = "$_\n";
	$line =~ s/\$(\w+)/$vars->{$1} || die("$1: no such variable")/eg;
	my($array) = $line =~ /\@(\w+)/;
	$array ? map(
	    {
		(my $l = $line) =~ s/[\@]$array/$_/
		    or die('@' . $array . ': not found');
		$l;
	    } @{ref($vars->{$array}) ? $vars->{$array}
	        : defined($vars->{$array})
		? [split(' ', $vars->{$array})]
	        : die("$array: no such array variable")},
	) : $line;
    } split(/\n/, $text)));
}

1;
