# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Form;
use strict;
$Bivio::UI::HTML::Widget::Form::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Form - renders an HTML form

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Form;
    Bivio::UI::HTML::Widget::Form->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Form::ISA = qw(Bivio::UI::HTML::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Form> is an HTML C<FORM> tag surrounding
a widget, which is usually a
L<Bivio::UI::HTML::Widget::Join|Bivio::UI::HTML::Widget::Join>,
but might be a
L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.
The widget or its children should contain a
L<Bivio::UI::HTML::Widget::FormButton|Bivio::UI::HTML::Widget::FormButton>.

No special formatting is implemented.  For layout, use, e.g.

=head1 ATTRIBUTES

=over 4

=item action : string [$req->format_uri]

Literal text to use as
the C<ACTION> attribute of the C<FORM> tag.

=item action : Bivio::Agent::TaskId [$req->format_uri]

Task to format_stateless_uri.

=item action : array_ref [$req->format_uri]

Dereferenced, passed to C<$source-E<gt>get_widget_value>, and
used as the C<ACTION> attribute of the C<FORM> tag.

=item cell_end_form : boolean [0]

Same value as L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.
Used to set default for I<end_tag>.

=item end_tag : boolean [see below]

Renders the C<FORM> end tag if true.  Default is true unless
I<cell_end_form> is true iwc is set to false.  See
L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.

=item form_class : Bivio::Biz::FormModel (inherited, get_request)

This value is computed from I<form_model> if it can be.  It
also be set.

=item form_method : string [POST] (inherited)

The value to be passed to the C<METHOD> attribute of the C<FORM> tag.

=item form_model : array_ref [*computed*] (required, inherited, get_request)

B<DEPRECATED>. Which form are we dealing with.
Use I<form_class>.

=item form_name : string [fnNNN] (inherited)

Name of the form which can be used within JavaScript.  Set dynamically
to C<fn>I<NNN> where I<NNN> is globally assigned starting at 1.
The value is set on the I<self>, so it can be used by fields.

=item link_target : string [] (inherited)

The value to be passed to the C<TARGET> attribute of C<A> tag.

=item value : Bivio::UI::Widget (required)

How to render the form.  Usually a
L<Bivio::UI::HTML::Widget::Join|Bivio::UI::HTML::Widget::Join>
or
L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.

=back

=cut

#=IMPORTS
use Bivio::HTML;
use Bivio::UI::HTML::Widget::TimezoneField;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_FORM_NAME_INDEX) = 0;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Form

Creates a new Form widget.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static information.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{prefix};

    # Compute form_class from form_model or vice-versa
    my($class) = $self->ancestral_get('form_class', undef);
    my($model) = $self->ancestral_get('form_model', undef);
    if ($class && $model) {
	# fall through
    }
    elsif ($model) {
	# DEPRECATED
	$class = $model->[0];
	$self->put(form_class => $class);
    }
    elsif ($class) {
	$model = [$class];
	$self->put(form_model => $model);
    }
    else {
	die('form_class not set');
    }
    die($class, ': invalid or not set form_class')
	    unless UNIVERSAL::isa($class, 'Bivio::Biz::FormModel');
    $fields->{class} = $class;

    # Compute form_name
    my($name) = $self->ancestral_get('form_name', undef);
    if ($name) {
	# Should be at least two chars starting with a letter
	die($name, ': invalid form_name') unless $name =~ /^[a-z]\w+$/i;
    }
    else {
	$name = 'fn'.$_FORM_NAME_INDEX++;
	$self->put(form_name => $name);
    }

    # Initialize prefix
    my($p) = '<form method=';
    $p .= $self->ancestral_get('form_method', 'POST');
    $p .= $self->link_target_as_html().' name="'.$name.'"';
    my($action) = $self->unsafe_get('action');
    $p .= ' action="';
    if (ref($action)) {
	# Task or widget value
	$fields->{action} = $action;
    }
    elsif (defined($action)) {
	$p .= $action;
    }
    else {
	$fields->{action} = 1;
    }
    $fields->{prefix} = $p;
    $fields->{end_tag} = $self->get_or_default('end_tag',
	    $self->get_or_default('cell_end_form', 0)
	    ? 0 : 1);

    # Initialize renderer
    $fields->{value} = $self->get('value');
    $fields->{value}->put(parent => $self);
    $fields->{value}->initialize;
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the form.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($req) = $source->get_request;
    my($model) = $req->get_widget_value($fields->{class});

    # Method
    $$buffer .= $fields->{prefix};

    # Action (if not static)
    my($action) = $fields->{action};
    if ($action) {
	# If there is an action, get it or format the task.
	# Otherwise, the action is this current task's action.
	$action = ref($action) eq 'ARRAY'
		? $source->get_widget_value(@$action)
			: ref($action) ? $req->format_stateless_uri($action)
				: $req->format_uri();
#TODO: Tightly Coupled with FormModel & Location.  Do not propagate form
#      context when you have a form to store the context in fields.
#      Context management is hard....
	$action =~ s/[&?]fc=[^&=]+//;
	$$buffer .= $action;
    }

    # Set encoding type if form has a file field
    unless ($fields->{middle}) {
	$fields->{middle} = '"';
	$fields->{middle} .= ' enctype="multipart/form-data"'
		if $model->get_info('file_fields');
	$fields->{middle} .= ">\n";
    }
    $$buffer .= $fields->{middle};

    # Timezone is computed on every form
    Bivio::UI::HTML::Widget::TimezoneField->render($source, $buffer);

    # Hidden fields (if any)
    my($hidden) = $model->get_hidden_field_values();
    while (@$hidden) {
	# hidden fields have been converted to literal, but not  escaped.
	$$buffer .= '<input type=hidden name='.shift(@$hidden).' value="'
		.Bivio::HTML->escape(shift(@$hidden))."\">\n";
    }

    # Rest of the form
    $fields->{value}->render($source, $buffer);
    $$buffer .= '</form>' if $fields->{end_tag};
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
