# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Ext::DBI;
use strict;
$Bivio::Ext::DBI::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Ext::DBI - configuration wrapper around DBI

=head1 SYNOPSIS

    use Bivio::Ext::DBI;
    Bivio::Ext::DBI->connect();
    Bivio::Ext::DBI->connect("my_db_cfg");

=cut

=head1 EXTENDS

L<DBI>

=cut

use DBI;
@Bivio::Ext::DBI::ISA = qw(DBI);

=head1 DESCRIPTION

C<Bivio::Ext::DBI> is a simple wrapper around the standard L<DBI>.  Instead of
specifying the configuration explicitly, the caller specifies a configuration
name which is used to connect to.

=cut

#=IMPORTS
use Bivio::IO::Config;
#use Bivio::IO::Trace;

#=VARIABLES
#use vars ($_TRACE);
#Bivio::IO::Trace->register;
#my($_PACKAGE) = __PACKAGE__;
Bivio::IO::Config->register({
    'ORACLE_HOME' => Bivio::IO::Config->REQUIRED,
    Bivio::IO::Config->NAMED => {
	'database' => Bivio::IO::Config->REQUIRED,
	'user' => Bivio::IO::Config->REQUIRED,
	'password' => Bivio::IO::Config->REQUIRED,
    },
});
my($_DEFAULT_OPTIONS) = {
    'AutoCommit' => 0,
    'RaiseError' => 1,
};

=head1 FACTORIES

=cut

=for html <a name="connect"></a>

=head2 static connect() : Bivio::Ext::DBI

=head2 static connect(string database) : Bivio::Ext::DBI

Connect to the default or the specfied database.  Returns a handle that
can be used just like DBI.

If an error is encountered, die is called.

=cut

sub connect {
    my($proto, $database) = @_;
    my($cfg) = Bivio::IO::Config->get($database);
    my($self) = &DBI::connect("dbi:Oracle:$cfg->{database}",
	    $cfg->{user}, $cfg->{password}, $_DEFAULT_OPTIONS);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="configure"></a>

=head2 static configure(hash cfg)

=over 4

=item name : type [default]

=back

=cut

sub configure {
    my(undef, $cfg) = @_;
    $ENV{ORACLE_HOME} = $cfg->{ORACLE_HOME};
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
