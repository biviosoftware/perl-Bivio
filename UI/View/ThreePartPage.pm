# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::ThreePartPage;
use strict;
use Bivio::Base 'Bivio::UI::View::Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TI) = b_use('Agent.TaskId');
my($_WANT_USER_AUTH) = $_TI->is_component_included('user_auth');
my($_C) = b_use('IO.Config');
b_use('IO.Config')->register(my $_CFG = {
    center_replaces_middle => 0,
});

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub internal_2014style_search_form {
    return SearchForm({
	value => DIV(
	    DIV(
		Join([
		    FormField('SearchForm.search', {
			class => 'form-control',
			PLACEHOLDER => 'Search',
			ID => 'bivio_search_field',
		    }),
		    DIV(
			BUTTON(
			    LinkIcon('SEARCH'),
			    'btn btn-default', {
				TYPE => 'submit',
			    }),
			'input-group-btn',
		    ),
		]),
		'input-group',
	    ),
	    'form-group',
	),
    })->put(class => 'navbar-form navbar-right');
}

sub internal_xhtml_adorned {
    my($self) = @_;
    $self->internal_xhtml_adorned_attrs;
    return Page({
	style => view_widget_value('xhtml_style'),
	head => Join([
	    view_widget_value('xhtml_adorned_title'),
	    view_widget_value('xhtml_head_tags'),
	    vs_rss_task_in_head(),
	]),
	body => $self->internal_xhtml_adorned_body,
	body_class => view_widget_value('xhtml_body_class'),
	xhtml => 1,
	want_page_print => view_widget_value('xhtml_want_page_print'),
    });
}

sub internal_xhtml_adorned_attrs {
    my($self) = @_;
   view_pre_execute(sub {
	my($req) = shift->get_request;
	Bivio::Biz::Model->new($req, 'SearchForm')->process
	    unless $req->unsafe_get('Model.SearchForm');
	return;
    }) if $_TI->unsafe_from_name('SEARCH_LIST')
        && !$self->unsafe_get('view_pre_execute');
    view_put(
	xhtml_title => vs_xhtml_title(),
	vs_pager => '',
	xhtml_adorned_title => vs_text_as_prose('xhtml_head_title'),
	xhtml_body_class => '',
	bootstrap_tab_bar => '',
	xhtml_head_tags => If2014Style(Join([
	    META({
		'HTTP-EQUIV' => 'X-UA-Compatible',
		CONTENT => 'IE=edge',
	    }),
	    META({
		NAME => 'viewport',
		CONTENT => 'width=device-width,initial-scale=1.0',
	    }),
	    LocalFileAggregator({
		base_values => [
		    'bootstrap.min.css',
		    'fontello/css/b_icon.min.css',
		    InlineCSS([sub {
#TODO: Widget.RenderView
				   my($source) = @_;
				   my($res) = UI_View()->render(
				       'CSS->render_2014style_css',
				       $source->req,
				   );
#TODO: Need to add this to InlineCSS from RealmCSS
				   $$res =~ s/^\!.*\n//mg;
				   return $$res;
			       }]),
		    IfUserAgent('is_msie_8_or_before', 'msie8shim/msie8shim.min.js'),
		],
	    }),
	])),
	xhtml_rss_task => '',
	xhtml_tools => '',
	xhtml_nav => '',
	xhtml_topic => '',
	xhtml_byline => '',
	xhtml_selector => '',
	xhtml_dock_left => _if_want(
	    'dock_left_standard',
	    undef,
	    vs_text_as_prose('xhtml_dock_left_standard'),
        ),
	_center_replaces_middle('xhtml_dock_middle') => '',
	xhtml_dock_right => JoinMenu([
	    $_C->if_version(8 => sub {_if_want('ForumDropDown')}),
	    _if_want(qw(HelpWiki HELP)),
	    $_WANT_USER_AUTH ? (
		_if_want(qw(UserSettingsForm USER_SETTINGS_FORM)),
		_if_want(qw(UserState LOGIN)),
	    ) : (),
	]),
	xhtml_header_left => vs_text_as_prose('xhtml_logo'),
	xhtml_want_page_print => 0,
	xhtml_main_left => '',
	xhtml_main_right => '',
	xhtml_footer_left => If2014Style('', XLink('back_to_top')),
	_center_replaces_middle('xhtml_footer_middle') => '',
	xhtml_footer_right => vs_text_as_prose('xhtml_copyright'),
	xhtml_want_first_focus => 1,
	xhtml_body_last => If2014Style(
	    LocalFileAggregator({
		base_values => [
		    'jquery/jquery.min.js',
		    'bootstrap/dist/js/bootstrap.min.js',
		    SearchSuggestAddon('bivio_search_field'),
		],
	    }),
	),
    );
    view_put(
	xhtml_body_first => Join([
	    EmptyTag(a => {html_attrs => ['name'], name => 'top'}),
            vs_first_focus(view_widget_value('xhtml_want_first_focus')),
	    Script('b_log_errors'),
	]),
	xhtml_header_right => $_C->if_version(
	    7 => sub {_if_want(qw(SearchForm SEARCH_LIST))},
	    sub {
		return Join([
		    DIV_user_state(view_widget_value('xhtml_dock_right')),
		    _if_want(qw(SearchForm SEARCH_LIST)),
		]);
	    },
	),
	_center_replaces_middle('xhtml_header_middle')
	    => DIV_nav(view_widget_value('xhtml_nav')),
	xhtml_style => RealmCSS(),
	_center_replaces_middle('xhtml_main_middle') => Join([
	    Acknowledgement(),
	    MainErrors(),
	    DIV_main_top(Join([
		$self->internal_xhtml_tools(1),
		DIV_title(view_widget_value('xhtml_title')),
		DIV_selector(
		    view_widget_value('xhtml_selector')),
		DIV_topic(view_widget_value('xhtml_topic')),
		DIV_byline(view_widget_value('xhtml_byline')),
	    ])),
	    DIV_main_body(view_widget_value('xhtml_body')),
	    DIV_main_bottom(
	        $self->internal_xhtml_tools(0),
	    ),
	]),
    );
    return;
}

