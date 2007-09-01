# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::HelpWiki;
use strict;
use base 'Bivio::UI::Widget';
use Bivio::UI::ViewLanguageAUTOLOAD;
use Bivio::UI::XHTML::Widget::WikiStyle;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_QUERY_KEY) = 'id';
my($_TASK_ID_FROM_REQ) = [sub {
    my($req) = @_;
    return Bivio::Agent::TaskId->from_int($req->get('query')->{$_QUERY_KEY});
}];

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	help_box => If([\&_wiki_text, $self, $_TASK_ID_FROM_REQ],
	    DIV_help_wiki(Join([
		DIV_help_close(Join([
		    If([\&_is_help_author],
			Link('[edit]',
			    ['->format_uri', 'FORUM_WIKI_EDIT', '',
				[\&_help_realm_name],
				[\&_help_page, $_TASK_ID_FROM_REQ]])),
		    vs_blank_cell(),
		    Link('[close]',
			'javascript: parent.toggle_help_popup()'),
		])),
		DIV_header(Prose(vs_text('helpwiki.header'))),
		DIV_help_wiki_body([['->get_request'], "$self"]),
		DIV_footer(Prose(vs_text('helpwiki.footer'))),
	    ])),
	),
        value => Join([
	    <<"EOF",
<script>
function resize_help_popup() {
  var o = document.getElementById('help_wiki_iframe');
  var node = document.getElementById('help_link');
  var top = node.offsetHeight;
  while (node) {
    top += node.offsetTop;
    node = node.offsetParent;
  }
  o.style.top = top + 'px';

  if (document.all) {
    var b = help_wiki_iframe.document.body;
    o.style.height = b.scrollHeight;
    o.style.width = b.scrollWidth;
    o.style.height = b.scrollHeight + (b.offsetHeight - b.clientHeight);
  }
  else {
    o.style.height = o.contentDocument.body.scrollHeight + 'px';
  }
  o.style.visibility = '@{[$self->get_or_default('visibility', 'hidden')]}';
}

function toggle_help_popup() {
  var o = document.getElementById('help_wiki_iframe');
  o.style.visibility = o.style.visibility == 'visible' ? 'hidden' : 'visible';
}
</script>
EOF
	    If([\&_wiki_text, $self],
		Join([
		    '<iframe id="help_wiki_iframe" marginewidth="0" scrolling="no" frameborder="0" src="',
		    URI({
  			task_id => 'FORUM_HELP_IFRAME',
			realm => [\&_help_realm_name],
			query => {
			    $_QUERY_KEY => ['task_id', '->as_int'],
			},
  		    }),
		    '"></iframe>',
		]),
	    ),
            If(['->unsafe_get', "$self"],
                DIV_help_link(Link('Help', 'javascript: toggle_help_popup()')
		   ->put(attributes => ' id="help_link"')),
                If([\&_is_help_author],
                    DIV_help_link(Link('Add Help',
		        ['->format_uri', 'FORUM_WIKI_EDIT', '',
			    [\&_help_realm_name], [\&_help_page]]))),
	       ),
        ]));
    return shift->SUPER::initialize(@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    $self->get($self->unsafe_get('show_help_box')
	? 'help_box' : 'value')->render($source, $buffer);
    return;
}

sub _help_page {
    my($req, $task_id) = @_;
    my($name) = Bivio::UI::Text->get_from_source($req)->get_value(
        'title', ($task_id || $req->get('task_id'))->get_name);
    $name =~ s/\W//g;
    return $name . 'Help';
}

sub _help_realm_name {
    my($source, $admin_only) = @_;
    my($req) = shift->get_request;
    my($realm_id) = Bivio::UI::Constant->get_from_source($req)
	->get_value('help_wiki_realm_id');
    my($name) = @{$req->map_user_realms(
	sub {
	    my($user_realm) = @_;
	    return grep($_->eq_administrator, @{$user_realm->{roles}})
		? $user_realm->{'RealmOwner.name'}
		    : ();
	}, {
	    'RealmUser.realm_id' => $realm_id,
	})};
    return $admin_only
	? $name
	: Bivio::Biz::Model->new($req, 'RealmOwner')->unauth_load_or_die({
	    realm_id => $realm_id,
	})->get('name');
}

sub _is_help_author {
    return _help_realm_name(@_, 1);
}

sub _wiki_text {
    my($source, $self, $task_id) = @_;
    my($req) = $source->get_request;
    return 0
	unless my($html) = Bivio::UI::XHTML::Widget::WikiStyle->render_html(
            _help_page($req, $task_id), $req, Bivio::Agent::TaskId->HELP,
	    Bivio::UI::Constant->get_from_source($req)
	    ->get_value('help_wiki_realm_id'));
    $req->put("$self" => $$html);
    return 1;
}

1;
