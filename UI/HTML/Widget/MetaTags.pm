# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::MetaTags;
use strict;
$Bivio::UI::HTML::Widget::MetaTags::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::MetaTags::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::MetaTags - generates meta tags in header

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::MetaTags;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::MetaTags::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::MetaTags>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args() : hash_ref

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my(undef, $description, $keywords, $attributes) = @_;
    return {
	meta_description => $description,
	meta_keywords => $keywords,
	($attributes ? %$attributes : ()),
    };
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the title by joining the I<values>.  We set the Title in the
reply as well.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    foreach my $k (sort(grep(s/^meta_//, @{$self->get_keys}))) {
	my($b);
	next unless $self->unsafe_render_attr("meta_$k", $source, \$b);
	$$buffer .= qq{<meta name="$k" content="}
	    . Bivio::HTML->escape($b) . qq{">\n};
    }
#TODO: Modify the reply header?
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
