# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
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

#=IMPORTS

#=VARIABLES

sub COMMON_CODE {
    return __PACKAGE__ . '::JAVASCRIPT_HEAD';
}

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
    return exists(($source->get_request->unsafe_get(COMMON_CODE()) || {})
	->{$module_tag});
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

    return _render_script_in_head($req, $buffer)
	unless defined($module_tag)
	    || defined($common_code)
	    || defined($script)
	    || defined($no_script_html);

    # Render common code
    my($defns) = $req->get_if_exists_else_put(COMMON_CODE(), {});
    $defns->{$module_tag} ||= $common_code
	if defined($module_tag) && defined($common_code);

    # Render the code and script in a JavaScript section
    if (defined($script)) {
	$$buffer .= "<script type=\"text/javascript\">\n<!--\n";
	$$buffer .= $script;
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

# _render_script_in_head() : 
#
# render the common code in <script> tags
# intended to be called in the html <head> block
#
sub _render_script_in_head {
    my($req, $buffer) = @_;
    my($defns) = $req->unsafe_get(COMMON_CODE());
    return
	unless defined($defns);
    $$buffer .= "<script type=\"text/javascript\">\n<!--\n";
    foreach my $v (values(%$defns)) {
        $$buffer .= $v;
    }
    $$buffer .= "\n// -->\n</script>";
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
