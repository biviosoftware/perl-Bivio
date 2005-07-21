# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
Bivio::Test->new('Bivio::Biz::Model::UserCreateForm')->unit([
    'Bivio::Biz::Model::UserCreateForm' => [
	{
	    method => 'parse_display_name',
	    compute_return => sub {
		my($case, $actual) = @_;
		my($a) = $actual->[0];
		return ref($actual->[0]) eq 'HASH'
		    ? [@$a{qw(first_name middle_name last_name)}]
		    : [$actual->[0]->get_name];
	    },
	} => [
	    'Dr. John' => ['Dr.', undef, 'John'],
	    'Hot, Dog' => ['Dog', undef, 'Hot'],
	    'Mary J. Keene, M.D.' => ['Mary', 'J.', 'Keene, M.D.'],
	    'Mary Krueger, R.N.' => ['Mary', undef, 'Krueger, R.N.'],
	    'Rob de la Roche' => ['Rob', undef, 'de la Roche'],
	    'Ludwig von Beethoven' => ['Ludwig', undef, 'von Beethoven'],
	    'Rev. H. Gross' => ['Rev. H.', undef, 'Gross'],
	    'Drew A. Barrymore' => ['Drew', 'A.', 'Barrymore'],
	    'King James III' => ['King', undef, 'James, III'],
	    'Joe Gross, JD' => ['Joe', undef, 'Gross, JD'],
	    'Mrs. Fiona A. Brydy' => ['Mrs. Fiona', 'A.', 'Brydy'],
	    'Dr. A. Carter MD' => ['Dr. A.', undef, 'Carter, MD'],
	    'Dr. Richards' => ['Dr.', undef, 'Richards'],
	    'Miss Missy M. Mistletoe, M.S.' => ['Miss Missy', 'M.', 'Mistletoe, M.S.'],
	    'Joe' => [undef, undef, 'Joe'],
	    'Jones Sr' => [undef, undef, 'Jones, Sr'],
	    'A.B. Gross' => ['A.', 'B.', 'Gross'],
	    'IM ALL CAPS' => ['IM', 'ALL', 'CAPS'],
	    'Mr.Eric R. Du Puis' => ['Mr. Eric', 'R.', 'Du Puis'],
	    'Juan Chuy de Marcos' => ['Juan', 'Chuy', 'de Marcos'],
	    'Maggie de la Rosa' => ['Maggie', undef, 'de la Rosa'],
	    ',' => 'NULL',
	    'MyVeryLongNameShouldBlowTheLengthLimit a b'
		=> 'FIRST_NAME_LENGTH',
	    'a MyVeryLongNameShouldBlowTheLengthLimit b'
		=> 'MIDDLE_NAME_LENGTH',
	    'a b MyVeryLongNameShouldBlowTheLengthLimit'
		=> 'LAST_NAME_LENGTH',
	],
    ],
]);
