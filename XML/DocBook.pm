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
my($_TO_HTML) = _to_html_compile({
    attribution => {
	prefix => '<div align=right>-- ',
	suffix => '</div>',
    },
    chapter => ['html', 'body'],
    emphasis => ['b'],
    epigraph => [],
    para => ['p'],
    simplesect => [],
    title => ['h1'],
});

=head1 METHODS

=cut

=for html <a name="to_html"></a>

=head2 to_html(string input_file) : string_ref

Converts I<input_file> from XML to HTML.

=cut

sub to_html {
    my($self, $input_file) = @_;
    return _to_html(XML::Parser->new(Style => 'Tree')->parsefile($input_file));
}

#=PRIVATE METHODS

# _to_html(array_ref tree) : string_ref
#
# Convert XML tree into HTML.
#
sub _to_html {
    my($tree) = @_;
    my($res) = '';
    $res .= _to_html_node(shift(@$tree), shift(@$tree)) while @$tree;
    return \$res;
}

# _to_html_compile(hash_ref config) : hash_ref
#
# Creates the $_TO_HTML hash from $config, which is a mapping of XML tags to
# HTML commands.  If the HTML command is an array_ref, calls _to_html_tags to
# create the prefix and suffix.
#
sub _to_html_compile {
    my($config) = @_;
    while (my($xml, $html) = each(%$config)) {
	$config->{$xml} = {
	    prefix => _to_html_tags($html, ''),
	    suffix => _to_html_tags([reverse(@$html)], '/'),
	} if ref($html) eq 'ARRAY';
    }
    return $config;
}

# _to_html_node(string tag, array_ref tree) : string
#
# Lookup $tag in $_TO_HTML and evaluate.
#
sub _to_html_node {
    my($tag, $tree) = @_;
    return HTML::Entities::encode($tree) unless $tag;
    die($tag, ': unhandled tag') unless my $op = $_TO_HTML->{$tag};
    # We ignore the attributes for now,
    shift(@$tree);
    return $op->{prefix} . ${_to_html($tree)} . $op->{suffix};
}

# _to_html_tags(array_ref names, string prefix) : string
#
# Converts @$names to HTML tags with prefix ('/' or ''), and concatenates
# the tags into a string.
#
sub _to_html_tags {
    my($names, $prefix) = @_;
    return join('', map {"<$prefix$_>"} @$names);
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
