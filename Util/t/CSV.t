# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
use Bivio::Test;
use Bivio::Util::CSV;

#my($str);

Bivio::Test->unit([
    {
	object => Bivio::Util::CSV->new,
	compute_params => sub {
	    my($case, $params) = @_;
	    my($expect) = $case->get('expect');
	    $case->expect([\$expect->[0]]);
	    # First parameter is -input value
	    $case->get('object')->put(input => \$params->[0]);
	    shift(@$params);
	    return $params;
	},
    } => [
	colrm => [
	    ["a,b,c\n", 0, 1] => ["b,c\n"],
	    ["a,b,c\n", 1, 2] => ["a\n"],
	    ["a,b,c,d\nw,x,y,z\n", 2] => ["a,b\nw,x\n"],
	],
    ],
    'Bivio::Util::CSV' => [
        to_csv_text => [
            [[]] => => [\("\n")],
            [['']] => => [\("\n")],
            [[undef]] => => [\("\n")],
            [[0]] => => [\("0\n")],
            [[1, 2, 3]] => [\("1,2,3\n")],
            [['ab"c', ' blah', 'blah ', "foo\n"]]
                => [\(qq{"ab""c"," blah","blah ","foo\n"\n})],
            [[
                [1, undef, 2],
                [undef, undef, "\n\n\n",3,4],
                [],
                ['the,end'],
            ]] => [
                \(qq{1,,2\n,,"\n\n\n",3,4\n\n"the,end"\n}),
            ],
        ],
        parse => [
            [\(qq{1,,2\n,,"\r\n\n\r",3,4\n\n"the,end"\n})]
                => [[
                    [1, '', 2],
                    ['', '', "\n\n\n",3,4],
                    [''],
                    ['the,end'],
                ]],
            [\(qq{1""2,3\n})] => Bivio::DieCode->DIE,
            [\(qq{"abc"2,3\n})] => Bivio::DieCode->DIE,
            [\(qq{"abc2,3\n})] => Bivio::DieCode->DIE,
            # needed to use a var to avoid "modification of read-only value"
            [\(my($str) = qq{missing eol,1,2,3})]
                => [[['missing eol', 1, 2, 3]]],
        ],
    ],
]);
