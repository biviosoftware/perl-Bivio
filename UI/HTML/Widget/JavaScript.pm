# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::JavaScript;
use strict;
$Bivio::UI::HTML::Widget::JavaScript::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::JavaScript::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::JavaScript - renders a JavaScript version flag

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::JavaScript;
    Bivio::UI::HTML::Widget::JavaScript->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::JavaScript::ISA = qw(Bivio::UI::Widget);

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
</script><script language="JavaScript1.2">
<!--
$_VV=1.2;
// -->
</script>
EOF
chomp($_JSV);

=head1 METHODS

=cut

=for html <a name="escape_string"></a>

=head2 escape_string(string_ref unescaped_text) : string_ref

Converts a text string into something safely escaped.
Returns its first argument.

=cut

sub escape_string {
    my($self, $text) = @_;
    $$text =~ s/\\/\\\\/g;
    $$text =~ s/'/\\'/g;
    $$text =~ s/\n/\\n/g;
    $$text =~ s#/#\\/#g;
    return $text;
}

=for html <a name="has_been_rendered"></a>

=head2 has_been_rendered(any source, string module_tag) : boolean

returns true if common code has been rendered.

=cut

sub has_been_rendered {
    my(undef, $source, $module_tag) = @_;
    return _tag($source->get_request, $module_tag) ? 0 : 1;
}

=for html <a name="render"></a>

=head2 static render(any source, string_ref buffer, string module_tag, string common_code, string script, string no_script_html)

Render the JavaScript version tag if not already rendered.
Renders the I<common_code> for I<module_tag> if not already
rendered.  Renders I<script> and I<no_script_html> if defined.

=cut

sub render {
    my(undef, $source, $buffer, $module_tag, $common_code,
	    $script, $no_script_html) = @_;
    my($req) = $source->get_request;

    # Render common code
    my($code);
    if (my $tag = _tag($req, $module_tag)) {
	# Render "global" common code first
	unless ($req->unsafe_get('javascript_jsv')) {
	    # Always write here
	    $$buffer .= $_JSV;
	    $req->put(javascript_jsv => 1);
	}
	$code = $common_code;
	$req->put($tag => 1);
    }

    # Render the code and script in a JavaScript section
    if (defined($script) || defined($code)) {
	$$buffer .= "<script language=\"JavaScript\">\n<!--\n";
	$$buffer .= $code if defined($code);
	$$buffer .= $script if defined($script);
	$$buffer .= "\n// -->\n</script>";
    }

    # Render noscript
    $$buffer .= '<noscript>'.$no_script_html.'</noscript>'
	    if defined($no_script_html);

    return;
}

=for html <a name="strip"></a>

=head2 static strip(string code) : string

Strips leading blanks and comments.

=cut

sub strip {
    my(undef, $code) = @_;
    # Strip leading blanks and blank lines
    $code =~ s/^\s+//sg;
    $code =~ s/\n\s+/\n/g;

    # Strip comments
    $code =~ s/\/\/.*\n//g;
    return $code;
}

#=PRIVATE METHODS

# _tag(Bivio::Agent::Request req, string module_tag) : string
#
# returns the tag if it hasn't already been rendered
#
sub _tag {
    my($req, $module_tag) = @_;
    my($tag) = 'javascript_'.$module_tag;
    return $req->unsafe_get($tag) ? undef : $tag;
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
