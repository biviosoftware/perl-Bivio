# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Hidden;
use strict;
$Bivio::UI::HTML::Widget::Hidden::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Hidden - renders hidden inputs for a form

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Hidden;
    Bivio::UI::HTML::Widget::Hidden->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Hidden::ISA = qw(Bivio::UI::HTML::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Hidden> renders hidden fields of a form.

=head1 ATTRIBUTES

=over 4

=item values : array_ref (required,simple)

Dereferenced and passed to C<$source-E<gt>get_widget_value> to
get hash_ref to use (see below).

=item values : hash_ref (required,simple)

Keys are passed C<NAME> attribute of C<INPUT> tag (not escaped).
Values are passed C<VALUE> attribute of C<INPUT> tag and
are passed to L<Bivio::Util::escape_html|Bivio::Util/"escape_html">
before rendering.

=cut

#=IMPORTS
use Bivio::Util;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Hidden

Creates a new Hidden inputs widget.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static information.  In this case, prefix and suffix
field values.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if exists($fields->{is_constant});
    my($values) = $self->simple_get(qw(values));
    if ($fields->{is_constant} = (ref($values) eq 'HASH')) {
	my($v) = '';
	_render($values, \$v);
	$fields->{value} = $v;
    }
    else {
	$fields->{values} = $values;
    }
    return;
}

=for html <a name="is_constant"></a>

=head2 is_constant : boolean

Returns true

=cut

sub is_constant {
#TODO: fix when image implemented
    return 1;
}

=for html <a name="render"></a>

=head2 render(any source, hidden_ref buffer)

Render the object.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    $$buffer .= $fields->{value}, return if $fields->{is_constant};
    _render($source->get_widget_value(@{$fields->{values}}, $buffer);
    return;
}

#=PRIVATE METHODS

# _render(hash_ref values, string_ref buffer)
#
# Iterates over keys and appends a list of input fields.
#
sub _render {
    my($values, $buffer) = @_;
    my($k);
    foreach $k (sort(keys(%$values))) {
	$$buffer .= '<input type=hidden name="'.$k''" value="'
		.Bivio::Util::escape_html($values->{$k})."\">\n";
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
