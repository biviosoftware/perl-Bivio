# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::ArrayIterator;
use strict;
$Bivio::UI::PDF::ArrayIterator::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::ArrayIterator - iterates over a perl array.

=head1 SYNOPSIS

    use Bivio::UI::PDF::ArrayIterator;
    Bivio::UI::PDF::ArrayIterator->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::PDF::ArrayIterator::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::PDF::ArrayIterator> 

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::ArrayIterator



=cut

sub new {
    my($self) = Bivio::UNIVERSAL::new(@_);
    my(undef, $array_ref, $index) = @_;
    $self->{$_PACKAGE} = {
	'index' => 0,
	'array_ref' => $array_ref,
	'push_array_ref' => []
    };
    my($fields) = $self->{$_PACKAGE};
    if (defined($index)) {
	$fields->{'index'} = $index;
    }
    return $self;
}

=head1 METHODS

=cut

=for html <a name="at_end"></a>

=head2 at_end() : 



=cut

sub at_end {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    if (($#{$fields->{'array_ref'}} < $fields->{'index'})
	    && (-1 == $#{$fields->{'push_array_ref'}})) {
	return(1);
    } else {
	return(0);
    }
}

=for html <a name="current_eol_ref"></a>

=head2 current_eol_ref() : 



=cut

sub current_eol_ref {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    if ($self->at_end()) {
	return(undef);
    }
    if (-1 == $#{$fields->{'push_array_ref'}}) {
	return(\$fields->{'array_ref'}->[$fields->{'index'} + 1]);
    } else {
	die("unexpected pushed text");
    }
}

=for html <a name="current_ref"></a>

=head2 current_ref() : 



=cut

sub current_ref {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    if ($self->at_end()) {
	return(undef);
    }
    if (-1 == $#{$fields->{'push_array_ref'}}) {
	return(\$fields->{'array_ref'}->[$fields->{'index'}]);
    } else {
	return(\$fields->{'push_array_ref'}->[$#{$fields->{'push_array_ref'}}]);
    }
}

=for html <a name="increment"></a>

=head2 increment() : 



=cut

sub increment {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    if ($self->at_end()) {
	return;
    }
    if (-1 == $#{$fields->{'push_array_ref'}}) {
	# The end of line sequences alternate with the line text in the array
	# referenced by array_ref.
	$fields->{'index'} += 2;
    } else {
	pop(@{$fields->{'push_array_ref'}});
    }
    return;
}

=for html <a name="push_back"></a>

=head2 push_back() : 



=cut

sub push_back {
    my($self, $text) = @_;
    my($fields) = $self->{$_PACKAGE};
    push(@{$fields->{'push_array_ref'}}, $text);
    return;
}

=for html <a name="replace_first"></a>

=head2 replace_first() : 



=cut

sub replace_first {
    my($self, $text) = @_;
    my($fields) = $self->{$_PACKAGE};
    $self->increment();
    $self->push_back($text);
    return;
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
