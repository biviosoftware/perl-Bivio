# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
{
    'header_in(content-type)' => 'application/x-www-form-urlencoded',
    content => 'a=1',
    expect => {
        _b_form_model_content_type => 'application/x-www-form-urlencoded',
        a => 1,
    },
};
