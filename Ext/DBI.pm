# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Ext::DBI;
use strict;
$Bivio::Ext::DBI::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Ext::DBI - configuration wrapper around DBI

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Ext::DBI;
    Bivio::Ext::DBI->connect();
    Bivio::Ext::DBI->connect("my_db_cfg");

=cut

=head1 EXTENDS

C<DBI>

=cut

use DBI;
@Bivio::Ext::DBI::ISA = qw(DBI);

=head1 DESCRIPTION

C<Bivio::Ext::DBI> is a simple wrapper around the standard C<DBI>.  Instead of
specifying the configuration explicitly, the caller specifies a configuration
name which is used to connect to.

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::IO::Config;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_ORACLE_HOME);
Bivio::IO::Config->register({
    'oracle_home' => $ENV{ORACLE_HOME} || Bivio::IO::Config->REQUIRED,
    Bivio::IO::Config->NAMED => {
	'database' => $ENV{ORACLE_SID} || Bivio::IO::Config->REQUIRED,
	'user' => $ENV{DBI_USER} || Bivio::IO::Config->REQUIRED,
	'password' => $ENV{DBI_PASS} || Bivio::IO::Config->REQUIRED,
	is_read_only => 0,
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
#TODO: Is this really true
    # Mod_perl wipes out %ENV on each request, it seems...
    $ENV{ORACLE_HOME} ||= $_ORACLE_HOME;
    _trace('dbi:Oracle:', $cfg->{database}, ':',
	    $cfg->{user}, '/', $cfg->{password},
	    ':', $_DEFAULT_OPTIONS) if $_TRACE;
    Bivio::IO::Alert->warn('DATABASE IS READ ONLY') if $cfg->{is_read_only};
    my($self) = DBI->connect("dbi:Oracle:$cfg->{database}",
	    $cfg->{user}, $cfg->{password}, $_DEFAULT_OPTIONS);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_config"></a>

=head2 static get_config() : hash_ref

=head2 static get_config(string database) : hash_ref

Returns the C<user>, C<password>, and C<database> used C<oracle_home>
used to make connections.  The hash_ref is a copy of the configuration.

=cut

sub get_config {
    my($self, $database) = @_;
    my($res) = {%{Bivio::IO::Config->get($database)}};
    $res->{oracle_home} = $_ORACLE_HOME;
    return $res;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item database : string [$ENV{ORACLE_SID} || required]

Database to connect to (named configuration)

=item oracle_home : string [$ENV{ORACLE_HOME} || required]

Where oracle resides

=item password : string [$ENV{DBI_PASS} || required]

Password to use (named configuration)

=item user : string [$ENV{DBI_USER} || required]

User to log in as (named configuration)

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_ORACLE_HOME = $cfg->{oracle_home};
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
