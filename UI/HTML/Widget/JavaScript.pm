# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::JavaScript;
use strict;
$Bivio::UI::HTML::Widget::JavaScript::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::JavaScript - renders a JavaScript version flag

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::JavaScript;
    Bivio::UI::HTML::Widget::JavaScript->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::JavaScript::ISA = qw(Bivio::UI::HTML::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::JavaScript> renders a JavaScript version
flag.

=cut


=head1 CONSTANTS

=cut

=for html <a name="VERSION_VAR"></a>

=head2 VERSION_VAR : string

Name of version variable

=cut

sub VERSION_VAR {
    return 'jsv';
}

#=IMPORTS

#=VARIABLES
my($_VV) = VERSION_VAR();
my($_JSV) = <<"EOF";
<script language="JavaScript">
<!--
var $_VV=1.0;
// -->
</script>
<script language="JavaScript1.2">
<!--
var $_VV=1.2;
// -->
</script>
EOF

=head1 METHODS

=cut

=for html <a name="render"></a>

=head2 static render(any source, string_ref buffer)

Render the JavaScript version tag.

=cut

sub render {
    my(undef, $source, $buffer) = @_;
    my($req) = Bivio::Agent::Request->get_current;
    return if $req->unsafe_get('javascript_jsv');
    $$buffer .= $_JSV;
    $req->put(javascript_jsv => 1);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
