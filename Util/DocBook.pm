# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
package Bivio::Util::DocBook;
use strict;
$Bivio::Util::DocBook::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::DocBook::VERSION;

=head1 NAME

Bivio::Util::DocBook - manipulate DocBook files

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Util::DocBook;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Util::DocBook::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Util::DocBook> manipulates DocBook files.

=cut

=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns:
  usage: b-docbook [options] command [args...]
  commands:
      xml_to_html -- converts input xml to output html

=cut

sub USAGE {
    return <<'EOF';
usage: b-docbook [options] command [args...]
commands:
    xml_to_html -- converts input xml to output html
EOF
}

#=IMPORTS
use XML::Parser;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
# Simple mapping of tags to values
my(%_XML_TO_HTML) = (
    chapter => 0,
    citetitle => 'i',
    classname => 'tt',
    command => 'tt',
    constant => 'tt',
    emphasis => 'strong',
    filename => 'tt',
    firstterm => 'i',
    function => 'tt',
    varname => 'tt',
    literal => 'tt',
    envar => 'tt',
    orderedlist => 'ol',
    para => 'p',
    programlisting => 'pre',
    sect1 => 0,
    simplesect => 0,
    superscript => 'sup',
    term => 0,
    type => 'tt',
    userinput => 'tt',
    variablelist => 'dl',
    varlistentry => 0,
);

=head1 METHODS

=cut

=for html <a name="xml_to_html"></a>

=head2 xml_to_html() : string_ref

Parses input and converts into an HTML output.

=cut

sub xml_to_html {
    my($self) = @_;
    my($state) = {
	out => '<html><body>',
	footnotes => '',
	footnote_counter => 1,
	tag => [],
    };
    _xml_to_html_parse(
	$state,
	XML::Parser->new(Style => 'Tree')->parsefile('unit-testing.xml'));
    $state->{out} .= $state->{footnotes}.'</body></html>';
    return \$state->{out};
}

#=PRIVATE METHODS

# _xml_to_html_parse(hash_ref state, array_ref tree, any tag)
#
# Iterates over tree as returned by XML::Parse->parsefile.  If tag
# is supplied, will print the tag before and after tree is parsed.
#
sub _xml_to_html_parse {
    my($state, $tree, $tags) = @_;
    if ($tags) {
	$tags = [$tags] unless ref($tags);
	foreach my $t (@$tags) {
	    $state->{out} .= "<$t>";
	}
    }
    while ($tree && @$tree) {
	my($tag) = shift(@$tree);
	unless ($tag) {
	    # Literal
	    $state->{out} .= shift(@$tree);
	    next;
	}
	unshift(@{$state->{tag}}, $tag);
	my($value) = shift(@$tree);
	$state->{attrs} = shift(@$value);
	$state->{out} .= '<a name="'.$state->{attrs}->{id}.'"></a>'
	    if $state->{attrs}->{id};
	my($sub) = \&{'_xml_to_html_parse_'.$tag};
	if (defined(&$sub)) {
	    &$sub($state, $value);
	}
	else {
	    die($tag, ': unknown tag') unless exists($_XML_TO_HTML{$tag});
	    _xml_to_html_parse($state, $value,
		exists($_XML_TO_HTML{$tag}) ? ($_XML_TO_HTML{$tag}) : ());
	}
	shift(@{$state->{tag}});
    }
    if ($tags) {
	foreach my $t (reverse(@$tags)) {
	    $state->{out} .= "</$t>";
	}
    }
    return;
}

# _xml_to_html_parse_attribution(hash_ref state, array_ref tree)
#
# Handles attributions.
#
sub _xml_to_html_parse_attribution {
    my($state, $tree) = @_;
    my($out) = $state->{out};
    $state->{out} = '';
    _xml_to_html_parse($state, $tree);
    $state->{attribution} = $state->{out};
    $state->{out} = $out;
    return;
}

# _xml_to_html_parse_blockquote(hash_ref state, array_ref tree)
#
# Converts to <blockquote>.
#
sub _xml_to_html_parse_blockquote {
    return _xml_to_html_parse(@_, 'blockquote', 'i');
}

