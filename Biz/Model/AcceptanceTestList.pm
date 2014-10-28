# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::AcceptanceTestList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_DT) = b_use('Type.DateTime');
b_use('IO.Config')->register(my $_CFG = {
    root => b_use('IO.Config')->REQUIRED,
});

sub internal_initialize {
    my($self) = @_;
    b_use('IO.Config')->assert_test;
    return $self->merge_initialize_info($self->SUPER::internal_initialize,
        {
	    version => '1',
	    primary_key => [
                {
                    name => 'test_name',
                    type => 'String',
                    constraint => 'NONE',
                },
	    ],
            other => [
                {
                    name => 'age',
                    type => 'String',
                    constraint => 'NONE',
                },
		{
		     name => 'timestamp',
		     type => 'String',
		     constraint => 'NONE',
                },
		{
		     name => 'outcome',
		     type => 'String',
		     constraint => 'NONE',
                },
	    ],
        });
    return;
}

sub internal_load_rows {
     my($self) = @_;
     my($units) = [[seconds => 60], [minutes => 60], [hours => 24], [days => 7], [weeks => 4], [months => 12], [years => 1]];
     my($now) = $_DT->to_unix($_DT->now);;
     my($result) = [];
     my($dir);
     my($name) = $self->get_result_directory;
     opendir($dir, $name) || b_die('Cannot open directory: ' . $name);
     foreach my $subdir (sort(readdir($dir))) {
	 my($full_name) = $name . '/' . $subdir;
	 next unless $subdir =~ /^[^.]/;
	 next unless -d $full_name;
	 my($file_time) = (stat($full_name))[9];
	 my($age) = $now - $file_time;
	 my($unit, $divisor);
	 foreach my $u (@$units) {
	     ($unit, $divisor) = @$u;
	     last unless int($age / $divisor);
	     $age = int($age / $divisor);
	 }
	 $unit =~ s/s$// if $age == 1;
	 push(@$result, {
	     test_name => $subdir,
	     age => $age . ' ' . $unit,
	     timestamp => $_DT->to_local_string($_DT->from_unix((((stat($full_name))[9])))),
	     outcome => (-e $full_name . '/test_run.err') ? '(failed)' : '',
	 });
     }
     closedir($dir);
     return $result;
}

sub get_result_directory {
    my($self, $test_name) = @_;
    my($home) = $ENV{HOME} . '/src/perl/';
    my($result) = $home . $_CFG->{root} . '/Test/t/log';
    $result .= '/'. $test_name if $test_name;
    return $result;
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

1;
