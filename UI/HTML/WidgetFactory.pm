# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::WidgetFactory;
use strict;
$Bivio::UI::HTML::WidgetFactory::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::WidgetFactory::VERSION;

=head1 NAME

Bivio::UI::HTML::WidgetFactory - creates widgets for model fields

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::WidgetFactory;
    my($widget) = Bivio::UI::HTML::WidgetFactory->create('RealmOwner.name');

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::WidgetFactory::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::WidgetFactory> creates widgets for model fields.

=head1 ATTRIBUTES

=over 4

=item wf_class : string []

Name of the widget class to use.  Overrides dynamic lookups.

=item wf_list_link : hash_ref []

Must contain a I<query> attribute which is a
L<Bivio::Biz::QueryType|Bivio::Biz::QueryType> and
the widget will be wrapped in a link whose I<href> is
a call to
L<Bivio::Biz::ListModel::format_uri|Bivio::Biz::ListModel/"format_uri">
with I<wf_list_link> as the query type.

If I<task> is specified, it will be passed as a second argument to
I<format_uri>.

If I<uri> is specified, it will be passed as a second argument to
I<format_uri>.

The rest of the attributes are passed to the link directly, e.g. control.
I<control_off_value> is set to be the widget (i.e. the name).

=item wf_want_display : boolean []

If true, the field will be rendered as a display only widget.

=item wf_want_select : boolean []

If true, will force a widget to a be a select, if it can.

=back

=cut

