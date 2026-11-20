# Copyright (c) 2008-2026 Bivio Software, Inc.  All Rights Reserved.
package Bivio::Util::Dev;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
use Cwd ();
use File::Basename ();
use File::Spec ();
use version ();
b_use('IO.ClassLoaderAUTOLOAD');


sub MIN_GIT_VERSION {
    # git rev-parse --path-format
    return '2.31';
}

sub USAGE {
    return <<'EOF';
usage: b-dev [options] command [args..]
commands
  bashrc_b_env_aliases - defines b_env and b_<prefix> aliases from Util.Release->map_projects
  setup_all - calls other setup_* methods
  setup_bconf_d_defaults_bconf - creates ~/bconf.d/defaults.bconf
  setup_btest_mail - creates ~/btest-mail/ and ~/.procmailrc
  setup_src - creates ~/src
  worktree_setup [worktree [bivio_dir]] - prepares a git worktree of the BCONF app, prints env
EOF
}

sub bashrc_b_env_aliases {
    my($self) = @_;
    return join(
        " ;\n",
        'b_env() { eval $(b-env "$@") && bivio_ps1 $1; }',
        @{ShellUtil_Release()->map_projects(
            sub {
                my($root, $prefix) = @_;
                return "b_$prefix\() { b_env $prefix $root; }";
            },
        )},
    );
}

sub is_git_version_ok {
    my($self) = @_;
    my($v) = ${$self->piped_exec([qw(git --version)])} =~ /(\d+(?:\.\d+)+)/;
    return $v && version->parse("v$v") >= version->parse('v' . $self->MIN_GIT_VERSION) ? 1 : 0;
}

sub setup_all {
    my($proto) = @_;
    $proto->setup_btest_mail;
    $proto->setup_bconf_d_defaults_bconf;
    $proto->setup_src;
    return;
}

sub setup_bconf_d_defaults_bconf {
    my($proto) = @_;
    my($defaults) = "$ENV{HOME}/bconf.d/defaults.bconf";
    return
        if -r $defaults;
    IO_File()->mkdir_parent_only($defaults);
    IO_File()->write(
        $defaults,
        <<'EOF',
{
    'Bivio::Die' => {
#        stack_trace_error => 1,
#        stack_trace => 1,
    },
    'Bivio::IO::Alert' => {
#        stack_trace_warn => 1,
#        stack_trace_warn_deprecated => 1,
#        max_arg_length => 1000000,
#        max_element_count => 50,
#        max_arg_depth => 5,
    },
    'Bivio::Biz::Action::AssertClient' => {
#        hosts => [qw()],
    },
    'Bivio::IO::Trace' => {
#        command_line_arg => 'sql',
#        package_filter => '/Agent|Task|Model/',
#        call_filter => '!grep(/Can.t locate/, @$msg)',
    },
};
EOF
    );
    $proto->print("Created: $defaults\n");
    return;
}

sub setup_btest_mail {
    my($proto) = @_;
    IO_File()->mkdir_p("$ENV{HOME}/btest-mail");
    my($rc) = "$ENV{HOME}/.procmailrc";
    my($rc_content) = <<'EOF';
UMASK=077
:0
btest-mail/.
EOF
    if (-r $rc) {
        return
            if ${IO_File()->read($rc)} =~ /btest-mail/;
        $proto->print(<<'EOF');
You need to add the following to your .procmailrc, probably near the top:
:0 H :
* ^X-Bivio-Test-Recipient:
* ! From:.*[< ](apache|wwwrun|root)@
btest-mail/.
EOF
        return;
    }
    IO_File()->chmod(
        0600,
        IO_File()->write($rc, $rc_content),
    );
    $proto->print("Created: $rc\n");
    return;
}

sub setup_src {
    my($self) = @_;
    IO_File()->do_in_dir(
        $ENV{HOME},
        sub {
            my($p) = IO_File()->absolute_path(IO_File()->mkdir_p('src/perl'));
            IO_File()->chdir(IO_File()->mkdir_p('src/biviosoftware'));
            foreach my $m (qw(perl-Bivio javascript-Bivio)) {
                $self->new_other('VC')->u_checkout($m)
                    if ! -d $m;
                #TODO: share with Util.VC
                next
                    if $m !~ /perl-(\w+)/;
                my($old) = IO_File()->absolute_path($1, $p);
                next
                    if -l $old;
                if (-d $old) {
                    $self->are_you_sure("Remove $old?");
                    IO_File()->rm_rf($old);
                }
                IO_File()->symlink(IO_File()->absolute_path($m), $old);
            }
        },
    );
    return;
}

