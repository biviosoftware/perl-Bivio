# Copyright (c) 2008-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::AssertClient;
use strict;
use Bivio::Base 'Biz.Action';

my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
    hosts => [qw(localhost.localdomain), b_use('Bivio.BConf')->bconf_host_name],
    addresses => [],
});
my($_CACHE);

sub execute {
    my($proto, $req) = @_;
    $req->throw_die(
	'CONFIG_ERROR',
	{
	    message => 'client not in allowed addresses or hosts',
	    entity => $req->get('client_addr'),
	},
    ) unless $proto->is_valid_address($req->get('client_addr'));
    return 0;
}

sub execute_is_dev {
    $_C->assert_dev;
    return shift->execute(@_);
}

sub execute_is_test {
    $_C->assert_test;
    return shift->execute(@_);
}

sub handle_config {
    my(undef, $cfg) = @_;
#TODO: Use Type.IPAddress and Type.CIDRNotation
    $_CACHE = {
	map(($_ => 1),
	    map(/^\d+\.\d+\.\d+\.\d+$/ ? $_
	        : Bivio::Die->die($_, ': invalid address'),
		@{$cfg->{addresses} || []}),
	    map({
		my($a) = (gethostbyname($_))[4];
		$a ? join('.', unpack('C4', $a))
	            : Bivio::IO::Alert->warn($_, ": unable to map host: $!");
	    } @{$cfg->{hosts} || []}),
	),
    };
    $_CFG = $cfg;
    return;
}

sub is_valid_address {
    my(undef, $address) = @_;
    return $_CACHE->{$address} || 0;
}

1;
