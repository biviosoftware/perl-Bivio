# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::F1065sk1::Y1999::Form;
use strict;
$Bivio::UI::PDF::Form::F1065sk1::Y1999::Form::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::F1065sk1::Y1999::Form - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::F1065sk1::Y1999::Form;
    Bivio::UI::PDF::Form::F1065sk1::Y1999::Form->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Form::Form>

=cut

use Bivio::UI::PDF::Form::Form;
@Bivio::UI::PDF::Form::F1065sk1::Y1999::Form::ISA = ('Bivio::UI::PDF::Form::Form');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::F1065sk1::Y1999::Form>

=cut

#=IMPORTS
use Bivio::UI::PDF::Form::F1065sk1::Y1999::Formf1065sk1;
use Bivio::UI::PDF::Form::F1065sk1::Y1999::Formf1065sk1Draft;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Form::F1065sk1::Y1999::Form



=cut

sub new {
    my($self) = Bivio::UI::PDF::Form::Form::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute() : 



=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($draft) = $req->get_widget_value('Bivio::Biz::Model::F1065K1Form',
	    'draft');
    my($real_form);
    if ($draft) {
	$real_form =
		Bivio::UI::PDF::Form::F1065sk1::Y1999::Formf1065sk1Draft->new();
    }
    else {
	$real_form = Bivio::UI::PDF::Form::F1065sk1::Y1999::Formf1065sk1->new();
    }

    return $real_form->execute($req);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
