# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::XML::DocBook;
use strict;
our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::XML::DocBook - converts XML DocBook files to HTML and counts words

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::XML::DocBook;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::XML::DocBook::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::XML::DocBook> converts XML DocBook files to HTML.
The mapping is only partially implemented by L<to_html|"to_html">.
Also can L<count_words|"count_words"> on XML files.

=cut


=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns usage string.

=cut

sub USAGE {
    return <<'EOF';
usage: b-docbook [options] command [args...]
commands:
    to_html file.xml -- converts input xml to output html
    count_words file.xml -- returns number of words in XML file
    to_pdf <dir> <a4|letter> file.pdf [test] -- converts xpip chapters from dir to file.pdf
EOF
}

#=IMPORTS
use Bivio::IO::File;
use HTML::Entities ();
use XML::Parser ();

#=VARIABLES
my($_XML_TO_HTML_PROGRAM) = {
    # Many-to-one mappings
    map({$_ => []} qw(
        answer/para
	figure
	qandaentry
	qandaset
	question/para
	sect1
	sect2
	simplesect
	term
	varlistentry
    )),
    map({$_ => ['i']} qw(
	citetitle
	firstterm
	replaceable
    )),
    map({$_ => ['tt']} qw(
	classname
	command
	constant
	envar
	filename
	function
	literal
	property
	type
	userinput
	varname
    )),
    map({$_ => '<i>${label}</i>${_}<br>'} qw(
        answer
        question
    )),
    map({(
	$_ => sub {
	    my($attr, $html, $clipboard) = @_;
	    $$html .= "<h3>Footnotes</h3><ol>\n$clipboard->{footnotes}</ol>\n"
		if $clipboard->{footnotes};
	    return "<html><body>$$html</body></html>";
	},
	"$_/title" => ['h1'],
    )} qw(
        chapter
        preface
    )),

    # One-to-one mappings
    abstract => '<p><table width="70%" align="center" border="0"><tr>'
        . '<td align="center">${_}</td></tr></table></p>',
    attribution => sub {
	my($attr, $html, $clipboard) = @_;
	# epigraph requires attribution be first in O'Reilly's dblite
	# DTD.  This means we have to store it in the clipboard and
	# retrieve it in epigraph.  Element order shouldn't matter...
	$clipboard->{attribution} = qq{<div align="right">-- $$html</div>};
	return '';
    },
    blockquote => ['blockquote'],
    comment => '<i>[COMMENT: ${_}]</i>',
    emphasis => sub {
	my($attr, $html) = @_;
	my($r) = !defined($attr->{role}) ? 'i'
	    : $attr->{role} eq 'bold' ? 'b'
	    : die($attr->{role}, ': bad role on emphasis');
	return "<$r>$$html</$r>";
    },
    epigraph => sub {
	my($attr, $html, $clipboard) = @_;
	return "<blockquote>$$html$clipboard->{attribution}</blockquote>";
    },
    'figure/title' => ['center', 'b'],
    footnote => sub {
	my($attr, $html, $clipboard) = @_;
	$clipboard->{footnote_idx}++;
	$clipboard->{footnotes}
	    .= qq(<li><a name="$clipboard->{footnote_idx}"></a>$$html</li>\n);
	return qq(<a href="#$clipboard->{footnote_idx}">)
	    . "[$clipboard->{footnote_idx}]</a>";

    },
    foreignphrase => ['i'],
    graphic => {
	template => '<div align="${align}"><img border="0" src="${fileref}"></div>',
	default_align => 'center',
    },
    itemizedlist => ['ul'],
    listitem => ['li'],
    literallayout => sub {
	my($attr, $html) = @_;
	$$html =~ s/\n/<br>\n/g;
	$$html =~ s/ /&nbsp;/g;
	return $$html;
    },
    note => '<blockquote><strong>Note:</strong><i>${_}</i></blockquote>',
    orderedlist => ['ol'],
    para => ['p'],
    programlisting => ['blockquote', 'pre'],
    'qandaset/para' => ['p', 'i'],
    quote => '"${_}"',
    'quote/quote' => q{'${_}'},
    'sect1/title' => ['h3'],
    'sect2/title' => ['h4'],
    sidebar => '<table width="95%" border="1" cellpadding="5" bgcolor="#CCCCCC">'
        . '<tr><td>${_}</td></tr></table>',
    'sidebar/title' => ['h3'],
    superscript => ['sup'],
    systemitem => '<a href="${_}">${_}</a>',
    trademark => '${_}&#153;',
    variablelist => ['dl'],
    'varlistentry/listitem' => ['dd'],
    'varlistentry/term' => ['dt'],
    warning =>
        '<blockquote><strong>Warning!</strong><p><i>${_}</i></blockquote>',
    xref => sub {
	my($attr, $html, $clipboard) = @_;
	my($glob) = $clipboard->{xml_file};
	$glob =~ s,[^/]+(?=\.xml$),\*,;
	my($target) = `fgrep -i -l 'id="$attr->{linkend}">' $glob`;
	die($attr->{linkend}, ': not found in ', $glob)
	    unless $target;
	chomp($target);
	my($title) = ${Bivio::IO::File->read($target)}
	    =~ m{id="$attr->{linkend}".*?<title>(.*?)</title}s;
	die($attr->{linkend}, ': title not found in ', $target)
	    unless $title;
	$target =~ s/xml$/html/;
	$target =~ s,.*/,,;
	return qq{<a href="$target#$attr->{linkend}">$title</a>};
    },
};

