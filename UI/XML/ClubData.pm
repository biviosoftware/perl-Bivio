# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::XML::ClubData;
use strict;
$Bivio::UI::XML::ClubData::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::XML::ClubData - dumps a club's data.

=head1 SYNOPSIS

    use Bivio::UI::XML::ClubData;
    Bivio::UI::XML::ClubData->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::XML::ClubData::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::XML::ClubData>

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Biz::Model::RealmOwner;
use Bivio::Type::ExportFileFormat;
use Bivio::UI::XML::Document;
use Bivio::UI::XML::Body;
use Bivio::UI::XML::Comment;
use Bivio::UI::XML::Element;
use Bivio::UI::XML::ListModelContent;
use Bivio::UI::XML::Prolog;
use Bivio::UI::XML::PropertyModelContent;
use Bivio::UI::XML::Strings;
use Bivio::Util;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

my($_GZ_TYPE_NAME) =
	Bivio::UI::XML::Strings::GZ_TYPE_NAME();
my($_UNCOMPRESSED_TYPE_NAME) =
	Bivio::UI::XML::Strings::UNCOMPRESSED_TYPE_NAME();
my($_ZIP_TYPE_NAME) = Bivio::UI::XML::Strings::ZIP_TYPE_NAME();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::XML::ClubData

Export club data.

=cut

