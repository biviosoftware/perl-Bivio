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

C<Bivio::XML::DocBook> converts XML DocBook files to HTML.  Also can
L<count_words|"count_words"> on XML files.

=cut


=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns:
  usage: b-docbook [options] command [args...]
  commands:
      to_html file.xml -- converts input xml to output html
      count_words file.xml -- returns number of words in XML file

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
my($_XML_TO_HTML_PROGRAM) = _compile_program([
    # Shared mappings
    [qw(
        answer/para
	epigraph
	figure
	qandaentry
	qandaset
	question/para
	sect1
	sect2
	simplesect
	term
	varlistentry
    )] => [],
    [qw(
	citetitle
	firstterm
	replaceable
    )] => ['i'],
    [qw(
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
    )] => ['tt'],
    [qw(
        answer
        question
    )] => '<i>${label}</i>${_}<br>',

    # Unique mappings
    abstract => '<p><table width="70%" align=center border=0><tr>'
        . '<td align=center>${_}</td></tr></table></p>',
    attribution => '<div align=right>-- ${_}</div>',
    blockquote => ['blockquote'],
    chapter => sub {
	my($attr, $html, $clipboard) = @_;
	$$html .= "<h2>Footnotes</h2><ol>\n$clipboard->{footnotes}</ol>\n"
	    if $clipboard->{footnotes};
	return "<html><body>$$html</body></html>";
    },
    'chapter/title' => ['h1'],
    comment => '<i>[COMMENT: ${_}]</i>',
    emphasis => ['b'],
    'figure/title' => ['center', 'b'],
    footnote => sub {
	my($attr, $html, $clipboard) = @_;
	$clipboard->{footnote_idx}++;
	$clipboard->{footnotes}
	    .= qq(<li><a name="$clipboard->{footnote_idx}"></a>$$html</li>\n);
	return qq(<a href="#$clipboard->{footnote_idx}">)
	    . "[$clipboard->{footnote_idx}]</a>";

    },
    graphic => {
	template => '<div align=${align}><img border=0 src="${fileref}"></div>',
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
    'sect1/title' => ['h2'],
    'sect2/title' => ['h3'],
    sidebar => '<table width="95%" border=0 cellpadding=5 bgcolor="#CCCCCC">'
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
    xref => '[CROSS-REFERENCE ${linkend}]',
]);

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

Converts I<xml_file> from XML to HTML.

=cut

sub to_html {
    my($self, $xml_file) = @_;
    return _to_html(
	'',
	XML::Parser->new(Style => 'Tree')->parsefile($xml_file),
        {});
}

#=PRIVATE METHODS

# _compile_program(array_ref config) : hash_ref
#
# Creates the $_XML_TO_HTML_PROGRAM hash from $config, which is a mapping of
# XML tags to HTML commands.  If the HTML command is an array_ref, calls
# _compile_tags_to_html to create the template.  If the HTML command
# is a code_ref, creates a 'code' element.  Defaults to a template.
#
sub _compile_program {
    my($config) = @_;
    my($res) = {};
    while (@$config) {
	my($xml_tags, $html) = splice(@$config, 0, 2);
	foreach my $xml (ref($xml_tags) ? @$xml_tags : $xml_tags) {
	    die("$xml: duplicate tag") if $res->{$xml};
	    $res->{$xml} = ref($html) eq 'ARRAY'
		? {template => _compile_tags_to_html($html, '')
		    .'${_}'
		    ._compile_tags_to_html([reverse(@$html)], '/')}
		: ref($html) eq 'CODE' ? {code => $html}
		: ref($html) eq 'HASH' ? {%$html}
		: {template => $html};
	    $res->{$xml}->{tag} = $xml;
	}
    }
    return $res;
}

# _compile_tags_to_html(array_ref names, string prefix) : string
#
# Converts @$names to HTML tags with prefix ('/' or ''), and concatenates
# the tags into a string.
#
sub _compile_tags_to_html {
    my($names, $prefix) = @_;
    return join('', map {"<$prefix$_>"} @$names);
}

# _count_words(array_ref children) : int
#
# Counts the words in the literal children and recurses the tree.
#
sub _count_words {
    my($children) = @_;
    shift(@$children) if ref($children->[0]) eq 'HASH';
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
# Lookup $tag in context of $parent_tag to find operator, evaluate $children,
# and then evaluate the found operator.  Returns the result of _eval_op.
#
sub _eval_child {
    my($tag, $children, $parent_tag, $clipboard) = @_;
    return HTML::Entities::encode($children) unless $tag;
    return _eval_op(
	_lookup_op($tag, $parent_tag),
        shift(@$children),
	_to_html($tag, $children, $clipboard),
	$clipboard);
}

# _eval_op(any op, hash_ref attr, string_ref html, hash_ref clipboard) : string
#
# If $op has code, call the subroutine with $html and $clipboard.  Otherwise,
# call _eval_template, which replaces attributes in $op->{template}.
#
sub _eval_op {
    my($op, $attr, $html, $clipboard) = @_;
    return $op->{code} ? &{$op->{code}}($attr, $html, $clipboard)
	: _eval_template($op, $attr, $html);
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
    my($res) = $op->{template};
    $res =~ s/\$\{(\w+)\}/
	$1 eq '_' ? $$html
	    : defined($attr->{$1}) ? HTML::Entities::encode($attr->{$1})
	    : defined($op->{'default_'.$1})
		? HTML::Entities::encode($op->{'default_'.$1})
	    : die("$1: missing attribute on tag <$op->{tag}> and no default")
    /egx;
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
    my($res) = '';
    $res .= _eval_child(splice(@$children, 0, 2), $tag, $clipboard)
	while @$children;
    return \$res;
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
