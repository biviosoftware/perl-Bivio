# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
use IO::File;
system('rm -rf File');
Bivio::Test->new('Bivio::IO::File')->unit([
    'Bivio::IO::File' => [
	{
	    method => 'mkdir_p',
	    check_return => sub {
		my($case, $actual, $expect) = @_;
		die($expect->[0], ": $!")
		    unless -d $expect->[0];
		return $expect;
	    },
	} => [
	    File => 'File',
	    'File/1' => 'File/1',
	],
	rm_rf => [
	    sub {
		my($case) = @_;
		return [$case->get('object')->pwd . '/File'];
	    } => sub {
		my($case) = @_;
		die("File: directory exists")
		    if -e 'File';
		return $case->get('params');
	    },
	],
	mkdir_parent_only => [
	    'File/1.txt' => 'File',
	],
	write => [
	    ['File/1.txt', 'hello'] => undef,
	    sub {
		return [IO::File->new('> File/2.txt'), "1\n2\n"];
	    } => undef,
	    ['File/not-found/3.txt', 'x'] => Bivio::DieCode->IO_ERROR,
	    sub {
		open(SAVE_STDOUT, '>&STDOUT') or die;
		my($avoid_a_warning) = \*SAVE_STDOUT;
		open(STDOUT, '> File/stdout.txt') or die;
		return ['-', 'stdout'];
	    } => sub {
		open(STDOUT, '>&SAVE_STDOUT') or die;
		return 1;
	    },
	],
	append => [
	    ['File/1.txt', "\ngoodbye"] => undef,
        ],
	read => [
	    ['File/1.txt'] => [\("hello\ngoodbye")],
	    sub {
		return [IO::File->new('< File/2.txt')];
	    } => [\("1\n2\n")],
	    # deprecated form
	    ['File/2.txt', IO::File->new('< File/2.txt')] => [\("1\n2\n")],
	    ['File/not-found/3.txt'] => Bivio::DieCode->IO_ERROR,
	    sub {
		open(STDIN, '< File/stdout.txt') or die;
		return ['-'];
	    } => [\('stdout')],
	],
    ],
]);
