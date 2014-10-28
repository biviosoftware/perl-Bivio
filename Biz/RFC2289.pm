# Copyright (c) 2007 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::RFC2289;
use strict;
use Bivio::Base 'Bivio::Collection::Attributes';
use Digest::MD5 ();
use Bivio::IO::File;

my($_DICTIONARY) = [map(@$_, @{Bivio::IO::File->map_lines(\*DATA, qr{\s+})})];
my($_REVERSE) = _build_reverse($_DICTIONARY);

sub canonical_hex {
    # Return uppercase hex otp from user input
    my($proto, $input) = @_;
    return undef
	unless $input;
    my($otp) = $proto->from_six_word_format($input);
    return $otp
	if $otp;
    $otp = uc(join('', split(/\s+/, $input)));
    return $otp
	if $otp =~ /^[0-9A-F]{16}$/;
    return undef;
}

sub checksum {
    # Return 2-bit checksum
    my(undef, $hex_otp) = @_;
    my($sum) = 0;
    foreach my $bin (
        unpack('a2'x32, unpack('B64', pack('H16', $hex_otp)))
    ) {
	$sum += unpack('n', pack('B16', '0'x14 . $bin));
    }
    return qw(0 4 8 C)[$sum % 4];
}

sub compute {
    my(undef, $count, $seed, $passwd) = @_;
    return undef
	unless $count >= 0;
    return uc(unpack('H16', _compute(lc($seed) . $passwd, $count)));
}

sub from_six_word_format {
    my($proto, $sw_otp) = @_;
    return undef
	unless $sw_otp;
    my($words) = [grep($_, split(/\s+/, $sw_otp))];
    return undef
	unless @$words == 6;
    my($bits) = join('', map({$_REVERSE->{uc($_)} || 'X'} @$words));
    return undef
	if $bits =~ /X/;
    my($otp) = uc(unpack('H17', pack('B66', $bits)));
    return undef
	unless chop($otp) eq $proto->checksum($otp);
    return $otp;
}

sub to_six_word_format {
    my(undef, $otp) = @_;
    return join(' ', map({$_DICTIONARY->[$_]} _split11(_checksum($otp))));
}

sub verify {
    my($proto, $hex_otp, $hex_last_otp) = @_;
    return 1
	if uc(unpack('H16', _compute(unpack('a8', pack('H16', $hex_otp)), 0)))
	    eq $hex_last_otp;
    return 0;
}

sub _build_reverse {
    my($dictionary) = @_;
    my($count) = 0;
    return {
        map({($_ => substr(unpack('B32', pack('N', $count++)), -11))}
	    @$dictionary),
    };
}

sub _checksum {
    # Append checksum to otp
    my($otp) = @_;
    return $otp . __PACKAGE__->checksum($otp);
}

sub _compute {
    my($text, $count) = @_;
    foreach my $c (0 .. $count) {
	$text = _fold(Digest::MD5::md5($text));
    }
    return $text;
}

sub _fold {
    # Fold 128-bit digest to 64-bits
    my($digest) = @_;
    return substr($digest, 0, 8) ^ substr($digest, 8);
}

sub _split11 {
    # Split otp + checksum into 6 11-bit words
    my($otp) = @_;
    return (map({unpack('N', pack('B32', '0'x21 . $_))}
        unpack('a11'x6, unpack('B66', pack('H17', $otp)))));
}

