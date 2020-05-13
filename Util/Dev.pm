# Copyright (c) 2008-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Dev;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
b_use('IO.ClassLoaderAUTOLOAD');


sub USAGE {
    return <<'EOF';
usage: b-dev [options] command [args..]
commands
  bashrc_b_env_aliases - defines b_env and b_<prefix> aliases from Util.Release->map_projects
  setup_all - calls other setup_* methods
  setup_bconf_d_defaults_bconf - creates ~/bconf.d/defaults.bconf
  setup_btest_mail - creates ~/btest-mail/ and ~/.procmailrc
  setup_src - creates ~/src
EOF
}

sub bashrc_b_env_aliases {
    my($self) = @_;
    return join(
	" ;\n",
	'b_env() { eval $(b-env "$@") && b_ps1 $1; }',
	@{ShellUtil_Release()->map_projects(
	    sub {
		my($root, $prefix) = @_;
		return "b_$prefix\() { b_env $prefix $root; }";
	    },
	)},
    );
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

1;
