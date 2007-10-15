# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::HelpWiki;
use strict;
use Bivio::Base 'Widget.If';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WN) = __PACKAGE__->use('Type.WikiName');
my($_REALM_NAME) = [['->req', 'Bivio::UI::Facade'], '->HELP_WIKI_REALM_NAME'];
my($_PAGE_NAME) = [sub {
    my($req) = shift->req;
    return $_WN->task_to_help($req->get('task_id'), $req);
}];
my($_PAGE_EXISTS) = [sub {
    my($source, $page) = @_;
    return WikiStyle()->help_exists($page, $source->req);
}, $_PAGE_NAME];

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
	    return Join([
		If($_PAGE_EXISTS,
		    Join([
			_js($self),
			_iframe($self),
			_link_open(),
		    ]),
		    _link_add(),
	        ),
	    ]);
	},
	control_on_value => sub {
	    return DIV_help_wiki(Join([
		DIV_tools(Join([
		    _link_edit(),
		    _link_close(),
		])),
		DIV_header(vs_text_as_prose('help_wiki_header')),
		DIV_help_wiki_body([_body_attr($self)]),
		DIV_footer(vs_text_as_prose('help_wiki_footer')),
	    ]), {
		control => [\&_iframe_body, _body_attr($self)],
	    });
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

sub _body_attr {
    my($self) = @_;
    return "$self.body";
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
    return 0
	unless my $html = WikiStyle()->render_help_html(
            $req->get('path_info'),
	    $req,
	);
    $req->put($body_attr => $$html);
    return 1;
}

sub _js {
    my($self) = @_;
    return [sub {
	my($source) = @_;
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
    }];
}

sub _link_add {
    return Link(
	vs_text_as_prose('help_wiki_add'),
	_uri('FORUM_WIKI_EDIT'),
	{
	    class => 'help_wiki_add',
	    control => [
		sub {
		    my($source, $name) = @_;
		    my($req) = $source->req;
		    return $req->with_realm(
			$name,
			sub {$req->can_user_execute_task(
			    'FORUM_WIKI_EDIT')},
		    );
		}, $_REALM_NAME,
	    ],
	},
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
	{
	    class => 'edit',
	    control =>
		[['->req'], '->can_user_execute_task', 'FORUM_WIKI_EDIT'],
	},
    );
}

sub _link_open {
    return Join([
	Link(
	    vs_text_as_prose('help_wiki_open'),
	    'javascript: help_wiki_toggle()',
	    {
		id => 'help_wiki_open',
		class => 'help_wiki_open',
	    },
	),
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

sub _uri {
    my($task, $path_info) = @_;
    return URI({
	task_id => $task,
	query => undef,
	realm => $_REALM_NAME,
	path_info => $path_info || [$_PAGE_NAME],
    });
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
