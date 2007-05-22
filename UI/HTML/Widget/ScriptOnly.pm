# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::ScriptOnly;
use strict;
$Bivio::UI::HTML::Widget::ScriptOnly::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::ScriptOnly::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::ScriptOnly - java script only widget rendering

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::ScriptOnly;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::ScriptOnly::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::ScriptOnly> java script only widget rendering.

=head1 ATTRIBUTES

=over 4

=item widget : Bivio::UI::Widget (required)

The widget to render when javascript is present.

=item alt_widget : Bivio::UI::Widget []

The widget which is rendered if javascript is not present.

=back

=cut

#=IMPORTS

#=VARIABLES

my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::ScriptOnly

Creates a new ScriptOnly widget.

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

Preparse the widget during startup.

=cut

sub initialize {
    my($self) = @_;
    $self->get('widget')->put(parent => $self)->initialize;
    $self->get('alt_widget')->put(parent => $self)->initialize
	    if $self->unsafe_get('alt_widget');
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Draws the widget on the buffer so that it will only be rendered if
javascript is present.

=cut

sub render {
    my($self, $source, $buffer) = @_;

    $$buffer .= <<'EOF';
<script type="text/javascript">
<!--
EOF

    # draw the javascript text within a document.write()
    my($str) = '';
    $self->get('widget')->render($source, \$str);
    # escape any single quotes
    $str =~ s|'|\\'|g;
    # ensure it is one line
    $str =~ s|\n| |g;
    $$buffer .= "document.write('".$str."');
// -->
</script>";

    if ($self->unsafe_get('alt_widget')) {
	$$buffer .= "\n<noscript>\n";
	$self->get('alt_widget')->render($source, $buffer);
	$$buffer .= "\n</noscript>\n";
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
