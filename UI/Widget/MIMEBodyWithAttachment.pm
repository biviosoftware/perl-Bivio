# Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::MIMEBodyWithAttachment;
use strict;
$Bivio::UI::Widget::MIMEBodyWithAttachment::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Widget::MIMEBodyWithAttachment::VERSION;

=head1 NAME

Bivio::UI::Widget::MIMEBodyWithAttachment - 

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::Widget::MIMEBodyWithAttachment;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::Widget::MIMEBodyWithAttachment::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::Widget::MIMEBodyWithAttachment>

=cut

#=IMPORTS
use MIME::Entity;

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::Widget::MIMEBodyWithAttachment

Create a new MIMEBodyWithAttachment widget

=cut

sub new {
    my($proto) = shift;
    my($self) = $proto->SUPER::new(@_);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="mail_headers"></a>

=head2 mail_headers(Bivio::Agent::Request req) : arrayref

Returns headers

=cut

sub mail_headers {
    my($self, $req) = @_;
    my($fields) = $req->unsafe_get("$self.instance");
    $self->die($self, ': must be rendered before headers() is called')
	unless $fields && exists($fields->{entity});

    return [
	map({
	    my($value) = $fields->{entity}->head()->get(lc($_));
            chomp ($value);
            [$_, $value];
        } 'MIME-Version', 'Content-Type', 'Content-Transfer-Encoding'),
    ];
}

=for html <a name="render"></a>

=head2 render(Bivio::UI::WidgetValueSource source, string_ref buffer)

Renders this instance into I<buffer> using I<source> to evaluate
widget values.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;

    my($entity) = MIME::Entity->build(
	Data => $self->render_attr('body', $req),
    );

    my($attachment) = $self->unsafe_resolve_widget_value(
        $self->unsafe_get('attachment'), $req);
    if ($attachment && $attachment->want_render($req)) {
	$entity->attach(
	    Data => $self->render_attr('attachment', $req),
	    Filename => ${$attachment->render_attr('filename', $req)},
	    Type => ${$attachment->render_attr('content_type', $req)},
#	    Encoding => $attachment->encoding(),
	    Disposition => 'attachment',
        );
    }

    $$buffer .= $entity->body_as_string;
    $req->put("$self.instance" => {entity => $entity});

    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
