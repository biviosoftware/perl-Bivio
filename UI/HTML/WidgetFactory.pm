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

C<Bivio::UI::HTML::WidgetFactory> creates widgets for model fields

=cut

#=IMPORTS
use Bivio::Biz::Model;
use Bivio::UI::HTML::Widget::AmountCell;
use Bivio::UI::HTML::Widget::DateTime;
use Bivio::UI::HTML::Widget::Enum;
use Bivio::UI::HTML::Widget::MailTo;
use Bivio::UI::HTML::Widget::PercentCell;
use Bivio::UI::HTML::Widget::String;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

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

    my($display_only) = 1;
    if (UNIVERSAL::isa($model, 'Bivio::Model::FormModel')) {
	die("not implemented");
    }

    my($widget);
    if ($display_only) {
	$widget = _create_display($field_name, $field_type, $attrs);
    }
    else {
	$widget = _create_edit($field_name, $field_type, $attrs);
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

#TODO: make this a Percent type, models should use it instead
    if ($field =~ /percent/) {
	return Bivio::UI::HTML::Widget::PercentCell->new({
	    field => $field,
	    %$attrs,
	});
    }

#TODO: should check if the list class "can()" format_name()
    if ($field eq 'RealmOwner.name') {
	return Bivio::UI::HTML::Widget::String->new({
	    value => ['->format_name'],
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Amount')) {
	return Bivio::UI::HTML::Widget::AmountCell->new({
	    field => $field,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::DateTime')) {
	return Bivio::UI::HTML::Widget::DateTime->new({
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
	value => [$field],
	string_font => 'table_cell',
	%$attrs,
    });
}

# _create_edit(string field, Bivio::Type type, hash_ref attrs) : Bivio::UI::HTML::Widget
#
# Create an editable widget for the specified field.
#
sub _create_edit {
    my($field, $type, $attrs) = @_;
    die("not implemented");
}

# _get_model_and_field_type(string field) : (Bivio::Biz::Model, string, Bivio::Type)
#
# Returns a model instance, field name and type for the specified field.
#
sub _get_model_and_field_type {
    my($field) = @_;

    # parse out the model and field names
    my($model_name, $field_name) = $field =~ /^([\w\:]+)\.(.+)$/;
    die("couldn't parse $field") unless $model_name && defined($field_name);

    my($model) = Bivio::Biz::Model->get_instance($model_name);
    return ($model, $field_name, $model->get_field_type($field_name));
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
