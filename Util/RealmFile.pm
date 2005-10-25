# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::RealmFile;
use strict;
use base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub OPTIONS {
    return {
	 %{shift->SUPER::OPTIONS(@_)},
	 volume => [FileVolume => 'PLAIN'],
	 is_public => [Boolean => 0],
    };
}

sub OPTIONS_USAGE {
    return shift->SUPER::OPTIONS_USAGE(@_) . <<'EOF'
    -volume [FileVolume] - file volume to operate on (default: PLAIN)
    -is_public - operate on public files (default: 0)
EOF
}

sub USAGE {
    return <<'EOF';
usage: b-realm-file [options] command [args...]
commands:
    import_tree root -- imports files in current directory into root of current realm
EOF
}

use Bivio::Biz::Model::RealmFile;
use File::Find ();

sub import_tree {
    my($self, $root) = @_;
    $root = $root ? $self->convert_literal('FilePath', $root) : '';
    my($req) = $self->initialize_ui;
    File::Find::find({
	wanted => sub {
	    return if $_ =~ /^\.\.?$/;
	    my($f) = $File::Find::name =~ m{^\./(.+)};
	    my($method) = -d $_ ? 'create_folder' : 'create_with_content';
	    Bivio::Biz::Model->new($req, 'RealmFile')->$method(
		{
		    path => $self->convert_literal('FilePath', "$root/$f"),
		    modified_date_time => Bivio::Type::DateTime->from_unix(
			(stat($_))[9],
		    ),
		    map(($_ => $self->get($_)), qw(volume is_public)),
		},
		$method =~ /content/ ? Bivio::IO::File->read($_) : (),
	    );
	},
    }, '.');
    return;
}

1;
