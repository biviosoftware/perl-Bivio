# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::ControlBase;
use strict;
$Bivio::UI::HTML::Widget::ControlBase::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::ControlBase::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::ControlBase - adds a class and id attributes

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::ControlBase;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget::ControlBase>

=cut

use Bivio::UI::Widget::ControlBase;
@Bivio::UI::HTML::Widget::ControlBase::ISA = ('Bivio::UI::Widget::ControlBase');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::ControlBase> renders common html attributes.

=head1 ATTRIBUTES

=over 4

=item class : string []

HTML class attribute.

=item id : string []

HTML id attribute.

=item html_attrs : array_ref [[class id]]

List of attributes to render.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

=head1 METHODS

=cut

=for html <a name="control_on_render"></a>

=head2 control_on_render(any source, string_ref buffer)

Render class and id.

=cut

sub control_on_render {
    my($self, $source, $buffer) = @_;
    $$buffer .= $_VS->vs_html_attrs_render(
	$self, $source, $self->unsafe_get('html_attrs'));
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes class attribute.

=cut

sub initialize {
    my($self) = @_;
    $_VS->vs_html_attrs_initialize($self, $self->unsafe_get('html_attrs'));
    return shift->SUPER::initialize(@_);
}

=for html <a name="internal_compute_new_args"></a>

=head2 static internal_compute_new_args(array_ref required, array_ref args) : hash_ref

=cut

sub internal_compute_new_args {
    my($proto, $required, $args) = @_;
    return {
	map({
	    my($a) = shift(@$args);
	    return qq{"$_" must be defined}
		unless defined($a);
	    ($_ => $a);
	} @$required),
	!@$args ? ()
	    : @$args > 2 ? return "too many parameters"
	    : (ref($args->[0]) ne 'HASH'
		   ? (class => shift(@$args))
		   : @$args == 2 ? return qq{"attributes" must be last} : (),
	       %{shift(@$args) || {}}),
    };
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(array_ref required, array_ref args) : hash_ref

=cut

sub internal_new_args {
    Bivio::IO::Alert->warn_deprecated('call internal_compute_new_args');
    return shift->internal_compute_new_args(@_);
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
