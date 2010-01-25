# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::SimpleWidgetFactory;
use strict;
use Bivio::Base 'UI.Widget';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_VS) = b_use('UIHTML.ViewShortcuts');
my($_QT) = b_use('Biz.QueryType');
my($_TI) = b_use('Agent.TaskId');
my($_FM) = b_use('Biz.FormModel');
my($_M) = b_use('Biz.Model');
my($_N) = b_use('Type.Name');
my($_TV) = b_use('Bivio.TypeValue');
my($_TA) = b_use('Type.TextArea');

sub create {
    my($proto, $field, $attrs) = @_;
    $attrs ||= {};
    my($model, $field_name, $field_type)
	= _get_model_and_field_type($field, $attrs);
    my($widget) = $attrs->{wf_widget}
	|| $attrs->{wf_class} && $_VS->vs_new($attrs->{wf_class}, {
	    field => $field_name,
	    %$attrs,
	});
    return $widget || $proto->internal_create_edit(
	$model, $field_name, $field_type, $attrs
    ) if !$attrs->{wf_want_display}
	&& $_FM->is_blessed($model);
#TODO: This is broken in the case of $attrs->{value} existing.  Hack for now
    $widget = $proto->internal_create_display(
	$model, $field_name, $field_type, $attrs,
    ) unless $widget;
    my(%attrs_copy) = %$attrs;
    delete($attrs_copy{value});
    # Wrap the resultant widget in a link?
    my($wll) = $widget->unsafe_get('wf_list_link');
    $wll = {task => $wll, query => 'THIS_DETAIL'}
	if defined($wll) && !ref($wll);
    $widget = $_VS->vs_new('Link', {
	href => ['->format_uri',
	    $_QT->from_any($wll->{query}),
	    $wll->{task} ? ($_TI->from_any($wll->{task}))
	    : $wll->{uri} ? $wll->{uri} : (),
	],
	value => $widget,
	control_off_value => $widget,
	$wll->{task} ? (control => $wll->{task}) : (),
	%attrs_copy,
	%$wll,
    }) if $wll;
    return $widget;
}

