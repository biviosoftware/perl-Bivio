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
my($_END_OF_VALUE) = qr/[\,\r\n]/o;
my($_END_OF_LINE) = qr/[\r\n]/o;

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

=head2 parse() : array_ref

=head2 parse(string_ref csv_text) : array_ref

=head2 parse(string_ref csv_text, boolean want_line_numbers) : array_ref

Parses I<csv_text> into an array of array rows. if I<csv_text> not supplied,
read_input is called.  I<csv_text> may also be a string (need not be a ref).

Dies on failure with an appropriate message.

If I<want_line_numbers> is specified, then the first item of each row
will contain the line number from the input text.

=cut

sub parse {
    my($self, $csv_text, $want_line_numbers) = @_;
    my($buf) = !defined($csv_text) ? $self->read_input
	: ref($csv_text) ? $csv_text : \$csv_text;
    my($state) = {
        buffer => $buf,
        want_line_numbers => $want_line_numbers,
        char_count => 0,
        line_number => 1,
        current_value => '',
        rows => [],
        current_row => [$want_line_numbers ? 1 : ()],
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

    # add last row if input is missing end-of-line
    if (length($state->{current_value})
        || scalar(@{$state->{current_row}}) > ($want_line_numbers ? 1 : 0)) {
        _end_value($state);
        _end_row($state);
    }

    # remove leading and trailing empty rows
    while (scalar(@{$state->{rows}})) {
        last if _is_row_empty($state, -1);
        pop(@{$state->{rows}});
    }

    while (scalar(@{$state->{rows}})) {
        last if _is_row_empty($state, 0);
        shift(@{$state->{rows}});
    }
    return $state->{rows};
}

=for html <a name="parse_records"></a>

=head2 parse_records() : array_ref

=head2 parse_records(string_ref csv_text) : array_ref

Parses the CSV data, treating the first row as headings and returns
an array of hash_ref records.

=cut

sub parse_records {
    my($self) = @_;
    my($rows) = shift->parse(@_);
    return $rows unless @$rows;
    my($heading) = shift(@$rows);
    return [
        map({
            my($row) = $_;
            +{
                map(($_, shift(@$row)), @$heading),
            };
        } @$rows),
    ];
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
    Bivio::Die->die('line: ', $state->{line_number}, ' ', @mesesage);
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
    $state->{current_row} = [
        $state->{want_line_numbers} ? $state->{line_number} : ()];
    return;
}

# _is_row_empty(hash_ref state, int index) : boolean
#
# Returns true if the row is empty, or contains a single entry composed
# of space.
#
sub _is_row_empty {
    my($state, $index) = @_;
    return scalar(@{$state->{rows}->[$index]})
            > ($state->{want_line_numbers} ? 2 : 1)
        || $state->{rows}->[$index]->[$state->{want_line_numbers} ? 1 : 0]
            =~ /\S/
        ? 1 : 0;
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
