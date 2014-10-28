# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::PropertyModel;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
b_use('IO.ClassLoaderAUTOLOAD');


sub USAGE {
    return <<'EOF';
usage: bivio PropertyModel [options] command [args..]
commands
  garbage_collector -- run handle_garbage_collector on all PropertyModels
EOF
}

sub garbage_collector {
    my($self) = @_;
    my($req) = $self->initialize_fully;
    Biz_PropertyModel()->do_iterate_model_subclasses(
	sub {
	    my($m) = shift->new($req);
	    if ($m->can('handle_garbage_collector')) {
		_trace($m) if $_TRACE;
		$m->handle_garbage_collector;
	    }
	    return 1;
	},
    );
    return;
}

1;

