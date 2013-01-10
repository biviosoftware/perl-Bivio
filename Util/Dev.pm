# Copyright (c) 2008-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Dev;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
b_use('IO.ClassLoaderAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: b-dev [options] command [args..]
commands
  bashrc_b_env_aliases - defines b_env and b_<prefix> aliases from Util.Release->map_projects
  setup - calls other setup_* methods
  setup_bconf_d_defaults_bconf - creates ~/bconf.d/defaults.bconf
  setup_btest_mail - creates ~/btest-mail/ and ~/.procmailrc
  setup_src_perl - creates ~/src/perl and create_test_db
EOF
}

sub bashrc_b_env_aliases {
    my($self) = @_;
    return join(
	" ;\n",
	'function b_env { eval $(b-env "$@") && b_ps1 $1; }',
	@{ShellUtil_Release()->map_projects(
	    sub {
		my($root, $prefix) = @_;
		return "alias b_$prefix='b_env $prefix $root'";
	    },
	)},
    );
}

sub setup {
    my($proto, $bunit_args) = @_;
    $proto->setup_btest_mail;
    $proto->setup_bconf_d_defaults_bconf;
    $proto->setup_src_perl($bunit_args);
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
#	stack_trace_error => 1,
#	stack_trace => 1,
    },
    'Bivio::IO::Alert' => {
#	stack_trace_warn => 1,
#	stack_trace_warn_deprecated => 1,
#	max_arg_length => 1000000,
#	max_element_count => 50,
#	max_arg_depth => 5,
    },
    'Bivio::Biz::Action::AssertClient' => {
#	hosts => [qw()],
    },
    'Bivio::IO::Trace' => {
#	command_line_arg => 'sql',
#	package_filter => '/Agent|Task|Model/',
#	call_filter => '!grep(/Can.t locate/, @$msg)',
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

sub setup_src_perl {
    my($proto, $bunit_args) = @_;
    my($perllib) = "$ENV{HOME}/src/perl";
    return
	if -r $perllib;
    $proto->print("Created: $perllib\n");
    my($ba) = sub {
	return ($bunit_args || {})->{shift(@_)} || shift(@_);
    };
    IO_File()->do_in_dir(
	IO_File()->mkdir_parent_only($perllib),
	sub {
	    my($module) = $ba->('cvs_module', 'perl');
	    my($arg) = $ba->('create_test_db_args', '');
	    foreach my $cmd (
		"cvs checkout $module",
		"bivio sql init_dbms$arg",
		"bivio project link_facade_files$arg",
		$arg ? () : 'bivio sql -force create_test_db',
	    ) {
		$proto->print("Created: $cmd\n");
		$proto->piped_exec("env PERLLIB=$perllib BCONF=Bivio::PetShop $cmd 2>&1");
		# DEBUG: You may need to do something like this to debug some of this:
		# system("cp /home/nagler/src/perl/Bivio/Util/Project.pm $perllib/Bivio/Util");
	    }
	    return;
	},
    );
    return;
}

1;
