# Copyright (c) 2005-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::RealmFile;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
use File::Find ();

my($_A) = b_use('IO.Alert');
my($_D) = b_use('Bivio.Die');
my($_DT) = b_use('Type.DateTime');
my($_F) = b_use('IO.File');
my($_FP) = b_use('Type.FilePath');
my($_MFN) = b_use('Type.MailFileName');

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
    audit_folders -- correct folder modified_date_time and user_id
    backup_realms dir realm... - export_tree for all realms in dir/<date-time>
    clear_files_and_mail
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

sub audit_folders {
    my($self) = @_;
    $self->model('RealmFile')->do_iterate(sub {
        my($rf) = @_;
	my($max, $user_id) = _max_modified_time($self, $rf);
	$rf->update({
	    override_is_read_only => 1,
	    modified_date_time => $max,
	    user_id => $user_id,
	}) if $max;
	return 1;
    }, {
	is_folder => 1,
    });
    return;
}

sub backup_realms {
    my($self, $base_dir, @realms) = @_;
    my($root) = $_FP->join($base_dir, $_DT->local_now_as_file_name);
    foreach my $r (@realms) {
	my($die) = b_catch(sub {
	    $_F->do_in_dir(
		$_F->mkdir_p($_FP->join($root, $r)),
		sub {
		    $self->req->with_realm(
			$r,
			sub {$self->export_tree('/', 1)},
		    );
		    $self->piped_exec("sh -c 'cd .. && tar czf $r.tgz $r && rm -rf $r' 2>&1");
		    return;
		},
	    );
        });
        b_warn($r, ': ', $die)
            if $die;
    }
    return;
}

sub clear_files_and_mail {
    my($self) = @_;
    $self->assert_test;
    $self->are_you_sure('delete realm files and mail?');
    $self->model('RealmMail')->delete_all;
    $self->model('RealmFile')->delete_all;
    return;
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
	    unless (my $p = $it->get('path')) =~ $re;
        return 1
            if $noarchive && $it->is_version;
	$p =~ s{^/}{};
	return 1 unless $p;

	if ($it->get('is_folder')) {
	    $_F->mkdir_p($p);
	}
	else {
	    $_F->mkdir_parent_only($p);
	    $_F->write($p, $it->get_content);
	    $_F->chmod(0444, $p)
		if $it->get('is_read_only');
	}
	$_F->set_modified_date_time($p, $it->get('modified_date_time'));
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
    my($folders) = [];
    my($files) = [];
    my($vc_re) = b_use('Util.VC')->CONTROL_DIR_RE;
    File::Find::find(
	{
	    wanted => sub {
		my($name) = $_;
		if ($name =~ $vc_re) {
		    $File::Find::prune = 1;
		    return;
		}
		return
		    if $name =~ m{(^|/)(\..*|.*~|#.*)$};

		push(
		    @{-d $name ? $folders : $files},
		    [$File::Find::name, (stat($name))[9]],
		);
		return;
	    },
	},
	'.',
    );
    foreach my $x (
	@$folders,
	sort({$a->[1] <=> $b->[1]} @$files),
    ) {
	my($name, $mtime) = @$x;
	my($f) = $name =~ m{^\./(.+)};
	my($path) = $self->convert_literal('FilePath', "$folder/$f");
	my($method) = -d $name ? 'create_folder' : 'create_with_content';
	my($rf) = $self->model('RealmFile');
	if ($rf->unsafe_load({path => $path})) {
	    next
		if $rf->get('is_folder');
	    $method = 'update_with_content';
	}
	my($modified_date_time) = $_DT->from_unix($mtime);
	if ($_MFN->is_absolute($path)) {
	    $self->model('RealmMail')
		->load({realm_file_id => $rf->get('realm_file_id')})
		->delete_message
		if $rf->is_loaded;
	    my($in);
	    my($die) = $_D->catch_quietly(
		sub {
		    $in = $self->model('RealmMail')
			->create_from_rfc822($_F->read($name));
		    return;
		},
	    );
	    if ($die) {
		b_info(
		    'mail from rfc822 failed: ',
		    'name: ',
		    $name,
		    ' err: ',
		    ($die->unsafe_get('attrs') || {})->{message},
		);
		next;
	    }
	    my($rf) = $self->req('Model.RealmFile');
	    $rf->update({
		override_is_read_only => 1,
		path => $path,
		modified_date_time => $in->get_date_time || $modified_date_time,
	    });
	    b_die('public mismatch')
		unless $_MFN->is_public($path)
		    eq $self->req(qw(Model.RealmFile is_public));
	    next;
	}
	$rf->$method(
	    _fix_values($self, $path, {
		modified_date_time => $modified_date_time,
		$noarchive ? (override_versioning => 1) : (),
	    }),
	    $method =~ /content/ ? $_F->read($name) : (),
	);
	next;
    }
    $self->audit_folders;
    $self->model('RealmMail')->audit_threads;
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
    my($c) = 0;
    my($commit) = sub {
	$self->commit_or_rollback;
	$_A->reset_warn_counter;
	return;
    };
    $self->model('RealmFile')->do_iterate(sub {
        my($rf) = @_;
	return 1 unless $rf->is_version;
	return 1 if $rf->get('is_folder');
	return 1 if $rf->get_content_length < $file_size;
#TODO(robnagler) this does not seem useful
#	$self->print($rf->get('realm_file_id'),
#	      ' ', int($rf->get_content_length / $m),
#	      'M ', $rf->get('path'), "\n");
#	$deleted_size += $rf->get_content_length / $m;
	$rf->new_other('RealmFileLock')->delete_all({
	    realm_file_id => $rf->get('realm_file_id'),
	});
	$rf->delete({
	    override_versioning => 1,
	    override_is_read_only => 1,
	});
        if ($c++ % 100 == 0) {
            b_info($c);
            $commit->();
        }
	return 1;
    });
    return $c . ' archive files deleted';
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

sub _max_modified_time {
    my($self, $folder) = @_;
    my($max) = $_DT->get_min;
    my($user_id);

    $self->model('RealmFile')->do_iterate(sub {
        my($rf) = @_;
	my($v, $u) = $rf->get('is_folder')
	    ? _max_modified_time($self, $rf)
	    : $rf->get(qw(modified_date_time user_id));

	if ($_DT->compare($v, $max) > 0) {
	    $max = $v;
	    $user_id = $u;
	}
	return 1;
    }, {
	folder_id => $folder->get('realm_file_id'),
    });
    return $max eq $_DT->get_min ? undef : ($max, $user_id);
}

1;
