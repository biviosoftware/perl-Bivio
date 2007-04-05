# Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::HTMLParser::Links;
use strict;
$Bivio::Test::HTMLParser::Links::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::HTMLParser::Links::VERSION;

=head1 NAME

Bivio::Test::HTMLParser::Links - models links on the page

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::HTMLParser::Links;

=cut

=head1 EXTENDS

L<Bivio::Test::HTMLParser>

=cut

use Bivio::Test::HTMLParser;
@Bivio::Test::HTMLParser::Links::ISA = ('Bivio::Test::HTMLParser');

=head1 DESCRIPTION

C<Bivio::Test::HTMLParser::Links> models the links on a page.

=cut

=head1 ATTRIBUTES

Links are stored as attributes indexed by their labels.

=over 4

=item E<lt>labelE<gt> => {

            label =>  <label of the hyperlink>,
            href  =>  <contents of href attribute>,
            alt   =>  <contents of alt attribute>
       }

=item usage:  $links->get('label')->{href}

=back

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_IDI) = __PACKAGE__->instance_data_index;
__PACKAGE__->register(['Cleaner']);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Test::HTMLParser parser) : Bivio::Test::HTMLParser::Links

Parses cleaned html for links.

=cut

sub new {
    my($proto, $parser) = @_;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="html_parser_end"></a>

=head2 html_parser_end(string tag, string origtext)

Dispatch to the _end_XXX routines.

=cut

sub html_parser_end {
    my($self, $tag) = @_;
    return _end_a($self) if $tag eq 'a';
    return;
}

=for html <a name="html_parser_start"></a>

=head2 html_parser_start(string tag, hash_ref attr, array_ref attrseq, string origtext)

Dispatches to the _start_XXX routines.

=cut

sub html_parser_start {
    my($self, $tag, $attr) = @_;
    my($fields) = $self->[$_IDI];
    return _start_a($fields, $attr) if $tag eq 'a';
    return _start_img($self, $attr) if $tag eq 'img';
    return;
}

=for html <a name="html_parser_text"></a>

=head2 html_parser_text(string text)

Text is applied to the current link, if any.

For links, we can't assume that we are called with an entire sequence
of text (like Forms), so we append until the end_a.

=cut

sub html_parser_text {
    my($self, $text) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{text} .= $text if $fields->{href};
    return;
}

#=PRIVATE METHODS

# _end_a(self)
#
# No longer in a link.
#
sub _end_a {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    _link($self, $fields->{text})
	if defined($fields->{text}) && defined($fields->{href});
    $fields->{href} = undef;
    return;
}

# _link(self, string label, string alt)
#
# Adds the link.  Creates unique name ($label_$i) if not unique.
#
sub _link {
    my($self, $label, $alt) = @_;
    my($fields) = $self->[$_IDI];
    my($base, $i) = $label;
    while ($self->get('elements')->{$label}) {
	return if $self->get('elements')->{$label}->{href}
            eq ($fields->{href} || '');
	$label = $base . '_' . ++$i;
    }
    $self->get('elements')->{$label} = {
	label => $label,
	href => $fields->{href},
	alt => $alt,
    };
    _trace($label, '->', $fields->{href}) if $_TRACE;
    return;
}

# _start_a(hash_ref fields, hash_ref attr)
#
# Stores the href.
#
sub _start_a {
    my($fields, $attr) = @_;
    Bivio::Die->die(
	'already have an href (missing </a>). current=', $fields->{href},
	' new=', $attr->{href},
    ) if $fields->{href};
    return if $attr->{name} && !$attr->{href};
    unless (defined($attr->{href}) || $attr->{name}) {
	Bivio::IO::Alert->info('missing href, ignoring: ', $attr);
	return;
    }
    $fields->{href} = $attr->{href};
    $fields->{text} = '';
    return;
}

# _start_img(self, hash_ref attr)
#
# Adds a new link.
#
sub _start_img {
    my($self, $attr) = @_;
    my($fields) = $self->[$_IDI];
    return unless $fields->{href};
    Bivio::Die->die('missing src: ', $attr)
        unless $attr->{src};
    # Delete the gif/jpg suffix and any directory prefix
    $attr->{src} =~ s/(?:.*\/)?([^\/]+)\.\w+$/$1/;
    _link($self, $attr->{src}, $attr->{alt});
    return;
}

=head1 COPYRIGHT

Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
