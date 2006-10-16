# Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::IO::File;
Bivio::IO::Config->introduce_values({
    'Bivio::IO::Log' => {
	directory => 'Log',
	directory_mode => 0700,
	file_mode => 0600,
     },
});
my($txt) = ${Bivio::IO::File->read(__FILE__)};
my $txt_gz = `gzip --best -c @{[__FILE__]}`;
Bivio::Test->new('Bivio::IO::Log')->unit([
    'Bivio::IO::Log' => [
	write => [
	    ['1.txt', $txt] => [],
	    ['1.txt.gz', $txt] => [],
	    ['.', $txt] => Bivio::DieCode->IO_ERROR,
	],
	read => [
	    '1.txt' => [\($txt)],
	    '1.txt.gz' => [\($txt)],
	    '.' => Bivio::DieCode->IO_ERROR,
	],
    ],
]);
