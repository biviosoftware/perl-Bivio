# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::DateYearHandler;
use strict;
$Bivio::UI::HTML::Widget::DateYearHandler::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::DateYearHandler::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::DateYearHandler - txn to val date handler

=head1 RELEASE SCOPE

Societas

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::DateYearHandler;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::DateYearHandler::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::DateYearHandler>

=head1 ATTRIBUTES

=over 4

=item form_name : string (inherited)

Used to access the form within JavaScript.

=item target_field : string

The date field to receive the new value. This value only get assigned
if the source date is less than the current value.

=cut

=head1 CONSTANTS

=cut

=for html <a name="JAVASCRIPT_FUNCTION_NAME"></a>

=head2 JAVASCRIPT_FUNCTION_NAME : string

Return the tag used by this class to prefix javascript functions.

=cut

sub JAVASCRIPT_FUNCTION_NAME {
    return 'dy';
}

#=IMPORTS
use Bivio::UI::HTML::Widget::JavaScript;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_FUNCS) = Bivio::UI::HTML::Widget::JavaScript->strip(<<"EOF");

// Adds the current four digit year to the source date if
// it is not given, or completes a two digit date (now+20 mapping).
// s - full source date (input by user)
// s_month - source month
// s_day - source day
// s_year - source year
// c_date - full current date (taken from local machine)
// c_year - current year (taken from local machine)
// slash_1 - index of first slash
// slash_2 - index of second slash (-1 if not present)
function dy_complete_date(s) {
  c_date = new Date();
  c_year = c_date.getFullYear();
  slash_1 = s.value.indexOf('/');
  slash_2 = s.value.indexOf('/', slash_1 + 1);
  s_month = s.value.substring(0, slash_1);
  s_day = s.value.substring(slash_1 + 1, slash_2);
  s_year = s.value.substring(slash_2 + 1, s.value.length);

  if (slash_2 == -1) {
    s.value = s.value + '/' + c_year;
  }

  else if (s_year.length == 2) {
    diff = c_year - 1980;

    if (diff >= s_year) {
      s_year = '20' + s_year;
    }

    else {
      s_year = '19' + s_year;
    }

    s.value = s_month + '/' + s_day + '/' + s_year;
  }
}
EOF

=head1 METHODS

=cut

=for html <a name="get_html_field_attributes"></a>

=head2 get_html_field_attributes(string field_name, ref source) : string

Returns the inlined source for this method.

=cut

sub get_html_field_attributes {
    my($self, $field_name, $source) = @_;
    # This has to be onBlur, because onChange doesn't work quite right in IE.
    return ' onBlur="dy_complete_date(this)"';
}

=for html <a name="initialize"></a>

=head2 initialize()

NOP

=cut

sub initialize {
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Renders the javascript.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    Bivio::UI::HTML::Widget::JavaScript->render($source, $buffer,
	    JAVASCRIPT_FUNCTION_NAME(), $_FUNCS);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