1;
__DATA__
A     ABE   ACE   ACT   AD    ADA   ADD   AGO
AID   AIM   AIR   ALL   ALP   AM    AMY   AN
ANA   AND   ANN   ANT   ANY   APE   APS   APT
ARC   ARE   ARK   ARM   ART   AS    ASH   ASK
AT    ATE   AUG   AUK   AVE   AWE   AWK   AWL
AWN   AX    AYE   BAD   BAG   BAH   BAM   BAN
BAR   BAT   BAY   BE    BED   BEE   BEG   BEN
BET   BEY   BIB   BID   BIG   BIN   BIT   BOB
BOG   BON   BOO   BOP   BOW   BOY   BUB   BUD
BUG   BUM   BUN   BUS   BUT   BUY   BY    BYE
CAB   CAL   CAM   CAN   CAP   CAR   CAT   CAW
COD   COG   COL   CON   COO   COP   COT   COW
COY   CRY   CUB   CUE   CUP   CUR   CUT   DAB
DAD   DAM   DAN   DAR   DAY   DEE   DEL   DEN
DES   DEW   DID   DIE   DIG   DIN   DIP   DO
DOE   DOG   DON   DOT   DOW   DRY   DUB   DUD
DUE   DUG   DUN   EAR   EAT   ED    EEL   EGG
EGO   ELI   ELK   ELM   ELY   EM    END   EST
ETC   EVA   EVE   EWE   EYE   FAD   FAN   FAR
FAT   FAY   FED   FEE   FEW   FIB   FIG   FIN
FIR   FIT   FLO   FLY   FOE   FOG   FOR   FRY
FUM   FUN   FUR   GAB   GAD   GAG   GAL   GAM
GAP   GAS   GAY   GEE   GEL   GEM   GET   GIG
GIL   GIN   GO    GOT   GUM   GUN   GUS   GUT
GUY   GYM   GYP   HA    HAD   HAL   HAM   HAN
HAP   HAS   HAT   HAW   HAY   HE    HEM   HEN
HER   HEW   HEY   HI    HID   HIM   HIP   HIS
HIT   HO    HOB   HOC   HOE   HOG   HOP   HOT
HOW   HUB   HUE   HUG   HUH   HUM   HUT   I
ICY   IDA   IF    IKE   ILL   INK   INN   IO
ION   IQ    IRA   IRE   IRK   IS    IT    ITS
IVY   JAB   JAG   JAM   JAN   JAR   JAW   JAY
JET   JIG   JIM   JO    JOB   JOE   JOG   JOT
JOY   JUG   JUT   KAY   KEG   KEN   KEY   KID
KIM   KIN   KIT   LA    LAB   LAC   LAD   LAG
LAM   LAP   LAW   LAY   LEA   LED   LEE   LEG
LEN   LEO   LET   LEW   LID   LIE   LIN   LIP
LIT   LO    LOB   LOG   LOP   LOS   LOT   LOU
LOW   LOY   LUG   LYE   MA    MAC   MAD   MAE
MAN   MAO   MAP   MAT   MAW   MAY   ME    MEG
MEL   MEN   MET   MEW   MID   MIN   MIT   MOB
MOD   MOE   MOO   MOP   MOS   MOT   MOW   MUD
MUG   MUM   MY    NAB   NAG   NAN   NAP   NAT

