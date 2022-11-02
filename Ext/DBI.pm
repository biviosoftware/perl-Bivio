# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Ext::DBI;
use strict;
use base 'DBI';
use Bivio::IO::Config;
use Bivio::IO::Trace;

# C<Bivio::Ext::DBI> is a simple wrapper around the standard C<DBI>.  Instead of
# specifying the configuration explicitly, the caller specifies a configuration
# name which is used to connect to.

our($_TRACE);
my($_ORACLE_HOME);
Bivio::IO::Config->register({
    'oracle_home' => $ENV{ORACLE_HOME},
    Bivio::IO::Config->NAMED => {
        database => $ENV{DBI_DATABASE} || Bivio::IO::Config->REQUIRED,
        user => $ENV{DBI_USER} || Bivio::IO::Config->REQUIRED,
        password => $ENV{DBI_PASS} || Bivio::IO::Config->REQUIRED,
        is_read_only => 0,
        connection => Bivio::IO::Config->REQUIRED,
    },
});
my($_DEFAULT_OPTIONS) = {
    AutoCommit => 0,
    RaiseError => 1,
    PrintError => 0,
};

sub connect {
    # (proto) : Ext.DBI
    # (proto, string) : Ext.DBI
    # Connect to the default or the specfied database.  Returns a handle that
    # can be used just like DBI.
    #
    # If an error is encountered, die is called.
    my($proto, $database) = @_;
    my($cfg) = Bivio::IO::Config->get($database);

    Bivio::Die->die("database not set, check 'BConf Bivio::Ext::DBI' section")
        if $cfg->{database} eq 'none';

#TODO: Is this really true
    # Mod_perl wipes out %ENV on each request, it seems...
    $ENV{ORACLE_HOME} ||= $_ORACLE_HOME if $_ORACLE_HOME;
    _trace($cfg->{connection}->get_dbi_prefix($cfg), $cfg->{database}, ':',
            $cfg->{user}, '/', $cfg->{password},
            ':', $_DEFAULT_OPTIONS) if $_TRACE;
    Bivio::IO::Alert->warn('DATABASE IS READ ONLY') if $cfg->{is_read_only};
    my($self) = DBI->connect($cfg->{connection}->get_dbi_prefix($cfg)
        .$cfg->{database}, $cfg->{user}, $cfg->{password},
        $_DEFAULT_OPTIONS);
    return $self;
}

sub get_config {
    # (proto) : hash_ref
    # (proto, string) : hash_ref
    # Returns the C<user>, C<password>, and C<database> used C<oracle_home>
    # used to make connections.  The hash_ref is a copy of the configuration.
    my($self, $database) = @_;
    my($res) = {%{Bivio::IO::Config->get($database)}};
    $res->{oracle_home} = $_ORACLE_HOME;
    return $res;
}

sub handle_config {
    # (proto, hash) : undef
    # database : string [$ENV{DBI_DATABASE} || required]
    #
    # Database to connect to (named configuration)
    #
    # oracle_home : string [$ENV{ORACLE_HOME}]
    #
    # Where oracle resides (optional).
    #
    # password : string [$ENV{DBI_PASS} || required]
    #
    # Password to use (named configuration)
    #
    # user : string [$ENV{DBI_USER} || required]
    #
    # User to log in as (named configuration)
    #
    # connection : string (required)
    #
    # The database connection implementation.
    my(undef, $cfg) = @_;
    $_ORACLE_HOME = $cfg->{oracle_home};
    return;
}

1;