sub worktree_setup {
    my($self, $worktree, $bivio) = @_;
    my($wt, $main, $git_dir) = _git_dirs($self, $worktree);
    my($repos) = [$main, $wt];
    my($app, $files) = _repo_path(UI_Facade()->get_local_file_root, $repos);
    my($db) = (_repo_path(Biz_File()->absolute_path(''), $repos))[1];
    b_die(UI_Facade()->get_local_file_root, ': BCONF app files not in ', $main, ' or ', $wt)
        unless defined($files) && defined($db);
    my($plain_b) = Type_FilePath()->join(
        '*',
        UI_LocalFileType()->PLAIN->get_path,
        UI_Facade()->get_local_file_plain_common_uri,
    );
    foreach my $p (_glob("$main/$files", $plain_b)) {
        _link(readlink("$main/$files/$p"), "$wt/$files/$p")
            if -l "$main/$files/$p";
    }
    # The dev DB is shared, so files that its rows reference or are derived from must be too
    my($shared) = {map(
        ($_ => 1),
        map(
            (_repo_path($_, $repos))[1],
            Search_Xapian()->get_db_path,
            map(Biz_File()->absolute_path($_), qw(Cache ModelBulletin RealmFile)),
        ),
    )};
    IO_File()->mkdir_p("$wt/$db");
    foreach my $x (map("$db/$_", _glob("$main/$db", '*'))) {
        $shared->{$x} ? _link("$main/$x", "$wt/$x") : _copy($self, "$main/$x", "$wt/$x");
    }
    my($perllib) = "$git_dir/perllib";
    # For perl-Bivio apps $app is Bivio, so the worktree overrides bivio_dir
    my($links) = {
        Bivio => Cwd::realpath($bivio || IO_Config()->bootstrap_package_dir('Bivio::BConf'))
            || b_die($bivio, ': bivio_dir not found'),
        $app => $wt,
    };
    foreach my $name (sort(keys(%$links))) {
        _link($links->{$name}, "$perllib/$name");
    }
    return "export PERLLIB='"
        . join(':', $perllib, grep($_ ne $perllib, split(/:/, $ENV{PERLLIB} || '')))
        . "' BCONF='$ENV{BCONF}'";
}

sub _copy {
    my($self, $from, $to) = @_;
    # A link here would let tests rewrite the main checkout's data
    unlink($to) || b_die($to, ": unlink: $!")
        if -l $to;
    $self->piped_exec([qw(cp --archive), $from, $to])
        unless -e $to;
    return;
}

sub _git_dirs {
    my($self, $dir) = @_;
    b_die('git ', $self->MIN_GIT_VERSION, ' or later is required')
        unless $self->is_git_version_ok;
    my($wt, $common, $git_dir) = map(
        Cwd::realpath($_),
        split(/\n/, ${$self->piped_exec([
            qw(git -C), $dir || '.',
            qw(rev-parse --show-toplevel --path-format=absolute),
            qw(--git-common-dir --absolute-git-dir),
        ])}),
    );
    my($main) = File::Basename::dirname($common);
    b_die($wt, ': is the main checkout, not a linked worktree')
        if $wt eq $main;
    return ($wt, $main, $git_dir);
}

sub _glob {
    my($dir, $pattern) = @_;
    return -d $dir ? IO_File()->do_in_dir($dir, sub {glob($pattern)}) : ();
}

sub _link {
    my($target, $link) = @_;
    return
        if (readlink($link) || '') eq $target;
    b_die($link, ': exists and is not a symlink')
        if -e $link && ! -l $link;
    IO_File()->mkdir_parent_only($link);
    # rename(2) replaces an existing link atomically
    my($tmp) = "$link.$$";
    IO_File()->symlink($target, $tmp);
    IO_File()->rename($tmp, $link);
    return;
}

sub _repo_path {
    my($path, $repos) = @_;
    my($dir) = File::Spec->canonpath($path);
    my($rel) = '';
    until ($dir eq File::Basename::dirname($dir)) {
        my($real) = Cwd::realpath($dir) || '';
        return (File::Basename::basename($dir), $rel)
            if grep($real eq $_, @$repos);
        $rel = Type_FilePath()->join(File::Basename::basename($dir), $rel);
        $dir = File::Basename::dirname($dir);
    }
    return;
}

1;
