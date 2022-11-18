# Copyright (c) 2001-2009 bivio Software, Inc.  All Rights reserved.
# $Id$
package Bivio::Util::CSV;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use POSIX ();

my($_QUOTE) = '"';
my($_END_OF_VALUE) = qr/[\,\n]/;
my($_END_OF_LINE) = qr/\n/;
my($_TA) = b_use('Type.TextArea');

sub USAGE {
    return <<'EOF';
usage: b-csv [options] command [args...]
commands:
    colrm start [end] -- removes columns like colrm command
    from_one_col value -- quotes a value if necessary
    from_one_row array_ref -- converts an array to a quoted row
    from_rows array_ref -- converts an array of arrays
    parse [text.csv [want_line_numbers]] -- returns array of arrays
    parse_records [text.csv [want_line_numbers]] -- returns array of hashes
    sort_csv -- returns sorted csv from input csv
    to_csv_text array -- returns text from array
EOF
}

sub colrm {
    my($self, $start, $end) = @_;
    # Reads I<input> and deletes columns starting at I<start> and ending at I<end>
    # (or end of file).  Currently sucks entire file into memory, which can be slow.
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

sub from_one_col {
    my(undef, $col) = @_;
    return '' unless defined($col);
    return $col
        unless $col =~ /(?:^\s|\s$|$_QUOTE|$_END_OF_VALUE|\r)/;
    $col =~ s/"/""/g;
    return qq{"$col"};
}

sub from_one_row {
     my($proto, $row) = @_;
     return \(join(',', map($proto->from_one_col($_), @$row)) . "\n");
}

sub from_rows {
     my($proto, $rows) = @_;
     return \(join('', map(${$proto->from_one_row($_)}, @$rows)));
}

sub parse {
    my($self, $csv_text, $want_line_numbers) = @_;
    # Parses I<csv_text> into an array of array rows. if I<csv_text> not supplied,
    # read_input is called.  I<csv_text> may also be a string (need not be a ref).
    #
    # Dies on failure with an appropriate message.
    #
    # If I<want_line_numbers> is specified, then the first item of each row
    # will contain the line number from the input text.
    my($state) = {
        buffer => $_TA->canonicalize_newlines(
            !defined($csv_text) ? $self->read_input
                : ref($csv_text) ? $csv_text
                : _assert_csv_text($self, $csv_text),
        ),
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
                    _next_line($state);
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
                _next_line($state);
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
        last unless _is_row_empty($state, -1);
        pop(@{$state->{rows}});
    }

    while (scalar(@{$state->{rows}})) {
        last unless _is_row_empty($state, 0);
        shift(@{$state->{rows}});
    }
    return $state->{rows};
}

sub parse_records {
    my($self, undef, $want_line_numbers, $heading_ref) = @_;
    # Parses the CSV data, treating the first row as headings and returns
    # an array of hash_ref records.
    my($rows) = shift->parse(@_);
    return $rows unless @$rows;
    my($heading) = shift(@$rows);
    @$heading_ref = @$heading
        if $heading_ref;
    $heading->[0] = '_line'
        if $want_line_numbers;
    return [
        map({
            my($row) = $_;
            +{
                map(($_, shift(@$row)), @$heading),
            };
        } @$rows),
    ];
}

sub sort_csv {
    my($self, $csv_text) = @_;
    my($headings) = [];
    my($rows) = $self->parse_records($csv_text, 0, $headings);
    my($h0) = $headings->[0];
    return join('',
        ${$self->to_csv_text($headings)},
        map({
            my($row) = $_;
            ${$self->to_csv_text([map($row->{$_}, @$headings)])};
        } sort({POSIX::strcoll($a->{$h0}, $b->{$h0})} @$rows)),
    );
}

sub to_csv_text {
    my($proto, $list) = @_;
    my($method) = @$list && ref($list->[0]) ? 'from_rows' : 'from_one_row';
    return $proto->$method($list);
}

sub _append_char {
    my($state, $char) = @_;
    # Appends a character to the current value.
    $state->{current_value} .= $char;
    return;
}

sub _assert_csv_text {
    my($self, $csv_text) = @_;
    $self->usage_error($csv_text, ': must be CSV, not file name')
        unless $csv_text =~ m{\n} || $csv_text !~ m{/};
    return \$csv_text;
}

sub _die {
    my($state, @mesesage) = @_;
    # Dies with the specified message. Includes the line number.
    Bivio::Die->die('line: ', $state->{line_number}, ' ', @mesesage);
}

sub _end_row {
    my($state) = @_;
    # Ends the current parsed row.
    push(@{$state->{rows}}, $state->{current_row});
    $state->{current_row} = [
        $state->{want_line_numbers} ? $state->{line_number} : ()];
    return;
}

sub _end_value {
    my($state) = @_;
    # Ends the current parsed value.
    push(@{$state->{current_row}}, $state->{current_value});
    $state->{current_value} = '';
    return;
}

sub _is_row_empty {
    my($state, $index) = @_;
    # Returns true if the row is empty, or contains a single entry composed
    # of space.
    return scalar(@{$state->{rows}->[$index]})
            > ($state->{want_line_numbers} ? 2 : 1)
        || $state->{rows}->[$index]->[$state->{want_line_numbers} ? 1 : 0]
            =~ /\S/
        ? 0 : 1;
}

sub _next_char {
    my($state) = @_;
    # Returns the next character, or undef if at the end of input.
    return $state->{char_count} > length(${$state->{buffer}})
        ? undef
        : substr(${$state->{buffer}}, $state->{char_count}++, 1);
}

sub _next_line {
    my($state) = @_;
    $state->{line_number}++;
    return;
}

sub _peek_char {
    my($state) = @_;
    # Return the next character without advancing.
    return substr(${$state->{buffer}}, $state->{char_count}, 1);
}


1;