NAY   NE    NED   NEE   NET   NEW   NIB   NIL
NIP   NIT   NO    NOB   NOD   NON   NOR   NOT
NOV   NOW   NU    NUN   NUT   O     OAF   OAK
OAR   OAT   ODD   ODE   OF    OFF   OFT   OH
OIL   OK    OLD   ON    ONE   OR    ORB   ORE
ORR   OS    OTT   OUR   OUT   OVA   OW    OWE
OWL   OWN   OX    PA    PAD   PAL   PAM   PAN
PAP   PAR   PAT   PAW   PAY   PEA   PEG   PEN
PEP   PER   PET   PEW   PHI   PI    PIE   PIN
PIT   PLY   PO    POD   POE   POP   POT   POW
PRO   PRY   PUB   PUG   PUN   PUP   PUT   QUO
RAG   RAM   RAN   RAP   RAT   RAW   RAY   REB
RED   REP   RET   RIB   RID   RIG   RIM   RIO
RIP   ROB   ROD   ROE   RON   ROT   ROW   ROY
RUB   RUE   RUG   RUM   RUN   RYE   SAC   SAD
SAG   SAL   SAM   SAN   SAP   SAT   SAW   SAY
SEA   SEC   SEE   SEN   SET   SEW   SHE   SHY
SIN   SIP   SIR   SIS   SIT   SKI   SKY   SLY
SO    SOB   SOD   SON   SOP   SOW   SOY   SPA
SPY   SUB   SUD   SUE   SUM   SUN   SUP   TAB
TAD   TAG   TAN   TAP   TAR   TEA   TED   TEE
TEN   THE   THY   TIC   TIE   TIM   TIN   TIP
TO    TOE   TOG   TOM   TON   TOO   TOP   TOW
TOY   TRY   TUB   TUG   TUM   TUN   TWO   UN
UP    US    USE   VAN   VAT   VET   VIE   WAD
WAG   WAR   WAS   WAY   WE    WEB   WED   WEE
WET   WHO   WHY   WIN   WIT   WOK   WON   WOO
WOW   WRY   WU    YAM   YAP   YAW   YE    YEA
YES   YET   YOU   ABED  ABEL  ABET  ABLE  ABUT
ACHE  ACID  ACME  ACRE  ACTA  ACTS  ADAM  ADDS
ADEN  AFAR  AFRO  AGEE  AHEM  AHOY  AIDA  AIDE
AIDS  AIRY  AJAR  AKIN  ALAN  ALEC  ALGA  ALIA
ALLY  ALMA  ALOE  ALSO  ALTO  ALUM  ALVA  AMEN
AMES  AMID  AMMO  AMOK  AMOS  AMRA  ANDY  ANEW
ANNA  ANNE  ANTE  ANTI  AQUA  ARAB  ARCH  AREA
ARGO  ARID  ARMY  ARTS  ARTY  ASIA  ASKS  ATOM
AUNT  AURA  AUTO  AVER  AVID  AVIS  AVON  AVOW
AWAY  AWRY  BABE  BABY  BACH  BACK  BADE  BAIL
BAIT  BAKE  BALD  BALE  BALI  BALK  BALL  BALM
BAND  BANE  BANG  BANK  BARB  BARD  BARE  BARK
BARN  BARR  BASE  BASH  BASK  BASS  BATE  BATH
BAWD  BAWL  BEAD  BEAK  BEAM  BEAN  BEAR  BEAT
BEAU  BECK  BEEF  BEEN  BEER  BEET  BELA  BELL
BELT  BEND  BENT  BERG  BERN  BERT  BESS  BEST
BETA  BETH  BHOY  BIAS  BIDE  BIEN  BILE  BILK
BILL  BIND  BING  BIRD  BITE  BITS  BLAB  BLAT
BLED  BLEW  BLOB  BLOC  BLOT  BLOW  BLUE  BLUM
BLUR  BOAR  BOAT  BOCA  BOCK  BODE  BODY  BOGY

