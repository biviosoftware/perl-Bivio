# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::PDFFont;
use strict;
$Bivio::UI::PDFFont::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::PDFFont::VERSION;

=head1 NAME

Bivio::UI::PDFFont - PDF font resource

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::PDFFont;

=cut

=head1 EXTENDS

L<Bivio::UI::FacadeComponent>

=cut

use Bivio::UI::FacadeComponent;
@Bivio::UI::PDFFont::ISA = ('Bivio::UI::FacadeComponent');

=head1 DESCRIPTION

C<Bivio::UI::PDFFont>

PDF supports the following core fonts:

 Courier
 Courier-Bold
 Courier-Oblique
 Courier-BoldOblique
 Helvetica
 Helvetica-Bold
 Helvetica-Oblique
 Helvetica-BoldOblique
 Times-Roman
 Times-Bold
 Times-Italic
 Times-BoldItalic
 Symbol
 ZapfDingbats

PDFFont attributes may be the following

 family=font-name
 color=color-name
 size=string
 underline
 overline
 strikeout

=cut

#=IMPORTS
use Bivio::UI::Color;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="handle_register"></a>

=head2 static handle_register()

Registers with Facade.

=cut

sub handle_register {
    my($proto) = @_;
    Bivio::UI::Facade->register($proto, ['Color']);
    return;
}

=for html <a name="initialization_complete"></a>

=head2 initialization_complete()

Verifies all standard fonts have been defined.

=cut

sub initialization_complete {
    my($self) = @_;

    # Initialize default first
    my($default) = $self->internal_get_value('default');
    $self->initialization_error(
        {names => ['default']}, ': default font not defined')
        unless $default;
    _initialize($self, $default, $default);

    # Initialize the rest of the values
    foreach my $v (@{$self->internal_get_all}) {
	_initialize($self, $v, $default);
    }

    $self->SUPER::initialization_complete();
    return;
}

=for html <a name="internal_initialize_value"></a>

=head2 internal_initialize_value(hash_ref value)

Does nothing.

=cut

sub internal_initialize_value {
    return;
}

=for html <a name="set_font"></a>

=head2 static set_font(string name, Bivio::Agent::Request req, Bivio::UI::PDF pdf)

Sets the font on the PDF.

=cut

sub set_font {
    my($proto, $name, $req, $pdf) = @_;

    # Lookup name
    my($value) = $proto->internal_get_value($name, $req);

    $pdf->setfont($pdf->findfont($value->{font}, "host", 0), $value->{size});

    # need to reset these each time
    foreach my $param (qw(underline overline strikeout)) {
        $pdf->set_parameter($param, $value->{$param} ? "true" : "false");
    }
    # leading is set to size during setfont()
    if ($value->{line_spacing}) {
        $pdf->set_value(leading => $value->{size} + $value->{line_spacing});
    }
    $pdf->setcolor('both', 'rgb', @{$value->{color}}, 0);
    return;
}

#=PRIVATE SUBROUTINES

# _initialize(Bivio::UI::Font self, hash_ref value, hash_ref default)
#
# Intializes the value.
#
sub _initialize {
    my($self, $value, $default) = @_;
    # Already initialized?  (Happens for default)
    return if $value->{font};

    foreach my $config (@{$value->{config}}) {
        if ($config =~ /^(underline|overline|strikeout)$/) {
            $value->{$config} = 1;
        }
        elsif ($config =~ /^(\w+)=([\w-]+)$/) {
            my($key, $val) = ($1, $2);

            if ($key =~ /^(size|line_spacing)$/) {
                $value->{$key} = $val;
            }
            elsif ($key eq 'family') {
                $value->{font} = $val;
            }
            elsif ($key eq 'color') {
                $value->{color} = Bivio::UI::Color->format_pdf(
                    $val, $self->get_facade);
            }
            else {
                Bivio::Die->die("invalid font attribute: ", $config);
            }
        }
        else {
            Bivio::Die->die("invalid font config: ", $config);
        }
    }

    # copy in the default values
    foreach my $key (keys(%$default)) {
        $value->{$key} ||= $default->{$key};
    }
    $value->{color} ||= [0, 0, 0];
    return;
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
