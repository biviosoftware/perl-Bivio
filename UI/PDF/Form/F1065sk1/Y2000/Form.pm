# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::F1065sk1::Y2000::Form;
use strict;
$Bivio::UI::PDF::Form::F1065sk1::Y2000::Form::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::F1065sk1::Y2000::Form - the Form referenced by the
task block for F1065sk1::Y2000.

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::F1065sk1::Y2000::Form;
    Bivio::UI::PDF::Form::F1065sk1::Y2000::Form->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Form::Form>

=cut

use Bivio::UI::PDF::Form::Form;
@Bivio::UI::PDF::Form::F1065sk1::Y2000::Form::ISA = ('Bivio::UI::PDF::Form::Form');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::F1065sk1::Y2000::Form>

=cut

#=IMPORTS
use Bivio::UI::PDF::Form::F1065sk1::Y2000::Formf1065sk1;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Form::F1065sk1::Y2000::Form



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
    $req->get('Bivio::Biz::Model::F1065K1List')->set_cursor_or_die(0);
    return Bivio::UI::PDF::Form::F1065sk1::Y2000::Formf1065sk1->new()
	    ->execute($req);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