BOHR  BOIL  BOLD  BOLO  BOLT  BOMB  BONA  BOND
BONE  BONG  BONN  BONY  BOOK  BOOM  BOON  BOOT
BORE  BORG  BORN  BOSE  BOSS  BOTH  BOUT  BOWL
BOYD  BRAD  BRAE  BRAG  BRAN  BRAY  BRED  BREW
BRIG  BRIM  BROW  BUCK  BUDD  BUFF  BULB  BULK
BULL  BUNK  BUNT  BUOY  BURG  BURL  BURN  BURR
BURT  BURY  BUSH  BUSS  BUST  BUSY  BYTE  CADY
CAFE  CAGE  CAIN  CAKE  CALF  CALL  CALM  CAME
CANE  CANT  CARD  CARE  CARL  CARR  CART  CASE
CASH  CASK  CAST  CAVE  CEIL  CELL  CENT  CERN
CHAD  CHAR  CHAT  CHAW  CHEF  CHEN  CHEW  CHIC
CHIN  CHOU  CHOW  CHUB  CHUG  CHUM  CITE  CITY
CLAD  CLAM  CLAN  CLAW  CLAY  CLOD  CLOG  CLOT
CLUB  CLUE  COAL  COAT  COCA  COCK  COCO  CODA
CODE  CODY  COED  COIL  COIN  COKE  COLA  COLD
COLT  COMA  COMB  COME  COOK  COOL  COON  COOT
CORD  CORE  CORK  CORN  COST  COVE  COWL  CRAB
CRAG  CRAM  CRAY  CREW  CRIB  CROW  CRUD  CUBA
CUBE  CUFF  CULL  CULT  CUNY  CURB  CURD  CURE
CURL  CURT  CUTS  DADE  DALE  DAME  DANA  DANE
DANG  DANK  DARE  DARK  DARN  DART  DASH  DATA
DATE  DAVE  DAVY  DAWN  DAYS  DEAD  DEAF  DEAL
DEAN  DEAR  DEBT  DECK  DEED  DEEM  DEER  DEFT
DEFY  DELL  DENT  DENY  DESK  DIAL  DICE  DIED
DIET  DIME  DINE  DING  DINT  DIRE  DIRT  DISC
DISH  DISK  DIVE  DOCK  DOES  DOLE  DOLL  DOLT
DOME  DONE  DOOM  DOOR  DORA  DOSE  DOTE  DOUG
DOUR  DOVE  DOWN  DRAB  DRAG  DRAM  DRAW  DREW
DRUB  DRUG  DRUM  DUAL  DUCK  DUCT  DUEL  DUET
DUKE  DULL  DUMB  DUNE  DUNK  DUSK  DUST  DUTY
EACH  EARL  EARN  EASE  EAST  EASY  EBEN  ECHO
EDDY  EDEN  EDGE  EDGY  EDIT  EDNA  EGAN  ELAN
ELBA  ELLA  ELSE  EMIL  EMIT  EMMA  ENDS  ERIC
EROS  EVEN  EVER  EVIL  EYED  FACE  FACT  FADE
FAIL  FAIN  FAIR  FAKE  FALL  FAME  FANG  FARM
FAST  FATE  FAWN  FEAR  FEAT  FEED  FEEL  FEET
FELL  FELT  FEND  FERN  FEST  FEUD  FIEF  FIGS
FILE  FILL  FILM  FIND  FINE  FINK  FIRE  FIRM
FISH  FISK  FIST  FITS  FIVE  FLAG  FLAK  FLAM
FLAT  FLAW  FLEA  FLED  FLEW  FLIT  FLOC  FLOG
FLOW  FLUB  FLUE  FOAL  FOAM  FOGY  FOIL  FOLD
FOLK  FOND  FONT  FOOD  FOOL  FOOT  FORD  FORE
FORK  FORM  FORT  FOSS  FOUL  FOUR  FOWL  FRAU
FRAY  FRED  FREE  FRET  FREY  FROG  FROM  FUEL
FULL  FUME  FUND  FUNK  FURY  FUSE  FUSS  GAFF
GAGE  GAIL  GAIN  GAIT  GALA  GALE  GALL  GALT
GAME  GANG  GARB  GARY  GASH  GATE  GAUL  GAUR
GAVE  GAWK  GEAR  GELD  GENE  GENT  GERM  GETS

