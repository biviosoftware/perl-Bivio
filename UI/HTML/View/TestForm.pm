# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::View::TestForm;
use strict;
$Bivio::UI::HTML::View::TestForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::View::TestForm - 

=head1 SYNOPSIS

    use Bivio::UI::HTML::View::TestForm;
    Bivio::UI::HTML::View::TestForm->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::View>

=cut

use Bivio::UI::HTML::View;
@Bivio::UI::HTML::View::TestForm::ISA = qw(Bivio::UI::HTML::View);

=head1 DESCRIPTION

C<Bivio::UI::HTML::View::TestForm>

=cut

#=IMPORTS
use Bivio::Agent::HTTP::Request;
use Bivio::Agent::TaskId;
use Bivio::UI::HTML::Widget::Form;
use Bivio::UI::HTML::Widget::Submit;
use Bivio::UI::Icon;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::View::TestForm



=cut

sub new {
    my($self) = &Bivio::UI::HTML::View::new(@_);
    $self->{$_PACKAGE} = {};
    $self->initialize;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)


=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{request} = $req;
    my($buffer) = $fields->{prefix};
# Cache this?
    $self->get('child')->render($req, \$buffer);
    $buffer .= $fields->{suffix};
    $req->get('reply')->print($buffer);
    $fields->{request} = undef;
    return;
}

=for html <a name="get_object"></a>

=head2 get_object(string name) : Bivio::UNIVERSAL

=cut

sub get_object {
    my($self, $name) = @_;
    return $self->{$_PACKAGE}->{request}->get($name);
}

=for html <a name="initialize"></a>

=head2 initialize()

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{prefix} = <<'EOF';
<html><head><title>TestForm</title></head><body>
EOF
    $fields->{suffix} = <<'EOF';
</body></html>
EOF
#    $self->put('child', Bivio::UI::HTML::Widget::Form->new({
#	parent => $self,
#	action => Bivio::Agent::HTTP::Request->format_uri(
#		Bivio::Agent::TaskId::TEST_VIEW(),
#		undef,
#		undef),
#	value => Bivio::UI::HTML::Widget::Submit->new(),
#    }));
#    $self->get('child')->initialize;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
