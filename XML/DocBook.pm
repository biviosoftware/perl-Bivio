# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
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

#=PRIVATE METHODS

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

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
