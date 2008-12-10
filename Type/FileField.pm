# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::FileField;
use strict;
use Bivio::Base 'Bivio::Type';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_T) = b_use('Type.Text');
my($_RF) = b_use('Model.RealmFile');
my($_TE) = b_use('Bivio.TypeError');
my($_FP) = b_use('Type.FilePath');
my($_F) = b_use('IO.File');

sub from_string_ref {
    return shift->from_literal({
	content => shift,
	filename => shift || '',
	content_type => shift || 'application/octet-stream',
    });
}

sub from_disk {
    my($v, $e) = shift->unsafe_from_disk(@_);
    return $v
	if $v;
    my(undef, $file_name) = @_;
    b_use($file_name, ': invalid disk file: ' , $e || $_TE->NULL);
    # DOES NOT RETURN
}

sub from_literal {
    my($proto, $value) = @_;
    $proto->internal_from_literal_warning
        unless wantarray;
    return (undef, undef)
	unless defined($value);
    unless (ref($value) eq 'HASH') {
	return (undef, $_TE->FILE_FIELD)
	    if length($value);
	return (undef, undef);
    }
    return $value
	if length(${$value->{content}});
    return (undef, undef)
	unless $value->{filename};
    return (undef, $_TE->NOT_FOUND)
	unless $value->{content_type};
    return (undef, $_TE->EMPTY);
}

sub from_sql_column {
    die("can't convert a FileField from sql");
}

sub get_width {
    return $_T->get_width;
}

#TODO: Make an object with hashlooks working in deprecated mode
# sub new {
#     my($self) = shift->SUPER::new(@_);
#     $self->[$_IDI] = {
#     };
#     return $self;
# }

sub to_literal {
    my(undef, $value) = @_;
    return ref($value) eq 'HASH' && defined($value->{filename})
	? $value->{filename} : '';
}

sub to_query {
    die("can't convert a FileField to a query");
}

sub to_uri {
    die("can't convert a FileField to a uri");
}

sub unsafe_from_disk {
    my($proto, $value) = @_;
    return (undef, undef)
	unless defined($value) && length($value);
    return $proto->use('IO.Ref')->nested_copy($value)
	if ref($value) eq 'HASH'
	&& grep(exists($value->{$_}), qw(filename content content_type)) == 3
	&& ref($value->{content}) eq 'SCALAR';
    return (undef, $_TE->NOT_FOUND)
	unless -r $value && !(-d _);
    return {
	filename => $_FP->get_tail($value),
	content_type => $_RF->get_content_type_for_path($value),
        content => $_F->read($value),
    };
}

1;
