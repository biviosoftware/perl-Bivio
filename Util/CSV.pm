# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
package Bivio::Util::CSV;
use strict;
$Bivio::Util::CSV::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::CSV::VERSION;

=head1 NAME

Bivio::Util::CSV - manipulate csv files

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Util::CSV;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Util::CSV::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Util::CSV> manipulates csv files.

=cut


=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string



=cut

sub USAGE {
    return <<'EOF';
usage: B-csv [options] command [args...]
commands:
    colrm start [end] -- removes columns like colrm command
EOF
}

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="colrm"></a>

=head2 colrm(int start, int end) : string_ref

Reads I<input> and deletes columns starting at I<start> and ending at I<end>
(or end of file).  Currently sucks entire file into memory, which can be slow.

=cut

sub colrm {
    my($self, $start, $end) = @_;
    $self->usage_error($start, ": bad start")
	unless $start =~ /^\d+$/;
    $self->usage_error($end, ": bad end")
	unless !defined($end) || $end =~ /^\d+$/;
    my($res);
    foreach my $line (split(/\n/, ${$self->read_input})) {
	$self->usage_error("quoted text not supported") if $line =~ /"/;
	my(@l) = split(/,/, $line);
        defined($end) ? splice(@l, $start, $end) : splice(@l, $start);
	$res .= join(',', @l)."\n";
    }
    return \$res;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
