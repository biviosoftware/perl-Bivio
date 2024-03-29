# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
{
   'header_in(content-type)' => 'multipart/form-data; boundary=xYzZY',
    content => <<'EOF',
--xYzZY
Content-Disposition: form-data;
  name="f1";
  filename="x.gif"
Content-Type: image/gif

GIF89a  �  �   !�    ,       2 ;
--xYzZY
Content-Disposition: form-data; name="f2"

18p9447f
--xYzZY
Content-Disposition: form-data; name="v"

1
--xYzZY--
EOF
    expect => {
        _b_form_model_content_type => 'multipart/form-data',
        v => 1,
        f1 => {
            content => \(q{GIF89a  �  �   !�    ,       2 ;}),
            name => 'f1',
            filename => 'x.gif',
            content_type => 'image/gif',
        },
        f2 => '18p9447f',
    },
};
