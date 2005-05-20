# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::FormError;
use strict;
$Bivio::UI::FormError::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::FormError::VERSION;

=head1 NAME

Bivio::UI::FormError - form errors

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::FormError;

=cut

=head1 EXTENDS

L<Bivio::UI::Text>

=cut

use Bivio::UI::Text;
@Bivio::UI::FormError::ISA = ('Bivio::UI::Text');

=head1 DESCRIPTION

C<Bivio::UI::FormError>

=cut

#=IMPORTS

#=VARIABLES
my($_IN_EVAL);

=head1 METHODS

=cut

=for html <a name="field_value"></a>

=head2 static field_value(string item) : string

Returns an attribute for the currently executing form error.  Dies if
in not evaluating or if I<item> is unknown.

=over 4

=item label : string

Field label, not escaped.

=back

=cut

sub field_value {
    my(undef, $item) = @_;
    Bivio::Die->die($item, ': FormError not evaluating')
        unless $_IN_EVAL;
    Bivio::Die->die($item, ': no such FormError attribute')
	unless exists($_IN_EVAL->{$item});
    return $_IN_EVAL->{$item};
}

=for html <a name="to_html"></a>

=head2 to_html(any source, Bivio::Biz::FormModel form, string field) : string

=head2 to_html(any source, Bivio::Biz::FormModel form, string field, string label, Bivio::TypeError error) : string

Returns the error string for this tuple.  If none is found,
C<get_long_desc> is called.

=cut

sub to_html {
    my($proto, $source, $form, $field, $label, $error) = @_;
    my($self) = $proto->internal_get_self($source->get_request);
    my($form_class) = ref($form) || $form;
    $error ||= $form->get_field_error($field);
    my($v) = $self->unsafe_get_value(
	$form_class->simple_package_name, $field, $error->get_name);
    if (defined($v)) {
	my($buf) = '';
	$_IN_EVAL = {
	    label => $label,
	};
	my($die) = Bivio::Die->catch(sub {
	    Bivio::UI::ViewShortcuts->vs_call('Prose', $v)
		->put_and_initialize(parent => undef)
		->render($source, \$buf);
	    return;
        });
	$_IN_EVAL = undef;
	return $buf
	    unless $die;
	Bivio::IO::Alert->warn(
	    'Error interpolating: ', $v, ': ', $die);
    }
    return Bivio::HTML->escape($error->get_long_desc)
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
