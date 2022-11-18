# Copyright (c) 2001-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::DateYearHandler;
use strict;
use Bivio::Base 'UI.Widget';

# form_name : string (inherited)
#
# Used to access the form within JavaScript.
#
# target_field : string
#
# The date field to receive the new value. This value only get assigned
# if the source date is less than the current value.

my($_JS) = b_use('HTMLWidget.JavaScript');
my($_FUNCS) = $_JS->strip(<<'EOF');
function dy_complete_date(s) {
    if (s.value.length == 0)
        return;
    var c_year = new Date().getFullYear() + '';
    var century = c_year.substring(0, 2);
    var pattern = new RegExp('^[0-9]?[0-9][/\.][0-9]?[0-9][/\.]?[0-9]?[0-9]?$');
    if (!pattern.test(s.value)) {
        pattern = new RegExp('^[0-9][0-9][0-9][0-9]$');
        if (!pattern.test(s.value)) {
            pattern = new RegExp('^[0-9][0-9][0-9][0-9][0-9][0-9]$');
            if (!pattern.test(s.value))
                return;
            c_year = century + s.value.substring(4, 6);
        }
        s.value = s.value.substring(0, 2) + '/'
            + s.value.substring(2, 4) + '/'
            + c_year;
        return;
    }
    var sep = '/';
    if ((sep_1 = s.value.indexOf(sep)) < 0)
        sep_1 = s.value.indexOf(sep = '.');
    var sep_2 = s.value.indexOf(sep, sep_1 + 1);
    var s_month = s.value.substring(0, sep_1);
    var s_day, s_year;
    if (sep_2 == -1) {
        s_day = s.value.substring(sep_1 + 1, s.value.length);
        s_year = '';
    }
    else {
        s_day = s.value.substring(sep_1 + 1, sep_2);
        s_year = s.value.substring(sep_2 + 1, s.value.length);
    }
    if (s_month.length > 2 || s_day.length > 2)
        return;
    if (sep_2 == -1) {
        var arr = s.value.match(/^([0-9]?[0-9])\/([0-9]?[0-9])$/);
        if (arr) {
            // default year to previous if compute date is 300 days out
            // helpful when entering december dates in january
            if ((new Date(c_year, arr[1] - 1, + arr[2]) - new Date())
                / (1000 * 60 * 60 * 24) > 300)
                c_year -= 1;
        }
        s.value = s.value + sep + c_year;
    }
    else if (s_year.length == 0)
        s.value = s.value + c_year;
    else if (s_year.length <= 2)
        s.value = s_month + sep + s_day + sep
            + (s_year.length == 1 ? century + '0'
            : c_year - (century + '00') >= s_year - 20 ? century
            : century - 1)
            + s_year;
}
EOF

sub JAVASCRIPT_FUNCTION_NAME {
    return 'dy';
}

sub get_html_field_attributes {
    my($self, $field_name, $source) = @_;
    return ' onblur="dy_complete_date(this)"';
}

sub render {
    my($self, $source, $buffer) = @_;
    $_JS->render($source, $buffer, shift->JAVASCRIPT_FUNCTION_NAME, $_FUNCS);
    return;
}

1;
