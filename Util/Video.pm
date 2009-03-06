# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Video;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_F) = __PACKAGE__->use('IO.File');
my($_DT) = __PACKAGE__->use('Type.DateTime');

sub USAGE {
    my($proto) = @_;
    return <<"EOF";
usage: bivio @{[$proto->simple_package_name]} [options] command [args..]
commands
  avchd_to_blu_ray [src_dir [dst_dir]] -- convert AVCHD file structure to Blu-Ray
  init_avchd_disk [src_tgz [dst_disk]] -- clear and init AVCHD disk on camera
EOF
}

sub avchd_to_blu_ray {
    # See http://www.elurauser.com/articles/avchd_to_bluray.jsp
    my($self, $src_dir, $dst_dir) = shift->name_args([
	[qw(src_dir FilePath /Volumes/CANON_HDD/AVCHD/BDMV)],
	[qw(dst_dir FilePath), "$ENV{HOME}/video"],
    ], \@_);
    my($date) = $_DT->to_local_file_name(
	$_F->get_modified_date_time("$src_dir/INDEX.BDM"));
    my($cp) = sub {
	my($s, $d) = @_;
	$self->print($s, "\n");
	system('cp', '-r', '-p', '-v', "$src_dir/$s", $d) == 0 || die;
    };
    $self->usage_error($dst_dir, ': already exists; remove first')
	if -e ($dst_dir = "$dst_dir/$date");
    $_F->do_in_dir($_F->mkdir_p($dst_dir), sub {
        $self->print('Created ', $_F->pwd, "\n");
	# Ignore errors, because chflags is wrong somehow
	system('cp', '-r', '-p', "$src_dir/../CANON", 'CANON');
	system("mkdir -p CERTIFICATE/BACKUP BDMV/{BDJO,JAR,AUXDATA,BACKUP}");
	$_F->do_in_dir(BDMV => sub {
	    $cp->(qw(INDEX.BDM index.bdmv));
	    $cp->(qw(MOVIEOBJ.BDM MovieObject.bdmv));
	    foreach my $x (
		[qw(PLAYLIST MPL mpls)],
		[qw(CLIPINF CPI clpi)],
		[qw(STREAM MTS m2ts)],
	    ) {
		my($dir, $src, $dst) = @$x;
		Bivio::IO::File->mkdir_p($dir);
		Bivio::IO::File->do_in_dir($dir, sub {
		    foreach my $b (
			map(/(\w+)\.$src$/, glob("$src_dir/$dir/*.$src")),
		    ) {
			$cp->("$dir/$b.$src", "$b.$dst");
		    }
		    return;
		});
	    }
	});
	my($rm) = [`find . -name \.DS_Store`];
	system('rm', '-rf', @$rm)
	    if @$rm;
	system('chmod', '-R', 'a+rX-w', '.');
    });
    return;
}

sub init_avchd_disk {
    my($self, $src_tgz, $dst_disk) = shift->name_args([
	[qw(src_tgz FilePath), "$ENV{HOME}/video/init_avchd.tgz"],
	[qw(dst_disk FilePath /Volumes/CANON_HDD)],
    ], \@_);
    my($dst) = "$dst_disk/AVCHD";
    $self->are_you_sure("ERASE $dst and reinitialize?");
    $_F->do_in_dir($dst_disk, sub {
        $_F->rm_rf($dst);
        system("tar xzf $src_tgz") == 0 || die;
	return;
    });
    return;
}

1;
