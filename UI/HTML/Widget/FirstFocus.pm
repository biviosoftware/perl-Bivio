# Copyright (c) 2004 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::FirstFocus;
use strict;
$Bivio::UI::HTML::Widget::FirstFocus::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::FirstFocus::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::FirstFocus - javascript focus on first form field, if present

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::FirstFocus;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::FirstFocus::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::FirstFocus>

    Page({
	head => Join([
            Title(...),
            # focus on first form field
            FirstFocus(),
        ]),
        body => ...
    });

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Registers with the parent Page's body html_tag_attrs.

=cut

sub initialize {
    my($self) = @_;
    return if $self->unsafe_get('initialized');
    my($current) = $self;

    while ($current = $current->unsafe_get('parent')) {
        last if $current
            && $current->isa('Bivio::UI::HTML::Widget::Page');
    }
    Bivio::Die->die("couldn't find parent Page") unless $current;
    my($body) = $current->get('body');
    $body->put(html_tag_attrs =>
        ($body->unsafe_get('html_tag_attrs') || '') . ' onload="ff();"');
    $self->put(initialized => 1);
    return;
}

=for html <a name="render"></a>

=head2 render(Bivio::UI::WidgetValueSource source, string_ref buffer)

Renders this instance into I<buffer> using I<source> to evaluate
widget values.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    $$buffer .= <<'EOF';
<script language="JavaScript">
<!--
function ff() {
    if (document.forms.length == 0)
        return;
    var fields = document.forms[0].elements;
    for (i=0; i < fields.length; i++) {
        if (fields[i].type == 'text' || fields[i].type == 'select-one'
            || fields[i].type == 'textarea') {
            fields[i].focus();
            break;
        }
    }
}
//-->
</script>
EOF
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2004 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
