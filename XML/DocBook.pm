# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::XML::DocBook;
use strict;
$Bivio::XML::DocBook::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::XML::DocBook::VERSION;

=head1 NAME

Bivio::XML::DocBook - Manipulate DocBook files

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

C<Bivio::XML::DocBook> manipulate DocBook files.

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
use XML::Parser ();
use HTML::Entities ();

#=VARIABLES
my($_TO_HTML_OP) = {
    chapter => ['html', 'body'],
    para => ['p'],
    simplesect => [],
    title => ['h1'],
};

=head1 METHODS

=cut

=for html <a name="to_html"></a>

=head2 to_html(string input_file) : string_ref

Converts I<input_file> from XML to HTML.

=cut

sub to_html {
    my($self, $input_file) = @_;
    my($tree) = XML::Parser->new(Style => 'Tree')->parsefile($input_file);
    my($res) = _to_html($tree);
    return \$res;
}

#=PRIVATE METHODS

# _to_html(array_ref tree) : string
#
# Convert XML tree into HTML.
#
sub _to_html {
    my($tree) = @_;
    my($res) = '';
    $res .= _to_html_node((shift(@$tree)), shift(@$tree)) while @$tree;
    return $res;
}

# _to_html_node(string tag, array_ref tree) : string
#
# Lookup $tag in $_TO_HTML_OP and evaluate.
#
sub _to_html_node {
    my($tag, $tree) = @_;
    return HTML::Entities::encode($tree) unless $tag;
    die($tag, ': unhandled tag') unless my $op = $_TO_HTML_OP->{$tag};
    shift(@$tree);
    return _to_html_tags($op)._to_html($tree)._to_html_tags([reverse(@$op)], '/');
}

# _to_html_tags(array_ref names, string prefix) : string
#
# Convert $names to tags with possible prefix ('/')
#
sub _to_html_tags {
    my($names, $prefix) = @_;
    return join('', map {'<'.($prefix || '').$_.'>'} @$names);
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
