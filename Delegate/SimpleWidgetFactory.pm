# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::SimpleWidgetFactory;
use strict;
use Bivio::Base 'UI.Widget';
use Bivio::Agent::TaskId;
use Bivio::Biz::QueryType;
use Bivio::IO::Trace;
use Bivio::Type::Name;
use Bivio::Type::TextArea;
use Bivio::TypeValue;
use Bivio::UI::DateTimeMode;
use Bivio::UI::HTML::ViewShortcuts;
use Bivio::UI::Widget;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
# also dynamically imports many optional widgets for optional types
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';
our($_TRACE);
Bivio::IO::Trace->register;

# A map of field names to default value for "decimals" attribute.
my(%_DEFAULT_DECIMALS) = (
    quantity => 4,
    share_price => 4,
    units => 6,
);

sub create {
    # (proto, string) : UI.Widget
    # (proto, string, hash_ref) : UI.Widget
    # Creates a widget for the specified field. 'field' should be of the form:
    #   '<model name>.<field name>'
    #
    # Form model properties receive editable widgets, other models receive
    # display-only widgets.
    my($proto, $field, $attrs) = @_;
    $attrs ||= {};

    my($model, $field_name, $field_type)
	= _get_model_and_field_type($field, $attrs);
    my($widget);
    if (! $attrs->{wf_want_display}
	    && UNIVERSAL::isa($model, 'Bivio::Biz::FormModel')) {
	$widget = $proto->internal_create_edit($model, $field_name,
            $field_type, $attrs);
    }
    else {
#TODO: This is broken in the case of $attrs->{value} existing.  Hack for now
	$widget = $proto->internal_create_display($model, $field_name,
            $field_type, $attrs);
	my(%attrs_copy) = %$attrs;
	delete($attrs_copy{value});
	# Wrap the resultant widget in a link?
	my($wll) = $widget->unsafe_get('wf_list_link');
	$wll = {task => $wll, query => 'THIS_DETAIL'}
	    if defined($wll) && !ref($wll);
	$widget = $_VS->vs_new('Link', {
	    href => ['->format_uri',
		Bivio::Biz::QueryType->from_any($wll->{query}),
		$wll->{task} ? (Bivio::Agent::TaskId->from_any($wll->{task}))
		: $wll->{uri} ? $wll->{uri} : (),
	    ],
	    value => $widget,
	    control_off_value => $widget,
            ($wll->{task} ? (control => $wll->{task}) : ()),
	    %$wll,
	    %attrs_copy,
	}) if $wll;
    }
    return $widget;
}

sub internal_create_display {
    # (proto, Biz.Model, string, Bivio.Type, hash_ref) : UI.Widget
    # Create a display-only widget for the specified field.
    my($proto, $model, $field, $type, $attrs) = @_;

    if ($attrs->{wf_class}) {
	return $_VS->vs_new($attrs->{wf_class}, {
	    field => $field,
	    %$attrs,
	});
    }

    if ($field eq 'RealmOwner.name' && $model->can('format_name')) {
	return $_VS->vs_new('String', {
	    field => $field,
#TODO: This is broken in the case of $attrs->{value} existing
	    value => ['->format_name'],
	    %$attrs,
	});
    }

    if (UNIVERSAL::isa($type, 'Bivio::Type::Percent')) {
	Bivio::IO::ClassLoader->simple_require(
		'Bivio::UI::HTML::Widget::PercentCell');
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
	    decimals => $_DEFAULT_DECIMALS{$field}
	    ? $_DEFAULT_DECIMALS{$field} : 2,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Date')) {
        return $_VS->vs_new('String', {
            field => $field,
            value => [[$field], 'HTMLFormat.DateTime',
                $attrs->{mode} || Bivio::UI::DateTimeMode->get_date_default,
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

    if ($attrs->{wf_class}) {
	return $_VS->vs_new($attrs->{wf_class}, {
	    field => $field,
	    %$attrs,
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

	# Having label on field with radio grid is sloppy.
	$attrs->{label_on_field} = 0;
	return $_VS->vs_new('RadioGrid', {
	    field => $field,
	    choices => $type,
	    %$attrs,
	});
    }

    if ($type->can('provide_select_choices')) {
	# Don't have larger than a 2x3 Grid
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
	    # Allow HH:MM:SS a.m.
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
	Bivio::IO::ClassLoader->simple_require(
		'Bivio::UI::HTML::Widget::File');
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
	    cols => Bivio::Type::TextArea->LINE_WIDTH,
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

    # If the Text is in_list, don't make multiline.  Fall through
    # to String below.
    if (UNIVERSAL::isa($type, 'Bivio::Type::Text')
	&& !$model->get_field_info($field, 'in_list')) {
	return $_VS->vs_new('TextArea', {
	    field => $field,
	    rows => 5,
	    cols => Bivio::Type::TextArea->LINE_WIDTH,
	    %$attrs,
	});
    }

    # Primary Ids are always select boxes.  The caller must supply
    # the details of the select, however.
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
	    choices => Bivio::TypeValue->new($type,
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

    Bivio::Die->die($type, ': unsupported type');
}

sub _default_size {
    # (any) : int
    # Returns the default size for text boxes.
    my($type) = @_;
    my($w) = $type->get_width;
    return $w <= 15 ? $w : $w <= Bivio::Type::Name->get_width ? 15 : 30;
}

sub _get_model_and_field_type {
    # (string, hash_ref) : (Biz.Model, string, Bivio.Type)
    # Returns a model instance, field name and type for the specified field.
    my($field, $attrs) = @_;

    # parse out the model (everything up to the first ".") and field names
    my($model_name, $field_name) = $field =~ /^([^\.]+)\.(.+)$/;
    Bivio::Die->die($field, ": couldn't parse")
        unless defined($model_name) && defined($field_name);

    my($model) = Bivio::Biz::Model->get_instance($model_name);
    return (
	$model,
	$field_name,
	$attrs->{wf_type} || $model->get_field_type($field_name),
    );
}

1;
