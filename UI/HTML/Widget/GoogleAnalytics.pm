# Copyright (c) 2013 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::GoogleAnalytics;
use strict;
use Bivio::Base 'Widget.Simple';

my($_C) = b_use('IO.Config');

sub initialize {
    my($self) = @_;
    my($tracking_id, $site) = $self->get(qw(tracking_id site));
    $self->put(
        value => $_C->is_production
            ? <<"EOF"
<script type="text/javascript">
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
  ga('create', '$tracking_id', '$site');
  ga('send', 'pageview');
</script>
EOF
            : ''
    );
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    my($self, $tracking_id, $site) = @_;
    return {
        tracking_id => $tracking_id,
        site => $site,
    };
}

1;
