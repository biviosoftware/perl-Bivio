# Copyright (c) 2013 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::GoogleAnalytics;
use strict;
use Bivio::Base 'Widget.Simple';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    my($tracking_id) = $self->get('tracking_id');
    $self->put(value => <<"EOF");
<script type="text/javascript">
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '$tracking_id']);
  _gaq.push(['_trackPageview']);
  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
</script>
EOF
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    my($self, $tracking_id) = @_;
    return {
	tracking_id => $tracking_id,
    };
}

1;
