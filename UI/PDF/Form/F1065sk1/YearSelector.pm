# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::F1065sk1::YearSelector;
use strict;
$Bivio::UI::PDF::Form::F1065sk1::YearSelector::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::PDF::Form::F1065sk1::YearSelector::VERSION;

=head1 NAME

Bivio::UI::PDF::Form::F1065sk1::YearSelector - selects the proper K-1 year

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::F1065sk1::YearSelector;

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::PDF::Form::F1065sk1::YearSelector::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::F1065sk1::YearSelector> selects the proper K-1 year

=cut

#=IMPORTS
use Bivio::Type::Date;
use Bivio::UI::PDF::Form::F1065sk1::Y1999::Form;
use Bivio::UI::PDF::Form::F1065sk1::Y2000::Form;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static boolean execute(Bivio::Agent::Request req)

Renders the correct K-1 Year, based on the request's 'report_date'
attribute.

=cut

sub execute {
    my($proto, $req) = @_;
    my($form) = 'Bivio::UI::PDF::Form::F1065sk1::Y'
	    .Bivio::Type::Date->get_part($req->get('report_date'), 'year')
	    .'::Form';
    return $form->new()->execute($req);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