sub internal_xhtml_adorned_body {
    my($self) = @_;
    return If2014Style(
	Join([
	    DIV_b_nav_and_content(Join([
		view_widget_value('xhtml_body_first'),
		Join([
		    view_widget_value('xhtml_dock_left'),
		])->b_widget_label('dock_left'),
		DIV_main_middle(DIV_container(Join([
		    view_widget_value('bootstrap_tab_bar'),
		    view_widget_value(
			_center_replaces_middle('xhtml_main_middle')),
		])->b_widget_label('main_middle'))),
	    ])),
	    DIV_b_nav_and_footer(
		DIV_container(Join([
		    $self->internal_xhtml_tools(1),
		    ' ',
		    DIV(
			view_widget_value('xhtml_footer_right'),
			'b_footer pull-right',
		    ),
		])),
	    ),
	    view_widget_value('xhtml_body_last'),
	]),
	# not 2014 style
	Join([
	    view_widget_value('xhtml_body_first'),
	    $_C->if_version(7 => sub {$self->internal_xhtml_grid3('dock')}),
	    $self->internal_xhtml_grid3('header'),
	    $self->internal_xhtml_grid3('main'),
	    $self->internal_xhtml_grid3('footer'),
	    view_widget_value('xhtml_body_last'),
	]),
    );
}

sub internal_xhtml_grid3 {
    my(undef, $name) = @_;
    return Grid(
	[[map(
	    {
		my($n) = "${name}_$_";
		Join(
		    [view_widget_value("xhtml_$n")],
		    {cell_class => $n},
		)->b_widget_label($n);
	    }
	    'left', _center_replaces_middle('middle'), 'right',
	)]],
	{
	    class => $name,
	    hide_empty_cells => 1,
	},
    )->b_widget_label($name);
}

sub internal_xhtml_tools {
    my($self, $is_header) = @_;
    return If2014Style(
	$is_header
	    ? Join([
		TaskMenuOverride(
		    view_widget_value('xhtml_tools'),
		    {
			class => 'pagination',
		    },
		),
		view_widget_value('vs_pager'),
	    ])
	    : '',
	DIV_tools(Join([
	    view_widget_value('xhtml_tools'),
	    view_widget_value('vs_pager'),
	], {
	    join_separator => $is_header
		? DIV_sep('')
		    : EmptyTag(DIV => 'sep'),
	})),
    );
}

sub _center_replaces_middle {
    my($name) = @_;
    $name =~ s/middle/center/
	if $_CFG->{center_replaces_middle};
    return $name;
}

sub _if_want {
    my($name, $task, $widget) = @_;
    return ''
	if $task && !$_TI->unsafe_from_name($task);
    $widget ||= $name;
    return If(
	vs_constant("ThreePartPage_want_$name"),
	ref($widget) ? $widget : vs_call($widget),
    );
}

1;
