# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Mail::Store::Formatter;
use strict;
$Bivio::Mail::Store::Formatter::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Mail::Store::Formatter - abstract base class of MIME formatters

=head1 SYNOPSIS

    use Bivio::Mail::Store::Formatter;
    Bivio::Mail::Store::Formatter->from_entity();

=cut

=head1 EXTENDS

L<Bivio::UNIVERSAL>

=cut

use Bivio::UNIVERSAL;
@Bivio::Mail::Store::Formatter::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Mail::Store::Formatter>

=cut

#=IMPORTS
use Bivio::Type::MIMEType;
use Bivio::IO::Trace;
use MIME::Entity;
#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;

my $_MIME_MAP = {
    'text/plain' => 'Bivio::Mail::Store::TextFormatter',
    'text/html' => 'Bivio::Mail::Store::HTMLFormatter',
};



=head1 FACTORIES

=cut

=head1 METHODS

=cut

=for html <a name="format_item"></a>

=head2 format_item() : scalar_ref

Formats the MIME entity for storage. Subclasses override this.
Seems silly to implement the default behavior the way I am, but
I need to return a scalar reference to write, not a MIME Body.
So the MIME body needs to write itself to a scalar. IO::Scalar
is used for this.

=cut

sub format_item {
    my($proto, $body) = @_;
    my($s);
    my($io) = IO::Scalar->new(\$s);
    $body->print($io);
    $io->print("\r\n");
    $io->close();
    return \$s;
}

=for html <a name="from_entity"></a>

=head2 static from_entity(MIMEEntity entity) : Bivio::Mail::Store::Formatter

This method returns a package which will handle the formatting
for a particular MIME type. If the MIME type is not handled
by any subclasses, this class' format_item() will handle it.
The default behavior is simply to write the MIME Body to
a scalar and return a reference to it.

=cut

sub from_entity {
    print(STDERR "\n\nFROM_ENTITY.");
    my($proto, $entity) = @_;
    my($ctype) = $entity->head->get('content-type');
#TODO this is a complete hack. If there is no MIME type (plain email)
    # then we won't have a content-type returned from the head.
    if(!$ctype){
	#we force it to be text/plain
	$ctype = "text/plain";
    }
#this is probably excessive:    
    my($type) =   Bivio::Type::MIMEType->from_content_type($ctype);
    _trace("type: \"", $type->get_short_desc(),  "\"");
    my $class = $_MIME_MAP->{$type->get_short_desc()};
    _trace('returning package: ', $class, ' for type ',
	    $type->get_short_desc()) if $_TRACE;
    return $class || $_PACKAGE;
}


#=PRIVATE METHODS


=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