#=IMPORTS
# also dynaimcally imports many optional widgets for optional types
use Bivio::Agent::TaskId;
use Bivio::Biz::QueryType;
use Bivio::Biz::Model;
use Bivio::Die;
use Bivio::IO::ClassLoader;
use Bivio::IO::Trace;
use Bivio::UI::Widget;
use Bivio::UI::HTML::Widget::AmountCell;
use Bivio::UI::HTML::Widget::Checkbox;
use Bivio::UI::HTML::Widget::DateField;
use Bivio::UI::HTML::Widget::DateTime;
use Bivio::UI::HTML::Widget::Enum;
use Bivio::UI::HTML::Widget::FormButton;
use Bivio::UI::Widget::Join;
use Bivio::UI::HTML::Widget::MailTo;
use Bivio::UI::HTML::Widget::RadioGrid;
use Bivio::UI::HTML::Widget::Select;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::HTML::Widget::Text;
use Bivio::UI::HTML::Widget::TextArea;
use Bivio::TypeValue;
use Bivio::Type::Name;
use Bivio::Type::TextArea;
use Bivio::UI::HTML::ViewShortcuts;

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
	$widget = Bivio::UI::HTML::Widget::Link->new({
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
	$widget = $_VS->vs_secure_data($widget)->put(%attrs_copy)
		if $field_type->is_secure_data;
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
	return Bivio::UI::HTML::Widget::String->new({
	    field => $field,
#TODO: This is broken in the case of $attrs->{value} existing
	    value => ['->format_name'],
	    %$attrs,
	});
    }

    if ($field =~ /is_public$/) {
	return $_VS->vs_checkmark($field)->put(
		column_align => 'center',
		column_control => [
		    sub { my($req) = shift->get_request;
			  return $req->get(
				  'realm_decor_show_all_columns')
				  && $req->get('realm_is_public');
		      }],
		%$attrs,
	       );
    }

    if (UNIVERSAL::isa($type, 'Bivio::Type::IRR')) {
	Bivio::IO::ClassLoader->simple_require(
		'Bivio::UI::HTML::Widget::IRRCell');
	return Bivio::UI::HTML::Widget::IRRCell->new({
	    field => $field,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Percent')) {
	Bivio::IO::ClassLoader->simple_require(
		'Bivio::UI::HTML::Widget::PercentCell');
	return Bivio::UI::HTML::Widget::PercentCell->new({
	    field => $field,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Amount')
	   || UNIVERSAL::isa($type, 'Bivio::Data::CSI::Amount')
	   || UNIVERSAL::isa($type, 'Bivio::Data::CSI::Quote')) {
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
#TODO: This is broken in the case of $attrs->{value} existing
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

    if (UNIVERSAL::isa($type, 'Bivio::Type::PrimaryId')) {
	return Bivio::UI::HTML::Widget::String->new({
	    field => $field,
	    value => [$field],
	    string_font => 'table_cell',
	    column_align => 'right',
	    %$attrs,
	}),
    }

    # Default number formatting
    if (UNIVERSAL::isa($type, 'Bivio::Type::Number')) {
	return Bivio::UI::HTML::Widget::AmountCell->new({
	    field => $field,
	    decimals => $type->get_decimals,
	    %$attrs,
	}),
    }

    # default type is string
    return Bivio::UI::HTML::Widget::String->new({
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
	return $proto->vs_new($attrs->{wf_class}, {
	    field => $field,
	    %$attrs,
	});
    }

    if ($field eq 'Instrument.ticker_symbol') {

	# Creates a text field with a "symbol lookup" button
	return Bivio::UI::Widget::Join->new({
	    # field is needed here by DescriptiveFormField
	    field => $field,
	    values => [
		Bivio::UI::HTML::Widget::Text->new({
		    field => $field,
		    size => 15,
		    %$attrs,
		}),
		' ',
		$proto->create(ref($model).'.lookup_button'),
		' ',
		$proto->create(ref($model).'.unlisted_button'),
	    ],
	});
    }

    if ($field =~ /is_public$/) {
	return $_VS->vs_director(
		[['->get_request'], 'user_can_modify_is_public'],
		{
		    0 => $_VS->vs_checkmark($field),
		    1 => Bivio::UI::HTML::Widget::Checkbox->new({
			field => $field,
			label => '',
                    }),
		}
	       )->put(
		       column_align => 'center',
		       column_control => [
			   sub { my($req) = shift->get_request;
				 return $req->get(
					 'realm_decor_show_all_columns')
					 && $req->get('realm_is_public');
			     }],
		       %$attrs,
		      );
    }

    if (UNIVERSAL::isa($type, 'Bivio::UI::FacadeChildType')) {
	return Bivio::UI::HTML::Widget::Select->new({
	    field => $field,
	    choices => $type,
	    enum_sort => 'as_int',
	    %$attrs,
	});
    }

    if (UNIVERSAL::isa($type, 'Bivio::Type::Enum')) {
	# Don't have larger than a 2x3 Grid
	return Bivio::UI::HTML::Widget::Select->new({
	    field => $field,
	    choices => $type,
	    %$attrs,
	}) if $type->get_count() > 6 || $attrs->{wf_want_select};

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
	Bivio::IO::ClassLoader->simple_require(
		'Bivio::UI::HTML::Widget::File');
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
	Bivio::IO::ClassLoader->simple_require(
		'Bivio::UI::HTML::Widget::Currency');
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

    if (UNIVERSAL::isa($type, 'Bivio::Type::CreditCardNumber')) {
	return Bivio::UI::HTML::Widget::Text->new({
	    field => $field,
	    size => $type->get_width,
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
	    cols => Bivio::Type::TextArea->LINE_WIDTH,
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
	    label => $_VS->vs_text($field),
	    %$attrs,
	});
    }

    if (UNIVERSAL::isa($type, 'Bivio::Type::Boolean')) {
	$attrs->{label_on_field} = 0;
	return Bivio::UI::HTML::Widget::Checkbox->new({
	    field => $field,
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

    if (UNIVERSAL::isa($type, 'Bivio::Type::PageSize')) {
	# We limit PageSize to a specific set of values,
	# because it is used in the EditPreferencesForm which
	# ignores all errors.  We try to make preferences be
	# always 'correct'.
	Bivio::Die->die($type, ': range changed')
		if $type->get_min != 5 || $type->get_max != 500;
	return Bivio::UI::HTML::Widget::Select->new({
	    field => $field,
	    choices => Bivio::TypeValue->new($type,
		    [qw(5 10 15 20 30 40 50 75 100 200 300 400 500)]),
	    %$attrs,
	});
    }

    if (UNIVERSAL::isa($type, 'Bivio::Type::Integer')) {
	return Bivio::UI::HTML::Widget::Text->new({
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

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
