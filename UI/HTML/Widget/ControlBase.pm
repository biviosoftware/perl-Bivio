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

=back

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="control_on_render"></a>

=head2 control_on_render(any source, string_ref buffer)

Render class and id.

=cut

sub control_on_render {
    my($self, $source, $buffer) = @_;
    for my $a (qw(class id)) {
	my($b) = undef;
	$$buffer .= qq{ $a="$b"}
	    if $self->unsafe_render_attr($a, $source, \$b) && length($b);
    }
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes class attribute.

=cut

sub initialize {
    my($self) = @_;
    $self->map_invoke(
	'unsafe_initialize_attr',
	[qw(class id)],
    );
    return shift->SUPER::initialize(@_);
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(hash_ref child, any class, hash_ref attributes) : hash_ref

=head2 static internal_new_args(hash_ref child, hash_ref attributes) : hash_ref

Pulls C<class> and C<attributes> off.   I<child> is passed in by
subclass.

=cut

sub internal_new_args {
    my($proto, $child, $class, $attributes) = @_;
    if (ref($class) eq 'HASH') {
	return 'too many parameters; "attributes" must be last'
	    if defined($attributes);
	$attributes = $class;
	$class = undef;
    }
    return {
	%$child,
	(defined($class) ? (class => $class) : ()),
	($attributes ? %$attributes : ()),
    };
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
