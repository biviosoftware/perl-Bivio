# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::WidgetFactory;
use strict;
$Bivio::UI::HTML::WidgetFactory::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::WidgetFactory - creates widgets for model fields

=head1 SYNOPSIS

    use Bivio::UI::HTML::WidgetFactory;
    my($widget) = Bivio::UI::HTML::WidgetFactory->create('RealmOwner.name');

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::HTML::WidgetFactory::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::HTML::WidgetFactory> creates widgets for model fields.

=head1 ATTRIBUTES

=over 4

=item wf_list_link : string []

Set to a L<Bivio::Biz::QueryType|Bivio::Biz::QueryType> and
the widget will be wrapped in a link whose I<href> is
a call to
L<Bivio::Biz::ListModel::format_uri|Bivio::Biz::ListModel/"format_uri">
with I<wf_list_link> as the query type.


=back

=cut

#=IMPORTS
use Bivio::Biz::Model;
use Bivio::UI::HTML::Widget::AmountCell;
use Bivio::UI::HTML::Widget::Checkbox;
use Bivio::UI::HTML::Widget::Currency;
use Bivio::UI::HTML::Widget::DateField;
use Bivio::UI::HTML::Widget::DateTime;
use Bivio::UI::HTML::Widget::Enum;
use Bivio::UI::HTML::Widget::File;
use Bivio::UI::HTML::Widget::FormButton;
use Bivio::UI::HTML::Widget::IRRCell;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::MailTo;
use Bivio::UI::HTML::Widget::PercentCell;
use Bivio::UI::HTML::Widget::RadioGrid;
use Bivio::UI::HTML::Widget::Select;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::HTML::Widget::Text;
use Bivio::UI::HTML::Widget::TextArea;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;

# A map of field names to default value for "decimals" attribute.
my(%_DEFAULT_DECIMALS) = (
    quantity => 3,
    share_price => 4,
    units => 6,
);

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 static create(string field) : Bivio::UI::HTML::Widget

=head2 static create(string field, hash_ref attrs) : Bivio::UI::HTML::Widget

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
    if (UNIVERSAL::isa($model, 'Bivio::Biz::FormModel')) {
	$widget = _create_edit($model, $field_name, $field_type, $attrs);
    }
    else {
	$widget = _create_display($field_name, $field_type, $attrs);

	# Wrap the resultant widget in a link?
	my($wll) = $widget->unsafe_get('wf_list_link');
	$widget = Bivio::UI::HTML::Widget::Link->new({
	    href => ['->format_uri', Bivio::Biz::QueryType->from_any($wll)],
	    value => $widget,
	    %$attrs,
	}) if $wll;
    }
    return $widget;
}

#=PRIVATE METHODS

