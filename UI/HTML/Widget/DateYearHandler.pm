# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::DateYearHandler;
use strict;
use Bivio::Base 'Bivio::UI::Widget';
use Bivio::UI::HTML::Widget::JavaScript;

# C<Bivio::UI::HTML::Widget::DateYearHandler>
#
#
#
# form_name : string (inherited)
#
# Used to access the form within JavaScript.
#
# target_field : string
#
# The date field to receive the new value. This value only get assigned
# if the source date is less than the current value.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FUNCS) = Bivio::UI::HTML::Widget::JavaScript->strip(<<"EOF");

// Adds the current four digit year to the source date if
// it is not given, or completes a two digit date (now+20 mapping).
// s - full source date (input by user)
// s_month - source month
// s_day - source day
// s_year - source year
// c_year - current year (taken from local machine)
// slash_1 - index of first slash
// slash_2 - index of second slash (-1 if not present)
function dy_complete_date(s) {
  if (s.value.length == 0)
    return;
  c_year = new Date().getFullYear();
  slash_1 = s.value.indexOf('/');
  slash_2 = s.value.indexOf('/', slash_1 + 1);
  s_month = s.value.substring(0, slash_1);

  if (slash_2 == -1) {
    s_day = s.value.substring(slash_1 + 1, s.value.length);
    s_year = "";
  } else {
    s_day = s.value.substring(slash_1 + 1, slash_2);
    s_year = s.value.substring(slash_2 + 1, s.value.length);
  }

  var pattern = new RegExp("[0-9]?[0-9]/[0-9]?[0-9](/[0-9][0-9])?");

  // Had to hack this a bit, don't think Regex works in IE correctly
  if (!pattern.test(s.value)) {
    return;
  } else if (s_month.length > 2 || s_day.length > 2) {
    return;
  }

  if (slash_2 == -1) {
    s.value = s.value + '/' + c_year;
  } else if (s_year.length == 2) {
    diff = c_year - 1980;

    if (diff >= s_year) {
      s_year = '20' + s_year;
    } else {
      s_year = '19' + s_year;
    }

    s.value = s_month + '/' + s_day + '/' + s_year;
  }
}
EOF

sub JAVASCRIPT_FUNCTION_NAME {
    # : string
    # Return the tag used by this class to prefix javascript functions.
    return 'dy';
}

sub get_html_field_attributes {
    # (self, string, ref) : string
    # Returns the inlined source for this method.
    my($self, $field_name, $source) = @_;
    # This has to be onBlur, because onChange doesn't work quite right in IE.
    return ' onblur="dy_complete_date(this)"';
}

sub initialize {
    # (self) : undef
    # NOP
    return;
}

sub render {
    # (self, any, string_ref) : undef
    # Renders the javascript.
    my($self, $source, $buffer) = @_;
    Bivio::UI::HTML::Widget::JavaScript->render($source, $buffer,
	    JAVASCRIPT_FUNCTION_NAME(), $_FUNCS);
    return;
}

1;
