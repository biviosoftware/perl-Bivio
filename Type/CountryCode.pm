# Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::CountryCode;
use strict;
$Bivio::Type::CountryCode::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::CountryCode::VERSION;

=head1 NAME

Bivio::Type::CountryCode - county codes

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::CountryCode;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::CountryCode::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::CountryCode>

=cut

#=IMPORTS

#=VARIABLES

__PACKAGE__->compile([
    UNKNOWN => [
	0,
	'Select Country',
    ],
    AF => [
	1,
	'Afghanistan',
    ],
    AL => [
	2,
	'Albania'
    ],
    DZ => [
	3,
	'Algeria',
    ],
    AS => [
	4,
	'American Samoa',
    ],
    AD => [
	5,
	'Andorra',
    ],
    AO => [
	6,
	'Angola',
    ],
    AI => [
	7,
	'Anguilla',
    ],
    AQ => [
	8,
	'Antarctica',
    ],
    AG => [
	9,
	'Antigua and Barbuda',
    ],
    AR => [
	10,
	'Argentina',
    ],
    AM => [
	11,
	'Armenia',
    ],
    AW => [
	12,
	'Aruba',
    ],
    AU => [
	13,
	'Australia',
    ],
    AT => [
	14,
	'Austria',
    ],
    AZ => [
	15,
	'Azerbaijan',
    ],
    BS => [
	16,
	'Bahamas',
    ],
    BH => [
	17,
	'Bahrain',
    ],
    BD => [
	18,
	'Bangladesh',
    ],
    BB => [
	19,
	'Barbados',
    ],
    BY => [
	20,
	'Belarus',
    ],
    BE => [
	21,
	'Belgium',
    ],
    BZ => [
	22,
	'Belize',
    ],
    BJ => [
	23,
	'Benin',
    ],
    BM => [
	24,
	'Bermuda',
    ],
    BT => [
	25,
	'Bhutan',
    ],
    BO => [
	26,
	'Bolivia',
    ],
    BA => [
	27,
	'Bosnia-Herzegovina',
    ],
    BW => [
	28,
	'Botswana',
    ],
    BV => [
	29,
	'Bouvet Island',
    ],
    BR => [
	30,
	'Brazil',
    ],
    IO => [
	31,
	'British Indian Ocean Territory',
    ],
    BN => [
	32,
	'Brunei Darussalam',
    ],
    BG => [
	33,
	'Bulgaria',
    ],
    BF => [
	34,
	'Burkina Faso',
    ],
    BI => [
	35,
	'Burundi',
    ],
    KH => [
	36,
	'Cambodia',
    ],
    CM => [
	37,
	'Cameroon',
    ],
    CA => [
	38,
	'Canada',
    ],
    CV => [
	39,
	'Cape Verde',
    ],
    KY => [
	40,
	'Cayman Islands',
    ],
    CF => [
	41,
	'Central African Republic',
    ],
    TD => [
	42,
	'Chad',
    ],
    CL => [
	43,
	'Chile',
    ],
    CN => [
	44,
	'China',
    ],
    CX => [
	45,
	'Christmas Island',
    ],
    CC => [
	46,
	'Cocos (Keeling) Islands',
    ],
    CO => [
	47,
	'Colombia',
    ],
    KM => [
	48,
	'Comoros',
    ],
    CG => [
	49,
	'Congo',
    ],
    CK => [
	50,
	'Cook Islands',
    ],
    CR => [
	51,
	'Costa Rica',
    ],
    CI => [
	52,
	"Cote d'Ivoire",
    ],
    HR => [
	53,
	'Croatia',
    ],
    CU => [
	54,
	'Cuba',
    ],
    CY => [
	55,
	'Cyprus',
    ],
    CZ => [
	56,
	'Czech Republic',
    ],
    DK => [
	57,
	'Denmark',
    ],
    DJ => [
	58,
	'Djibouti',
    ],
    DM => [
	59,
	'Dominica',
    ],
    DO => [
	60,
	'Dominican Republic',
    ],
    TP => [
	61,
	'East Timor',
    ],
    EC => [
	62,
	'Ecuador',
    ],
    EG => [
	63,
	'Egypt',
    ],
    SV => [
	64,
	'El Salvador',
    ],
    GQ => [
	65,
	'Equatorial Guinea',
    ],
    ER => [
	66,
	'Eritrea',
    ],
    EE => [
	67,
	'Estonia',
    ],
    ET => [
	68,
	'Ethiopia',
    ],
    FK => [
	69,
	'Falkland Islands',
    ],
    FO => [
	70,
	'Faroe Islands',
    ],
    FJ => [
	71,
	'Fiji',
    ],
    FI => [
	72,
	'Finland',
    ],
    FR => [
	73,
	'France',
    ],
    GF => [
	74,
	'French Guiana',
    ],
    PF => [
	75,
	'French Polynesia',
    ],
    TF => [
	76,
	'French Southern Territories',
    ],
    GA => [
	77,
	'Gabon',
    ],
    GM => [
	78,
	'Gambia',
    ],
    'GE' => [
	79,
	'Georgia',
    ],
    DE => [
	80,
	'Germany',
    ],
    GH => [
	81,
	'Ghana',
    ],
    GI => [
	82,
	'Gibraltar',
    ],
    GR => [
	83,
	'Greece',
    ],
    GL => [
	84,
	'Greenland',
    ],
    GD => [
	85,
	'Grenada',
    ],
    GP => [
	86,
	'Guadeloupe',
    ],
    GU => [
	87,
	'Guam',
    ],
    'GT' => [
	88,
	'Guatemala',
    ],
    GN => [
	89,
	'Guinea',
    ],
    GW => [
	90,
	'Guinea-Bissau',
    ],
    GY => [
	91,
	'Guyana',
    ],
    HT => [
	92,
	'Haiti',
    ],
    HM => [
	93,
	'Heard and McDonald Islands',
    ],
    HN => [
	94,
	'Honduras',
    ],
    HK => [95,
	'Hong Kong',
    ],
    HU => [
	96,
	'Hungary',
    ],
    IS => [
	97,
	'Iceland',
    ],
    IN => [
	98,
	'India',
    ],
    ID => [
	99,
	'Indonesia',
    ],
    IR => [
	100,
	'Iran',
    ],
    IQ => [
	101,
	'Iraq',
    ],
    IE => [
	102,
	'Ireland',
    ],
    IL => [
	103,
	'Israel',
    ],
    IT => [
	104,
	'Italy',
    ],
    JM => [
	105,
	'Jamaica',
    ],
    JP => [
	106,
	'Japan',
    ],
    JO => [
	107,
	'Jordan',
    ],
    KZ => [
	108,
	'Kazakhstan',
    ],
    KE => [
	109,
	'Kenya',
    ],
    KI => [
	110,
	'Kiribati',
    ],
    KP => [
	111,
	'North Korea',
    ],
    KR => [
	112,
	'Korea, South',
    ],
    KW => [
	113,
	'Kuwait',
    ],
    KG => [
	114,
	'Kyrgyzstan',
    ],
    LA => [
	115,
	'Laos',
    ],
    LV => [
	116,
	'Latvia',
    ],
    LB => [
	117,
	'Lebanon',
    ],
    LS => [
	118,
	'Lesotho',
    ],
    LR => [
	119,
	'Liberia',
    ],
    LY => [
	120,
	'Libya',
    ],
    LI => [
	121,
	'Liechtenstein',
    ],
    'LT' => [
	122,
	'Lithuania',
    ],
    LU => [
	123,
	'Luxembourg',
    ],
    MO => [
	124,
	'Macau',
    ],
    MK => [
	125,
	'Macedonia',
    ],
    MG => [
	126,
	'Madagascar',
    ],
    MW => [
	127,
	'Malawi',
    ],
    MY => [
	128,
	'Malaysia',
    ],
    MV => [
	129,
	'Maldives',
    ],
    ML => [
	130,
	'Mali',
    ],
    MT => [
	131,
	'Malta',
    ],
    MH => [
	132,
	'Marshall Islands',
    ],
    MQ => [
	133,
	'Martinique',
    ],
    MR => [
	134,
	'Mauritania',
    ],
    MU => [
	135,
	'Mauritius',
    ],
    YT => [
	136,
	'Mayotte',
    ],
    MX => [
	137,
	'Mexico',
    ],
    FM => [
	138,
	'Micronesia',
    ],
    MD => [
	139,
	'Moldova',
    ],
    MC => [
	140,
	'Monaco',
    ],
    MN => [
	141,
	'Mongolia',
    ],
    MS => [
	142,
	'Montserrat',
    ],
    MA => [
	143,
	'Morocco',
    ],
    MZ => [
	144,
	'Mozambique',
    ],
    MM => [
	145,
	'Myanmar',
    ],
    NA => [
	146,
	'Namibia',
    ],
    NR => [
	147,
	'Nauru',
    ],
    NP => [
	148,
	'Nepal',
    ],
    NL => [
	149,
	'Netherlands',
    ],
    AN => [
	150,
	'Netherlands Antilles',
    ],
    NT => [
	151,
	'Neutral Zone',
    ],
    NC => [
	152,
	'New Caledonia',
    ],
    NZ => [
	153,
	'New Zealand',
    ],
    NI => [
	154,
	'Nicaragua',
    ],
    'NE' => [
	155,
	'Niger',
    ],
    NG => [
	156,
	'Nigeria',
    ],
    NU => [
	157,
	'Niue',
    ],
    NF => [
	158,
	'Norfolk Island',
    ],
    MP => [
	159,
	'Northern Mariana Islands',
    ],
    NO => [
	160,
	'Norway',
    ],
    OM => [
	161,
	'Oman',
    ],
    PK => [
	162,
	'Pakistan',
    ],
    PW => [
	163,
	'Palau',
    ],
    PA => [
	164,
	'Panama',
    ],
    PG => [
	165,
	'Papua New Guinea',
    ],
    PY => [
	166,
	'Paraguay',
    ],
    PE => [
	167,
	'Peru',
    ],
    PH => [
	168,
	'Philippines',
    ],
    PN => [
	169,
	'Pitcairn',
    ],
    PL => [
	170,
	'Poland',
    ],
    PT => [
	171,
	'Portugal',
    ],
    PR => [
	172,
	'Puerto Rico',
    ],
    QA => [
	173,
	'Qatar',
    ],
    RE => [
	174,
	"Re'union",
    ],
    RO => [
	175,
	'Romania',
    ],
    RU => [
	176,
	'Russia',
    ],
    RW => [
	177,
	'Rwanda',
    ],
    SH => [
	178,
	'Saint Helena',
    ],
    KN => [
	179,
	'Saint Kitts and Nevis',
    ],
    LC => [
	180,
	'Saint Lucia',
    ],
    PM  => [
	181,
	'Saint Pierre and Miquelon',
    ],
    VC => [
	182,
	'Saint Vincent and the Grenadines',
    ],
    WS => [
	183,
	'Samoa',
    ],
    SM => [
	184,
	'San Marino',
    ],
    ST => [
	185,
	'Sao Tome and Principe',
    ],
    SA => [
	186,
	'Saudi Arabia',
    ],
    SN => [187,
	'Senegal',
    ],
    SC => [
	188,
	'Seychelles',
    ],
    SL => [
	189,
	'Sierra Leone',
    ],
    SG => [
	190,
	'Singapore',
    ],
    SK => [
	191,
	'Slovakia',
    ],
    SI => [
	192,
	'Slovenia',
    ],
    SB => [
	193,
	'Solomon Islands',
    ],
    SO => [
	194,
	'Somalia',
    ],
    ZA => [
	195,
	'South Africa',
    ],
    ES => [
	196,
	'Spain',
    ],
    LK => [
	197,
	'Sri Lanka',
    ],
    SD => [
	198,
	'Sudan',
    ],
    SR => [
	199,
	'Suriname',
    ],
    SJ => [
	200,
	'Svalbard and Jan Mayen Islands',
    ],
    SZ => [
	201,
	'Swaziland',
    ],
    SE => [
	202,
	'Sweden',
    ],
    CH => [
	203,
	'Switzerland',
    ],
    SY => [
	204,
	'Syria',
    ],
    TW => [
	205,
	'Taiwan',
    ],
    TJ => [
	206,
	'Tajikistan',
    ],
    TZ => [
	207,
	'Tanzania',
    ],
    TH => [
	208,
	'Thailand',
    ],
    TG => [
	209,
	'Togo',
    ],
    TK => [
	210,
	'Tokelau',
    ],
    TO => [
	211,
	'Tonga',
    ],
    TT => [
	212,
	'Trinidad and Tobago',
    ],
    TN => [
	213,
	'Tunisia',
    ],
    TR => [
	214,
	'Turkey',
    ],
    TM => [
	215,
	'Turkmenistan',
    ],
    TC => [
	216,
	'Turks and Caicos Islands',
    ],
    TV => [
	217,
	'Tuvalu',
    ],
    UG => [
	218,
	'Uganda',
    ],
    UA => [
	219,
	'Ukraine',
    ],
    AE => [
	220,
	'United Arab Emirates',
    ],
    GB => [
	221,
	'United Kingdom',
    ],
    US => [
	222,
	'United States',
    ],
    UM => [
	223,
	'United States Minor Outlying Islands',
    ],
    UY => [
	224,
	'Uruguay',
    ],
    UZ => [
	225,
	'Uzbekistan',
    ],
    VU => [
	226,
	'Vanuatu',
    ],
    VA => [
	227,
	'Vatican City State',
    ],
    VE => [
	228,
	'Venezuela',
    ],
    VN => [
	229,
	'Vietnam',
    ],
    VG => [
	230,
	'Virgin Islands',
    ],
    VI => [
	231,
	'Virgin Islands (U.S.)',
    ],
    WF => [
	232,
	'Wallis and Futuna Islands',
    ],
    EH => [
	233,
	'Western Sahara',
    ],
    YE => [
	234,
	'Yemen',
    ],
    YU => [
	235,
	'Yugoslavia',
    ],
    ZR => [
	236,
	'Zaire',
    ],
    ZM => [
	237,
	'Zambia',
    ],
    ZW => [
	238,
	'Zimbabwe',
    ],
    ZZ => [
        239,
        'Various',
    ],
]);

=head1 METHODS

=cut

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