my($tex) = '';
my($ignore) = 0;
my($in_attrib) = 0;
my($in_preface) = 0;
my($in_keyword) = 0;
my($keyword) = '';
my($clean_normal) = 1;
my($programlisting) = 0;
my($clean_literal) = 0;
my($attrib) = '';
my($label) = '';
my($GRAPHIC_WIDTH) = "4.3in";
my($dir) = '';

# used to clean latex special characters
# used when $clean_normal
my($_CLEAN_CHAR) = {
    "\n" => ' ',
    '_' => '\_',
    '$' => '\$',
    '&' => '\&',
    '%' => '\%',
    '#' => '\#',
    '{' => '\{',
    '}' => '\}',
    '\\' => '$\backslash$',
    '^' => '\symbol{94}',
    '~' => '\symbol{126}',
};

# used to clean latex special characters in "alltt" environments
# used when !$clean_normal
my($_CLEAN_VERB_CHAR) = {
    '{' => '\{',
    '}' => '\}',
    '\\' => '\symbol{92}',
    "\n" => ' \newline ',
};

my(@_CHAPTERS) = (
    'preface.xml',
    'the-problem.xml',
    'extreme-programming.xml',
    'perl.xml',
    'release-planning.xml',
    'iteration-planning.xml',
    'pair-programming.xml',
    'tracking.xml',
    'acceptance-testing.xml',
    'coding-style.xml',
    'logistics.xml',
    'test-driven-design.xml',
    'continuous-design.xml',
    'unit-testing.xml',
    'refactoring.xml',
    'its-a-smop.xml',
   );

