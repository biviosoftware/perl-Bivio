# Copyright (c) 2003-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::MIMEEntity;
use strict;
use Bivio::Base 'Bivio::UI::Widget::Join';
use MIME::Entity ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub headers_as_string {
    my($self, $source) = @_;
    # Return MIME headers as string.  B<Must call L<render|"render"> before calling
    # this routine>, and returns the last rendered value put on the request.
    return $source->get_request->get("$self.headers");
}

sub initialize {
    my($self) = @_;
    # Initializes mime_type and mime_encoding if not already set.
    foreach my $x (
	[mime_type => 'multipart/mixed'],
	[mime_encoding => '7bit'],
    ) {
	$self->get_if_exists_else_put(@$x);
    }
    return shift->SUPER::initialize(@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    # Renders this instance into I<buffer> using I<source> to evaluate
    # widget values.  Saves mime headers on the request.
    my($name) = 0;
    my($entity) = MIME::Entity->build(
        map({
	    ($_ => ${$self->render_attr('mime_' . lc($_), $source)});
	} qw(Type Encoding)),
    );
    foreach my $v (@{$self->get('values')}) {
	my($e);
	if (UNIVERSAL::isa($v, 'Bivio::UI::HTML::Widget::FileAttachment')) {
	    $entity->attach(
	        Path => ${$v->render_attr('path', $source)},
                Disposition => 'attachment',
	    map({
		($_ => ${$v->render_attr('mime_' . lc($_), $source)});
	    } qw(Type Encoding)),
        );} else {
            $entity->attach(
	        Data => ${$self->render_value($name++, $v, $source)},
	        map({
		    ($_ => ${$v->render_attr('mime_' . lc($_), $source)});
	        } qw(Type Encoding)),
	    );
        }
    }
    $$buffer .= $entity->body_as_string;
    $source->get_request->put(
	"$self.headers" => join('',
	    map({
		$_ . ': ', $entity->head->get(lc($_));
	    } 'MIME-Version', 'Content-Type', 'Content-Transfer-Encoding'),
	),
    );
    return;
}

1;


__END__

sub render {
    my($self, $source, $buffer) = @_;
    my($name) = 0;
    my($entity) = MIME::Entity->new;
    foreach my $v (@{$self->get('values')}) {
        next if $v->can('want_render') && !$v->want_render($source);
	my($data) = '';
	$v->render($source, \$data);
        $self->die($v, ': empty mime part')
	    unless length($data);
	$entity->attach({
	        Data => $data,
	        map({
		     my($x) = '';
		     ($_ => $v->unsafe_render_attr('mime_' . lc($_), $source, \$x) => $x : $_DEFAULT->{$_});
	        } qw(Type Encoding)),
        });
    );
    if ($self->has_keys('mime_type')) {
	map({
	    ($_ => ${$self->render_attr('mime_' . lc($_), $source)});
	} qw(Type Encoding));
    }
    else {
        if (scalar($entity->parts) == 1) {
            $entity->make_singlepart;
        else {
             $entity->make_multipart;
        }
    }
    $$buffer .= $entity->body_as_string;
    $source->get_request->put(
	"$self.headers" => join('',
	    map({
		$_ . ': ', $entity->head->get(lc($_));
	    } 'MIME-Version', 'Content-Type', 'Content-Transfer-Encoding'),
	),
    );
    return;
}
