# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::RealmFile;
use strict;
use base 'Bivio::ShellUtil';
use Bivio::Biz::Model::RealmFile;
use File::Find ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub OPTIONS {
    return {
	 %{shift->SUPER::OPTIONS(@_)},
	 is_public => [Boolean => 0],
	 is_read_only => [Boolean => 0],
    };
}

sub OPTIONS_USAGE {
    return shift->SUPER::OPTIONS_USAGE(@_) . <<'EOF'
    -is_public - operate on public files (default: 0)
    -is_read_only - operate on read only files (default: 0)
EOF
}

sub USAGE {
    return <<'EOF';
usage: b-realm-file [options] command [args...]
commands:
    create_folder folder -- creates folder and parents
    import_tree [folder] -- imports files in current directory into folder [/]
EOF
}

sub create_folder {
    my($self, $folder) = @_;
    return Bivio::Biz::Model->new($self->initialize_ui, 'RealmFile')
	->create_folder(
	    _fix_values($self, {
		path => $self->convert_literal('FilePath', $folder),
	    }),
	)->get('path');
}

sub import_tree {
    my($self, $folder) = @_;
    my($req) = $self->initialize_ui;
    $folder = $folder ? $self->convert_literal(FilePath => $folder) : '/';
    File::Find::find({
	wanted => sub {
	    return if $_ =~ m{(^|/)(\.*|CVS|.*~)$};
	    my($f) = $File::Find::name =~ m{^\./(.+)};
	    my($path) = $self->convert_literal('FilePath', "$folder/$f");
	    my($method) = -d $_ ? 'create_folder' : 'create_with_content';
	    my($rf) = Bivio::Biz::Model->new($req, 'RealmFile');
	    $method = 'update'
		if $rf->unsafe_load({
		    path => $path,
		}) && !($method =~ s/create_with/update_with/);
	    $rf->$method(
		_fix_values($self, {
		    path => $path,
		    modified_date_time => Bivio::Type::DateTime->from_unix(
			(stat($_))[9],
		    ),
		}),
		$method =~ /content/ ? Bivio::IO::File->read($_) : (),
	    );
	    return;
	},
    }, '.');
    return;
}

sub _fix_values {
    my($self, $values) = @_;
    return {
	%$values,
	map(($_ => $self->get($_)), qw(is_public is_read_only)),
    };
}

1;