# used to convert xml tags to latex commands
my($_XML_TO_LATEX_PROGRAM) = {
    # Many-to-one mappings
    # Do nothing unless a label should be defined (id=foo)
    map({$_ => sub { 
	 my($args) = @_;
	 return '' unless defined($args);
	 return '' unless $args =~ /id=/;
	 $args =~ s/id=//;
	 $args =~ s/"//g;
	 $args =~ s/\///;
	 $label = $args;
	 return '';
     }
    } qw(
        answer/para
	question/para
        figure
	sect1
	sect2
	simplesect
	term
	varlistentry
        answer//para
	question//para
	/figure
	/sect1
	/sect2
	/simplesect
	/term
	/varlistentry
    )),
    map({$_ => '\textit{'} qw(
	citetitle
	firstterm
	replaceable
    )),
    map({$_ => '}'} qw(
	/citetitle
	/firstterm
	/replaceable
    )),
    map({$_ => '\texttt{'} qw(
	classname
	command
	constant
	envar
	filename
	function
	literal
	property
	type
	userinput
	varname
    )),
    map({$_ => '}'} qw(
	/classname
	/command
	/constant
	/envar
	/filename
	/function
	/literal
	/property
	/type
	/userinput
	/varname
    )),
    # Do nothing unless label should be defined (id=foo)
    map({$_ => sub {
	 my($args) = @_;
	 return '' unless defined($args);
	 return '' unless $args =~ /id=/;
	 $args =~ s/id=//;
	 $args =~ s/"//g;
	 $args =~ s/\///;
	 $label = $args;
	 return '';
     }
    } qw(
        chapter
    )),
    map({$_ => ''} qw(
        /chapter
    )),

    # One-to-one mappings
    # Have to save the attribution to be output after the epigraph
    attribution => sub {
	$in_attrib = 1;
	$attrib = '';
	return '';
    },
    '/attribution' => sub {
	$in_attrib = 0;
	return '';
    },
    blockquote => '\begin{quote}',
    '/blockquote' => '\end{quote}',
    'chapter/title' => '\chapter{',
    # Output label for each chapter
    'chapter//title' => sub {
	return '}' . "\n" if $label eq '';
	my($result) = '}\label{' . $label . '}' . "\n";
	$label = '';
	return $result;
    },
    # Ignore comments
    comment => sub {
	$ignore = 1;
	return '';
    },
    '/comment' => sub {
	$ignore = 0;
	return '';
    },
    emphasis => '\emph{',
    '/emphasis' => '}',
    # Use texttt mode because some epigraphs use verbatim mode
    # which always appears as as true type font
    epigraph => '\begin{quote}',
    # Output saved attribution after epigraph is closed
    '/epigraph' => sub {
	return '\end{quote}}\begin{flushright}-- ' .
	    $attrib . '\end{flushright}' . "\n";
    },
    'figure/title' => '\begin{center}\textbf{',
    'figure//title' => '}\end{center}' . "\n",
    'firstterm' => sub {
	$in_keyword = 1;
	$keyword = '';
	return '\index{';
    },
    '/firstterm' => sub {
	$in_keyword = 0;
	return '}' . $keyword;
    },
    footnote => '\footnote{',
    '/footnote' => '}',
    foreignphrase => '\textit{',
    '/foreignphrase' => '}',
    graphic => sub {
	my($args) = @_;
	my($file);
	$file = $` if $args =~ / /;
	$file = $args if !($args =~ / /);
	$file =~ s/fileref=//;
	$file =~ s/\"//g;
	return '\begin{center}\includegraphics[width=' . $GRAPHIC_WIDTH . ']{' .
	    $dir . '/' . $file . '}\end{center}' . "\n";
    },
    itemizedlist => '\begin{itemize}' . "\n",
    '/itemizedlist' => '\end{itemize}' . "\n",
    listitem => '\item ',
    '/listitem' => "\n",
    literallayout => sub {
	$clean_normal = 0;
	return '';
    },
    '/literallayout' => sub {
	$clean_normal = 1;
	return '' . "\n";
    },
    para => "\n",
    '/para' => "\n",
    'preface/title' => '\chapter*{',
    'preface//title' => sub {
	return '}' . "\n" if $label eq '';
	my($result) = '}\label{' . $label . '}' . "\n" .
	    '\addcontentsline{toc}{chapter}{Preface}' . "\n";
	$label = '';
	return $result;
    },
    'preface' => sub {
	my($args) = @_;
	return '' unless defined($args);
	return '' unless $args =~ /id=/;
	$args =~ s/id=//;
	$args =~ s/"//g;
	$args =~ s/\///;
	$label = $args;
	$in_preface = 1;
	return '';
    },
    '/preface' => sub {
	$in_preface = 0;
	return '\mainmatter' . "\n";
    },
    programlisting => sub {
        $programlisting = 1;
	return '\newline\verb#';
    },
    '/programlisting' => sub {
        $programlisting = 0;
        _end_verb();
	return '\newline';
    },
    quote => '``',
    '/quote' => '\'\'',
    'sect1/title' => sub {
	$in_preface ? return '\section*{' : return '\section{';
    },
    'sect1//title' => sub {
	return '}' . "\n" if $label eq '';
	my($result) = '}\label{' . $label . '}' . "\n";
	$label = '';
	return $result;
    },
    'sect2/title' => sub {
	$in_preface ? return '\section*{' : return '\section{';
    },
    'sect2//title' => sub {
	return '}' . "\n" if $label eq '';
	my($result) = '}\label{' . $label . '}' . "\n";
	$label = '';
	return $result;
    },
    sidebar => sub {
	my($args) = @_;
	return "\n" . '\fbox{\fbox{\begin{minipage}{4.3in}' . "\n"
	    unless defined($args);
	return "\n" . '\fbox{\fbox{\begin{minipage}{4.3in}' . "\n"
	    unless $args =~ /id=/;
	$args =~ s/id=//;
	$args =~ s/"//g;
	$args =~ s/\///;
	$label = $args;
	return "\n" . '\fbox{\fbox{\begin{minipage}{4.3in}' . "\n"
    },
    '/sidebar' => '\end{minipage}}}' . "\n",
    superscript => '^{',
    '/superscript' => '}',
    systemitem => '\linebreak[3]',
    '/systemitem' => '',
    'term' => sub {
	$in_keyword = 1;
	$keyword = '';
	return '\index{';
    },
    '/term' => sub {
	$in_keyword = 0;
	$tex .= $keyword;
	return '}';
    },
    'title' => sub {
	$in_preface ? return '\section*{' : return '\section{';
    },
    '/title' => '}',
    variablelist => '\begin{description}' . "\n",
    '/variablelist' => '\end{description}' . "\n",
    'varlistentry/listitem' => "\n",
    'varlistentry//listitem' => "\n",
    'varlistentry/term' => '\item[',
    'varlistentry//term' => ']',
    warning => '\quote{\textbf{Warning!}\textit{${_}',
    '/warning' => '}',
    xref => sub {
	my($args) = @_;
	$args =~ s/linkend=//;
	$args =~ s/"//g;
	$args =~ s/\///;
	return '\nameref{' . $args . '}';
    },
    '/xref' => '', #Nothing to be done here
};

=head1 METHODS

=cut

=for html <a name="count_words"></a>

=head2 count_words(string xml_file) : int

Returns the words in XML content.

=cut

sub count_words {
    my($self, $xml_file) = @_;
    return _count_words(
	XML::Parser->new(Style => 'Tree')->parsefile($xml_file))
	. "\n";
}

=for html <a name="to_html"></a>

=head2 to_html(string xml_file) : string_ref

Converts I<xml_file> from XML to HTML.  Dies if the XML is not well-formed or
if a tag is not handled by the mapping.  See the initialization of
$_XML_TO_HTML_PROGRAM for the list of handled tags.

=cut

sub to_html {
    my($self, $xml_file) = @_;
    return _to_html(
	'',
	XML::Parser->new(Style => 'Tree')->parsefile($xml_file),
        {
	    xml_file => $xml_file,
	});
}

=for html <a name="to_pdf"></a>

=head2 to_pdf(string input_dir, string paper_size, string output_pdf)

=head2 to_pdf(string input_dir, string paper_size, string output_pdf, string $mode)

Converts the xpip xml chapters to a single book-style pdf.  If
$mode eq "test" then the program will output the resulting
tex file.

=cut

sub to_pdf {
    my($self, $input_dir, $paper_size, $output_pdf, $mode) = @_;
    print "usage: perl -w xpip2pdf.PL <input_dir> <a4|letter> <name>.pdf\n"
	unless defined($input_dir) && defined($paper_size) && ($output_pdf);
    return unless defined($input_dir) && defined($paper_size) && ($output_pdf);
    if ($output_pdf !~ /\.pdf/ ||
	($paper_size ne "letter" && $paper_size ne "a4")) {
	print "usage: perl -w xpip2pdf.PL <input_dir> <a4|letter> <name>.pdf\n";
	return;
    }
    my($output_root) = $output_pdf;
    $output_root =~ s/\.pdf//;
    my($output_tex) = $output_root . '.tex';
    my($output_idx) = $output_root . '.idx';
    $dir = $input_dir;

    _start_tex($paper_size);

    my($full_path);
    foreach my $xml_file (@_CHAPTERS) {
	$full_path = $input_dir . '/' . $xml_file;
	print "Processing $full_path\n";
	_process_xml_file($full_path);
    }

    _end_tex();

    _clean_tex();

    print $tex if defined($mode) && $mode eq "test";

    Bivio::IO::File->write($output_tex, $tex);
    system("pdflatex -interaction nonstopmode $output_tex > $output_root.log");
    system("makeindex -q $output_root");
    # LaTeX must be run thrice to process table of contents and index
    system("pdflatex -interaction nonstopmode $output_tex > $output_root.log");
    my($result) = system("pdflatex -interaction nonstopmode $output_tex > $output_root.log");
    foreach my $ext (qw(aux idx ilg ind log out toc)) {
	system("rm $output_root.$ext") unless $result < 0;
    }
    print "PDF Generation failed, check $output_root.log for details\n"
	if $result < 0;
    print "$output_pdf Created\n";

    return;
}

#=PRIVATE METHODS

# _clean_tex()
#
# Cleans the global tex string
#
sub _clean_tex {
    $tex =~ s/\\&quot;/"/g;
    $tex =~ s/\&quot;/"/g;
    $tex =~ s/\&amp;/&/g;
    $tex =~ s/\\&lt;/</g;
    $tex =~ s/\&lt;/</g;
    $tex =~ s/\\&gt;/>/g;
    $tex =~ s/\&gt;/>/g;
    $tex =~ s{(?<=^\\verb#)(\s+)}{' ' x int(length($1) / 2)}meg;
    return;
}

# _count_words(array_ref children) : int
#
# Counts the words in the literal children and recurses the tree.
#
sub _count_words {
    my($children) = @_;
    shift(@$children)
	if ref($children->[0]) eq 'HASH';
    my($res) = 0;
    my(@dontcare);
    while (@$children) {
	my($tag, $child) = splice(@$children, 0, 2);
	$res += $tag ? _count_words($child)
	    : scalar(@dontcare = split(' ', $child));
    }
    return $res;
}

# _end_tex()
#
# Adds necessary information to end of tex string
#
sub _end_tex {
    $tex .= <<'EOF';
\backmatter
\printindex
\end{document}
EOF
    return;
}

# _end_verb()
#
# Ends a verb or deletes \verb#
#
sub _end_verb {
    $tex .= '#'
	unless $tex =~ s/\\verb\#$//s;
    return;
}

# _eval_child(string tag, array_ref children, string parent_tag, hash_ref clipboard) : string
#
# _eval_child(string tag, array_ref children, string parent_tag, hash_ref clipboard) : string
#
# Look up $tag in context of $parent_tag to find operator, evaluate $children,
# and then evaluate the found operator.  Returns the result of _eval_op.
# Modifies $children so this routine is not idempotent.
#
sub _eval_child {
    my($tag, $children, $parent_tag, $clipboard) = @_;
    return HTML::Entities::encode($children)
	unless $tag;
    return _eval_op(
	_lookup_op($tag, $parent_tag),
        shift(@$children),
	_to_html($tag, $children, $clipboard),
	$clipboard);
}

# _eval_op(any op, hash_ref attr, string_ref html, hash_ref clipboard) : string
#
# Wraps $html in HTML tags defined by $op, prefixing with an anchor if
# $attr->{id}.  If $op is a ARRAY, call _to_tags() to convert the simple tag
# names to form the prefix and suffix.  If $op is a HASH or string (!ref),
# calls _eval_template.  If $op is CODE, call the subroutine with $html and
# $clipboard.  Dies if $op's type is not handled (program error in
# $_XML_TO_HTML_PROGRAM).
#
sub _eval_op {
    my($op, $attr, $html, $clipboard) = @_;
    substr($$html, 0, 0) = qq{<a name="$attr->{id}"></a>}
	if $attr->{id};
    return 'ARRAY' eq ref($op)
	    ? _to_tags($op, '') . $$html  . _to_tags([reverse(@$op)], '/')
	: 'CODE' eq ref($op)
	    ? $op->($attr, $html, $clipboard)
	: 'HASH' eq ref($op) || !ref($op)
	    ? _eval_template($op, $attr, $html)
        : Bivio::Die->die('bad operation ', $op);
}

# _eval_template(string op, hash_ref attr, string_ref html) : string
#
# Replace $attr keys found in $op.  Attributes are words surrounded by
# braces and beginning with a $.  The special attribute ${_} is replaced
# with $html.  An attribute can have a default, which is simply the named
# attribute on $op prefixed with 'default_'.
#
sub _eval_template {
    my($op, $attr, $html) = @_;
    my($res) = ref($op) ? $op->{template} : $op;
    $res =~ s{\$\{(\w+)\}}{
	$1 eq '_' ? $$html
	    : defined($attr->{$1}) ? HTML::Entities::encode($attr->{$1})
	    : ref($op) && defined($op->{'default_'.$1})
		? HTML::Entities::encode($op->{'default_'.$1})
	    : die("$1: missing attribute on tag and no default")
    }egx;
    return $res;
}

# _lookup_op(string tag, string parent_tag) : hash_ref
#
# Lookup $parent_tag/$tag or $tag in $_XML_TO_HTML_PROGRAM and return.
# Dies if not found.
#
sub _lookup_op {
    my($tag, $parent_tag) = @_;
    return $_XML_TO_HTML_PROGRAM->{"$parent_tag/$tag"}
	|| $_XML_TO_HTML_PROGRAM->{$tag}
	|| die("$parent_tag/$tag: unhandled tag");
}

# _process_tag()
#
# Processes each xml tag, adds appropriate tex code to tex string
#
sub _process_tag {
    my($parent_tag, $tag, $args) = @_;

    my($result);
    if (defined($_XML_TO_LATEX_PROGRAM->{"$parent_tag/$tag"})) {
	$result = $_XML_TO_LATEX_PROGRAM->{"$parent_tag/$tag"}
    } elsif (defined($_XML_TO_LATEX_PROGRAM->{$tag})) {
	$result = $_XML_TO_LATEX_PROGRAM->{$tag};
    } else {
	die("$parent_tag/$tag: unhandled tag");
    }

    if ('CODE' eq ref($result)) {
	$attrib .= $result->($args) if $in_attrib;
	$tex .= $result->($args) if !$in_attrib;
    } else {
	$attrib .= $result if $in_attrib;
	$tex .= $result if !$in_attrib;
    }
}

# _process_xml_file(string filename)
#
# Reads an xml file, converts it to a tex file, adds information to global
# tex string
#
sub _process_xml_file {
    my($filename) = @_;
    my($xml) = ${Bivio::IO::File->read($filename)};

    my($in_tag) = 0;
    my($parent_tag) = '';
    my($tag) = '';
    my($args);

    my(@open_tags) = ('root');
    my(@xml_chars) = split(//, $xml);
    foreach my $c (@xml_chars) {
	my($char) = $c;
	$char = $_CLEAN_CHAR->{$char} if $clean_normal &&
	    defined($_CLEAN_CHAR->{$char});
	$char = $_CLEAN_VERB_CHAR->{$char} if !$clean_normal &&
	    defined($_CLEAN_VERB_CHAR->{$char});

	if ($char eq '<' && !$in_tag) {
	    $in_tag = 1;
	    $args = '';
	    next;
	} elsif ($char eq '>' && $in_tag) {
	    $in_tag = 0;
	    if ($parent_tag =~ / /) {
		$parent_tag =~ /(.+)( )(.+)/;
		$parent_tag = $1;
	    }

	    if ($tag =~ / /) {
		$tag =~ /(.+?)( )(.+)/;
		$tag = $1;
		$args = $3;
	    }

	    if ($tag !~ /\//) {
		$parent_tag = $open_tags[$#open_tags];
		push(@open_tags, $tag);
	    } else {
		pop(@open_tags);
		$parent_tag = $open_tags[$#open_tags];
	    }

	    _end_verb()
		if $programlisting && $tag !~ /programlisting/;
	    _process_tag($parent_tag, $tag, $args);
	    $tex .= '\verb#'
		if $programlisting && $tag !~ /programlisting/;
	    $tag = '';
	    next;
	}
	elsif ($open_tags[$#open_tags] eq 'programlisting') {
	    $char = $c eq '#' ? '#\verb!#!\verb#'
		: $c eq "\n" ? "#\\newline\n\\verb#"
		: $c;
	    _end_verb()
		if $char =~ s/^#//;
	}

	$tag .= $char if $in_tag;
	$tex .= $char if !$in_tag && !$ignore && !$in_attrib;
	$attrib .= $char if !$in_tag && $in_attrib;
	$keyword .= $char if $in_keyword && !$in_tag;
    }
}

# _start_tex(string paper_size)
#
# Adds necessary information to beginning of tex string
#
sub _start_tex {
    my($paper_size) = @_;
    $tex .= '\documentclass[11pt,' . $paper_size . "paper,makeidx]{book}\n"
	. <<'EOF';
\usepackage{color}
\usepackage{graphicx}
\usepackage{alltt}
\usepackage{fancyhdr}
\usepackage{makeidx}
% Need to figure out these
% \topmargin 0in
% \footskip 1in
% \oddsidemargin -.5in
% \evensidemargin .5in
\RequirePackage[pdftex,pdfpagemode=none, pdftoolbar=true, pdffitwindow=true,pdfcenterwindow=true]{hyperref}
\pagestyle{fancy}
\fancyhf{}
\makeindex
\renewcommand{\headrulewidth}{0}
\renewcommand{\footrulewidth}{0}
\lfoot{Copyright~\copyright~2004~~Robert Nagler \newline All rights reserved~~nagler@extremeperl.org}
\rfoot{\thepage}
\begin{document}
\frontmatter
\title{Extreme Programming in Perl}
\author{Robert Nagler}
% Why doesn't this center?
\date{\today \newline \newline Copyright~\copyright~2004~~Robert Nagler \newline All rights reserved~~nagler@extremeperl.org}
\maketitle
\thispagestyle{empty}
\tableofcontents
EOF
    return;
}

# _to_html(string tag, array_ref children, hash_ref clipboard) : string_ref
#
# Concatenate evaluation of $children and return the resultant HTML.
#
sub _to_html {
    my($tag, $children, $clipboard) = @_;
    return \(join('',
	map({
	    _eval_child(
		$children->[$_ *= 2], $children->[++$_], $tag, $clipboard);
	} 0 .. @$children/2 - 1),
    ));
}

# _to_tags(array_ref names, string prefix) : string
#
# Converts @$names to HTML tags with prefix ('/' or ''), and concatenates
# the tags into a string.
#
sub _to_tags {
    my($names, $prefix) = @_;
    return join('', map({"<$prefix$_>"} @$names));
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
