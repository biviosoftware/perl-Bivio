# Copyright (c) 2003-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::MIMEEntity;
use strict;
use Bivio::Base 'Widget.Join';
use MIME::Entity ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_ATTR) = [qw(Type Encoding Filename Disposition Charset Path Data)];

sub initialize {
    my($self) = @_;
    $self->map_invoke(initialize_attr => [
	map([_a($_) => ''], @$_ATTR),
	[values => []],
    ]);
    return shift->SUPER::initialize(@_);
}

sub mime_entity {
    my($self, $source) = @_;
    # Might not have rendered
    return $source->get_request->unsafe_get("$self");
}

sub mail_headers {
    my($entity) = shift->mime_entity(@_);
    return [
	map({
	    my($value) = $entity->head->get(lc($_));
	    chomp($value)
		if $value;
	    $value ? [$_, $value] : ();
	} qw(
	    MIME-Version
	    Content-Type
	    Content-Transfer-Encoding
	    Content-Disposition
	)),
    ];
}

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($entity) = MIME::Entity->build(%{_render($self, undef, $self, $source)});
    my($name) = 0;
    foreach my $value (@{$self->get('values')}) {
	my($v) = _render(
	    $self,
	    $name++,
	    $self->unsafe_resolve_widget_value($value, $source),
	    $source,
	);
	if ($v->{entity}) {
	    $entity->make_multipart;
	    $entity->add_part($v->{entity});
	}
	elsif (defined($v->{Data}) || defined($v->{Path})) {
	    $entity->attach(%$v)
	}
    }
    $$buffer .= $entity->body_as_string;
    $source->get_request->put("$self" => $entity);
    return;
}

sub _a {
    return 'mime_' . lc(shift(@_));
}

sub _render {
    my($self, $name, $value, $source) = @_;
    my($d);
    $self->unsafe_render_value($name, $value, $source, \$d)
	unless $self eq $value;
    return {
	Type => 'multipart/mixed',
	defined($d) && length($d) ? (Data => \$d) : (),
	$self ne $value && $value->can('mime_entity')
            ? (entity => $value->mime_entity($source))
	    : map({
		my($v) = $value->render_simple_attr(_a($_), $source);
		length($v) ? ($_ => $v) : ();
	    } @$_ATTR),
    };
}

1;
