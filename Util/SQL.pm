# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Util::SQL;
use strict;
$Bivio::Util::SQL::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::SQL::VERSION;

=head1 NAME

Bivio::Util::SQL - execute SQL from the command line using configured db

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Util::SQL;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Util::SQL::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Util::SQL> executes SQL using the configured db.

=cut


=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns:

  usage: b-sql [options] command [args...]
  commands:
      drop -- drops objects which would be created by running input
      drop_and_run -- calls drop then run
      run -- executes sql contained in input and dies on error

=cut

sub USAGE {
    return <<'EOF';
usage: b-sql [options] command [args...]
commands:
    drop -- drops objects which would be created by running input
    drop_and_run -- calls drop then run
    run -- executes sql contained in input and dies on error
EOF
}

#=IMPORTS
use Bivio::SQL::Connection;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="drop"></a>

=head2 drop()

Reads I<input> and executes "drop I<object>" where I<object> may
be a table, index, sequence, etc.  The values are parsed from
I<input> which must be of the form:

   create table ....
   create [unique] index ...
   create sequence
   ALTER TABLE realm_role_t
      ADD CONSTRAINT realm_role_t1
      PRIMARY KEY(realm_id, role)

and so on.

Ignores "does not exist" errors.

=cut

sub drop {
    my($self) = @_;
    foreach my $s (_parse($self)) {
	next unless $s =~ /^(\s*)create(?:\s+unique)?\s+(\w+\s+\w+)\s+/is
		|| $s =~ /^\s*(alter\s+table\s*\w+\s*)add\s+(constraint\s+\w+)\s+/is;
	Bivio::Die->eval(sub {
	    Bivio::SQL::Connection->execute($1.'drop '.$2);
	    return;
	});
    }
    return;
}

=for html <a name="drop_and_run"></a>

=head2 drop_and_run()

Executes L<drop|"drop"> and then L<run|"run"> with same input.

=cut

sub drop_and_run {
    my($self) = @_;
    $self->drop;
    return $self->run;
}

=for html <a name="run"></a>

=head2 run()

Runs I<input>, terminating on errors.  Any query results are thrown
away.

=cut

sub run {
    my($self) = @_;
    foreach my $s (_parse($self)) {
	Bivio::SQL::Connection->execute($s);
    }
    return;
}

#=PRIVATE METHODS

# _parse(self) : array
#
# Parses input into SQL statements.  Dies if there as an extra statement.
#
sub _parse {
    my($self) = @_;
    $self->setup;
    my(@res);
    my($s) = '';
    foreach my $line (split(/\n/, ${$self->read_input})) {
	# Skip comments and blank lines
	next if $line =~ /^\s*--|^\s*$/s;

	# Execute statement if '/' found
	if ($line =~ /^\s*\/\s*$/s) {
	    push(@res, $s);
	    $s = '';
	    next;
	}

	# Build up statement
	$s .= $line."\n";
    }
    $self->usage($s, ': left over statement') if $s;
    return @res;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
