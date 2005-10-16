# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::ViewShortcuts;
use strict;
use base 'Bivio::UI::HTML::ViewShortcuts';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD);

sub AUTOLOAD {
    return Bivio::UI::ViewLanguage->call_method(
	$AUTOLOAD, 'Bivio::UI::ViewLanguage', @_,
    );
}

sub vs_phone {
    my($proto) = @_;
    return $proto->vs_call(Join => [$proto->vs_text('support_phone')]);
}

sub vs_acknowledgement {
    my($proto, $die_if_not_found) = @_;
    return $proto->vs_call(
	'If',
	[sub {
	     return Bivio::Biz::Action->get_instance('Acknowledgement')
		 ->extract_label(shift->get_request);
	}],
	$proto->vs_call(
	    'Tag',
	    'p',
	    [sub {
		 my($req) = shift->get_request;
		 return __PACKAGE__->vs_call(
		     'String',
		     __PACKAGE__->vs_call(
			 'Prose',
			 Bivio::UI::Text->get_value(
			     'acknowledgement',
			     $req->get_nested(
				 'Action.Acknowledgement', 'label'),
			     $req,
			 ),
		     ),
		 );
	     }],
	    'ack',
	),
    );
}

sub vs_descriptive_field {
    my($proto, $field) = @_;
    my($name, $attrs) = ref($field) ? @$field : $field;
    $name =~ /^(\w+)\.(.+)/;
    my($label, $input)
	= UNIVERSAL::isa(
	    Bivio::Biz::Model->get_instance($1)->get_field_type($2),
	    'Bivio::Type::Boolean',
	) ? ($proto->vs_call(Join => ['']), $proto->vs_call(FormField => $name))
	: $proto->vs_form_field($name, $attrs);
    return [
	$label->put(cell_class => 'label'),
	$proto->vs_call(
	    'Join',
	    [
		$input,
		[sub {
		     my($req) = shift->get_request;
		     my($proto, $name) = @_;
#TODO: Need to create a separate space for field_descriptions so we don't
#      default to something that we don't expect.
		     my($v) = $req->get_nested('Bivio::UI::Facade', 'Text')
			 ->unsafe_get_value($name, 'desc');
		     return $v ?
			 $proto->vs_call(
			     'Join', [
				 '<br />',
				 $proto->vs_call(
				     'Tag', 'p',
				     $proto->vs_call('Prose', $v),
				     'desc',
				 ),
			     ],
			 ) :  '';
		 }, $proto, $name],
	    ], {
		cell_class => 'field',
	    },
	),
    ];
}

sub vs_form_error_title {
    my($proto, $form) = @_;
    return $proto->vs_call(
	If => [['->get_request'], "Model.$form", '->in_error'],
	$proto->vs_call(Tag => div =>
	    $proto->vs_call(
		String => $proto->vs_text('form_error_title'), 0),
	    'err_title'));
}

sub vs_list_form {
    my($proto, $form, $columns, $empty_list) = @_;
    return $proto->vs_call(
	If => [
	    'Model.'
	    . Bivio::Biz::Model->get_instance(
		Bivio::Biz::Model->get_instance($form)->get_list_class
	    )->simple_package_name,
	    '->get_result_set_size',
	],
	$proto->vs_call(
	    Form => $form,
	    $proto->vs_call('Join', [
		$proto->vs_form_error_title($form),
		$proto->vs_call(Table => $form => [
		    map({
			$_ = ref($_) eq 'ARRAY' ? {
			    field => $_->[0],
			    $_->[1] ? %{$->[1]} : (),
			} : {field => $_}
			    unless ref($_) eq 'HASH';
			$_->{column_class} ||= 'field';
			$_;
		    } @$columns),
		], {
		    class => 'list',
		}),
		$proto->vs_call(
		    Tag => div => $proto->vs_call(
			# cell_class tells StandardSubmit to produce XHTML
			StandardSubmit => {cell_class => 'button'},
		    ),
		    'submit',
		),
	    ]),
	),
	$proto->vs_call('Tag', div => $empty_list, 'empty_list'),
    );
}

sub vs_simple_form {
    my($proto, $form, $rows) = @_;
    my($have_submit) = 0;
    my($m) = Bivio::Biz::Model->get_instance($form);
    return Form($form,
	Join([
	    $proto->vs_form_error_title($form),
	    Grid([
	    map({
		my($x);
		if (UNIVERSAL::isa($_, 'Bivio::UI::Widget') &&
			$_->simple_package_name eq 'FormField'
		) {
		    $_->get_if_exists_else_put(cell_class => 'field'),
		    $x = [
			$proto->vs_call('Join', [''], {cell_class => 'label'}),
			$_,
		    ];
		}
		elsif (UNIVERSAL::isa($_, 'Bivio::UI::Widget')) {
		    $x = [$_->put(cell_colspan => 2)];
		}
		elsif ($_ =~ s/^-//) {
		    $x = [String(
			vs_text($form, 'separator', $_),
			0,
			{
			    cell_colspan => 2,
			    cell_class => 'sep',
			},
		    )];
		}
		elsif ($_ =~ s/^\*//) {
		    $have_submit = 1;
		    $x = [StandardSubmit(
			{
			    cell_colspan => 2,
			    cell_class => 'submit',
			    $_ ? (buttons => [split(/\s+/, $_)]) : (),
			},
		    )];
		}
		elsif (ref($_) eq 'ARRAY' && ref($_->[0])) {
		    $x = $_;
		}
		else {
		    $x = $proto->vs_descriptive_field($_);
		}
		$x;
	    } @$rows),
	    $have_submit ? () : [
		StandardSubmit({
		    cell_colspan => 2,
		    cell_class => 'submit',
		}),
	    ],
	], {
	    class => 'simple',
	}),
	]),
    );
}

1;
