# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::XML::PropertyModelContent;
use strict;
$Bivio::UI::XML::PropertyModelContent::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::XML::PropertyModelContent - contains the data necessary to emit
rows from a PropertyModel as XML element content.

=head1 SYNOPSIS

    use Bivio::UI::XML::PropertyModelContent;
    my($property_model_content) =
	Bivio::UI::XML::PropertyModelContent->new($req, $model_name, $fields, $sort[, $row_name]);
    $property_model_content->emit_xml_text(string_ref $text, string $indent);

=cut

use Bivio::UI::XML::ElementContent;
@Bivio::UI::XML::PropertyModelContent::ISA = ('Bivio::UI::XML::ElementContent');

=head1 DESCRIPTION

C<Bivio::UI::XML::PropertyModelContent> contains the data necessary to emit
the data of a PropertyModel in XML format.

=cut

#=IMPORTS
use Bivio::Type::XMLElementContent;
use Bivio::UI::XML::Strings;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

my($_PROPERTY_MODEL_TYPE_NAME) =
	Bivio::UI::XML::Strings::PROPERTY_MODEL_TYPE_NAME();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new($req, string $model_name, hash_ref $columns,
string $sort[, $row_name | $Bivio::UI::XML::Element_ref]) :
	Bivio::UI::XML::PropertyModelContent

=cut

sub new {
    my($self) = Bivio::UI::XML::ElementContent::new($_[0],
	Bivio::Type::XMLElementContent->from_name($_PROPERTY_MODEL_TYPE_NAME));
    my(undef, $req, $model_name, $columns, $sort, $row_name) = @_;
    $self->{$_PACKAGE} = {
	req => $req,
	model_name => $model_name,
	columns => $columns,
	sort => $sort,
	row_name => $row_name,
	id => undef,
	id_column_name => undef,
	row => {}
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="emit_xml_text"></a>

=head2 emit_xml_text(string_ref $text, string $indent)

Create a child element for each row in the given property
model whose realm_id matches the auth_id in the given request.  Each child
element will, in turn, have a child element for each of the columns in
%{$columns}.  The %{$columns} hash has the name of a field in the property
model as a key, and the corresponding value is the tag to give to the
child.  The child's text value will be the value of the field.  The rows
will be ordered by the column given in $sort.  If $row_name is given, emit the
colums of the row as elements in separate parent element with $row_name as
the tag; otherwise just emit them in the current element.

=cut

sub emit_xml_text {
    my($self, $xml_text_ref, $indent) = @_;
    my($fields) = $self->{$_PACKAGE};

    eval("require $fields->{model_name};");

    my($model) = $fields->{model_name}->new($fields->{req});
    my($it);

    if (defined($fields->{id})) {
	$it = $model->iterate_start_with_id($fields->{id}, $fields->{sort});
    }
    else {
	$it = $model->iterate_start($fields->{sort});
    }

    if (defined($fields->{row_name})) {
	while ($model->iterate_next($it, $fields->{row}, 'to_xml')) {
	    my($row_elements) =
		    Bivio::UI::XML::Element->new($fields->{row_name});
	    my($key, $value);
	    while (($key, $value) = each %{$fields->{columns}}) {
		my($column_element) = Bivio::UI::XML::Element->new($value);
		unless (defined(${$fields->{row}}{$key})) {
		    Bivio::IO::Alert->die("Unknown field name \"$key\"");
		}
		$column_element->add_text(${$fields->{row}}{$key});
		$row_elements->add_child($column_element);
	    }
	    $row_elements->emit_xml_text($xml_text_ref, $indent);
	}
    }
    else {
	while ($model->iterate_next($it, $fields->{row}, 'to_xml')) {
	    my($key, $value);
	    while (($key, $value) = each %{$fields->{columns}}) {
		my($column_element) = Bivio::UI::XML::Element->new($value);
		unless (defined(${$fields->{row}}{$key})) {
		    Bivio::IO::Alert->die("Unknown field name \"$key\"");
		}
		$column_element->add_text(${$fields->{row}}{$key});
		$column_element->emit_xml_text($xml_text_ref, $indent);
	    }
	}
    }
    $model->iterate_end($it);

    return;
}

=for html <a name="generate_children"></a>

=head2 generate_children(Bivio::UI::XML::Element_ref) : 

Generate elements and add them as children to the given element.

=cut

sub generate_children {
    my($self, $element_ref) = @_;
    my($fields) = $self->{$_PACKAGE};

    eval("require $fields->{model_name};");

    my($model) = $fields->{model_name}->new($fields->{req});
    my($it);

    if (defined($fields->{id})) {
	$it = $model->iterate_start_with_id($fields->{id}, $fields->{sort});
    }
    else {
	$it = $model->iterate_start($fields->{sort});
    }

    while ($model->iterate_next($it, $fields->{row}, 'to_xml')) {
	my($key, $value);
	while (($key, $value) = each %{$fields->{columns}}) {
	    my($column_element) = Bivio::UI::XML::Element->new($value);
	    unless (defined(${$fields->{row}}{$key})) {
		Bivio::IO::Alert->die("Unknown field name \"$key\"");
	    }
	    $column_element->add_text(${$fields->{row}}{$key});
	    $element_ref->add_child($column_element);
	}
    }
}

=for html <a name="has_content"></a>

=head2 has_content() : boolean

See if this object has any content that emit_xml_text will emit.  Always
assume that property model content objects have content, since we don't want
to access the database to find out.

=cut

sub has_content {
    return 1;
}

=for html <a name="set_id"></a>

=head2 set_id(string id)

Set the value of the id to use for the select.  This replaces the value
stored in the request.

=cut

sub set_id {
    my($self, $id) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{id} = $id;
    return;
}

=for html <a name="set_id_column_name"></a>

=head2 set_id_column_name(string $name)

Set the column name of the column that contains the index to use for a
child PropertyModelContent.

=cut

sub set_id_column_name {
    my($self, $id_column_name) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{id_column_name} = $id_column_name;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
