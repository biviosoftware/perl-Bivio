# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::F1065sk1::Y1999::Form;
use strict;
$Bivio::UI::PDF::Form::F1065sk1::Y1999::Form::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::F1065sk1::Y1999::Form - the Form referenced by the
task block for F1065sk1::Y1999.

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

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Form::F1065sk1::Y1999::Form



=cut

sub new {
    my($self) = Bivio::UI::PDF::Form::Form::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute() : 



=cut

sub execute {
    my($self, $req) = @_;
    $req->get('Bivio::Biz::Model::F1065K1List')->set_cursor_or_die(0);
    return Bivio::UI::PDF::Form::F1065sk1::Y1999::Formf1065sk1->new()
	    ->execute($req);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
