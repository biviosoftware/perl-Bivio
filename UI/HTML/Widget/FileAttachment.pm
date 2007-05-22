# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::FileAttachment;
use strict;
$Bivio::UI::HTML::Widget::FileAttachment::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::FileAttachment::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::FileAttachment - a file widget for attaching files to email

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::FileAttachment;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::FileAttachment::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::FileAttachment> is a file field for forms.

=head1 ATTRIBUTES

=over 4

=back

=cut

#=IMPORTS

#=VARIABLES

my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::FileAttachment

Creates a FileAttachment widget.

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes from configuration attributes.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)



=cut

sub render {
    my($self, $source, $buffer) = @_;
#    my($fields) = $self->[$_IDI];
#    my($form) = $source->get_request->get_widget_value(@{$fields->{model}});
#    my($field) = $fields->{field};

    # first render initialization
#    if ($fields->{is_first_render}) {
#	my($type) = $fields->{type} = $form->get_field_type($field);
#	$fields->{prefix} = '<input type=file size='.$self->get('size')
#		.' name=';
#	$fields->{is_first_render} = 0;
#    }
#    $$buffer .= $fields->{prefix}.$form->get_field_name_for_html($field)
#	    .' value="'.$form->get_field_as_html($field).'">';
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
