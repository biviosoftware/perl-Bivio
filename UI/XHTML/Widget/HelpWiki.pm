# Copyright (c) 2006-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::HelpWiki;
use strict;
use Bivio::Base 'Widget.If';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WN) = b_use('Type.WikiName');
my($_WT) = b_use('XHTMLWidget.WikiText');
my($_RF) = b_use('Action.RealmFile');
my($_T) = b_use('FacadeComponent.Text');
my($_C) = b_use('FacadeComponent.Constant');
my($_TASK_ID) = b_use('Agent.TaskId')->HELP;

sub RESIZE_FUNCTION {
    return 'help_wiki_resize';
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr(control => 0);
    $self->initialize_attr(position_over_link => 0);
    $self->initialize_attr(visibility => 'hidden');
    $self->put_unless_exists(
        control_off_value => sub {
	    return [sub {
		my($source) = @_;
		return _page_exists($source)
		    ? Join([_js($self, $source), _iframe($self), _link_open()])
		    : _user_can_edit($source)
		    ? _link_add()
		    : ();
	    }],
	},
	control_on_value => sub {
	    return [sub {
		my($source) = @_;
		my($body_attr) = "$self.body";
		return
		    unless _iframe_body($source, $body_attr);
		return DIV_help_wiki(Join([
		    DIV_tools(Join([
			_user_can_edit($source) ?  _link_edit() : (),
			_link_close(),
		    ])),
		    DIV_header(vs_text_as_prose('help_wiki_header')),
		    DIV_help_wiki_body([$body_attr]),
		    DIV_footer(vs_text_as_prose('help_wiki_footer')),
		]))->put(link_target => '_top');
	    }],
        },
    );
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    my(undef, $control, $attributes) = @_;
    return {
	control => $control || 0,
	($attributes ? %$attributes : ()),
    };
}

sub page_name {
    my($proto, $req, $task_id) = @_;
    return $_WN->title_to_help(
	vs_render_widget(
	    Prose(
		$_T->get_value(
		    'HelpWiki',
		    'title',
		    ($task_id || $req->get('task_id'))->get_name,
		    $req,
		),
	    ),
	    $req,
	),
    );
}

sub _iframe {
    my($self) = @_;
    return EmptyTag({
	tag => 'iframe',
	id => 'help_wiki_iframe',
	class => 'help_wiki_iframe',
	MARGINWIDTH => 0,
	SCROLLING => 'no',
	FRAMEBORDER => 0,
	SRC => _uri('HELP'),
    });
}

sub _iframe_body {
    my($source, $body_attr) = @_;
    my($req) = $source->get_request;
    return
	unless my $html = _render_html(
            $req->get('path_info'),
	    $req,
	);
    $req->put($body_attr => $html);
    return 1;
}

sub _js {
    my($self, $source) = @_;
    my($x) = JavaScript()->strip(<<"EOF");
<script type="text/javascript">
function @{[$self->RESIZE_FUNCTION]}() {
  var o = document.getElementById('help_wiki_iframe');
  var node = document.getElementById('help_wiki_open');
  var top = @{[
    $self->render_simple_attr('position_over_link', $source)
      ? '0' : 'node.offsetHeight'
  ]};
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
  o.style.visibility = '@{[_visibility($self, $source)]}';
  if (document.all)
    document.getElementById('help_wiki_open').style.visibility = 'visible';
}

function help_wiki_toggle() {
  var o = document.getElementById('help_wiki_iframe');
  o.style.visibility = o.style.visibility == 'visible' ? 'hidden' : 'visible';
}
</script>
EOF
    chomp($x);
    return $x;
}

sub _link_add {
    return Link(
	vs_text_as_prose('help_wiki_add'),
	_uri('FORUM_WIKI_EDIT'),
	'help_wiki_add',
    );
}

sub _link_close {
    return Link(
	vs_text_as_prose('help_wiki_close'),
	'javascript: parent.help_wiki_toggle()',
        'close',
    );
}

sub _link_edit {
    return Link(
	vs_text_as_prose('help_wiki_edit'),
	_uri('FORUM_WIKI_EDIT', ['->req', 'path_info']),
	'edit',
    );
}

sub _link_open {
    return Join([
	ScriptOnly({
	    alt_widget => Link(vs_text_as_prose('help_wiki_open'),
		_uri('FORUM_WIKI_VIEW')),
	    widget => Link(
		vs_text_as_prose('help_wiki_open'),
		'javascript: help_wiki_toggle()',
		{
		    id => 'help_wiki_open',
		    class => 'help_wiki_open',
		},
	    ),
	}),
	# If you click on the help link in IE while it is loading
	# it doesn't render correctly
	JavaScript()->strip(<<"EOF"),
<script type="text/javascript">
if (document.all)
  document.getElementById('help_wiki_open').style.visibility = 'hidden';
</script>
EOF
    ]);
}

sub _page_exists {
    my($source) = @_;
    my($req) = $source->req;
    my($die_code);
    return $_RF->access_controlled_load(
	vs_constant($req, 'help_wiki_realm_id'),
	$_WN->to_absolute(_page_name($source)),
	$source->req,
	\$die_code,
    );
}

sub _page_name {
    return __PACKAGE__->page_name(shift->req);
}

sub _realm_name {
    return vs_constant(shift->req, 'help_wiki_realm_name');
}

sub _render_html {
    my($name, $req) = @_;
    my($wa) = $_WT->prepare_html(
	vs_constant($req, 'help_wiki_realm_id'),
	$name,
	$_TASK_ID,
	$req,
    );
    $wa->{realm_name} = _realm_name($req);
    $wa->{link_target} = '_top';
    return $_WT->render_html($wa);
}

sub _uri {
    my($task, $path_info) = @_;
    return URI({
	task_id => $task,
	query => undef,
	realm => [\&_realm_name],
	path_info => $path_info || [\&_page_name],
    });
}

sub _user_can_edit {
    my($req) = shift->req;
    return $req->with_realm(
	_realm_name($req),
	sub {$req->can_user_execute_task('FORUM_WIKI_EDIT')},
    );
}

sub _visibility {
    my($self, $source) = @_;
    my($res) = lc($self->render_simple_attr('visibility', $source));
    return $res
	if $res =~ /^(?:hidden|visible)$/;
    Bivio::IO::Alert->warn($res, ': not a valid visibility value: ', $self);
    return 'visible';
}

1;
