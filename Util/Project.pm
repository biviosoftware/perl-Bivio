# Copyright (c) 2011-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Project;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
use File::Find ();
b_use('IO.ClassLoaderAUTOLOAD');

my($_F) = b_use('IO.File');
my($_C) = b_use('IO.Config');

sub USAGE {
    return <<'EOF';
usage: bivio Project [options] command [args..]
commands
  generate_bootstrap_css [facade_uri [output_path]]
  link_facade_files
EOF
}

sub bootstrap_css_path {
    my($self, $facade) = _facade_and_args(@_);
    return $facade->get_local_file_plain_app_uri('/css/bootstrap.min.css');
}

sub bootstrap_less_path {
    my($self, $facade) = _facade_and_args(@_);
    return $facade->get_local_file_plain_app_uri('/less/*.less');
}

sub generate_bootstrap_css {
    my($self, $facade, $output_path) = _facade_and_args(@_);
    $self->assert_dev;
    return IO_File()->do_in_dir(
        $facade->get_local_file_name(UI_LocalFileType()->PLAIN),
        sub {
            $output_path ||= $self->bootstrap_css_path($facade);
            my($pwd) = IO_File()->pwd;
            $self->are_you_sure("overwrite $pwd$output_path?")
                if -f $pwd . $output_path;
            my($include) = _get_plain($facade, '/bootstrap/less', 'common'),
            my($less_path) = _write_less($self, $facade);
            $self->piped_exec(
                "lessc -x --include-path=$include $less_path ./$output_path");
            return $output_path;
        },
    );
}

sub link_facade_files {
    my($self) = @_;
    $self->initialize_fully;
    my($vc_re) = b_use('Util.VC')->CONTROL_DIR_RE;
    my($default) = b_use('UI.Facade')->get_instance;
    $_F->do_in_dir(
        $default->get_local_file_root,
        sub {
            my($default_prefix) = $default->get('local_file_prefix');
            unless (-d $default_prefix) {
                b_die($default_prefix, ': local_file_prefix not found')
                    unless -d 'ddl';
                (my $d = $default_prefix) =~ s{/}{}g;
                $_F->symlink('.', $d);
            }
            if ($_C->is_dev) {
                _make_javascript($self, $default);
            }
            else {
                IO_File()->do_in_dir(
                    "$default_prefix/ddl",
                    sub {$self->new_other('SQL')->write_bop_ddl_files},
                );
            }
            my($prefixes) = [
                grep(
                    $_ ne $default_prefix,
                    map(
                        $default->get_instance($_)->get('local_file_prefix'),
                        @{$default->get_all_classes},
                    ),
                ),
            ];
            File::Find::find(
                {
                    no_chdir => 1,
                    follow => 0,
                    wanted => sub {
                        my($file) = $File::Find::name;
                        return
                            if $file =~ $vc_re || $file =~ /\~$/;
                        return
                            unless $file =~ s,^$default_prefix,,;
                        foreach my $prefix (@$prefixes) {
                            my($destination) = $prefix . $file;
                            next
                                if -e $destination;
                            if (-d $File::Find::name && ! -l $File::Find::name) {
                                $_F->mkdir_p($destination);
                                next;
                            }
                            my($up) = $File::Find::dir;
                            $up =~ s,[^/]+,..,g;
                            next if $File::Find::name =~ /\.cvsignore/;
                            $_F->symlink("$up/$File::Find::name", $destination)
                                unless -f $destination;
                        }
                        return;
                    },
                },
                $default_prefix,
            );
            return;
        },
    );
    return;
}

sub _add_import_line {
    my($file, $buffer) = @_;
    $$buffer .= '@import "' . $file . "\";\n";
    return;
}

sub _facade_and_args {
    my($self, $facade_or_uri) = (shift, shift);
    my($facade);
    if (ref($facade_or_uri)) {
        $facade = $facade_or_uri;
    }
    elsif ($facade_or_uri) {
        $self->initialize_fully;
        $facade = UI_Facade()->get_instance($facade_or_uri);
    }
    elsif ($self->ureq('UI.Facade')) {
        $facade = $self->req('UI.Facade');
    }
    else {
        $self->initialize_fully;
        $facade = UI_Facade()->get_instance;
    }
    return ($self, $facade, @_);
}

sub _get_plain {
    my($facade, $path, $which) = @_;
    $which ||= 'app';
    my($method) = "get_local_file_plain_${which}_uri";
    return $facade->get_local_plain_file_name($facade->$method($path));
}

sub _make_javascript {
    my($self, $default) = @_;
    #TODO: Share Util.VC
    my($src) = $ENV{PERLLIB} =~ /src/ ? File::Basename::dirname($ENV{PERLLIB})
        : "$ENV{HOME}/src";
    my($common) = "$src/perl/Bivio/files";
    $_F->mkdir_p($_F->rm_rf($common));
    IO_File()->do_in_dir(
        "$src/biviosoftware/javascript-Bivio",
        sub {$self->piped_exec([qw(sh build.sh), $common])},
    );
    my($common_b) = $default->get_local_file_name(
        'PLAIN',
        $default->get_local_file_plain_common_uri,
    );
    $_F->symlink($common, $common_b)
        unless -d $common_b;
    return;
}

sub _write_less {
    my($self, $facade) = @_;
    my($b) = '';
    _add_import_line('bootstrap.less', \$b);
    $b .= '@icon-font-path: "'
        . $facade->get_local_file_plain_common_uri('/bootstrap/fonts/')
        . "\";\n";
    foreach my $l (glob('.' . $self->bootstrap_less_path)) {
        _add_import_line($l, \$b);
    }
    _add_import_line('utilities.less', \$b);
    my($output_path) = IO_File()->tmp_path($self->req);
    IO_File()->write($output_path, \$b);
    return $output_path;
}

1;
