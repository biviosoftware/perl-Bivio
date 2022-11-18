# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::TimeZone;
use strict;
use Bivio::Base 'Type.Enum';
use DateTime ();

my($_DT) = b_use('Type.DateTime');
__PACKAGE__->compile;
b_use('IO.Config')->register(my $_CFG = {
    default => 'UTC',
});

sub ROW_TAG_KEY {
    return 'TIME_ZONE';
}

sub compile {
    my($i) = 2;
    return shift->SUPER::compile([
        UNKNOWN => [0, 'Select Time Zone'],
        UTC => [1, 'UTC'],
        map({
            my($x) = $_;
            $x =~ s/\W/_/g;
            (uc($x) => [$i++, $_]);
        } @{_names_for_version($DateTime::TimeZone::VERSION)}),
    ]);
}

sub date_time_from_utc {
    my($self, $date_time) = @_;
    return _convert($self, $date_time, $self->UTC, $self);
}

sub date_time_to_utc {
    my($self, $date_time) = @_;
    return _convert($self, $date_time, $self, $self->UTC);
}

sub as_display_name {
    return shift->get_long_desc;
}

sub get_default {
    return $_CFG->{default};
}

sub handle_config {
    my($proto, $cfg) = @_;
    $_CFG->{default} = $proto->from_any($cfg->{default});
    return;
}

sub _convert {
    my($self, $date_time, $source, $target) = @_;
    my($sec, $min, $hour, $mday, $mon, $year) = $_DT->to_parts($date_time);
    my($dt) = scalar(DateTime->new(
        year   => $year,
        month  => $mon,
        day    => $mday,
        hour   => $hour,
        minute => $min,
        second => $sec,
        time_zone => $source->get_short_desc,
    ));
    $dt->set_time_zone($target->get_short_desc);
    return $_DT->from_parts_or_die(
        $dt->second, $dt->minute, $dt->hour, $dt->day, $dt->month, $dt->year);
}

