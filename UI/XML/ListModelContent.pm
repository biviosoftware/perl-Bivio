# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::XML::ListModelContent;
use strict;
$Bivio::UI::XML::ListModelContent::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::XML::ListModelContent - contains the data necessary to emit rows
from a ListModel as XML element content.

=head1 SYNOPSIS

    use Bivio::UI::XML::ListModelContent;
    my($list_model_content) = Bivio::UI::XML::ListModelContent->new($req,
	$model_name, $fields [, $row name]);
    $list_model_content->emit_xml_text(string_ref $text, string $indent);

=cut

=head1 EXTENDS

L<Bivio::UI::XML::ElementContent>

=cut

use Bivio::UI::XML::ElementContent;
@Bivio::UI::XML::ListModelContent::ISA = ('Bivio::UI::XML::ElementContent');

=head1 DESCRIPTION

C<Bivio::UI::XML::ListModelContent> contains the data necessary to emit
the data of a ListModel in XML format.

=cut

#=IMPORTS
use Bivio::Type::XMLElementContent;
use Bivio::UI::XML::Strings;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

my($_LIST_MODEL_TYPE_NAME) = Bivio::UI::XML::Strings::LIST_MODEL_TYPE_NAME();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new($req, string $model_name, hash_ref $columns [, $row_name) :
	Bivio::UI::XML::ListModelContent


=cut

sub new {
    my($self) = Bivio::UI::XML::ElementContent::new($_[0],
	  Bivio::Type::XMLElementContent->from_name($_LIST_MODEL_TYPE_NAME));
    my(undef, $req, $model_name, $columns, $row_name) = @_;
    $self->{$_PACKAGE} = {
	req => $req,
	model_name => $model_name,
	columns => $columns,
	row_name => $row_name
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="emit_xml_text"></a>

=head2 emit_xml_text(string_ref $text, string $indent)

Create a child element for each row in the given list model.  Each child
element will, in turn, have a child element for each of the columns in
%{$columns}.  The %{$columns} hash has the name of a field in the list model as
a key, and the corresponding value is the tag to give to the child.  The
child's text value will be the value of the field.  If $row_name is given, emit
the colums of the row as elements in separate parent element with $row_name as
the tag; otherwise just emit them in the current element.

=cut

sub emit_xml_text {
    my($self, $xml_text_ref, $indent) = @_;
    my($fields) = $self->{$_PACKAGE};

    eval("require $fields->{model_name};");

    my($model) = $fields->{model_name}->new($fields->{req});
    $model->load({count => Bivio::Type::Integer->get_max});

    if (defined($fields->{row_name})) {
	while ($model->next_row()) {
	    my($row_elements) =
		    Bivio::UI::XML::Element->new($fields->{row_name});
	    my($key, $value);
	    while (($key, $value) = each %{$fields->{columns}}) {
		my($column_element) = Bivio::UI::XML::Element->new($value);
		$column_element->add_text(_string($self, $model, $key));
		$row_elements->add_child($column_element);
	    }
	    $row_elements->emit_xml_text($xml_text_ref, $indent);
	}
    }
    else {
	while ($model->next_row()) {
	    my($key, $value);
	    while (($key, $value) = each %{$fields->{columns}}) {
		my($column_element) = Bivio::UI::XML::Element->new($value);
		$column_element->add_text(_string($self, $model, $key));
		$column_element->emit_xml_text($xml_text_ref, $indent);
	    }
	}
    }

    return;
}

=for html <a name="has_content"></a>

=head2 has_content() : boolean

See if this object has any content that emit_xml_text will emit.  Always
assume that list model content objects have content, since we don't want
to access the database to find out.

=cut

sub has_content {
    return 1;
}

#=PRIVATE METHODS

# _string($model, $field_name) : string_ref
#
#
#
sub _string {
    my($self, $model, $field_name) = @_;
    my($type) = $model->get_field_type($field_name);
    my($value) = $model->get($field_name);
    $value = $type->to_xml($value);
    return \$value;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
