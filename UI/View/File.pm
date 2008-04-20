# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::File;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub text_form {
    return shift->internal_body(vs_simple_form(TextFileForm => [
	Join([
	    FormFieldError({
		field => 'content',
		label => 'text',
	    }),
	    TextArea({
		field => 'content',
		rows => 30,
		cols => 80,
	    }),
	]),
    ]));
}

sub tree_list {
    return shift->internal_body(vs_tree_list(RealmFileTreeList => [
	['RealmFile.path', {
	    column_order_by => ['RealmFile.path_lc'],
	    column_widget => String(['base_name']),
	}],
	'RealmFile.modified_date_time',
	'Email.email',
	{
	    column_heading => String('Actions'),
	    column_widget => ListActions([
#TODO: Don't display remove link for root folder
		map({
		    my($n, $t, $c) = @$_;
		    [
			$n,
			$t,
			URI({
			    task_id => $t,
			    realm => [['->get_list_model'],
				      'RealmOwner.name'],
			    query => undef,
			    path_info => ['RealmFile.path'],
			}),
			$c,
			[['->get_list_model'], 'RealmOwner.name'],
		    ];
		}
		    ['Edit' => 'FORUM_TEXT_FILE_FORM' =>
			And(
			    ['->is_text_content_type'],
			    ['!', '->is_folder'],
			),
		    ],
		),
	    ]),
	},
    ]));
}

1;
