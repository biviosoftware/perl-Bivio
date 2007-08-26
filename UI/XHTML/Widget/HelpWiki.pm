# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::HelpWiki;
use strict;
use base 'Bivio::UI::Widget';
use Bivio::UI::ViewLanguageAUTOLOAD;
use Bivio::UI::XHTML::Widget::WikiStyle;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
        value => Join([
	    <<'EOF',	       
<script>
function toggle_help_popup() {
  var o = document.getElementById('help_wiki');
  o.style.visibility = o.style.visibility == 'visible' ? 'hidden' : 'visible';
}
</script>
EOF
            RoundedBox({
		class => 'help_wiki',
		tag => 'div',
		id => 'help_wiki',
		control => [\&_wiki_text, $self],
		value => Join([
		    DIV_help_close(_toggle_link('[close]')),
	            DIV_header(Prose(vs_text('helpwiki.header'))),
	            DIV_help_wiki_body([['->get_request'], "$self"]),
	            DIV_footer(Prose(vs_text('helpwiki.footer'))),
		]),
	    }),
            If(['->unsafe_get', "$self"],
                DIV_help_link(_toggle_link('Help')),
                If([\&_is_help_author],
                    DIV_help_link(Link('Add Help', 
		        ['->format_uri', 'FORUM_WIKI_VIEW', '', 
		        [\&_help_realm_name], [\&_help_page]]))),
            ),
        ]));
    return shift->SUPER::initialize(@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    $self->get('value')->render($source, $buffer);
    return;
}

sub _help_page {
    my($req) = @_;
    my($name) = Bivio::UI::Text->get_from_source($req)->get_value(
        'title', $req->get('task_id')->get_name);
    $name =~ s/\W//g;
    return $name . 'Help';
}

sub _help_realm_name {
    my($req) = shift->get_request;
    return @{$req->map_user_realms(sub {
        my($user_realm) = @_;
	return grep($_->eq_administrator, @{$user_realm->{roles}})
	    ? $user_realm->{'RealmOwner.name'}
	    : ();
    }, {
	'RealmUser.realm_id' => Bivio::UI::Constant->get_from_source($req)
	    ->get_value('help_wiki_realm_id'),
    })};
}

sub _is_help_author {
    return _help_realm_name(@_);
}

sub _toggle_link {
    my($text) = @_;
    return Link($text, 'javascript: toggle_help_popup()');
}

sub _wiki_text {
    my($source, $self) = @_;
    my($req) = $source->get_request;
    return 0
	unless my($html) = Bivio::UI::XHTML::Widget::WikiStyle->render_html(
            _help_page($req), $req, Bivio::Agent::TaskId->HELP,
	    Bivio::UI::Constant->get_from_source($req)
	        ->get_value('help_wiki_realm_id'));
    $req->put("$self" => $$html);
    return 1;
}

1;
