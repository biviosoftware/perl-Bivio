use Bivio::Test;
use Bivio::Util::CSV;

Bivio::Test->unit([
    {
	object => Bivio::Util::CSV->new,
	compute_params => sub {
	    my($object, $method, $params) = @_;
	    # First parameter is -input value
	    $object->put(input => \$params->[0]);
	    shift(@$params);
	    return $params;
	},
	result_ok => sub {
	    my($object, $method, $params, $expect, $actual) = @_;
	    return ${$actual->[0]} eq $expect->[0];
	},
    } => [
	colrm => [
	    ["a,b,c\n", 0, 1] => ["b,c\n"],
	    ["a,b,c\n", 1, 2] => ["a\n"],
	    ["a,b,c,d\nw,x,y,z\n", 2] => ["a,b\nw,x\n"],
	],
    ],
]);