GIBE  GIFT  GILD  GILL  GILT  GINA  GIRD  GIRL
GIST  GIVE  GLAD  GLEE  GLEN  GLIB  GLOB  GLOM
GLOW  GLUE  GLUM  GLUT  GOAD  GOAL  GOAT  GOER
GOES  GOLD  GOLF  GONE  GONG  GOOD  GOOF  GORE
GORY  GOSH  GOUT  GOWN  GRAB  GRAD  GRAY  GREG
GREW  GREY  GRID  GRIM  GRIN  GRIT  GROW  GRUB
GULF  GULL  GUNK  GURU  GUSH  GUST  GWEN  GWYN
HAAG  HAAS  HACK  HAIL  HAIR  HALE  HALF  HALL
HALO  HALT  HAND  HANG  HANK  HANS  HARD  HARK
HARM  HART  HASH  HAST  HATE  HATH  HAUL  HAVE
HAWK  HAYS  HEAD  HEAL  HEAR  HEAT  HEBE  HECK
HEED  HEEL  HEFT  HELD  HELL  HELM  HERB  HERD
HERE  HERO  HERS  HESS  HEWN  HICK  HIDE  HIGH
HIKE  HILL  HILT  HIND  HINT  HIRE  HISS  HIVE
HOBO  HOCK  HOFF  HOLD  HOLE  HOLM  HOLT  HOME
HONE  HONK  HOOD  HOOF  HOOK  HOOT  HORN  HOSE
HOST  HOUR  HOVE  HOWE  HOWL  HOYT  HUCK  HUED
HUFF  HUGE  HUGH  HUGO  HULK  HULL  HUNK  HUNT
HURD  HURL  HURT  HUSH  HYDE  HYMN  IBIS  ICON
IDEA  IDLE  IFFY  INCA  INCH  INTO  IONS  IOTA
IOWA  IRIS  IRMA  IRON  ISLE  ITCH  ITEM  IVAN
JACK  JADE  JAIL  JAKE  JANE  JAVA  JEAN  JEFF
JERK  JESS  JEST  JIBE  JILL  JILT  JIVE  JOAN
JOBS  JOCK  JOEL  JOEY  JOHN  JOIN  JOKE  JOLT
JOVE  JUDD  JUDE  JUDO  JUDY  JUJU  JUKE  JULY
JUNE  JUNK  JUNO  JURY  JUST  JUTE  KAHN  KALE
KANE  KANT  KARL  KATE  KEEL  KEEN  KENO  KENT
KERN  KERR  KEYS  KICK  KILL  KIND  KING  KIRK
KISS  KITE  KLAN  KNEE  KNEW  KNIT  KNOB  KNOT
KNOW  KOCH  KONG  KUDO  KURD  KURT  KYLE  LACE
LACK  LACY  LADY  LAID  LAIN  LAIR  LAKE  LAMB
LAME  LAND  LANE  LANG  LARD  LARK  LASS  LAST
LATE  LAUD  LAVA  LAWN  LAWS  LAYS  LEAD  LEAF
LEAK  LEAN  LEAR  LEEK  LEER  LEFT  LEND  LENS
LENT  LEON  LESK  LESS  LEST  LETS  LIAR  LICE
LICK  LIED  LIEN  LIES  LIEU  LIFE  LIFT  LIKE
LILA  LILT  LILY  LIMA  LIMB  LIME  LIND  LINE
LINK  LINT  LION  LISA  LIST  LIVE  LOAD  LOAF
LOAM  LOAN  LOCK  LOFT  LOGE  LOIS  LOLA  LONE
LONG  LOOK  LOON  LOOT  LORD  LORE  LOSE  LOSS
LOST  LOUD  LOVE  LOWE  LUCK  LUCY  LUGE  LUKE
LULU  LUND  LUNG  LURA  LURE  LURK  LUSH  LUST
LYLE  LYNN  LYON  LYRA  MACE  MADE  MAGI  MAID
MAIL  MAIN  MAKE  MALE  MALI  MALL  MALT  MANA
MANN  MANY  MARC  MARE  MARK  MARS  MART  MARY
MASH  MASK  MASS  MAST  MATE  MATH  MAUL  MAYO
MEAD  MEAL  MEAN  MEAT  MEEK  MEET  MELD  MELT
MEMO  MEND  MENU  MERT  MESH  MESS  MICE  MIKE

