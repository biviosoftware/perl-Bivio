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
	$html =~ s{\&reg\;}{(r)}g;
	_recurse(
	    $self,
	    \&_extract_content,
	    XML::Parser->new(Style => 'Tree')->parse($html));
	my($wiki) = _recurse($self, \&_from_xhtml, $self->get('content'));
	$wiki =~ s{\n{2,}}{\n}sg;
	$wiki =~ s{\n{3,}}{\n\n}sg;
	Bivio::IO::File->write($out, \$wiki);
    }
    return;
}

sub _extract_content {
    my($self, $tag, $children) = @_;
    return
	unless $tag;
    my($copy) = [@$children];
    $self->put(content => $copy)
	if (shift(@$copy)->{class} || '') =~ /^(?:main_middle|main_body)$/;
    _recurse($self, \&_extract_content, $copy);
    return;
}

sub _from_xhtml {
    my($self, $tag, $children) = @_;
    unless ($tag) {
	$children .= "\n"
	    unless $children =~ /\n$/s;
	return $children;
    }
    my($attr) = shift(@$children);
    delete($attr->{target});
    $attr->{href} =~ s/[\?\&]fc=[^&]+//
	if $attr->{href};
    my($value) = _recurse($self, \&_from_xhtml, $children);
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

sub _recurse {
    my($self, $op, $children) = @_;
    return join('', @{$self->map_by_two(sub {$op->($self, @_)}, $children)});
}

1;