# _create_display(string field, Bivio::Type type, hash_ref attrs) : Bivio::UI::HTML::Widget
#
# Create a display-only widget for the specified field.
#
sub _create_display {
    my($field, $type, $attrs) = @_;

#TODO: should check if the list class "can()" format_name()
    if ($field eq 'RealmOwner.name') {
	return Bivio::UI::HTML::Widget::String->new({
	    field => $field,
	    value => ['->format_name'],
	    %$attrs,
	});
    }

    if (UNIVERSAL::isa($type, 'Bivio::Type::IRR')) {
	return Bivio::UI::HTML::Widget::IRRCell->new({
	    field => $field,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Percent')) {
	return Bivio::UI::HTML::Widget::PercentCell->new({
	    field => $field,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Amount')) {
	return Bivio::UI::HTML::Widget::AmountCell->new({
	    field => $field,
	    decimals => $_DEFAULT_DECIMALS{$field}
	    ? $_DEFAULT_DECIMALS{$field} : 2,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::DateTime')) {
	return Bivio::UI::HTML::Widget::DateTime->new({
	    field => $field,
	    mode => 'DATE',
	    column_align => 'E',
	    value => [$field],
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Enum')) {
	return Bivio::UI::HTML::Widget::Enum->new({
	    field => $field,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Email')) {
	return Bivio::UI::HTML::Widget::MailTo->new({
	    field => $field,
	    email => [$field],
	    %$attrs,
	});
    }

    # Numbers are just right adjusted strings.  Falls through
    if (UNIVERSAL::isa($type, 'Bivio::Type::Number')) {
	$attrs->{column_align} = 'right' unless $attrs->{column_align}
    }

    # default type is string
    return Bivio::UI::HTML::Widget::String->new({
        field => $field,
	value => [$field],
	string_font => 'table_cell',
	%$attrs,
    });
}

# _create_edit(Bivio::Biz::Model model, string field, Bivio::Type type, hash_ref attrs) : Bivio::UI::HTML::Widget
#
# Create an editable widget for the specified field.
#
sub _create_edit {
    my($model, $field, $type, $attrs) = @_;

    if ($field eq 'Instrument.ticker_symbol') {
	# Creates a text field with a "symbol lookup" button
	return Bivio::UI::HTML::Widget::Join->new({
	    # field is needed here by DescriptiveFormField
	    field => $field,
	    values => [
		    Bivio::UI::HTML::Widget::Text->new({
			field => $field,
			size => 15,
			%$attrs,
		    }),
		    ' ',
		    Bivio::UI::HTML::Widget::Join->new({
			values => [
				'<input type=submit name="submit" value="'.
		       Bivio::Biz::Model::InstrumentLookupForm::SYMBOL_LOOKUP()
				.'">',
		        ],
		    }),
		    ' ',
		    Bivio::UI::HTML::Widget::Join->new({
			values => [
				'<input type=submit name="submit" value="'.
		       Bivio::Biz::Model::LocalInstrumentForm::NEW_UNLISTED()
				.'">',
		        ],
		    }),
	    ],
	});
    }

    if ($field eq 'valuation_search_date') {
	# create a date field with a "refresh" button
	return Bivio::UI::HTML::Widget::Join->new({
	    field => $field,
	    values => [
		    Bivio::UI::HTML::Widget::DateField->new({
			field => $field,
			%$attrs,
		    }),
		    ' ',
		    Bivio::UI::HTML::Widget::Join->new({
			values => [
				'<input type=submit name="submit" value="'.
				Bivio::Biz::Model::LocalPricesForm::REFRESH()
				.'">',
		        ],
		    }),
	    ],
	});
    }

    if (UNIVERSAL::isa($type, 'Bivio::Type::Enum')) {
	# Don't have larger than a 2x3 Grid
	return Bivio::UI::HTML::Widget::Select->new({
	    field => $field,
	    choices => $type,
	    %$attrs,
#TODO: hacked in want_select, don't want radios for list forms
	}) if $type->get_count() > 6 || $attrs->{want_select};

	# Having label on field with radio grid is sloppy.
	$attrs->{label_on_field} = 0;
	return Bivio::UI::HTML::Widget::RadioGrid->new({
	    field => $field,
	    choices => $type,
	    %$attrs,
	});
    }

    if (UNIVERSAL::isa($type, 'Bivio::Type::DateTime')) {
	return Bivio::UI::HTML::Widget::DateField->new({
	    field => $field,
	    %$attrs,
	});
    }

    if (UNIVERSAL::isa($type, 'Bivio::Type::FileField')) {
	return Bivio::UI::HTML::Widget::File->new({
	    field => $field,
	    size => 45,
	    %$attrs,
	});
    }

    if (UNIVERSAL::isa($type, 'Bivio::Type::Amount')) {
	if (exists($attrs->{format})) {
	    return Bivio::UI::HTML::Widget::Text->new({
		field => $field,
		size => 10,
		%$attrs,
	    });
	}
	return Bivio::UI::HTML::Widget::Currency->new({
	    field => $field,
	    size => 10,
	    %$attrs,
	});
    }

    if (UNIVERSAL::isa($type, 'Bivio::Type::USTaxId')) {
	return Bivio::UI::HTML::Widget::Text->new({
	    field => $field,
	    size => $type->get_width,
	    format => 'Bivio::UI::HTML::Format::USTaxId',
	    %$attrs,
	});
    }

    # If the Text is in_list, don't make multiline.  Fall through
    # to String below.
    if (UNIVERSAL::isa($type, 'Bivio::Type::Text')
	&& !$model->get_field_info($field, 'in_list')) {
	return Bivio::UI::HTML::Widget::TextArea->new({
	    field => $field,
	    rows => 5,
	    cols => 45,
	    %$attrs,
	});
    }

    if (UNIVERSAL::isa($type, 'Bivio::Type::BLOB')) {
	return Bivio::UI::HTML::Widget::TextArea->new({
	    field => $field,
	    rows => 15,
	    cols => 60,
	    %$attrs,
	});
    }

    # Primary Ids are always select boxes.  The caller must supply
    # the details of the select, however.
    if (UNIVERSAL::isa($type, 'Bivio::Type::PrimaryId')) {
	return Bivio::UI::HTML::Widget::Select->new({
	    field => $field,
	    %$attrs,
	});
    }

    # PUT SUPERCLASSES last since they may be overridden

#TODO: need to be intelligent here, create widget based on the field type
    if (UNIVERSAL::isa($type, 'Bivio::Type::String')) {
	return Bivio::UI::HTML::Widget::Text->new({
	    field => $field,
	    size => _default_size($type),
	    %$attrs,
	});
    }

    if (UNIVERSAL::isa($type, 'Bivio::Type::FormButton')) {
	$attrs->{label_on_field} = 0;
	return Bivio::UI::HTML::Widget::FormButton->new({
	    field => $field,
	    text => Bivio::UI::Label->get_simple($field),
	    %$attrs,
	});
    }

    if (UNIVERSAL::isa($type, 'Bivio::Type::Boolean')) {
	$attrs->{label_on_field} = 0;
	return Bivio::UI::HTML::Widget::Checkbox->new({
	    field => $field,
	    label => Bivio::UI::Label->get_simple($field),
	    %$attrs,
	});
    }

    if (UNIVERSAL::isa($type, 'Bivio::Type::Year')) {
	return Bivio::UI::HTML::Widget::Text->new({
	    field => $field,
	    size => $type->get_width,
	    %$attrs,
	});
    }

    Bivio::IO::Alert->die($type, ': unsupported type');
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
    Bivio::IO::Alert->die($field, ": couldn't parse")
                unless defined($model_name) && defined($field_name);

    my($model) = Bivio::Biz::Model->get_instance($model_name);
    return ($model, $field_name, $model->get_field_type($field_name));
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
