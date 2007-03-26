# Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.
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
    create path -- creates file_path with input
    create_folder path -- creates folder and parents
    delete path ... -- deletes files specified
    import_tree [folder] -- imports files in current directory into folder [/]
    list_folder folder -- lists a folder
    read path -- returns file contents
EOF
}

sub create {
    my($self, $path) = @_;
    _do($self, create_with_content => $path, $self->read_input);
    return;
}

sub create_folder {
    my($self, $path) = @_;
    _do($self, create_folder => $path);
    return;
}

sub delete {
    my($self) = shift;
    foreach my $p (@_) {
	_do($self, delete => $p);
    }
    return;
}

sub import_tree {
    my($self, $folder) = @_;
    my($req) = $self->initialize_ui;
    $folder = $folder ? $self->convert_literal(FilePath => $folder) : '/';
    File::Find::find({
	wanted => sub {
	    if ($_ =~ /^CVS$/) {
		$File::Find::prune = 1;
		return;
	    }
	    return if $_ =~ m{(^|/)(\.*|.*~)$};
	    my($f) = $File::Find::name =~ m{^\./(.+)};
	    my($path) = $self->convert_literal('FilePath', "$folder/$f");
	    my($method) = -d $_ ? 'create_folder' : 'create_with_content';
	    my($rf) = Bivio::Biz::Model->new($req, 'RealmFile');
	    $method = 'update'
		if $rf->unsafe_load({
		    path => $path,
		}) && !($method =~ s/create_with/update_with/);
	    $rf->$method(
		_fix_values($self, $path, {
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

sub list_folder {
    my($self, $path) = @_;
    return Bivio::Biz::Model->new($self->initialize_ui, 'RealmFileList')
	->map_iterate(
	    sub {shift->get('RealmFile.path')},
	    {path_info => $self->convert_literal('FilePath', $path)},
	);
}

sub read {
    my($self, $path) = @_;
    return _do($self, load => $path)->get_content;
}

sub update {
    my($self, $path) = @_;
    _do($self, load => $path)->update_with_content({}, $self->read_input);
    return;
}

sub _do {
    my($self, $method, $path, @args) = @_;
    return Bivio::Biz::Model->new($self->initialize_ui, 'RealmFile')
	->$method(_fix_values($self, $path, {}, $method eq 'load'), @args);
}

sub _fix_values {
    my($self, $path, $values, $ignore_is) = @_;
    return {
	$values ? %$values : (),
	path => $self->convert_literal('FilePath', $path),
	$ignore_is ? () : map(($_ => $self->get($_)), qw(is_public is_read_only)),
    };
}

1;
