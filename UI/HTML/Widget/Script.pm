# Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::Script;
use strict;
$Bivio::UI::HTML::Widget::Script::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::Script::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::Script - generates scripts in header

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Script;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::Script::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Script> is called with a script name, which
is rendered in the head.   Currently, only scripts that are constants,
called JAVASCRIPT_I<script_name> are allowed.  The script must have an
onload function called I<script_name>_onload.

Only supports JavaScript.

=head1 ATTRIBUTES

=over 4

=item value : any []

Renders the name of the script to render.

=back

=cut

=head1 CONSTANTS

=cut

=for html <a name="JAVASCRIPT_CORRECT_TABLE_LAYOUT_BUG"></a>

=head2 JAVASCRIPT_CORRECT_TABLE_LAYOUT_BUG() : string

Adds newline to html body to cause the browser to layout the table
again. Works around mozilla/firefox layout bug.

=cut

sub JAVASCRIPT_CORRECT_TABLE_LAYOUT_BUG {
    return <<'EOF';
function correct_table_layout_bug_onload() {
    if (navigator.appName == "Netscape")
      document.body.innerHTML += "\n";
}
EOF
}

=for html <a name="JAVASCRIPT_FIRST_FOCUS"></a>

=head2 JAVASCRIPT_FIRST_FOCUS : string

Forces focus to first text input field, if there is one.

=cut

sub JAVASCRIPT_FIRST_FOCUS {
    return <<'EOF';
function first_focus_onload() {
    if (document.forms.length == 0)
        return;
    var fields = document.forms[0].elements;
    for (i=0; i < fields.length; i++) {
        if (fields[i].type == 'text' || fields[i].type == 'textarea') {
            try {
                fields[i].focus();
            } catch (err) {}
            break;
        }
    }
}
EOF
}

=for html <a name="JAVASCRIPT_PAGE_PRINT"></a>

=head2 JAVASCRIPT_PAGE_PRINT : string

Prints on load.

=cut

sub JAVASCRIPT_PAGE_PRINT {
    return 'function page_print_onload(){window.print()}';
}

#=IMPORTS

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

=cut

sub initialize {
    my($self) = @_;
    $self->unsafe_initialize_attr('value');
    return;
}

=for html <a name="internal_new_args"></a>

=head2 internal_new_args(...) : any

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my($proto, $value, $attrs) = @_;
    return {
	($value ? (value => $value) : ()),
	($attrs ? %$attrs : ()),
    };
}

=for html <a name="render"></a>

=head2 render(Bivio::UI::WidgetValueSource source, string_ref buffer)

Renders this instance into I<buffer> using I<source> to evaluate
widget values.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    if ($self->has_keys('value')) {
	my($x) = '';
	if ($self->unsafe_render_attr('value', $source, \$x) && $x) {
	    $x = 'JAVASCRIPT_' . uc($x);
	    $self->die('value', $source, $x, ': no such script')
		unless $self->can($x);
	    my($names) = $req->get_if_exists_else_put(__PACKAGE__, []);
	    push(@$names, $x)
		unless grep($x eq $_, @$names);
	}
	return;
    }
    my($names) = $req->unsafe_get(__PACKAGE__);
    return unless $names;
    $req->delete(__PACKAGE__);

    my($js) = $_VS->vs_call('JavaScript');
    $$buffer .= join(
	"\n",
	qq{<script type="text/javascript">\n<!--},
	map($js->strip($self->$_()), @$names),
	'window.onload=function(){',
	grep(s/JAVASCRIPT_(.*)/\L$1\E_onload();/, @$names),
	'}',
	"// --></script>",
	'',
    );
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
