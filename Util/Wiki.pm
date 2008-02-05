# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Wiki;
use strict;
use Bivio::Base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: b-wiki [options] command [args..]
commands
  from_xhtml file.html ... - converts file.html to file (wiki)
EOF
}

sub from_xhtml {
    my($self, @files) = @_;
    $self->use('XML::Parser');
    $self->use('HTML::Entities');
    $self->use('Bivio::IO::File');
    foreach my $in (@files) {
	(my $out = $in) =~ s/\.html$//;
	my($html) = ${Bivio::IO::File->read($in)};
	$html =~ s{.*(?=\Q<div class="main_body">\E)}{}s;
	$html =~ s{\Q</td>\E.*}{}s;
	$html =~ s{\&reg\;}{(r)}g;
	my($wiki) = _from_xhtml_children(
	    XML::Parser->new(Style => 'Tree')->parse($html));
	$wiki =~ s{^\@div class=main_body\n}{}s;
	$wiki =~ s{\@/div\n$}{}s;
	$wiki =~ s{\n{2,}}{\n}sg;
#	$wiki =~ s{^\@/p$}{}mg;
#	$wiki =~ s{^\@p$}{}mg;
	$wiki =~ s{\n{3,}}{\n\n}sg;
	Bivio::IO::File->write($out, \$wiki);
    }
    return;
}

sub _from_xhtml_children {
    my($children) = @_;
    return join('', map(
	_from_xhtml_child($children->[$_ *= 2], $children->[++$_]),
	0 .. @$children/2 - 1,
    ));
}

sub _from_xhtml_child {
    my($tag, $children) = @_;
    unless ($tag) {
	$children .= "\n"
	    unless $children =~ /\n$/s;
	return $children;
    }
    my($attr) = shift(@$children);
    delete($attr->{target});
    $attr->{href} =~ s/[\?\&]fc=[^&]+//
	if $attr->{href};
    my($value) = _from_xhtml_children($children);
    $value = "\n"
	unless defined($value) && length($value);
    return join('',
	'@',
	join(' ', $tag, map(
	    $attr->{$_} =~ /\s/ ? qq{$_="$attr->{$_}"} : qq{$_=$attr->{$_}},
	    sort(keys(%$attr)))),
	($value =~ /\@|\n.*\n/s ? ("\n", $value, '@/', $tag, "\n") : " $value"),
    );
}

1;
