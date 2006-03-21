# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::StyleSheet;
use strict;
$Bivio::UI::HTML::Widget::StyleSheet::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::StyleSheet::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::StyleSheet - draws style sheet inline of production

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::StyleSheet;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::ControlBase>

=cut

use Bivio::UI::HTML::Widget::ControlBase;
@Bivio::UI::HTML::Widget::StyleSheet::ISA = ('Bivio::UI::HTML::Widget::ControlBase');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::StyleSheet>

=head1 ATTRIBUTES

=over 4

=item value : any (required)

Name of css file to render.

=back

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="control_off_render"></a>

=head2 control_off_render(any source, string_ref buffer)

Renders the style sheet inline.

=cut

sub control_off_render {
    my($self, $source, $buffer) = @_;
    $$buffer .= "<style>\n<!--\n"
	. ${Bivio::IO::File->read(
	    Bivio::UI::Facade->get_local_file_name(
		Bivio::UI::LocalFileType->PLAIN,
		${$self->render_attr('value', $source)},
		$source->get_request,
	    ),
	)} . "\n-->\n</style>\n";
    return;
}

=for html <a name="control_on_render"></a>

=head2 control_on_render(any source, string_ref buffer)

Renders the style sheet as a link.

=cut

sub control_on_render {
    my($self, $source, $buffer) = @_;
    $$buffer .= q{<link href="}
	. ${$self->render_attr('value', $source)}
	. qq{" rel="stylesheet" type="text/css">\n};
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes widget state and children.

=cut

sub initialize {
    my($self) = @_;
    $self->initialize_attr('value');
    $self->put(control => [
	['->get_request'], 'Bivio::UI::Facade', 'want_local_file_cache',
    ]);
    return shift->SUPER::initialize(@_);
}

=for html <a name="internal_as_string"></a>

=head2 internal_as_string() : array

Returns value.

=cut

sub internal_as_string {
    return shift->unsafe_get('value');
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(any arg, ...) : any

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    return shift->internal_compute_new_args([qw(value)], \@_);
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
