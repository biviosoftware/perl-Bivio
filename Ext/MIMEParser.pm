# Copyright (c) 2002-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Ext::MIMEParser;
use strict;
use base 'MIME::Parser';

# C<Bivio::Ext::MIMEParser> simplifies instantiation of MIME::Parser for
# in core interfaces.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
# This avoids warning messages when MIME::Parser initializes.
# The related Mail::Field class doesn't initialize nicely, and issues
# warnings which shouldn't be caught by Bivio::IO::Alert and Bivio::Die.
BEGIN {
   local($SIG{__WARN__});
   local($SIG{__DIE__});
   eval('use MIME::Parser ()');
}

sub new {
    # (proto) : Ext.MIMEParser
    # Creates and configures for in core parsing.
    my($self) = shift->SUPER::new(@_);
    $self->output_to_core(1);
    $self->tmp_to_core(1);
    $self->use_inner_files(1);
    return $self;
}

sub parse_data {
    # (proto, string_ref) : MIME.Entity
    # Calls L<new|"new"> and then I<parse_data> with I<data> if called statically.
    # Otherwise, simply calls parse_data.
    my($proto) = shift;
    return (ref($proto) ? $proto : $proto->new)->SUPER::parse_data(@_);
}

1;
