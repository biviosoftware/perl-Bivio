# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::IO::Format;
use strict;
$Bivio::IO::Format::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::IO::Format::VERSION;

=head1 NAME

Bivio::IO::Format - uses formline to generate paged string output

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::IO::Format;

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::IO::Format::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::IO::Format> uses formline to generate a string output.  The example
I<swrite> in the perlform man page doesn't take into account TOP format
statements.  This class does.

=head1 ATTRIBUTES

=over 4

=item delete_blank_lines : boolean [0]

If a line results in a blank, don't print it unless the line is
a constant blank line.

=back

=head1 EXAMPLES

Let's say you have:

      format INVITES_TOP =
  Club: @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  $club_info

  ID 		              Sent                        Privileges
  Email		              Full Name                   Login
  URL
  ----------------------------------------------------------------------
  .

      format INVITES =
  @<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<
  $id, $date, $privileges
  @<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<
  $email, $full_name, $login
  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  $invite_url

  .

You would translate this to:

  my($form) = Bivio::IO::Format->new
           ->put_top(<<"EOF")
  Club: $club_info

  ID 		              Sent                        Privileges
  Email		              Full Name                   Login
  URL
  ----------------------------------------------------------------------
  EOF
           ->add_line(<<'EOF', [\$id, \$date, \$privileges])
  @<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<
  EOF
           ->add_line(<<'EOF', [\$email, \$full_name, \$login])
  @<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<
  EOF
           ->add_line(<<'EOF', [\$invite_url]);
  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  $invite_url

You then can make the following call iteratively:

  $form->process();

This will write the values to an internal result which is returned by
L<get_result|"get_result">.

=cut

#=IMPORTS
use Bivio::Die;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attrs) : Bivio::IO::Format

Returns a new Bivio::IO::Format.

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {
	lines => [],
	result => '',
	line_num => undef,
    };
    return $self->put_top('');
}

=head1 METHODS

=cut

=for html <a name="add_line"></a>

=head2 add_line(string format) : Bivio::IO::Format

=head2 add_line(string format, array_ref args) : Bivio::IO::Format

Add another format line to this instance.  I<format> is a perl
format.  I<args> is list of refs which will be passed to
formline.

Returns self.

=cut

sub add_line {
    my($self, $format, $args) = @_;
    $args ||= [];
    my($fields) = $self->[$_IDI];
    Bivio::Die->die('all arguments must be references')
	if grep(!ref($_), @$args);
    _append_newline(\$format);
    push(@{$fields->{lines}}, {
	format => $format,
	args => $args,
	is_blank => $format =~ /^\s*$/s ? 1 : 0,
    });
    return $self;
}

=for html <a name="clear_result"></a>

=head2 clear_result() : Bivio::IO::Format

Clears the contents of the result.

Returns self.

=cut

sub clear_result {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{result} = '';
    return $self;
}

=for html <a name="get_result"></a>

=head2 get_result() : string_ref

Returns the internal value of the result by reference.  B<DO NOT MODIFY.>

=cut

sub get_result {
    my($fields) = shift->[$_IDI];
    return \$fields->{result};
}

=for html <a name="process"></a>

=head2 process() : Bivio::IO::Format

Execute one iteration of the formats and append to result.

Returns self.

=cut

sub process {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    # We'll check for top here...
    local($^A);
    my($delete_blank_lines) = $self->get_or_default('delete_blank_lines', 0);
    my($res);
    foreach my $l (@{$fields->{lines}}) {
	$^A = '';
	# Dynamically generate the formline, because we are passed the values
	# by reference and formline takes scalars, not references.  To get the
	# proper behavior of caret (^>>>) fields, we have to pass the
	# dereferenced value in place due to formline's "by name" semantics.
	eval('formline($l->{format},'
		.join(',', map {'${$l->{args}->['.$_.']}'} 0..$#{$l->{args}})
		.')')
		|| die($@);
	$res .= $^A unless $delete_blank_lines && $^A =~ /^\s*$/s
		&& !$l->{is_blank};
    }
    my($lines) = _count_lines($res);
    return $self unless $lines;

    my($new_page) = _new_page($fields)
	    unless defined($fields->{line_num});
    _new_page($fields) if !$new_page && $lines + $fields->{line_num} > $=;
    $fields->{line_num} += $lines;
    $fields->{result} .= $res;
    return $self;
}

=for html <a name="put_top"></a>

=head2 put_top(string top) : Bivio::IO::Format

This is the string to write at the top of pages.  If not set, will
put nothing.

Returns self.

=cut

sub put_top {
    my($self, $top) = @_;
    my($fields) = $self->[$_IDI];
    _append_newline(\$top);
    $fields->{top} = $^L.$top;
    $fields->{top_line_count} = _count_lines($top);
    return $self;
}

#=PRIVATE METHODS

# _append_newline(string_ref s)
#
# Appends a newline if $s doesn't end in one.
#
sub _append_newline {
    my($s) = @_;
    $$s .= "\n" unless $$s =~ /\n$/s;
    return;
}

# _count_lines(string s) : int
#
# Returns number of lines in s.
#
sub _count_lines {
    my($s) = @_;
    return $s =~ tr/\n//;
}

# _new_page(hash_ref fields) : boolean
#
# Generate the top header and reset the line number.
# Always returns true.
#
sub _new_page {
    my($fields) = @_;
    $fields->{line_num} = $fields->{top_line_count};
    $fields->{result} .= $fields->{top};
    return 1;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