sub internal_create_display {
    # (proto, Biz.Model, string, Bivio.Type, hash_ref) : UI.Widget
    # Create a display-only widget for the specified field.
    my($proto, $model, $field, $type, $attrs) = @_;

    if ($field eq 'RealmOwner.name' && $model->can('format_name')) {
	return $_VS->vs_new('String', {
	    field => $field,
#TODO: This is broken in the case of $attrs->{value} existing
	    value => ['->format_name'],
	    %$attrs,
	});
    }

    if (UNIVERSAL::isa($type, 'Bivio::Type::Percent')) {
	b_use('HTMLWidget.PercentCell');
	return $_VS->vs_new('PercentCell', {
	    field => $field,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Dollar')) {
	return $_VS->vs_new('DollarCell', {
	    field => $field,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Year')) {
	return $_VS->vs_new('String', {
	    field => $field,
	    value => [$field],
	    string_font => 'table_cell',
	    column_align => 'right',
	    column_data_class => 'amount_cell',
	    %$attrs,
	}),
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Integer')) {
	return $_VS->vs_new('Integer', {
	    field => $field,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Amount')) {
	return $_VS->vs_new('AmountCell', {
	    field => $field,
	    decimals => $proto->internal_default_decimals($field),
	    want_parens => $proto->internal_default_want_parens($field),
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::DateTimeWithTimeZone')) {
	return $_VS->vs_new('String', {
	    field => $field,
	    value => [$field, '->as_literal'],
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Date')) {
        return $_VS->vs_new('String', {
            field => $field,
            value => [[$field], 'HTMLFormat.DateTime',
                $attrs->{mode} || b_use('UI.DateTimeMode')->get_date_default,
		defined($attrs->{no_timezone})
                    ? $attrs->{no_timezone} : 1],
	    column_align => 'E',
	    %$attrs,
        });
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Time')) {
        return $_VS->vs_new('String', {
	    field => $field,
            value => ['Bivio::Type::Time', '->to_string', [$field]],
	    column_align => 'E',
	    %$attrs,
        });
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::DateTime')) {
	return $_VS->vs_new('DateTime', {
	    field => $field,
	    column_align => 'E',
#TODO: This is broken in the case of $attrs->{value} existing
	    value => [$field],
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Enum')) {
	return $_VS->vs_new('Enum', {
	    field => $field,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Email')) {
	return $_VS->vs_new('MailTo', {
	    field => $field,
	    email => [$field],
	    %$attrs,
	});
    }

    if (UNIVERSAL::isa($type, 'Bivio::Type::PrimaryId')) {
	return $_VS->vs_new('String', {
	    field => $field,
	    value => [$field],
	    string_font => 'table_cell',
	    column_align => 'right',
	    %$attrs,
	}),
    }

    # Default number formatting
    if (UNIVERSAL::isa($type, 'Bivio::Type::Number')) {
	return $_VS->vs_new('AmountCell', {
	    field => $field,
	    decimals => $type->get_decimals,
	    %$attrs,
	}),
    }

    if (UNIVERSAL::isa($type, 'Bivio::Type::HTTPURI')) {
	return $_VS->vs_new(Link => {
	    href => [$field],
	    control => [$field],
	    value => $_VS->vs_new(String => {value => [$field]}),
	    %$attrs,
	});
    }

    # default type is string
    return $_VS->vs_new('String', {
        field => $field,
#TODO: This is broken in the case of $attrs->{value} existing
	value => [$field],
	string_font => 'table_cell',
	%$attrs,
    });
}

sub internal_create_edit {
    # (proto, Biz.Model, string, Bivio.Type, hash_ref) : UI.Widget
    # Create an editable widget for the specified field.
    my($proto, $model, $field, $type, $attrs) = @_;
    if (UNIVERSAL::isa($type, 'Bivio::Type::TimeZoneSelector')) {
	return $_VS->vs_new(ComboBox => {
	    field => $field,
	    list_class => 'TimeZoneList',
	    list_display_field => ['display_name'],
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Enum')) {
	# Don't have larger than a 2x3 Grid
	return $_VS->vs_new('Select', {
	    field => $field,
	    choices => $type,
	    %$attrs,
	}) if $attrs->{wf_want_select}
	    || !defined($attrs->{wf_want_select}) && $type->get_count() > 6;
	$attrs->{label_on_field} = 0;
	return $_VS->vs_new('RadioGrid', {
	    field => $field,
	    choices => $type,
	    %$attrs,
	});
    }
    if ($type->can('provide_select_choices')) {
	return $_VS->vs_new('Select', {
	    field => $field,
	    choices => $type,
	    unknown_label => $_VS->vs_unknown_label($model, $field),
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Time')) {
	return $_VS->vs_new('Text', {
	    field => $field,
	    size => 14,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::DateTime')) {
	return $_VS->vs_new('DateField', {
	    field => $field,
	    event_handler => $_VS->vs_new('DateYearHandler'),
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::FileField')) {
	b_use('HTMLWidget.File');
	return $_VS->vs_new('File', {
	    field => $field,
	    size => 45,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Amount')) {
	return $_VS->vs_new('Text', {
	    field => $field,
	    size => 10,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::StringArray')) {
	return $_VS->vs_new('TextArea', {
	    field => $field,
	    rows => 2,
	    cols => $_TA->LINE_WIDTH,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::TupleSlot')) {
	return $_VS->vs_new('Text', {
	    field => $field,
	    size => 30,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Text')
	&& !$model->get_field_info($field, 'in_list')
    ) {
	return $_VS->vs_new('TextArea', {
	    field => $field,
	    rows => 5,
	    cols => $_TA->LINE_WIDTH,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::PrimaryId')) {
	return $_VS->vs_new('Select', {
	    field => $field,
	    %$attrs,
	});
    }
    # PUT SUPERCLASSES last since they may be overridden
#TODO: need to be intelligent here, create widget based on the field type
    if (UNIVERSAL::isa($type, 'Bivio::Type::String')
	   || UNIVERSAL::isa($type, 'Bivio::Type::RealmName')) {
	return $_VS->vs_new('Text', {
	    field => $field,
	    size => _default_size($type),
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::FormButton')) {
	$attrs->{label_on_field} = 0;
	return $_VS->vs_new('FormButton', {
	    field => $field,
	    label => $_VS->vs_text($model->simple_package_name, $field),
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Boolean')) {
	$attrs->{label_on_field} = 0;
	return $_VS->vs_new('Checkbox', {
	    field => $field,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Year')) {
	return $_VS->vs_new('Text', {
	    field => $field,
	    size => $type->get_width,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::PageSize')) {
	b_die($type, ': range changed')
            if $type->get_min != 5 || $type->get_max != 500;
	return $_VS->vs_new('Select', {
	    field => $field,
	    choices => $_TV->new(
		$type,
		[qw(5 10 15 20 30 40 50 75 100 200 300 400 500)]),
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Number')) {
	return $_VS->vs_new('Text', {
	    field => $field,
	    size => $type->get_width,
	    %$attrs,
	});
    }
    b_die($type, ': unsupported type');
    # DOES NOT RETURN
}

sub internal_default_decimals {
    return 2;
}

sub internal_default_want_parens {
    return 0;
}

sub _default_size {
    my($type) = @_;
    my($w) = $type->get_width;
    return $w <= 15 ? $w : $w <= $_N->get_width ? 15 : 30;
}

sub _get_model_and_field_type {
    my($field, $attrs) = @_;
    my($model_name, $field_name) = $field =~ /^([^\.]+)\.(.+)$/;
    b_die($field, ": couldn't parse")
        unless defined($model_name) && defined($field_name);
    my($model) = $_M->get_instance($model_name);
    return (
	$model,
	$field_name,
	$attrs->{wf_type} || $model->get_field_type($field_name),
    );
}

1;