MILD  MILE  MILK  MILL  MILT  MIMI  MIND  MINE
MINI  MINK  MINT  MIRE  MISS  MIST  MITE  MITT
MOAN  MOAT  MOCK  MODE  MOLD  MOLE  MOLL  MOLT
MONA  MONK  MONT  MOOD  MOON  MOOR  MOOT  MORE
MORN  MORT  MOSS  MOST  MOTH  MOVE  MUCH  MUCK
MUDD  MUFF  MULE  MULL  MURK  MUSH  MUST  MUTE
MUTT  MYRA  MYTH  NAGY  NAIL  NAIR  NAME  NARY
NASH  NAVE  NAVY  NEAL  NEAR  NEAT  NECK  NEED
NEIL  NELL  NEON  NERO  NESS  NEST  NEWS  NEWT
NIBS  NICE  NICK  NILE  NINA  NINE  NOAH  NODE
NOEL  NOLL  NONE  NOOK  NOON  NORM  NOSE  NOTE
NOUN  NOVA  NUDE  NULL  NUMB  OATH  OBEY  OBOE
ODIN  OHIO  OILY  OINT  OKAY  OLAF  OLDY  OLGA
OLIN  OMAN  OMEN  OMIT  ONCE  ONES  ONLY  ONTO
ONUS  ORAL  ORGY  OSLO  OTIS  OTTO  OUCH  OUST
OUTS  OVAL  OVEN  OVER  OWLY  OWNS  QUAD  QUIT
QUOD  RACE  RACK  RACY  RAFT  RAGE  RAID  RAIL
RAIN  RAKE  RANK  RANT  RARE  RASH  RATE  RAVE
RAYS  READ  REAL  REAM  REAR  RECK  REED  REEF
REEK  REEL  REID  REIN  RENA  REND  RENT  REST
RICE  RICH  RICK  RIDE  RIFT  RILL  RIME  RING
RINK  RISE  RISK  RITE  ROAD  ROAM  ROAR  ROBE
ROCK  RODE  ROIL  ROLL  ROME  ROOD  ROOF  ROOK
ROOM  ROOT  ROSA  ROSE  ROSS  ROSY  ROTH  ROUT
ROVE  ROWE  ROWS  RUBE  RUBY  RUDE  RUDY  RUIN
RULE  RUNG  RUNS  RUNT  RUSE  RUSH  RUSK  RUSS
RUST  RUTH  SACK  SAFE  SAGE  SAID  SAIL  SALE
SALK  SALT  SAME  SAND  SANE  SANG  SANK  SARA
SAUL  SAVE  SAYS  SCAN  SCAR  SCAT  SCOT  SEAL
SEAM  SEAR  SEAT  SEED  SEEK  SEEM  SEEN  SEES
SELF  SELL  SEND  SENT  SETS  SEWN  SHAG  SHAM
SHAW  SHAY  SHED  SHIM  SHIN  SHOD  SHOE  SHOT
SHOW  SHUN  SHUT  SICK  SIDE  SIFT  SIGH  SIGN
SILK  SILL  SILO  SILT  SINE  SING  SINK  SIRE
SITE  SITS  SITU  SKAT  SKEW  SKID  SKIM  SKIN
SKIT  SLAB  SLAM  SLAT  SLAY  SLED  SLEW  SLID
SLIM  SLIT  SLOB  SLOG  SLOT  SLOW  SLUG  SLUM
SLUR  SMOG  SMUG  SNAG  SNOB  SNOW  SNUB  SNUG
SOAK  SOAR  SOCK  SODA  SOFA  SOFT  SOIL  SOLD
SOME  SONG  SOON  SOOT  SORE  SORT  SOUL  SOUR
SOWN  STAB  STAG  STAN  STAR  STAY  STEM  STEW
STIR  STOW  STUB  STUN  SUCH  SUDS  SUIT  SULK
SUMS  SUNG  SUNK  SURE  SURF  SWAB  SWAG  SWAM
SWAN  SWAT  SWAY  SWIM  SWUM  TACK  TACT  TAIL
TAKE  TALE  TALK  TALL  TANK  TASK  TATE  TAUT
TEAL  TEAM  TEAR  TECH  TEEM  TEEN  TEET  TELL
TEND  TENT  TERM  TERN  TESS  TEST  THAN  THAT
THEE  THEM  THEN  THEY  THIN  THIS  THUD  THUG

TICK  TIDE  TIDY  TIED  TIER  TILE  TILL  TILT
TIME  TINA  TINE  TINT  TINY  TIRE  TOAD  TOGO
TOIL  TOLD  TOLL  TONE  TONG  TONY  TOOK  TOOL
TOOT  TORE  TORN  TOTE  TOUR  TOUT  TOWN  TRAG
TRAM  TRAY  TREE  TREK  TRIG  TRIM  TRIO  TROD
TROT  TROY  TRUE  TUBA  TUBE  TUCK  TUFT  TUNA
TUNE  TUNG  TURF  TURN  TUSK  TWIG  TWIN  TWIT
ULAN  UNIT  URGE  USED  USER  USES  UTAH  VAIL
VAIN  VALE  VARY  VASE  VAST  VEAL  VEDA  VEIL
VEIN  VEND  VENT  VERB  VERY  VETO  VICE  VIEW
VINE  VISE  VOID  VOLT  VOTE  WACK  WADE  WAGE
WAIL  WAIT  WAKE  WALE  WALK  WALL  WALT  WAND
WANE  WANG  WANT  WARD  WARM  WARN  WART  WASH
WAST  WATS  WATT  WAVE  WAVY  WAYS  WEAK  WEAL
WEAN  WEAR  WEED  WEEK  WEIR  WELD  WELL  WELT
WENT  WERE  WERT  WEST  WHAM  WHAT  WHEE  WHEN
WHET  WHOA  WHOM  WICK  WIFE  WILD  WILL  WIND
WINE  WING  WINK  WINO  WIRE  WISE  WISH  WITH
WOLF  WONT  WOOD  WOOL  WORD  WORE  WORK  WORM
WORN  WOVE  WRIT  WYNN  YALE  YANG  YANK  YARD
YARN  YAWL  YAWN  YEAH  YEAR  YELL  YOGA  YOKE
