# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::BlogCreateForm;
use strict;
use Bivio::Base 'Model.WikiBaseForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_BFN) = b_use('Type.BlogFileName');
my($_BC) = b_use('Type.BlogContent');
my($_DT) = b_use('Type.DateTime');

sub execute_ok {
    my($self) = @_;
    my($now) = $_DT->now;
    my($rf) = $self->new_other('RealmFile');
    my($bfn);
    my($p) = $self->unsafe_get('RealmFile.is_public') ? 1 : 0;
    foreach my $x (1..100) {
	$bfn = $_BFN->from_date_time($now);
	my($v) = {
	    path => $_BFN->to_absolute($bfn, $p),
	    is_public => $p,
	};
	unless ($rf->unsafe_load($v)) {
	    $rf->create_with_content(
		$v, $_BC->join($self->get(qw(title body))));
	    $self->get_request->put();
	    return $self->return_with_validate({
		path_info => $bfn,
	    });
	}
	$bfn = undef;
	$now = $_DT->add_seconds($now, 1);
    }
    $self->die(
	$_BFN->from_date_time($now) , ': unable to create unique file',
    );
    # DOES NOT RETURN
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    {
		name => 'title',
		type => 'BlogTitle',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'body',
		type => 'BlogBody',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'RealmFile.is_public',
		constraint => 'NONE',
	    },
	],
    });
}

1;
