# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::FormErrorList;
use strict;
$Bivio::UI::HTML::Widget::FormErrorList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::FormErrorList - renders the errors of a form in a table

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::FormErrorList;
    Bivio::UI::HTML::Widget::FormErrorList->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::FormErrorList::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::FormErrorList> renders the form errors in
the order specified by I<fields>.  The output is a table.
If the form isn't in error, renders nothing.

=head1 ATTRIBUTES

=over 4

=item form_model : array_ref (required, inherited)

Which form are we dealing with.

=item fields : array_ref (required)

The order of the list of errors.  This is a static array_ref, not
a widget value.  The value of which is not checked until rendering
time.

=back

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::UI::HTML::FormErrors;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::FormErrorList

Creates a new FormErrorList widget.

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

Copies the attributes to local fields.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if exists($fields->{model});
    $fields->{model} = $self->ancestral_get('form_model');
    $fields->{fields} = $self->get('fields');
    my($p, $s) = Bivio::UI::Font->as_html('error');
    $fields->{prefix}
	    = "${p}Please correct the following errors:$s<p><ul>";
    $fields->{suffix} = "</ul><p>\n";
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the link.  Most of the code is involved in avoiding unnecessary method
calls.  If the I<value> is a constant, then it will only be rendered once.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
#TODO: Optimize for is_constant
    my($model) = $source->get_widget_value(@{$fields->{model}});
    return unless $model->in_error;
    my($errors) = $model->get_errors;
    my($e) = $fields->{prefix};

    # iterate errors, so general errors don't have to be bound to a field
    foreach my $name (keys(%$errors)) {
	my($caption) = _get_caption($self, $name);
	$e .= "\n<li>";
	$e .= Bivio::Util::escape_html($caption.': ') if $caption;
	$e .= Bivio::UI::HTML::FormErrors->to_html(
		$source, $model, $name, $caption || '', $errors->{$name});
    }

    $$buffer .= $e.$fields->{suffix};
    return;
}

#=PRIVATE METHODS

# _get_caption(string name) : string
#
# Returns the caption for the specified field name. Returns undef if no
# field exists for the name.
#
sub _get_caption {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};

    foreach my $f (@{$fields->{fields}}) {
	return $f->[1] if ($f->[0] eq $name);
    }
    return undef;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
