# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
{
   'header_in(content-type)' => 'multipart/form-data; boundary=xYzZY',
    content => <<'EOF',
--xYzZY
Content-Disposition: form-data; name="mode"

add
--xYzZY
Content-Disposition: form-data; name="currentpath"

Public/
--xYzZY
Content-Disposition: form-data; name="newfile"; filename="a.txt"
Content-Type: text/plain

I am a.txt
--xYzZY
Content-Disposition: form-data; name="newfile"; filename="b.txt"
Content-Type: text/plain

I am b.txt
--xYzZY
Content-Disposition: form-data; name="droppedfiles"


--xYzZY--
EOF
    expect => {
        _b_form_model_content_type => 'multipart/form-data',
        mode => 'add',
        currentpath => 'Public/',
        newfile => [
        {
                  content => \('I am a.txt'),
                  filename => 'a.txt',
                  content_type => 'text/plain', 
        },
        {
                  content => \('I am b.txt'),
                  filename => 'b.txt',
                  content_type => 'text/plain', 
        },
        ],
        droppedfiles => '',
    },
};
