# Copyright (c) 2001-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::POD;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Bivio::HTML;
use Bivio::IO::File;
use Bivio::IO::Trace;
use File::Basename ();
use File::Find ();
use Pod::Html ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_HTML_ROOT_TAG) = '/SOME/UNIQUE/PATH/TO/FIND';

sub OPTIONS {
    my($proto) = @_;
    my($res) = $proto->SUPER::OPTIONS;
    $res->{package_dir} = ['Line', undef];
    $res->{checkout} = ['Boolean', 0];
    return $res;
}

sub OPTIONS_USAGE {
    my($proto) = @_;
    return <<'EOF'.$proto->SUPER::OPTIONS_USAGE;
special options:
    -checkout - runs cvs checkout on package_dir first
    -package_dir dir - limits the operation to this package's directory
EOF
}

sub USAGE {
    return <<'EOF';
usage: b-pod [options] command [args...]
commands:
    to_comments File.pm -- converts POD in-place to # comments
    to_html input_dir output_dir -- converts input_dir pods to output_dir html
EOF
}

sub to_comments {
    my($self, $file_pm) = @_;
    Bivio::IO::File->do_read_write($file_pm, sub {
        my($which_hash) = 'init';
	my($toss_for_emacs) = 0;
	my($in_description) = 0;
        my($parts) = {
	    constant => [],
	    method => [],
	    private => [],
	    nl => [''],
	    init => [q{our($VERSION) = sprintf('%d.%02d', q$}
	        . q{Revision: 0.0$ =~ /\d+/g);}],
	    end => ['1;', ''],
	};
	my($header_done) = 0;
	my($copy_to_end);
	my($lineno) = 0;
	my($err) = sub {
	    Bivio::Die->die("$file_pm:$lineno ", @_, "\n", $parts);
	};
	my($push) = sub {
	    my($part, $v) = @_;
	    $parts->{$part} ||= [];
	    push(@{$parts->{$part}}, $v)
		if defined($v);
	    return $parts->{$part};
	};
	my($clear) = sub {
	    my($part) = @_;
	    return delete($parts->{$part});
	};
	my($clear_comment) = sub {
	    my($c) = $clear->('comment') || [];
	    pop(@$c)
		while @$c && $c->[$#$c] =~ /^#\s*$/;
	    shift(@$c)
		while @$c && $c->[0] =~ /^#\s*(?:$|_\w+\()/;
	    return $c;
	};
	my($line);
	foreach $line (split(/\n/, ${shift(@_)})) {
	    $lineno++;
	    if ($line =~ /^=/ && !$parts->{pod}) {
		$which_hash = 'comment'
		    if $line =~ /^=head1 (?:METHOD|FACTORIES)/;
		$push->('pod', undef);
		$in_description = 1
		    if $line =~ /^=head1\s+DESCRIPTION/i;
		$header_done = 1;
		$clear->('comment');
	    }
	    if (my $pod = $parts->{pod}) {
		$line =~ s/^=item //;
		$push->(pod => $line)
		    unless $line =~ /^=/;
		if ($line =~ /^=cut/) {
		    $parts->{comment} = [
			grep(s{^}{#@{[$_ =~ /\S/ ? ' ' : '']}}s,
			    @{$clear->('pod') || []}),
		    ];
		    if ($in_description) {
			$parts->{description} = $clear_comment->();
			$in_description = 0;
		    }
		}
		next;
	    }
	    unless ($header_done) {
		$push->(header => $line)
		    if $line =~ /^(?:# Copyright|package |use strict|# \$Id)/;
		next;
	    }
	    next
		if $line =~ /^#=/;
	    if ($line =~ /^#/ && !$parts->{sub}) {
		$push->($which_hash => $line);
		next;
	    }
	    if ($line =~ s/^use vars //) {
		$push->(init => [map("our($_);", Bivio::Die->eval_or_die($line))]);
		next;
	    }
	    next
		if $line =~ /^(?:Bivio::IO::Trace|1;)/;
	    if ($line =~ /^\$_\s*=\s*\<\<\'\}/) {
		$toss_for_emacs = 1;
		next;
	    }
	    if ($line =~ /^use /) {
		$push->(import => $line)
		     if $parts->{import};
		next;
	    }
	    if ($line =~ /^\@.*::ISA = (?:qw.|\(')([\w:]+)/) {
		$push->(import => qq{use Bivio::Base '$1';});
		next;
	    }
	    $push->('sub')
		if $line =~ /^sub \w+ \{/;
	    if (my $sub = $parts->{sub}) {
		if (@$sub == 1) {
		    if ($line =~ /^\s+my/) {
			$push->(sub => $line);
			$line = undef;
		    }
		    push(@$sub, grep(s/^/    /, @{$clear_comment->()}));
		    next unless defined($line);
		}
		$push->(sub => $line);
		if ($line =~ /^\}\s*$/) {
		    $push->(sub => '');
		    $clear->('sub');
		    $push->(
			$sub->[0] =~ /sub [A-Z]/ ? 'constant'
			    : $sub->[0] =~ /sub _/ ? 'private' : 'method',
			$sub,
		    ) unless $toss_for_emacs;
		    $toss_for_emacs = 0;
		}
		next;
	    }
	    if ($line =~ /^\S/ && $parts->{init}) {
		$push->(init => $line);
		next;
	    }
	}
	$parts->{import} = [sort(@{$parts->{import}})];
	foreach my $p (qw(constant method private)) {
	    $parts->{$p} = [sort {$a->[0] cmp $b->[0]} @{$parts->{$p}}];
	}
	$parts->{import} = [sort(@{$parts->{import}})];
	return join(
	    "\n",
	    map(ref($_) ? @$_ : $_,
		map(@{$parts->{$_} || []},
		qw(header base import nl description nl init nl constant method private end))),
        );
    });
    return;
}

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

sub _checkout {
    my($self, $input_dir) = @_;
    my($pkg) = $self->unsafe_get('package_dir');
    $self->usage('package must be supplied with -checkout') unless $pkg;
    Bivio::IO::File->mkdir_p($input_dir);
    system("cd $input_dir && cvs -Q checkout $pkg") == 0
	    || Bivio::Die->die('checkout ', $pkg, ' failed');
    return;
}

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

sub _fixup_html {
    my($module, $html) = @_;
    my($rel_root) = $module;
    $rel_root =~ s!/+!/!g;
    $rel_root =~ s![^/]+$!!;
    $rel_root =~ s![^/]+!..!g;
    my($data) = Bivio::IO::File->read($html);
    my($n) = $$data =~ s/$_HTML_ROOT_TAG\/*/$rel_root/sg;
    Bivio::IO::File->write($html, $data);
    return
}

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

    # Delete junk that POD creates
    unlink('pod2htmd.x~~');
    unlink('pod2htmi.x~~');
    return;
}

1;
