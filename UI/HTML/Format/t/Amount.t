#!perl -w
# $Id$
#
use strict;

use Bivio::Test;
use Bivio::TypeError;
use Bivio::UI::HTML::Format::Amount;

Bivio::Test->unit([
    'Bivio::UI::HTML::Format::Amount' => [
        get_widget_value => [
            ['123'] => '123.00',
            ['123.456'] => '123.46',
            ['-125.73'] => '-125.73',
            ['-125.73', 0] => '-126',
            ['1234567.89'] => '1,234,567.89',
            ['0', undef, undef, 1] => ' ',
            ['+0', undef, undef, 1] => ' ',
            ['+0'] => '0.00',
            ['-0'] => '0.00',
            ['+123'] => '123.00',
            ['-1125.73', undef, 1] => '(1,125.73)',
            ['-1125.73', 0, 1] => '(1,126)',
        ],
    ],
]);
