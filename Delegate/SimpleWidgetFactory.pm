# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::SimpleWidgetFactory;
use strict;
$Bivio::Delegate::SimpleWidgetFactory::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegate::SimpleWidgetFactory::VERSION;

=head1 NAME

Bivio::Delegate::SimpleWidgetFactory - creates widgets for model fields

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::WidgetFactory;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::Delegate::SimpleWidgetFactory::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::Delegate::SimpleWidgetFactory> is the delegate of
L<Bivio::UI::HTML::WidgetFactory|Bivio::UI::HTML::WidgetFactory>.

=cut

#=IMPORTS
# also dynamically imports many optional widgets for optional types
use Bivio::Agent::TaskId;
use Bivio::Biz::Model;
use Bivio::Biz::QueryType;
use Bivio::Die;
use Bivio::IO::ClassLoader;
use Bivio::IO::Trace;
use Bivio::Type::Name;
use Bivio::Type::TextArea;
use Bivio::UI::HTML::ViewShortcuts;
use Bivio::UI::Widget;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;

# A map of field names to default value for "decimals" attribute.
my(%_DEFAULT_DECIMALS) = (
    quantity => 4,
    share_price => 4,
    units => 6,
);

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 static create(string field) : Bivio::UI::Widget

=head2 static create(string field, hash_ref attrs) : Bivio::UI::Widget

Creates a widget for the specified field. 'field' should be of the form:
  '<model name>.<field name>'

Form model properties receive editable widgets, other models receive
display-only widgets.

=cut

sub create {
    my($proto, $field, $attrs) = @_;
    $attrs ||= {};

    my($model, $field_name, $field_type) = _get_model_and_field_type($field);
    my($widget);
    if (! $attrs->{wf_want_display}
	    && UNIVERSAL::isa($model, 'Bivio::Biz::FormModel')) {
	$widget = _create_edit($proto, $model, $field_name, $field_type,
		$attrs);
    }
    else {
#TODO: This is broken in the case of $attrs->{value} existing.  Hack for now
	$widget = _create_display($proto, $model, $field_name, $field_type, $attrs);
	my(%attrs_copy) = %$attrs;
	delete($attrs_copy{value});
	# Wrap the resultant widget in a link?
	my($wll) = $widget->unsafe_get('wf_list_link');
	$widget = $_VS->vs_new('Link', {
	    href => ['->format_uri',
		Bivio::Biz::QueryType->from_any($wll->{query}),
		$wll->{task} ? (Bivio::Agent::TaskId->from_any($wll->{task}))
		: $wll->{uri} ? $wll->{uri} : (),
	    ],
	    value => $widget,
	    control_off_value => $widget,
	    %$wll,
	    %attrs_copy,
	}) if $wll;
    }
    return $widget;
}

#=PRIVATE METHODS

# _create_display(Bivio::Biz::Model model, string field, Bivio::Type type, hash_ref attrs) : Bivio::UI::Widget
#
# Create a display-only widget for the specified field.
#
sub _create_display {
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
    if (UNIVERSAL::isa($type, 'Bivio::Type::Amount')) {
	return $_VS->vs_new('AmountCell', {
	    field => $field,
	    decimals => $_DEFAULT_DECIMALS{$field}
	    ? $_DEFAULT_DECIMALS{$field} : 2,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::DateTime')) {
	return $_VS->vs_new('DateTime', {
	    field => $field,
	    mode => 'DATE',
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

# _create_edit(Bivio::Biz::Model model, string field, Bivio::Type type, hash_ref attrs) : Bivio::UI::Widget
#
# Create an editable widget for the specified field.
#
sub _create_edit {
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
	}) if $type->get_count() > 6 || $attrs->{wf_want_select};

	# Having label on field with radio grid is sloppy.
	$attrs->{label_on_field} = 0;
	return $_VS->vs_new('RadioGrid', {
	    field => $field,
	    choices => $type,
	    %$attrs,
	});
    }

    if (UNIVERSAL::isa($type, 'Bivio::Type::DateTime')) {
	return $_VS->vs_new('DateField', {
	    field => $field,
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
	if (exists($attrs->{format})) {
	    return $_VS->vs_new('Text', {
		field => $field,
		size => 10,
		%$attrs,
	    });
	}
	$_VS->vs_new('Currency');
	return $_VS->vs_new('Currency', {
	    field => $field,
	    size => 10,
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
	    label => $_VS->vs_text($field),
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

    if (UNIVERSAL::isa($type, 'Bivio::Type::Integer')) {
	return $_VS->vs_new('Text', {
	    field => $field,
	    size => $type->get_width,
	    %$attrs,
	});
    }

    Bivio::Die->die($type, ': unsupported type');
}

# _default_size(any type) : int
#
# Returns the default size for text boxes.
#
sub _default_size {
    my($type) = @_;
    my($w) = $type->get_width;
    return $w <= 15 ? $w : $w <= Bivio::Type::Name->get_width ? 15 : 30;
}

# _get_model_and_field_type(string field) : (Bivio::Biz::Model, string, Bivio::Type)
#
# Returns a model instance, field name and type for the specified field.
#
sub _get_model_and_field_type {
    my($field) = @_;

    # parse out the model (everything up to the first ".") and field names
    my($model_name, $field_name) = $field =~ /^([^\.]+)\.(.+)$/;
    Bivio::Die->die($field, ": couldn't parse")
                unless defined($model_name) && defined($field_name);

    my($model) = Bivio::Biz::Model->get_instance($model_name);
    return ($model, $field_name, $model->get_field_type($field_name));
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
