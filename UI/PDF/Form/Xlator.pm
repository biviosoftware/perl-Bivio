# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::Xlator;
use strict;
$Bivio::UI::PDF::Form::Xlator::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::Xlator - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::Xlator;
    Bivio::UI::PDF::Form::Xlator->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::PDF::Form::Xlator::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::Xlator>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Form::Xlator



=cut

sub new {
    my($self) = Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_pdf_field_names"></a>

=head2 abstract get_pdf_field_names() : 



=cut

sub get_pdf_field_names {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    die(__FILE__, ", ", __LINE__, " Abstract method\n");
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