sub _names_for_version {
    my($version) = @_;
    # order is important, add new names for new versions at the end
    my($v2) = '1.39';
    return [
        'Africa/Abidjan',
        'Africa/Accra',
        'Africa/Addis_Ababa',
        'Africa/Algiers',
        $version < $v2
            ? 'Africa/Asmera'
            : 'Africa/Asmara',
        'Africa/Bamako',
        'Africa/Bangui',
        'Africa/Banjul',
        'Africa/Bissau',
        'Africa/Blantyre',
        'Africa/Brazzaville',
        'Africa/Bujumbura',
        'Africa/Cairo',
        'Africa/Casablanca',
        'Africa/Ceuta',
        'Africa/Conakry',
        'Africa/Dakar',
        'Africa/Dar_es_Salaam',
        'Africa/Djibouti',
        'Africa/Douala',
        'Africa/El_Aaiun',
        'Africa/Freetown',
        'Africa/Gaborone',
        'Africa/Harare',
        'Africa/Johannesburg',
        'Africa/Kampala',
        'Africa/Khartoum',
        'Africa/Kigali',
        'Africa/Kinshasa',
        'Africa/Lagos',
        'Africa/Libreville',
        'Africa/Lome',
        'Africa/Luanda',
        'Africa/Lubumbashi',
        'Africa/Lusaka',
        'Africa/Malabo',
        'Africa/Maputo',
        'Africa/Maseru',
        'Africa/Mbabane',
        'Africa/Mogadishu',
        'Africa/Monrovia',
        'Africa/Nairobi',
        'Africa/Ndjamena',
        'Africa/Niamey',
        'Africa/Nouakchott',
        'Africa/Ouagadougou',
        'Africa/Porto-Novo',
        'Africa/Sao_Tome',
        'Africa/Tripoli',
        'Africa/Tunis',
        'Africa/Windhoek',
        'America/Adak',
        'America/Anchorage',
        'America/Anguilla',
        'America/Antigua',
        'America/Araguaina',
        'America/Argentina/Buenos_Aires',
        'America/Argentina/Catamarca',
        'America/Argentina/Cordoba',
        'America/Argentina/Jujuy',
        'America/Argentina/La_Rioja',
        'America/Argentina/Mendoza',
        'America/Argentina/Rio_Gallegos',
        'America/Argentina/San_Juan',
        'America/Argentina/Tucuman',
        'America/Argentina/Ushuaia',
        'America/Aruba',
        'America/Asuncion',
        'America/Atikokan',
        'America/Bahia',
        'America/Barbados',
        'America/Belem',
        'America/Belize',
        'America/Blanc-Sablon',
        'America/Boa_Vista',
        'America/Bogota',
        'America/Boise',
        'America/Cambridge_Bay',
        'America/Campo_Grande',
        'America/Cancun',
        'America/Caracas',
        'America/Cayenne',
        'America/Cayman',
        'America/Chicago',
        'America/Chihuahua',
        'America/Costa_Rica',
        'America/Cuiaba',
        'America/Curacao',
        'America/Danmarkshavn',
        'America/Dawson',
        'America/Dawson_Creek',
        'America/Denver',
        'America/Detroit',
        'America/Dominica',
        'America/Edmonton',
        'America/Eirunepe',
        'America/El_Salvador',
        'America/Fortaleza',
        'America/Glace_Bay',
        'America/Godthab',
        'America/Goose_Bay',
        'America/Grand_Turk',
        'America/Grenada',
        'America/Guadeloupe',
        'America/Guatemala',
        'America/Guayaquil',
        'America/Guyana',
        'America/Halifax',
        'America/Havana',
        'America/Hermosillo',
        'America/Indiana/Indianapolis',
        'America/Indiana/Knox',
        'America/Indiana/Marengo',
        'America/Indiana/Petersburg',
        'America/Indiana/Vevay',
        'America/Indiana/Vincennes',
        'America/Inuvik',
        'America/Iqaluit',
        'America/Jamaica',
        'America/Juneau',
        'America/Kentucky/Louisville',
        'America/Kentucky/Monticello',
        'America/La_Paz',
        'America/Lima',
        'America/Los_Angeles',
        'America/Maceio',
        'America/Managua',
        'America/Manaus',
        'America/Martinique',
        'America/Mazatlan',
        'America/Menominee',
        'America/Merida',
        'America/Mexico_City',
        'America/Miquelon',
        'America/Moncton',
        'America/Monterrey',
        'America/Montevideo',
        'America/Montreal',
        'America/Montserrat',
        'America/Nassau',
        'America/New_York',
        'America/Nipigon',
        'America/Nome',
        'America/Noronha',
        'America/North_Dakota/Center',
        'America/North_Dakota/New_Salem',
        'America/Panama',
        'America/Pangnirtung',
        'America/Paramaribo',
        'America/Phoenix',
        'America/Port-au-Prince',
        'America/Port_of_Spain',
        'America/Porto_Velho',
        'America/Puerto_Rico',
        'America/Rainy_River',
        'America/Rankin_Inlet',
        'America/Recife',
        'America/Regina',
        'America/Rio_Branco',
        'America/Santiago',
        'America/Santo_Domingo',
        'America/Sao_Paulo',
        'America/Scoresbysund',
        'America/St_Johns',
        'America/St_Kitts',
        'America/St_Lucia',
        'America/St_Thomas',
        'America/St_Vincent',
        'America/Swift_Current',
        'America/Tegucigalpa',
        'America/Thule',
        'America/Thunder_Bay',
        'America/Tijuana',
        'America/Toronto',
        'America/Tortola',
        'America/Vancouver',
        'America/Whitehorse',
        'America/Winnipeg',
        'America/Yakutat',
        'America/Yellowknife',
        'Antarctica/Casey',
        'Antarctica/Davis',
        'Antarctica/DumontDUrville',
        'Antarctica/Mawson',
        'Antarctica/McMurdo',
        'Antarctica/Palmer',
        'Antarctica/Rothera',
        'Antarctica/Syowa',
        'Antarctica/Vostok',
        'Asia/Aden',
        'Asia/Almaty',
        'Asia/Amman',
        'Asia/Anadyr',
        'Asia/Aqtau',
        'Asia/Aqtobe',
        'Asia/Ashgabat',
        'Asia/Baghdad',
        'Asia/Bahrain',
        'Asia/Baku',
        'Asia/Bangkok',
        'Asia/Beirut',
        'Asia/Bishkek',
        'Asia/Brunei',
        $version < $v2
            ? 'Asia/Calcutta'
            : 'Asia/Kolkata',
        'Asia/Choibalsan',
        'Asia/Chongqing',
        'Asia/Colombo',
        'Asia/Damascus',
        'Asia/Dhaka',
        'Asia/Dili',
        'Asia/Dubai',
        'Asia/Dushanbe',
        'Asia/Gaza',
        'Asia/Harbin',
        'Asia/Hong_Kong',
        'Asia/Hovd',
        'Asia/Irkutsk',
        'Asia/Jakarta',
        'Asia/Jayapura',
        'Asia/Jerusalem',
        'Asia/Kabul',
        'Asia/Kamchatka',
        'Asia/Karachi',
        'Asia/Kashgar',
        $version < $v2
            ? 'Asia/Katmandu'
            : 'Asia/Kathmandu',
        'Asia/Krasnoyarsk',
        'Asia/Kuala_Lumpur',
        'Asia/Kuching',
        'Asia/Kuwait',
        'Asia/Macau',
        'Asia/Magadan',
        'Asia/Makassar',
        'Asia/Manila',
        'Asia/Muscat',
        'Asia/Nicosia',
        'Asia/Novosibirsk',
        'Asia/Omsk',
        'Asia/Oral',
        'Asia/Phnom_Penh',
        'Asia/Pontianak',
        'Asia/Pyongyang',
        'Asia/Qatar',
        'Asia/Qyzylorda',
        'Asia/Rangoon',
        'Asia/Riyadh',
        $version < $v2
            ? 'Asia/Saigon'
            : 'Asia/Ho_Chi_Minh',
        'Asia/Sakhalin',
        'Asia/Samarkand',
        'Asia/Seoul',
        'Asia/Shanghai',
        'Asia/Singapore',
        'Asia/Taipei',
        'Asia/Tashkent',
        'Asia/Tbilisi',
        'Asia/Tehran',
        'Asia/Thimphu',
        'Asia/Tokyo',
        'Asia/Ulaanbaatar',
        'Asia/Urumqi',
        'Asia/Vientiane',
        'Asia/Vladivostok',
        'Asia/Yakutsk',
        'Asia/Yekaterinburg',
        'Asia/Yerevan',
        'Atlantic/Azores',
        'Atlantic/Bermuda',
        'Atlantic/Canary',
        'Atlantic/Cape_Verde',
        $version < $v2
            ? 'Atlantic/Faeroe'
            : 'Atlantic/Faroe',
        'Atlantic/Madeira',
        'Atlantic/Reykjavik',
        'Atlantic/South_Georgia',
        'Atlantic/St_Helena',
        'Atlantic/Stanley',
        'Australia/Adelaide',
        'Australia/Brisbane',
        'Australia/Broken_Hill',
        'Australia/Currie',
        'Australia/Darwin',
        'Australia/Hobart',
        'Australia/Lindeman',
        'Australia/Lord_Howe',
        'Australia/Melbourne',
        'Australia/Perth',
        'Australia/Sydney',
        'CST6CDT',
        'EST',
        'EST5EDT',
        'Europe/Amsterdam',
        'Europe/Andorra',
        'Europe/Athens',
        'Europe/Belgrade',
        'Europe/Berlin',
        'Europe/Brussels',
        'Europe/Bucharest',
        'Europe/Budapest',
        'Europe/Chisinau',
        'Europe/Copenhagen',
        'Europe/Dublin',
        'Europe/Gibraltar',
        'Europe/Helsinki',
        'Europe/Istanbul',
        'Europe/Kaliningrad',
        'Europe/Kiev',
        'Europe/Lisbon',
        'Europe/London',
        'Europe/Luxembourg',
        'Europe/Madrid',
        'Europe/Malta',
        'Europe/Minsk',
        'Europe/Monaco',
        'Europe/Moscow',
        'Europe/Oslo',
        'Europe/Paris',
        'Europe/Prague',
        'Europe/Riga',
        'Europe/Rome',
        'Europe/Samara',
        'Europe/Simferopol',
        'Europe/Sofia',
        'Europe/Stockholm',
        'Europe/Tallinn',
        'Europe/Tirane',
        'Europe/Uzhgorod',
        'Europe/Vaduz',
        'Europe/Vienna',
        'Europe/Vilnius',
        'Europe/Volgograd',
        'Europe/Warsaw',
        'Europe/Zaporozhye',
        'Europe/Zurich',
        'HST',
        'Indian/Antananarivo',
        'Indian/Chagos',
        'Indian/Christmas',
        'Indian/Cocos',
        'Indian/Comoro',
        'Indian/Kerguelen',
        'Indian/Mahe',
        'Indian/Maldives',
        'Indian/Mauritius',
        'Indian/Mayotte',
        'Indian/Reunion',
        'MST',
        'MST7MDT',
        'PST8PDT',
        'Pacific/Apia',
        'Pacific/Auckland',
        'Pacific/Chatham',
        'Pacific/Easter',
        'Pacific/Efate',
        'Pacific/Enderbury',
        'Pacific/Fakaofo',
        'Pacific/Fiji',
        'Pacific/Funafuti',
        'Pacific/Galapagos',
        'Pacific/Gambier',
        'Pacific/Guadalcanal',
        'Pacific/Guam',
        'Pacific/Honolulu',
        'Pacific/Johnston',
        'Pacific/Kiritimati',
        'Pacific/Kosrae',
        'Pacific/Kwajalein',
        'Pacific/Majuro',
        'Pacific/Marquesas',
        'Pacific/Midway',
        'Pacific/Nauru',
        'Pacific/Niue',
        'Pacific/Norfolk',
        'Pacific/Noumea',
        'Pacific/Pago_Pago',
        'Pacific/Palau',
        'Pacific/Pitcairn',
        $version < $v2
            ? 'Pacific/Ponape'
            : 'Pacific/Pohnpei',
        'Pacific/Port_Moresby',
        'Pacific/Rarotonga',
        'Pacific/Saipan',
        'Pacific/Tahiti',
        'Pacific/Tarawa',
        'Pacific/Tongatapu',
        $version < $v2
            ? 'Pacific/Truk'
            : 'Pacific/Chuuk',
        'Pacific/Wake',
        'Pacific/Wallis',

        $version >= $v2 ? (
            'Africa/Juba',
            'America/Argentina/Salta',
            'America/Argentina/San_Luis',
            'America/Bahia_Banderas',
            'America/Indiana/Tell_City',
            'America/Indiana/Winamac',
            'America/Matamoros',
            'America/Metlakatla',
            'America/North_Dakota/Beulah',
            'America/Ojinaga',
            'America/Resolute',
            'America/Santa_Isabel',
            'America/Santarem',
            'America/Sitka',
            'Antarctica/Macquarie',
            'Asia/Hebron',
            'Asia/Novokuznetsk',
            'Australia/Eucla',
            'CET',
            'EET',
            'MET',
            'WET',
        ) : (),
    ];
}

1;