sub new {
    my($self) = Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {
	format => undef
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute($req)



=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($document) = Bivio::UI::XML::Document->new();

    my($prolog) = Bivio::UI::XML::Prolog->new();
    $document->add_prolog($prolog);

    my($body) = Bivio::UI::XML::Body->new();
    $document->add_body($body);

    my($document_element) = Bivio::UI::XML::Element->new('Document_element');
    $body->add_document_element($document_element);

    # Add an info element that has some basic data.
    my($info) = Bivio::UI::XML::Element->new('Info');
    $document_element->add_child($info);

    my($version) = Bivio::UI::XML::Element->new('Version');
    $info->add_child($version);
    $version->add_text('1.00');

    my($vendor) = Bivio::UI::XML::Element->new('Vendor');
    $info->add_child($vendor);
    $vendor->add_text('bivio');

    my($timestamp) = Bivio::UI::XML::Element->new('Timestamp');
    $info->add_child($timestamp);
    my($sec, $min, $hour, $day, $month, $year) = (gmtime)[0..5];
    $timestamp->add_text(
	    sprintf("%02d/%02d/%04d %02d:%02d:%02d GMT", $month + 1, $day,
		    $year + 1900, $hour, $min, $sec));

    # Create an element that has club information.
    my($club_info) = Bivio::UI::XML::Element->new('club_info');
    $document_element->add_child($club_info);

    # Add some of the data from address_t to the club_info element.
    my($realm_data) = Bivio::UI::XML::PropertyModelContent->new(
	    $req, 'Bivio::Biz::Model::RealmOwner',
	    {
		name => 'name',
		display_name => 'display_name',
		creation_date_time => 'creation_date_time'
	    }, 'creation_date_time');
    $club_info->add_generated_children($realm_data);

    # Add some of the data from address_t to the club_info element.
    my($address) = Bivio::UI::XML::PropertyModelContent->new(
	    $req, 'Bivio::Biz::Model::Address',
	    {
		street1 => 'street1',
		street2 => 'street2',
		city => 'city',
		state => 'state',
		zip => 'zip',
		country => 'country'
	    }, 'location');
    $club_info->add_generated_children($address);

    # Add some of the data from phone_t to the club_info element.
    my($phone) = Bivio::UI::XML::PropertyModelContent->new(
	    $req, 'Bivio::Biz::Model::Phone',
	    {
		phone => 'phone'
	    }, 'phone');
    $club_info->add_generated_children($phone);

    # Add some of the data from tax_id_t to the club_info element.
    my($tax_id) = Bivio::UI::XML::PropertyModelContent->new(
	    $req, 'Bivio::Biz::Model::TaxId',
	    {
		tax_id => 'tax_id'
	    }, 'tax_id');
    $club_info->add_generated_children($tax_id);

    # Add some of the data from club_t to the club_info element.
    my($club) = Bivio::UI::XML::PropertyModelContent->new(
	    $req, 'Bivio::Biz::Model::Club',
	    {
		start_date => 'start_date',
	    }, 'start_date');
    $club_info->add_generated_children($club);

    # Add the club_data element that has the actual club data.
    my($club_data) = Bivio::UI::XML::Element->new('club_data');
    $document_element->add_child($club_data);

    # Add the data from realm_user_t and user_t to the club data as
    # members.
    my($realm_user) = Bivio::UI::XML::Element->new('members');
    $club_data->add_child($realm_user);
    my($realm_user_row) = Bivio::UI::XML::ListModelContent->new(
	    $req, 'Bivio::Biz::Model::AllMemberList',
	    {
		'RealmUser.user_id' => 'user_id',
		'RealmUser.role' => 'role',
		'User.first_name' => 'first_name',
		'User.middle_name' => 'middle_name',
		'User.last_name' => 'last_name',
	    }, 'member');
    $realm_user->add_child($realm_user_row);

    # Add the account data.
    my($account_data) = Bivio::UI::XML::Element->new('account_data');
    $club_data->add_child($account_data);

    # Add the data from realm_account_t to the account_data.
    my($realm_account) = Bivio::UI::XML::Element->new('realm_accounts');
    $account_data->add_child($realm_account);
    my($realm_account_row) = Bivio::UI::XML::PropertyModelContent->new(
	    $req, 'Bivio::Biz::Model::RealmAccount',
	    {
		realm_account_id => 'realm_account_id',
		name => 'name',
		tax_free => 'tax_free',
		in_valuation => 'in_valuation',
		institution_id => 'institution_id',
		account_number => 'account_number',
		external_password => 'external_password'
	    }, 'name', 'realm_account');
    $realm_account->add_child($realm_account_row);

    # Add the data from realm_account_entry_t to the account_data.
    my($realm_account_entry) =
	    Bivio::UI::XML::Element->new('realm_account_entrys');
    $account_data->add_child($realm_account_entry);
    my($realm_account_entry_row) = Bivio::UI::XML::PropertyModelContent->new(
	    $req, 'Bivio::Biz::Model::RealmAccountEntry',
	    {
		entry_id => 'entry_id',
		realm_account_id => 'realm_account_id',
	    }, 'entry_id', 'realm_account_entry');
    $realm_account_entry->add_child($realm_account_entry_row);

    # Add the data from entry_t to the account_data.
    my($entry) = Bivio::UI::XML::Element->new('entrys');
    $account_data->add_child($entry);
    my($entry_row) = Bivio::UI::XML::PropertyModelContent->new(
	    $req, 'Bivio::Biz::Model::Entry',
	    {
		entry_id => 'entry_id',
		realm_transaction_id => 'realm_transaction_id',
		class => 'class',
		entry_type => 'entry_type',
		tax_category => 'tax_category',
		tax_basis => 'tax_basis',
		amount => 'amount'
	    }, 'entry_id', 'entry');
    $entry->add_child($entry_row);

    # Add the data from member_entry_t to the account_data.
    my($member_entry) = Bivio::UI::XML::Element->new('member_entrys');
    $account_data->add_child($member_entry);
    my($member_entry_row) = Bivio::UI::XML::PropertyModelContent->new(
	    $req, 'Bivio::Biz::Model::MemberEntry',
	    {
		entry_id => 'entry_id',
		user_id => 'user_id',
		units => 'units',
		valuation_date => 'valuation_date'
	    }, 'valuation_date', 'member_entry');
    $member_entry->add_child($member_entry_row);

    # Add the data from realm_transaction_t to the account_data.
    my($realm_transaction) =
	    Bivio::UI::XML::Element->new('realm_transactions');
    $account_data->add_child($realm_transaction);
    my($realm_transaction_row) = Bivio::UI::XML::PropertyModelContent->new(
	    $req, 'Bivio::Biz::Model::RealmTransaction',
	    {
		realm_transaction_id => 'realm_transaction_id',
		source_class => 'source_class',
		date_time => 'date_time',
		user_id => 'user_id',
		remark => 'remark',
		broker_code => 'broker_code'
	    }, 'date_time', 'realm_transaction');
    $realm_transaction->add_child($realm_transaction_row);

    # Add the data from realm_instrument_t to the account_data.
    my($realm_instrument) = Bivio::UI::XML::Element->new('realm_instruments');
    $account_data->add_child($realm_instrument);
    my($realm_instrument_row) = Bivio::UI::XML::PropertyModelContent->new(
	    $req, 'Bivio::Biz::Model::RealmInstrument',
	    {
		realm_instrument_id => 'realm_instrument_id',
		instrument_id => 'instrument_id',
		account_number => 'account_number',
		average_cost_method => 'average_cost_method',
		drp_plan => 'drp_plan',
		remark => 'remark',
		name => 'name',
		ticker_symbol => 'ticker_symbol',
		exchange_name => 'exchange_name',
		instrument_type => 'instrument_type',
		fed_tax_free => 'fed_tax_free',
		country => 'country'
	    }, 'instrument_type', 'realm_instrument');
    $realm_instrument->add_child($realm_instrument_row);

    # Add the data from realm_instrument_entry_t to the account_data.
    my($realm_instrument_entry) =
	    Bivio::UI::XML::Element->new('realm_instrument_entrys');
    $account_data->add_child($realm_instrument_entry);
    my($realm_instrument_entry_row) =
	    Bivio::UI::XML::PropertyModelContent->new(
	    $req, 'Bivio::Biz::Model::RealmInstrumentEntry',
	    {
		entry_id => 'entry_id',
		realm_instrument_id => 'realm_instrument_id',
		count => 'count',
		external_identifier => 'external_identifier',
		acquisition_date => 'acquisition_date'
	    }, 'acquisition_date', 'realm_instrument_entry');
    $realm_instrument_entry->add_child($realm_instrument_entry_row);

    # Add the data from realm_instrument_valuation_t to the account_data.
    my($realm_instrument_valuation) =
	    Bivio::UI::XML::Element->new('realm_instrument_valuations');
    $account_data->add_child($realm_instrument_valuation);
    my($realm_instrument_valuation_row) =
	    Bivio::UI::XML::PropertyModelContent->new(
	    $req, 'Bivio::Biz::Model::RealmInstrumentValuation',
	    {
		realm_instrument_id => 'realm_instrument_id',
		date_time => 'date_time',
		price_per_share => 'price_per_share'
	    }, 'date_time', 'realm_instrument_valuation');
    $realm_instrument_valuation->add_child($realm_instrument_valuation_row);

    # Add the data from tax_1065_t and tax_k1_t to the account_data.
    my($tax) =
	    Bivio::UI::XML::Element->new('tax');
    $account_data->add_child($tax);
    my($tax_1065_row) =
	    Bivio::UI::XML::PropertyModelContent->new(
	    $req, 'Bivio::Biz::Model::Tax1065',
	    {
		fiscal_end_date => 'fiscal_end_date',
		partnership_type => 'partnership_type',
		partner_is_partnership => 'partner_is_partnership',
		consolidated_audit => 'consolidated_audit',
		publicly_traded => 'publicly_traded',
		tax_shelter => 'tax_shelter',
		foreign_account_country => 'foreign_account_country',
		foreign_trust => 'foreign_trust',
		return_type => 'return_type',
		irs_center => 'irs_center',
		allocation_method => 'allocation_method',
		draft => 'draft',
	    }, 'fiscal_end_date', 'tax_1065');
    $tax->add_child($tax_1065_row);

    my($tax_k1_row) =
	    Bivio::UI::XML::PropertyModelContent->new(
	    $req, 'Bivio::Biz::Model::TaxK1',
	    {
		user_id => 'user_id',
		fiscal_end_date => 'fiscal_end_date',
		entity_type => 'entity_type',
		partner_type => 'partner_type',
		foreign_partner => 'foreign_partner',
	    }, 'user_id', 'tax_k1');
    $tax->add_child($tax_k1_row);

    # Create all the XML text.  Call with initial indent string.
    my($xml_text_ref) = $document->emit_xml_text('');

    # Get the name of the file from the uri.
    my($file_name) = $req->get('uri');
    # Get rid of the path part.
    $file_name =~ s(.*/)();
    # Get rid of the extension.
    $file_name =~ s(\..*$)();

    my($reply) = $req->get('reply');

    # Determine what output file format to use.
    my($format_name) = $fields->{format}->get_name();
    if ($_ZIP_TYPE_NAME eq $format_name) {
	# We want to name the file we zip $file_name.xml, but there may
	# be more than one task doing this at the same time, so create a
	# directory in /tmp of the form
	#	<club id (max 10 characters)><value returned by time>
	# and create $file_name.xml in that directory.
	my($dir_name) = '/tmp/';
	$dir_name .= substr($req->get_widget_value('auth_realm',
		'owner', 'name'), 0, 10);
	$dir_name .= time();
	unless (mkdir($dir_name, 0700)) {
		Bivio::IO::Alert->die("Error creating '", $dir_name);
	}
	open(TMP_FILE, ">$dir_name/$file_name.xml") or
		Bivio::IO::Alert->die("Error opening tmp file");
	print(TMP_FILE ${$xml_text_ref});
	close(TMP_FILE) or
		Bivio::IO::Alert->die("Error closing tmp file");
	system("cd $dir_name; zip -j $file_name.zip $file_name.xml");
	open(ZIP_FILE, "/$dir_name/$file_name.zip") or
		Bivio::IO::Alert->die("Error opening zip file");
	$/ = undef;
	my($zip_file) = <ZIP_FILE>;
	close(ZIP_FILE) or
		Bivio::IO::Alert->die("Error closing zip file");

	# Remove temporary files.
	unless (1 == unlink("$dir_name/$file_name.zip")) {
		Bivio::IO::Alert->die("Error unlinking tmp zip file");
	}
	unless (1 == unlink("$dir_name/$file_name.xml")) {
		Bivio::IO::Alert->die("Error unlinking tmp xml file");
	}
	unless (rmdir("$dir_name")) {
		Bivio::IO::Alert->die("Error removing '", $dir_name);
	}

	$xml_text_ref = \$zip_file;
	$reply->set_output_type('application/zip');
    }
    elsif ($_UNCOMPRESSED_TYPE_NAME eq $format_name) {
	$reply->set_output_type('text/xml');
    }
    elsif ($_GZ_TYPE_NAME eq $format_name) {
	$reply->set_output_type('application/x-gzip');
	$xml_text_ref = Bivio::Util::shell('/usr/bin/gzip --best',
		$xml_text_ref);
    }
    else {
	Bivio::IO::Alert->die("Unexpected format name '", $format_name,
		"'");
    }

    $reply->set_output($xml_text_ref);

    return;
}

=for html <a name="gz"></a>

=head2 gz($req)



=cut

sub gz {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{format} =
	    Bivio::Type::ExportFileFormat->from_name($_GZ_TYPE_NAME);
    $self->execute($req);
    return;
}

=for html <a name="uncompressed"></a>

=head2 uncompressed($req)



=cut

sub uncompressed {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{format} =
	    Bivio::Type::ExportFileFormat->from_name($_UNCOMPRESSED_TYPE_NAME);
    $self->execute($req);
    return;
}

=for html <a name="zip"></a>

=head2 zip($req)



=cut

sub zip {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{format} =
	    Bivio::Type::ExportFileFormat->from_name($_ZIP_TYPE_NAME);
    $self->execute($req);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
