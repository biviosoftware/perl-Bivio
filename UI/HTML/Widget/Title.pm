# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Title;
use strict;
$Bivio::UI::HTML::Widget::Title::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Title - renders title from subtopic, topic, and realm

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Title;
    Bivio::UI::HTML::Widget::Title->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::Title::ISA = qw(Bivio::UI::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Title> adds a level of titleion to
the rendering of widgets.  The widget which is this widget's I<value>
is rendered dynamically by accessing this widget's attributes dynamically.

=head1 ATTRIBUTES

=over 4

=item values : array_ref (required)

Each element will be rendered with
L<Bivio::UI::Widget::unsafe_render_value|Bivio::UI::Widget/"unsafe_render_value">

If result is C<undef> or zerol length, no value
is rendered.  In all cases, the strings are passed to escaped.

=item title_separator : string [' - '] (inherited)

Used to separate values in title.

=back

=cut

#=IMPORTS
use Bivio::HTML;

#=VARIABLES

my($_PACKAGE) = __PACKAGE__;
my($_DEFAULT_SEPARATOR) = ' - ';

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Form

Creates a new Form widget.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

No op.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{values};

    my($i) = 0;
    $fields->{values} = [map {
	$self->initialize_value($i++, $_);
    } @{$self->get('values')}];
    $fields->{separator} = $self->ancestral_get('title_separator',
	    $_DEFAULT_SEPARATOR);
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the title by joining the I<values>.  We set the Title in the
reply as well.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my(@v, @t) = ();
    my($i) = 0;
    foreach my $v (@{$fields->{values}}) {
	my($x) = $v;
	if (ref($x)) {
	    my($b) = '';
	    $self->unsafe_render_value($i++, $x, $source, \$b);
	    next unless length($b);
	    $x = $b;
	}
	push(@v, Bivio::HTML->escape($x));
	push(@t, $x);
    }
    $$buffer .= '<title>'.join($fields->{separator}, @v)."</title>\n";
    $source->get('reply')->set_header('Title', join($fields->{separator}, @t));
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