# _xml_to_html_parse_comment(hash_ref state, array_ref tree)
#
# Converts to <>.
#
sub _xml_to_html_parse_comment {
    my($state, $tree) = @_;
    $state->{out} .= '<i>[COMMENT: ';
    _xml_to_html_parse($state, $tree);
    $state->{out} .= ']</i>';
    return;
}

# _xml_to_html_parse_epigraph(hash_ref state, array_ref tree)
#
# Converts to <>.
#
sub _xml_to_html_parse_epigraph {
    my($state, $tree) = @_;
    _xml_to_html_parse($state, $tree);
    $state->{out} .= '<center>-- '.$state->{attribution}.'</center>';
    return;
}

# _xml_to_html_parse_footnote(hash_ref state, array_ref tree)
#
# Creates a superscript in $state->{out} and adds to $state->{footnotes}.
#
sub _xml_to_html_parse_footnote {
    my($state, $tree) = @_;
    my($i) = $state->{footnote_counter}++;
    $state->{out} .= '<a href="footnoote-'.$i.'"><sup>'.$i."</sup></a>\n";
    my($out) = $state->{out};
    $state->{out} = '<a name="footnoote-'.$i.'"><sup>'.$i."</sup></a>\n";
    _xml_to_html_parse($state, $tree);
    $state->{footnotes} .= $state->{out};
    $state->{out} = $out;
    return;
}

# _xml_to_html_parse_listitem(hash_ref state, array_ref tree)
#
# Converts to <li> or <dt>, depending on $state->{tag}->[1].
#
sub _xml_to_html_parse_listitem {
    my($state, $tree) = @_;
    my($t) = $state->{tag}->[1] eq 'varlistentry' ? 'dd' : 'li';
    return _xml_to_html_parse(@_, $t);
}

# _xml_to_html_parse_note(hash_ref state, array_ref tree)
#
# Converts to <note>.
#
sub _xml_to_html_parse_note {
    my($state, $tree) = @_;
    $state->{out} .= '<blockquote><strong>Note:</strong><i>';
    _xml_to_html_parse($state, $tree);
    $state->{out} .= '</i></blockquote>';
    return;
}

# _xml_to_html_parse_quote(hash_ref state, array_ref tree)
#
# Converts to "bla".
#
sub _xml_to_html_parse_quote {
    my($state, $tree) = @_;
    $state->{out} .= '"';
    _xml_to_html_parse($state, $tree);
    $state->{out} .= '"';
    return;
}

# _xml_to_html_parse_sidebar(hash_ref state, array_ref tree)
#
# Encloses text in a table with borders and gray background.
#
sub _xml_to_html_parse_sidebar {
    my($state, $tree) = @_;
    $state->{out} .= '<table border=1 cellpadding=5 bgcolor="#CCCCCC"><tr><td>';
    _xml_to_html_parse(@_);
    $state->{out} .= '</td></tr></table>';
    return;
}

# _xml_to_html_parse_systemitem(hash_ref state, array_ref tree)
#
# Converts to <a href=>.
#
sub _xml_to_html_parse_systemitem {
    my($state, $tree) = @_;
    my($out) = $state->{out};
    $state->{out} = '';
    _xml_to_html_parse($state, $tree);
    $state->{out} = $out.'<a href="'.$state->{out}.'">'.$state->{out}.'</a>';
    return;
}

# _xml_to_html_parse_title(hash_ref state, array_ref tree)
#
# Converts to <head1>.
#
sub _xml_to_html_parse_title {
    my($state, $tree) = @_;
    my($h) = 'h'.int(int(@{$state->{tag}})/2);
    return _xml_to_html_parse(@_, $h);
}

# _xml_to_html_parse_warning(hash_ref state, array_ref tree)
#
# Converts to <warning>.
#
sub _xml_to_html_parse_warning {
    my($state, $tree) = @_;
    $state->{out} .= '<blockquote><strong>Warning!</strong><p><i>';
    _xml_to_html_parse($state, $tree);
    $state->{out} .= '</i></blockquote>';
    return;
}

# _xml_to_html_parse_xref(hash_ref state, array_ref tree)
#
# Converts to a link to linkend.
#
sub _xml_to_html_parse_xref {
    my($state, $tree) = @_;
    $state->{out} .= '<a href="'.$state->{attrs}->{linkend}.'.html">'
	.$state->{attrs}->{linkend}.'</a>';
    # There is no value with an xref
    return;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
