# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::HTMLParser;
use strict;
$Bivio::Test::HTMLParser::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::HTMLParser::VERSION;

=head1 NAME

Bivio::Test::HTMLParser - holds parsed HTML in various formats

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::HTMLParser;

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::Test::HTMLParser::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::Test::HTMLParser> directs parsing of html by calling classes in the
TestHTMLParser class map.

=head1 ATTRIBUTES

=over 4

=item html : string

The HTML which was passed to new

=item E<lt>simple_classE<gt> : string

Each parser class is put on I<self>.  See parser classes for their attributes.

=back

=cut

#=IMPORTS
use Bivio::Ext::HTMLParser;
use Bivio::IO::ClassLoader;

#=VARIABLES
my(@_CLASSES);
Bivio::IO::ClassLoader->map_require_all('TestHTMLParser');

=head1 FACTORIES

=cut

=for html <a name="internal_new"></a>

=head2 static internal_new(Bivio::Test::HTMLParser parser) : Bivio::Test::HTMLParser

Calls parser subclass to parse cleaned html.  Subclass must implement
L<Bivio::Ext::HTMLParser|Bivio::Ext::HTMLParser> interface.  Sets two
attributes: I<cleaner> and I<elements>.  I<cleaner> is an instance of
C<Cleaner>, and I<elements> is a hash which will be put as the attributes of
I<self> when parsing is complete.

=cut

sub internal_new {
    my($proto, $parser) = @_;
    my($self) = $proto->new;
    $self->internal_put({
	cleaner => $parser->get('Cleaner'),
	elements => {},
    });

    my($p) = Bivio::Ext::HTMLParser->new($self);
    $p->ignore_elements(qw(script style));
    $p->parse($self->get('cleaner')->get('html'));
    $self->internal_put($self->get('elements'));
    return $self->set_read_only;
}

=for html <a name="new"></a>

=head2 static new(string_ref html) : Bivio::Test::HTMLParser

=head2 static new(hash_ref attrs) : Bivio::Test::HTMLParser

Parse I<html> using registered parser classes.

If I<html> is undef or I<attrs> is passed, does nothing (pass through
L<internal_new|"internal_new"> for subclasses).

=cut

sub new {
    my($proto) = shift;
    return $proto->SUPER::new(@_)
       unless (ref($proto) || $proto) eq __PACKAGE__;

    my($html) = shift;
    my($self) = $proto->SUPER::new({html => $$html});
    foreach my $c (@_CLASSES) {
	$self->put($c->simple_package_name => $c->internal_new($self));
    }
    return $self->set_read_only;
}

=head1 METHODS

=cut

sub html_parser_comment {
    return;
}

sub html_parser_end {
    return;
}

sub html_parser_start {
    return;
}

sub html_parser_text {
    return;
}

=for html <a name="register"></a>

=head2 static register(array_ref prerequisite_classes)

Adds I<proto> to list of classes, but first loads I<prerequisite_classes>.

=cut

sub register {
    my($proto, $prerequisite_classes) = @_;
    foreach my $p (@{$prerequisite_classes || []}) {
	Bivio::IO::ClassLoader->map_require('TestHTMLParser', $p);
    }
    push(@_CLASSES, ref($proto) || $proto);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
