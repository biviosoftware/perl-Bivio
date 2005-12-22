# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
package Bivio::Util::CSV;
use strict;
$Bivio::Util::CSV::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::CSV::VERSION;

=head1 NAME

Bivio::Util::CSV - manipulate csv files

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Util::CSV;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Util::CSV::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Util::CSV> manipulates csv files.

=cut


=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

See below

=cut

sub USAGE {
    return <<'EOF';
usage: b-csv [options] command [args...]
commands:
    colrm start [end] -- removes columns like colrm command
EOF
}

#=IMPORTS

#=VARIABLES
my($_QUOTE) = '"';
my($_END_OF_VALUE) = qr/,|\r|\n/o;
my($_END_OF_LINE) = qr/\r|\n/o;

=head1 METHODS

=cut

=for html <a name="colrm"></a>

=head2 colrm(int start, int end) : string_ref

Reads I<input> and deletes columns starting at I<start> and ending at I<end>
(or end of file).  Currently sucks entire file into memory, which can be slow.

=cut

sub colrm {
    my($self, $start, $end) = @_;
    $self->usage_error($start, ": bad start")
	unless $start =~ /^\d+$/;
    $self->usage_error($end, ": bad end")
	unless !defined($end) || $end =~ /^\d+$/;
    my($res);
    foreach my $line (split(/\n/, ${$self->read_input})) {
	$self->usage_error("quoted text not supported") if $line =~ /"/;
	my(@l) = split(/,/, $line);
        defined($end) ? splice(@l, $start, $end) : splice(@l, $start);
	$res .= join(',', @l)."\n";
    }
    return \$res;
}

=for html <a name="parse"></a>

=head2 static parse(string_ref csv_text) : array_ref

Parses the CSV text file into an array of array rows.
Embedded CR LF or CR values are converted to LF ("\n").
Dies on failure with an appropriate message.

=cut

sub parse {
    my($proto, $csv_text) = @_;
    $$csv_text .= "\n"
        unless $$csv_text =~ /(\r|\n)$/;
    my($state) = {
        buffer => $csv_text,
        char_count => 0,
        line_number => 0,
        current_value => '',
        rows => [],
        current_row => [],
    };

    while (defined(my $char = _next_char($state))) {

        if ($char eq $_QUOTE) {
            _die($state, 'quote character within unquoted value')
                if length($state->{current_value});

            while (defined($char = _next_char($state))) {

                if ($char eq $_QUOTE) {

                    if (_peek_char($state) eq $_QUOTE) {
                        _append_char($state, $char);
                        _next_char($state);
                    }
                    else {
                        _die($state,
                            'unexpected character after closing quote')
                            unless _peek_char($state) =~ $_END_OF_VALUE;
                        last;
                    }
                }
                elsif ($char =~ $_END_OF_LINE) {
                    _next_line($state, $char);
                    _append_char($state, "\n");
                }
                else {
                    _append_char($state, $char);
                }
            }
            _die($state, 'unterminated quoted value')
                unless defined($char);
        }
        elsif ($char =~ $_END_OF_VALUE) {
            _end_value($state);

            if ($char =~ $_END_OF_LINE) {
                _next_line($state, $char);
                _end_row($state);
            }
        }
        else {
            _append_char($state, $char);
        }
    }
    _die($state, 'unterminated input: "', $state->{current_value}, '"')
        if length($state->{current_value});
    return $state->{rows};
}

=for html <a name="to_csv_text"></a>

=head2 static to_csv_text(array_ref list) : string_ref

Converts a single row or a table of rows into CSV output.

=cut

sub to_csv_text {
    my($proto, $list) = @_;
    my($buffer) = '';

    if (@$list && ref($list->[0])) {
        $buffer = join('', map(${$proto->to_csv_text($_)}, @$list));
    }
    else {
        $buffer .= join(',', map(_to_csv($_), @$list)) . "\n";
    }
    return \$buffer;
}

#=PRIVATE METHODS

# _append_char(hash_ref state, string char)
#
# Appends a character to the current value.
#
sub _append_char {
    my($state, $char) = @_;
    $state->{current_value} .= $char;
    return;
}

# _die(hash_ref state, string message, ...)
#
# Dies with the specified message. Includes the line number.
#
sub _die {
    my($state, @mesesage) = @_;
    Bivio::Die->die('line: ', $state->{line_number} + 1, ' ', @mesesage);
}

# _end_value(hash_ref state)
#
# Ends the current parsed value.
#
sub _end_value {
    my($state) = @_;
    push(@{$state->{current_row}}, $state->{current_value});
    $state->{current_value} = '';
    return;
}

# _end_row(hash_ref state)
#
# Ends the current parsed row.
#
sub _end_row {
    my($state) = @_;
    push(@{$state->{rows}}, $state->{current_row});
    $state->{current_row} = [];
    return;
}

# _peek_char(hash_ref state) : string
#
# Return the next character without advancing.
#
sub _peek_char {
    my($state) = @_;
    return substr(${$state->{buffer}}, $state->{char_count}, 1);
}

# _next_char(hash_ref state) : string
#
# Returns the next character, or undef if at the end of input.
#
sub _next_char {
    my($state) = @_;
    return $state->{char_count} > length(${$state->{buffer}})
        ? undef
        : substr(${$state->{buffer}}, $state->{char_count}++, 1);
}

# _next_line(hash_ref state, string char)
#
# Advances to the next line. Removes CR LF pair if present.
#
sub _next_line {
    my($state, $char) = @_;
    _next_char($state)
        if $char eq "\r" && _peek_char($state) eq "\n";
    $state->{line_number}++;
    return;
}

# _to_csv(string value) : string
#
# Returns the appropriate CSV output for the specified value.
# Escapes quotes.
# Quotes values with leading or trailing spaces, multiple lines, or
# embedded CSV characters.
# Undef values are represented as an empty string.
#
sub _to_csv {
    my($value) = @_;
    return '' unless defined($value);

    if ($value =~ /^\s/ || $value =~ /\s$/
        || $value =~ /$_QUOTE/ || $value =~ $_END_OF_VALUE) {
        $value =~ s/"/""/g;
        return '"' . $value . '"';
    }
    return $value;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
