# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::JavaScript;
use strict;
use Bivio::Base 'Bivio::UI::Widget';

my($_COMMON_CODE) = __PACKAGE__ . '.common_code';
my($_ID) = 0;

sub BASE_VAR_NAME {
    return 'window.bivio';
}

sub escape_string {
    my($self, $text) = @_;
    # Converts a text string into something safely escaped.
    # Returns its first argument.
    $$text =~ s/\\/\\\\/g;
    $$text =~ s/'/\\'/g;
    $$text =~ s/\n/\\n/g;
    $$text =~ s#/#\\/#g;
    return $text;
}

sub has_been_rendered {
    my(undef, $source, $module_tag) = @_;
    # returns true if common code has been rendered.
    return exists(($source->get_request->unsafe_get($_COMMON_CODE) || {})
        ->{$module_tag});
}

sub render {
    my($self, $source, $buffer, $module_tag, $common_code,
    # Render the JavaScript version tag if not already rendered.
    # Renders the I<common_code> for I<module_tag> if not already
    # rendered.  Renders I<script> and I<no_script_html> if defined.
            $script, $no_script_html) = @_;
    my($req) = $source->get_request;

    return _render_script_in_head($self, $req, $buffer)
        unless defined($module_tag)
            || defined($common_code)
            || defined($script)
            || defined($no_script_html);

    # Render common code (on parent request if embedded)
    my($root_req) = $req->unsafe_get_current_root || $req;
    my($defns) = $root_req->get_if_exists_else_put($_COMMON_CODE, {});
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

sub strip {
    my(undef, $code) = @_;
    # Strips leading blanks and comments.
    # Strip leading blanks and blank lines
    $code =~ s/^\s+//sg;
    $code =~ s/\n\s+/\n/g;
    $code =~ s{^\s*//.*\n}{}mg;
    return $code;
}

sub unique_html_id {
    return 'b_js' . ++$_ID;
}

sub var_name {
    my($self, $suffix) = @_;
    return $self->BASE_VAR_NAME . ".$suffix";
}

sub _render_script_in_head {
    my($self, $req, $buffer) = @_;
    # render the common code in <script> tags
    # intended to be called in the html <head> block
    my($defns) = $req->unsafe_get($_COMMON_CODE);
    return
        unless defined($defns);
    my($bvn) = $self->BASE_VAR_NAME;
    $$buffer .= <<"EOF"
<script type=\"text/javascript\">
<!--
$bvn = $bvn || {};
EOF
        . join('', values(%$defns))
        . "
// -->
</script>";
    return;
}

1;
