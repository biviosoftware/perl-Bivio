# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::TimezoneField;
use strict;
$Bivio::UI::HTML::Widget::TimezoneField::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::TimezoneField - hidden field which computes Timezone

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::TimezoneField;
    Bivio::UI::HTML::Widget::TimezoneField->render($source, $buffer);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::TimezoneField::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::TimezoneField> renders a hidden field
which computes the Timezone in JavaScript.  Since there is no
C<getTimezone> in JavaScript.  This is a hack.  Right now, we only
get the delta for I<now>.  This should be sufficient for most
problems.  In general, we try to render dates and times on the
client.

=cut

#=IMPORTS
use Bivio::Biz::FormModel;
use Bivio::UI::HTML::Widget::JavaScript;

#=VARIABLES
my($_FIELD) = Bivio::Biz::FormModel->TIMEZONE_FIELD;
my($_FUNCS) = <<"EOF";
function tzf(){
    // Compute the timezone
    var d=new Date();
    var o=d.getTimezoneOffset();
    document.write('<input name=$_FIELD type=hidden value="'+o+'">');
}
EOF
Bivio::UI::HTML::Widget::JavaScript->strip(\$_FUNCS);

=head1 METHODS

=cut

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

=cut

sub render {
    my($self, $source, $buffer) = @_;
    Bivio::UI::HTML::Widget::JavaScript->render($source, $buffer,
	    'tzf',
	    $_FUNCS,
	    "tzf()");
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
