# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::XML::DocBook;
use strict;
our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::XML::DocBook - converts XML DocBook files to HTML

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

=cut


=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns:
  usage: b-docbook [options] command [args...]
  commands:
      to_html file.xml -- converts input xml to output html

=cut

sub USAGE {
    return <<'EOF';
usage: b-docbook [options] command [args...]
commands:
    to_html file.xml -- converts input xml to output html
EOF
}

#=IMPORTS
use Bivio::IO::File;
use HTML::Entities ();
use XML::Parser ();

#=VARIABLES
my($_XML_TO_HTML_PROGRAM) = _compile_program({
    attribution => {
	prefix => '<div align=right>-- ',
	suffix => '</div>',
    },
    blockquote => ['blockquote'],
    'chapter/title' => ['h1'],
    chapter => ['html', 'body'],
    command => ['tt'],
    emphasis => ['b'],
    epigraph => [],
    function => ['tt'],
    literal => ['tt'],
    para => ['p'],
    programlisting => ['blockquote', 'pre'],
    sect1 => [],
    'sect1/title' => ['h2'],
    simplesect => [],
});

=head1 METHODS

=cut

=for html <a name="to_html"></a>

=head2 to_html(string xml_file) : string_ref

Converts I<xml_file> from XML to HTML.

=cut

sub to_html {
    my($self, $xml_file) = @_;
    return _to_html(
	'', XML::Parser->new(Style => 'Tree')->parsefile($xml_file));
}

#=PRIVATE METHODS

# _compile_program(hash_ref config) : hash_ref
#
# Creates the $_XML_TO_HTML_PROGRAM hash from $config, which is a mapping of
# XML tags to HTML commands.  If the HTML command is an array_ref, calls
# _compile_tags_to_html to create the prefix and suffix.
#
sub _compile_program {
    my($config) = @_;
    while (my($xml, $html) = each(%$config)) {
	$config->{$xml} = {
	    prefix => _compile_tags_to_html($html, ''),
	    suffix => _compile_tags_to_html([reverse(@$html)], '/'),
	} if ref($html) eq 'ARRAY';
    }
    return $config;
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

# _eval_child(string tag, array_ref children, string parent_tag) : string
#
# Lookup $tag in context of $parent_tag to find operator, evaluate $children,
# and then evaluate the found operator.  Returns the result of _eval_op.
#
sub _eval_child {
    my($tag, $children, $parent_tag) = @_;
    return HTML::Entities::encode($children) unless $tag;
    # We ignore the attributes for now.
    shift(@$children);
    return _eval_op(
	_lookup_op($tag, $parent_tag),
	_to_html($tag, $children));
}

# _eval_op(hash_ref op, string_ref html) : string
#
# Surround $html with prefix and suffix from $op.  Return concatenation.
#
sub _eval_op {
    my($op, $html) = @_;
    return $op->{prefix} . $$html . $op->{suffix};
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

# _to_html(string tag, array_ref children) : string_ref
#
# Concatenate evaluation of $children and return the resultant HTML.
#
sub _to_html {
    my($tag, $children) = @_;
    my($res) = '';
    $res .= _eval_child(splice(@$children, 0, 2), $tag) while @$children;
    return \$res;
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
