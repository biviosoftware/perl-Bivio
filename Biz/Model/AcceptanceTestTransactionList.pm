# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::AcceptanceTestTransactionList;
use strict;
use Bivio::Base 'Biz.ListModel';
use URI::Escape;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_ATL) = b_use('Model.AcceptanceTestList');


sub get_http_request {
    my($proto, $path, $req_nr) = @_;
    my($fn) = $_ATL->get_result_directory(sprintf('%s/http-%05d.req', $path, $req_nr));
    my($location, @lines) = _read_file($fn);
    return join('', @lines);
}

sub get_http_response {
    my($proto, $path, $req_nr, $res_nr) = @_;
    my($req_fn) = $_ATL->get_result_directory(sprintf('%s/http-%05d.req', $path, $req_nr));
    my($res_fn) = $_ATL->get_result_directory(sprintf('%s/http-%05d.res', $path, $res_nr));
    my($command) = _read_file($req_fn);
    my($base, undef, $extension) = $command =~ qr{(http://[^/]+/).*?((\.\S+)(\s|$|\?))?};
    $extension ||= '.html';
    my($sts, @res_lines) = _read_file($res_fn);
    my($nr_empty);
    my(@headers) = map({$nr_empty++ if $_ eq "\n"; $nr_empty ? () : $_} @res_lines);
    my(@page) = @res_lines;
    splice(@page, 0, int(@headers) + 1);
    map({$_ =~ s/<head>/<head><base href="$base">/} @page)
	if $base;
    return join('', @page);
}

sub get_test_name {
    my($proto, $req) = @_;
    my($result) = $req->get('path_info');
    $result =~ s|/*||;
    return $result;
}


sub internal_initialize {
    my($self) = @_;
    b_use('IO.Config')->assert_test;  
    return $self->merge_initialize_info($self->SUPER::internal_initialize,
        {
	    version => '1',
            other => [
                {
                    name => 'request_number',
                    type => 'String',
                    constraint => 'NONE',
                },
                {
                    name => 'response_number',
                    type => 'String',
                    constraint => 'NONE',
                },
                {
                    name => 'test_line_number',
                    type => 'String',
                    constraint => 'NONE',
                },
                {
                    name => 'http_status',
                    type => 'String',
                    constraint => 'NONE',
                },
                {
                    name => 'command',
                    type => 'String',
                    constraint => 'NONE',
                },
	    ]
	});
    return;
}


sub internal_load_rows {
     my($self) = @_;
     my($result) = [];
     my($test_name) = $self->req('path_info');
     my(@req_files) = glob($_ATL->get_result_directory($test_name .  '/http*.req'));
     foreach my $req_file (@req_files) {
	my($req_nr) = $req_file =~ /http-(\d+)/;
	my($res_nr) = sprintf('%05d', $req_nr + 1);
	my($test_line_number, $command) = _read_file($req_file);
	$test_line_number =~ s/^.*?:\s*//;
	my($res_file) = $req_file;
	$res_file =~ s/http-\d+.req/http-$res_nr.res/;
	my(@res_lines) = _read_file($res_file);
	my($http_status) = $res_lines[0]  =~ /HTTP\/1.1 (\d+).*/;
	push(@$result, {
	     request_number => int($req_nr),
	     response_number => int($res_nr),
	     test_line_number => $test_line_number,
	     http_status => $http_status,
             command => $command,
	 });
     }
     return $result;
}

sub _read_file {
     my($fn) = @_;
     my($fh);
     open($fh, '<', $fn) || b_die('cannot open: ' . $fn);
     my(@lines) = <$fh>;
     close($fh);
     return @lines;
 }

1;
