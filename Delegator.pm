# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Delegator;
use strict;
$Bivio::Delegator::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegator::VERSION;

=head1 NAME

Bivio::Delegator - delegates implementation to another class

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Delegator;

=cut

use Bivio::UNIVERSAL;
@Bivio::Delegator::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Delegator> delegates implementation to another class. Subclasses
must have an entry in ClassLoader.delegates.

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::IO::ClassLoader;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
use vars ('$AUTOLOAD');

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(...) : Bivio::Delegator

Creates a new instance of the delegator and the delegate.

=cut

sub new {
    my($proto, @args) = @_;
    my($self) = Bivio::UNIVERSAL::new($proto);
    $self->{$_PACKAGE} = {
	delegate => _get_delegate_class($proto)->new(@args),
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="AUTOLOAD"></a>

=head2 AUTOLOAD()

Handles method calls by invoking the delegate. This is only called if the
subclass doesn't implement the method.

=cut

sub AUTOLOAD {
    my($proto, @args) = @_;
    # magic variable, created by perl
    my($method) = $AUTOLOAD;

    # strip out package prefix
    $method =~ s/.*:://;

    # don't forward destructors, it will be handled by perl
    return if $method eq 'DESTROY';

    _trace((ref($proto) ? 'self' : 'proto'), '->',
	    $method, '(', join(', ', @args), ')') if $_TRACE;

    if (ref($proto)) {
	my($fields) = $proto->{$_PACKAGE};
	return $fields->{delegate}->$method(@args);
    }
    return _get_delegate_class($proto)->$method(@args);
}

#=PRIVATE METHODS

# _get_delegate_class() : string
#
# Returns the delegate class for the current class/instance.
#
sub _get_delegate_class {
    my($proto) = @_;
    return Bivio::IO::ClassLoader->delegate_require(ref($proto) || $proto);
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
