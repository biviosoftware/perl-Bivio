# Copyright (c) 2001 bivio Software Artisans, Inc.  All Rights reserved.
# $Id$
package Bivio::Util::POD;
use strict;
$Bivio::Util::POD::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::POD::VERSION;

=head1 NAME

Bivio::Util::POD - manipulate pod (perl's plain old documentation)

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Util::POD;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Util::POD::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Util::POD> manipulates pod (perl's plain old documentation).

L<to_html|"to_html"> takes the drudgery of running I<Pod::Html>.
It makes some assumptions, creates a relative tree, and creates
an index.

=cut

=head1 CONSTANTS

=cut

=for html <a name="OPTIONS"></a>

=head2 OPTIONS : hash_ref

Adds the I<-checkout> and I<-package_dir> options.

=cut

sub OPTIONS {
    my($proto) = @_;
    my($res) = $proto->SUPER::OPTIONS;
    $res->{package_dir} = ['Line', undef];
    $res->{checkout} = ['Boolean', 0];
    return $res;
}

=for html <a name="OPTIONS_USAGE"></a>

=head2 OPTIONS_USAGE : string

special options:
    -checkout - runs cvs checkout on package_dir first
    -package_dir dir - limits the operation to this package's directory

=cut

sub OPTIONS_USAGE {
    my($proto) = @_;
    return <<'EOF'.$proto->SUPER::OPTIONS_USAGE;
special options:
    -checkout - runs cvs checkout on package_dir first
    -package_dir dir - limits the operation to this package's directory
EOF
}

=for html <a name="USAGE"></a>

=head2 USAGE : string

commands:
    to_html input_dir output_dir -- converts input_dir pods to output_dir html

=cut

sub USAGE {
    return <<'EOF';
usage: b-pod [options] command [args...]
commands:
    to_html input_dir output_dir -- converts input_dir pods to output_dir html
EOF
}

#=IMPORTS
use Bivio::HTML;
use Bivio::IO::File;
use Bivio::IO::Trace;
use File::Basename ();
use File::Find ();
use Pod::Html ();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_HTML_ROOT_TAG) = '/SOME/UNIQUE/PATH/TO/FIND';

=head1 METHODS

=cut

=for html <a name="to_html"></a>

=head2 to_html(string input_dir, string output_dir) : files

Parses I<input_dir> for perl modules (file names that end with .pm)
and programs (files which contain #!.*perl).  Once parsed, converts
all files to html and writes result to I<output_dir>.

Makes all links relative. Generates an index.

=cut

sub to_html {
    my($self, $input_dir, $output_dir) = @_;
    $self->usage('missing input_dir or output_dir')
	    unless $input_dir && $output_dir;
    my($state) = {
	self => $self,
	input_dir => $input_dir,
	output_dir => $output_dir,
	package_dir => $self->unsafe_get('package_dir') || '',
	pod => {},
	html => {},
    };
    _checkout($self, $input_dir) if $self->unsafe_get('checkout');
    $self->usage('no files found in ', $input_dir) unless _find_files($state);
    _to_html($state);
    _html_index($state);
    return "Translated ".int(@{$state->{modules}})." files\n";
}

#=PRIVATE METHODS

# _checkout(self, string input_dir)
#
# Runs cvs checkout on files
#
sub _checkout {
    my($self, $input_dir) = @_;
    my($pkg) = $self->unsafe_get('package_dir');
    $self->usage('package must be supplied with -checkout') unless $pkg;
    Bivio::IO::File->mkdir_p($input_dir);
    system("cd $input_dir && cvs -Q checkout $pkg") == 0
	    || Bivio::Die->die('checkout ', $pkg, ' failed');
    return;
}

# _find_files(hash_ref state)
#
# Sets hash_ref $files in $state.
#
sub _find_files {
    my($state) = @_;
    my($pkg) = $state->{package_dir};
    File::Find::find(
	sub {
	    my($n) = $File::Find::name;
	    return $File::Find::prune = 1
		unless ! -d || !/^CVS$/ && /^(?:\.|[A-Z]\w*)$/;
	    return unless -r && -f;

	    # Legitimate perl file
	    return unless $n =~ s/\.(pm|PL|pl)$// || $n =~ m!/\w[-\w]*$!;
	    $n =~ s/^\Q$state->{input_dir}\E\/*//;

	    # Only add files which are in the package specified
	    return unless !$pkg || $n =~ /^\Q$pkg\E\//;

	    my($info) = _pod_info($_);
	    return unless defined($info);

	    $state->{pod}->{$n} = $File::Find::name;
	    $state->{html}->{$n} = $state->{output_dir}.'/'.$n.'.html';
	    $state->{info}->{$n} = $info;
	    my($d) = File::Basename::dirname($n);
	    $d =~ s/^\.$//;
	    $d =~ s/\//::/g;
	    $state->{parent}->{$n} = $d;
	    _trace($n, ': ', $info) if $_TRACE;
	    return;
	},
	$state->{input_dir},
    );
    $state->{modules} = [
	sort {
	    # Sort by package then file.  This avoids '/' problems.
	    my($x) = $state->{parent}->{$a} cmp $state->{parent}->{$b};
	    return $x ? $x : $a cmp $b;
	}
	keys(%{$state->{pod}})
    ];
    return %{$state->{pod}} ? 1 : 0;
}

# _fixup_html(string module, string html)
#
# Rewrites html with $_HTML_ROOT_TAG replaced with relative paths.
#
sub _fixup_html {
    return;
    my($module, $html) = @_;
    my($rel_root) = $module;
    $rel_root =~ s!/+!/!g;
    $rel_root =~ s![^/]+$!!;
    $rel_root =~ s![^/]+!..!g;
    my($data) = Bivio::IO::File->read($html);
    $$data =~ s/\Q$_HTML_ROOT_TAG\E\/*/$rel_root/sg;
    Bivio::IO::File->write($html, $data);
    return
}

# _html_index(hash_ref state)
#
# Creates an index of all the files.
#
sub _html_index {
    my($state) = @_;
    my($pkg) = $state->{package_dir};
    $pkg .= ' ' if $pkg;
    my($html) = "<html><head><title>${pkg}Package Index</title></head><body>"
	    ."<h1>${pkg}Package Index</h1>\n";
    my($last_parent) = 'no-match';
    local($_);
    foreach my $module (@{$state->{modules}}) {
	my($parent) = $state->{parent}->{$module};
	# get the root package and add heading if it has changed
	my($base) = $module;
	$base =~ s/.*\///;
	unless ($last_parent eq $parent) {
	    $html .= "<h2>$parent</h2>\n" if $parent;
	    $last_parent = $parent;
	}
	my($info) = Bivio::HTML->escape($state->{info}->{$module});
	$html .= '<a href="'.$module.'.html">'.$base.'</a>'
		.($info ? ' -- '.$info : '')
		."<br>\n";
    }
    $html .= '</body></html>';
    Bivio::IO::File->write($state->{output_dir}.'/index.html', \$html);
    return;
}

# _pod_info(string file) : string
#
# Parses the info from file.  If the file doesn't have pod, returns
# undef.  Otherwise, returns
#
sub _pod_info {
    my($file) = @_;
    my($desc) = '';
    return undef unless open(IN, '< '.$file);
    my($res) = undef;
    TRY: {
	last unless -T IN;
	my($first_line) = scalar(<IN>);
	# The file must have a legitimate suffix or begin with #!.*perl
	last unless $first_line
		&& ($first_line =~ /^#!.*perl/ || $file =~ s/.(pm|PL|pl)$//);
	my($ok);
	local($_);

	# Avoid searching large log files.  POD should be pretty near top
	my($max_lines) = 1000;

	while (<IN>) {
	    if ($ok && s/^(\S*$file)\s+-\s+//) {
		chomp;
		last;
	    }
	    last TRY if --$max_lines < 0;
	    /^=head1\s+NAME/ && $ok++;
	}
	$res = $ok ? defined($_) ? $_ : '' : undef;
    }
    close(IN);
    return $res;
}

# _to_html(hash_ref state)
#
# Generates HTML for $state->{modules}.
#
sub _to_html {
    my($state) = @_;
    foreach my $module (@{$state->{modules}}) {
	my($pod) = $state->{pod}->{$module};
	my($html) = $state->{html}->{$module};
	Bivio::IO::File->mkdir_parent_only($html);
	Pod::Html::pod2html(
	    '--infile='.$pod,
	    '--outfile='.$html,
	    '--htmlroot='.$_HTML_ROOT_TAG,
	);
	_fixup_html($module, $html);
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans, Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
