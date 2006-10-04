# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Ext::MIMEParser;
use strict;
$Bivio::Ext::MIMEParser::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Ext::MIMEParser::VERSION;

=head1 NAME

Bivio::Ext::MIMEParser - simplifies interface to MIME::Parser

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Ext::MIMEParser;

=cut

=head1 EXTENDS

L<MIME::Parser>

=cut

# This avoids warning messages when MIME::Parser initializes.
# The related Mail::Field class doesn't initialize nicely, and issues
# warnings which shouldn't be caught by Bivio::IO::Alert and Bivio::Die.
BEGIN {
   local($SIG{__WARN__});
   local($SIG{__DIE__});
   eval('use MIME::Parser ()');
}
@Bivio::Ext::MIMEParser::ISA = ('MIME::Parser');

=head1 DESCRIPTION

C<Bivio::Ext::MIMEParser> simplifies instantiation of MIME::Parser for
in core interfaces.

=cut

#=IMPORTS

#=VARIABLES


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Ext::MIMEParser

Creates and configures for in core parsing.

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->output_to_core(1);
    $self->tmp_to_core(1);
    $self->use_inner_files(1);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="parse_data"></a>

=head2 static parse_data(string_ref data) : MIME::Entity

Calls L<new|"new"> and then I<parse_data> with I<data> if called statically.
Otherwise, simply calls parse_data.

=cut

sub parse_data {
    my($proto) = shift;
    return (ref($proto) ? $proto : $proto->new)->SUPER::parse_data(@_);
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
