# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::t::CSVImportForm::TForm;
use strict;
use Bivio::Base 'Model.CSVImportForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        other => [
	    {
		name => 'result',
		type => 'Array',
		constraint => 'NONE',
	    },
	],
    });
}

sub process_record {
    my($self, $row, $count) = @_;
    my($res);
    $self->internal_put_field(result => $res = [])
	unless $res = $self->unsafe_get('result');
    $row->{count} = $count;
    push(@$res, $row);
    return;
}

1;
