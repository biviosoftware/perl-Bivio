# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::NewApp;
use strict;
$Bivio::Util::NewApp::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::NewApp::VERSION;

=head1 NAME

Bivio::Util::NewApp - creates initial structure for a new application

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Util::NewApp;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Util::NewApp::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Util::NewApp>

=cut

#=IMPORTS
use Bivio::IO::File;
use Bivio::Template::Util::SQL;
use Bivio::Template::Facade;
use Bivio::Template::BConf;
use Bivio::Template::DevelBConf;
use Bivio::Template::TaskId;
use Bivio::Template::TypeError;
use Bivio::Template::MySiteRedirect;
use Bivio::Template::AppSQL;
use Env qw(HOME);
#=VARIABLES

my($_SRC_PATH) = "~/src/perl";

=head1 METHODS

=cut

=for html <a name="OPTIONS"></a>

=head2 OPTIONS() : 



=cut

sub OPTIONS {
    return {
	%{__PACKAGE__->SUPER::OPTIONS()},
#	facade => ['String', ''],
    };
}

=for html <a name="OPTIONS_USAGE"></a>

=head2 OPTIONS_USAGE() : 



=cut

sub OPTIONS_USAGE {
    return <<'EOF';
EOF
}

=for html <a name="USAGE"></a>

=head2 USAGE() : 



=cut

sub USAGE {
    return <<'EOF';
usage: b-newapp [options] command [args...]
commands:
    create appname dbname facade... -- creates the directory structure and initial db files for a new application.
EOF
}

=for html <a name="create"></a>

=head2 create()

creates the initial application files. "Company" is hard coded for now :-)


=cut

sub create {
    my($self, $appname, $dbname, $facade) = @_;
    $facade = $dbname unless $facade;
    print "\nCreating directories for " . $appname;
    _system("mkdir -p $_SRC_PATH/$appname/Facade");
    map({
	print "\n\t", $_;
	_system("mkdir -p $_SRC_PATH/$appname/files/$_");
    } qw(view/adm view/site_root/hm plain/i plain/d cache ddl));
    map({
	_system("mkdir -p $_SRC_PATH/$appname/$_");
    } qw(Delegate HTMLWidget Model Action Type UI Util));
    _system("cd $_SRC_PATH/$appname/files/ && ln -s . $facade");
    _system("cd $_SRC_PATH/$appname/files/ddl");
    map({
	_system("touch $_SRC_PATH/$appname/files/ddl/$facade-$_.sql");
    } qw(tables constraints sequences));
    _system("cp $_SRC_PATH/Bivio/Template/files/plain/i/* $_SRC_PATH/$appname/files/plain/i/");
    print "\nCreating ddl files for " . $appname;
    _create_ddl_files($appname);
    print "\nCreating boilerplate code... ";
    map({
	my($file, $util) = @$_;
	_write_boilerplate("$HOME/src/perl/$appname/$file", $util->new,
	    $appname, $dbname, $facade, "Company");
	print "\n\t", $file;

	} (
	    ["Util/SQL.pm", 'Bivio::Template::Util::SQL'],
	    ["Facade/$appname.pm", 'Bivio::Template::Facade'],
	    ["Facade/BConf.pm", 'Bivio::Template::BConf'],
	    ["TaskId.pm", 'Bivio::Template::TaskId'],
	    ["TypeError.pm", 'Bivio::Template::TypeError'],
	    ["Action/MySiteRedirect.pm", 'Bivio::Template::MySiteRedirect'],
	    ["Util/$facade-sql", 'Bivio::Template::AppSQL'],
	   )
       );
    print "\nCreating developer bconf for " . $appname;
    _make_bconf("$HOME/bconf/$appname.bconf", $appname, $dbname);
    print "\nDone\n";
    return;
}


#=PRIVATE SUBROUTINES

# _create_ddl_files() : 
#
#
#
sub _create_ddl_files {
    my($appname) = @_;
    _system("cp $_SRC_PATH/Bivio/Template/files/ddl/bOP*sql ~/src/perl/$appname/files/ddl/");
    return;
}

# _make_bconf() : 
#
#
#
sub _make_bconf {
    my($filename, $appname, $dbname) = @_;
    my($bconf) = Bivio::Template::DevelBConf->new($appname, $dbname);
    my($buffer) = $bconf->get_code;
    my($file) = Bivio::IO::File->write($filename, \$buffer);
    return;
}

# _system(string command, string_ref output)
#
# Executes the specified command, appending any results to the output.
# Dies if the system call fails.
#
sub _system {
    my($command, $output) = @_;
    my($die) = Bivio::Die->catch(sub {
	$command =~ s/'/"/g;
	$$output .= "** $command\n";
	$$output .= ${__PACKAGE__->piped_exec("sh -ec '$command' 2>&1")};
	return;
    });
    return unless $die;
    Bivio::IO::Alert->print_literally(
	$$output . ${$die->get('attrs')->{output}});
    $die->throw;
    # DOES NOT RETURN
}

# _write_boilerplate() : 
#
#
#
sub _write_boilerplate {
    my($filename, $module, $appname, $dbname, $facade) = @_;
    my($buffer) = $module->get_code($appname, $dbname, $facade, "Company");
    my($file) = Bivio::IO::File->write($filename, \$buffer);
    return;
}



=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
