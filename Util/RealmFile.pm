# Copyright (c) 2005-2009 bivio Software, Inc.  All Rights Reserved.
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
    create_or_update path -- creates or updates file_path with input
    create_folder path -- creates folder and parents
    delete_deep path ... -- deletes files or folders specified
    rename old new --- moves old to new
    export_tree folder -- exports an entire tree to current directory
    import_tree [folder] -- imports files in current directory into folder [/]
    list_folder folder -- lists a folder
    read path -- returns file contents
    send_file_via_mail email subject path -- email a file as an attachment
    update path --  updates path with input
EOF
}

sub create {
    my($self, $path) = @_;
    _do($self, create_with_content => $path, $self->read_input);
    return;
}

sub create_or_update {
    my($self, $path) = @_;
    _do($self, create_or_update_with_content => $path, $self->read_input);
    return;
}

sub create_folder {
    my($self, $path) = @_;
    _do($self, create_folder => $path);
    return;
}

sub delete_deep {
    my($self) = shift;
    foreach my $p (@_) {
	_do($self, 'unauth_delete_deep', $p);
    }
    return;
}

sub export_tree {
    my($self, $folder) = shift->name_args([[qw(folder FilePath)]], \@_);
    $self->initialize_ui;
    $folder .= '/'
	unless length($folder) == 1;
    my($re) = qr{^\Q$folder\E}is;
    $self->model('RealmFile')->do_iterate(sub {
        my($it) = @_;
	return 1
	    unless !$it->get('is_folder')
	    && (my $p = $it->get('path')) =~ $re;
	$p =~ s{^/}{};
	Bivio::IO::File->mkdir_parent_only($p);
	Bivio::IO::File->write($p, $it->get_content);
	Bivio::IO::File->chmod(0444, $p)
	    if $it->get('is_read_only');
        return 1;
    });
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
	    return if $_ =~ m{(^|/)(\..*|.*~|#.*)$};
	    my($f) = $File::Find::name =~ m{^\./(.+)};
	    my($path) = $self->convert_literal('FilePath', "$folder/$f");
	    my($method) = -d $_ ? 'create_folder' : 'create_with_content';
	    my($rf) = Bivio::Biz::Model->new($req, 'RealmFile');
	    if ($rf->unsafe_load({path => $path})) {
		return if $rf->get('is_folder');
		$method = 'update_with_content';
	    }
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

sub rename {
    my($self, $old, $new) = @_;
    _do($self, load => $old)->update({path => $new});
    return;
}

sub send_file_via_mail {
    my($self, $email, $subject, $path) = @_;
    $self->send_mail($email, $subject || $path, _do($self, load => $path));
    return;
}

sub update {
    my($self, $path) = @_;
    _do($self, load => $path)->update_with_content({}, $self->read_input);
    return;
}

sub _do {
    my($self, $method, $path, @args) = @_;
    return Bivio::Biz::Model->new($self->initialize_ui, 'RealmFile')
	->$method(_fix_values($self, $path, {}, $method =~ /(delete|load)/), @args);
}

sub _fix_values {
    my($self, $path, $values, $ignore_is) = @_;
    return {
	$values ? %$values : (),
	path => $self->convert_literal('FilePath', $path),
	$ignore_is ? () : map(($_ => $self->get($_)), qw(is_public is_read_only)),
	$self->get('force') ? (override_is_read_only => 1) : (),
    };
}

1;
