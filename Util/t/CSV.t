use Bivio::Test;
use Bivio::Util::CSV;

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
]);
