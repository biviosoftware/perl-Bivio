# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
Summary: Release.bunit test data
Group: Bivio/Test

_b_release_include('release-bunit.include');

_b_release_files(q{
    %defattr(440,root,root)
    ${bunit_macro2}

    ${bunit_macro1}->{bunit_file}
    ${bunit_macro1}->{not_found_value}

    %
    +

    %files
});

