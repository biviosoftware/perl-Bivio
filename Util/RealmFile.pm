# Copyright (c) 2005-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::RealmFile;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
use File::Find ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_F) = b_use('IO.File');
my($_MFN) = b_use('Type.MailFileName');
my($_FP) = b_use('Type.FilePath');

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
    export_tree folder [noarchive] -- exports an entire tree to current directory
    import_tree [folder] [noarchive] -- imports files in current directory into folder [/]
    list_folder folder -- lists a folder
    purge_archive [min_file_size] -- deletes archived files
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
    my($self, $folder, $noarchive) = shift->name_args([
        [qw(folder FilePath)],
        [qw(?noarchive Boolean)],
    ], \@_);
    $self->initialize_ui;
    $folder .= '/'
	unless length($folder) == 1;
    my($re) = qr{^\Q$folder\E}is;
    $self->model('RealmFile')->do_iterate(sub {
        my($it) = @_;
	return 1
	    unless !$it->get('is_folder')
	    && (my $p = $it->get('path')) =~ $re;
        return 1
            if $noarchive && $it->is_version;
	$p =~ s{^/}{};
	$_F->mkdir_parent_only($p);
	$_F->write($p, $it->get_content);
	$_F->chmod(0444, $p)
	    if $it->get('is_read_only');
        return 1;
    });
    return;
}

sub folder_sizes {
    sub FOLDER_SIZES {[[qw(folder FilePath /)]]}
    my($self, $bp) = shift->parameters(\@_);
    $self->get_request;
    my($res) = {TOTAL => 0};
    my($pat) = qr{^\Q@{[$_FP->add_trailing_slash($bp->{folder})]}\E}i;
    $self->model('RealmFile')->do_iterate(
	sub {
	    my($it) = @_;
	    my($p) = $it->get('path');
	    return 1
		unless $p =~ $pat;
	    my($l) = $it->get_content_length;
	    $res->{($p =~ m{(.*)/})[0] || '/'} += $l;
	    $res->{TOTAL} += $l;
	    return 1;
	},
	undef,
	{is_folder => 0},
    );
    return join(
	'',
	sprintf("%6s %s\n", 'KB', 'Folder'),
	map(
	    sprintf("%6d %s\n", $res->{$_}/1024, $_),
	    sort(keys(%$res)),
	),
    );
}

sub import_tree {
    my($self, $folder, $noarchive) = shift->name_args([
        [qw(?folder String)],
        [qw(?noarchive Boolean)],
    ], \@_);
    my($req) = $self->initialize_ui;
    $folder = $folder ? $self->convert_literal(FilePath => $folder) : '/';
    File::Find::find({
	wanted => sub {
	    if ($_ =~ /^CVS$/) {
		$File::Find::prune = 1;
		return;
	    }
	    return
		if $_ =~ m{(^|/)(\..*|.*~|#.*)$};
	    my($f) = $File::Find::name =~ m{^\./(.+)};
	    my($path) = $self->convert_literal('FilePath', "$folder/$f");
	    my($method) = -d $_ ? 'create_folder' : 'create_with_content';
	    my($rf) = $self->model('RealmFile');
	    if ($rf->unsafe_load({path => $path})) {
		return
		    if $rf->get('is_folder');
		$method = 'update_with_content';
	    }
	    if ($_MFN->is_absolute($path)) {
		$self->model('RealmMail')
		    ->cascade_delete({realm_file_id => $rf->get('realm_file_id')})
		    if $rf->is_loaded;
		$self->model('RealmMail')->create_from_rfc822($_F->read($_));
		return;
	    }
	    $rf->$method(
		_fix_values($self, $path, {
		    modified_date_time => $_DT->from_unix(
			(stat($_))[9],
		    ),
		    $noarchive ? (override_versioning => 1) : (),
		}),
		$method =~ /content/ ? $_F->read($_) : (),
	    );
	    return;
	},
    }, '.');
    return;
}

sub list_folder {
    my($self, $path) = @_;
    $self->initialize_fully;
    return $self->model('RealmFileList')->map_iterate(
	    sub {shift->get('RealmFile.path')},
	    {path_info => $self->convert_literal('FilePath', $path)},
	);
}

sub purge_archive {
    my($self, $file_size) = @_;
    $file_size = defined($file_size) ? $file_size : 1;
    $self->are_you_sure('Delete all archived files larger than '
        . $file_size . 'M in ' . $self->req(qw(auth_realm owner name)) . '?');
    my($m) = 1024 * 1024;
    $file_size *= $m;
    my($deleted_count) = 0;
    my($deleted_size) = 0;
    $self->model('RealmFile')->do_iterate(sub {
        my($rf) = @_;
	return 1 unless $rf->is_version;
	return 1 if $rf->get('is_folder');
	return 1 if $rf->get_content_length <= $file_size;
	$self->print($rf->get('realm_file_id'),
	      ' ', int($rf->get_content_length / $m),
	      'M ', $rf->get('path'), "\n");
	$deleted_size += $rf->get_content_length / $m;
	$rf->new_other('RealmFileLock')->delete_all({
	    realm_file_id => $rf->get('realm_file_id'),
	});
	$rf->delete({
	    override_versioning => 1,
	    override_is_read_only => 1,
	});
	$deleted_count++;
	return 1;
    });
    return $deleted_count . ' archive files deleted: '
	. sprintf("%.2fM", $deleted_size);
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
    $self->initialize_fully;
    return $self->model('RealmFile')
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
