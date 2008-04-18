# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::AssertClient;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
Bivio::IO::Config->register(my $_CFG = {
    hosts => [qw(localhost.localdomain)],
    addresses => [],
});
my($_CACHE);

sub execute {
    my($proto, $req) = @_;
    $req->throw_die(FORBIDDEN => {
	message => 'not in addresses',
	entity => $req->get('client_addr'),
    }) unless $proto->is_valid_address($req->get('client_addr'));
    return 0;
}

sub handle_config {
    my(undef, $cfg) = @_;
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
