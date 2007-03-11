# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::SampleText;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Bivio::Biz::Random;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_DATA) = {
    title => [split(/\n/, <<'EOF')],
Aenean Leo Ligula
Aliquam Lectus. Donec Cursus. Suspendisse Potenti
Clamea Admittenda In Itinere Per Atturnatum
Claves Sancti Petri
Clerico Capto Per Statutum Mercatorum
Concordia Cum Veritate
Cras Tempus Mattis Mi
Credo Quia Absurdum Est
Cuiusvis Hominis Est Errare, Nullius Nisi Insipientis In Errore Perseverare
Curabitur Ullamcorper Ultricies Nisi
De Gustibus Non Est Disputandum
Dictum Metus Orci Sit Amet Felis
Docendo Disco, Scribendo Cogito
Duis Ante. Praesent Sed Elit Ut Lectus Hendrerit Varius
Entitas Ipsa Involvit Aptitudinem Ad Extorquendum Certum Assensum
Ex Abundanti Cautela
Fere Libenter Homines Id Quod Volunt Credunt
Fusce Fermentum. Nullam Cursus Lacinia Erat
Gutta Cavat Lapidem Non Vi Sed Saepe Cadendo
Haec Olim Meminisse Iuvabit
Honor Virtutis Praemium
Igne Natura Renovatur Integra
In Hac Habitasse Platea Dictumst
In Lumine Tuo Videbimus Lumen
In Manus Tuas Commendo Spiritum Meum
Ipsa Scientia Potestas Est
Iura Novit Curia
Juris Ignorantia Est Cum Jus Nostrum Ignoramus
Jus Ad Bellum
Justitia Omnibus
Justo Metus Blandit Velit
Leges Sine Moribus Vanae
Liberate Me Ex Infernis
Lupus Non Mordet Lupum
Lux Mentis Lux Orbis
Magna Europa Est Patria Nostra
Mala Tempora Currunt
Malum Quo Communius Eo Peius
Manus Manum Lavat
Media Vita In Morte Sumus
Memores Acti Prudentes Futuri
Miles Gloriosus
Miserabile Visu
Mobilis In Mobili
Montis Insignia Calpe
Morbi Non Justo Sit Amet Erat Molestie Pellentesque
Natura Non Contristatur
Navigare Necesse Est Vivere Non Est Necesse
Ne Sutor Ultra Crepidam
Nec Dextrorsum, Nec Sinistrorsum
Nemo Nisi Per Amicitiam Cognoscitur
Nil Nisi Malis Terrori
Nil Satis Nisi Optimum
Non Facias Malum Ut Inde Fiat Bonum
Non In Legendo Sed In Intelligendo Legis Consistunt
Non Progredi Est Regredi
Non Silba, Sed Anthar; Deo Vindice
Nulla Dies Sine Linea
Nulla Eget Nisl
Nunc Scio Quid Sit Amor
Nunquam Non Paratus
O Homines Ad Servitutem Paratos
Obscurum Per Obscurius
Omnia Dicta Fortiora Si Dicta Latina
Omnia Praesumuntur Legitime Facta Donec Probetur In Contrarium
Opus Anglicanum
Ordo Ab Chao
Orta Recens Quam Pura Nites
Panem Et Circenses
Para Bellum
Parvis Imbutus Tentabis Grandia Tutus
Pauca Sed Matura
Pax Maternum, Ergo Pax Familiarum
Pax Vobiscum
Pendent Opera Interrupta
Phasellus Quis Leo Nec Risus Dapibus Tristique
Phasellus Quis Leo Nec Risus Dapibus Tristique
Post Hoc Ergo Propter Hoc
Praemonitus Praemunitus
Primum Movens
Prior Tempore Potior Iure
Pro Brasilia Fiant Eximia
Pro Studio Et Labore
Pulvis Et Umbra Sumus
Quamdiu Bene Gesserit
Quando Omni Flunkus, Mortati
Quare Clausum Fregit
Quem Di Diligunt Adulescens Moritur
Quia Suam Uxorem Etiam Suspiciore Vacare Vellet
Quisque Libero Metus, Condimentum Nec
Quo Errat Demonstrator
Quo Fata Ferunt
Quod Erat Demonstrandum
Quod Gratis Asseritur, Gratis Negatur
Quod Licet Iovi Non Licet Bovi
Quod Me Nutrit Me Destruit
Radix Malorum Est Cupiditas
Rebus Sic Stantibus
Reductio Ad Absurdum
Reductio Ad Infinitum
Repetitio Est Mater Studiorum
Rerum Cognoscere Causas
Sed Elementum Diam
Si Tacuisses, Philosophus Mansisses
Suspendisse Semper Dictum Enim
Vestibulum Ante Ipsum Primis In Faucibus Orci Luctus Et Ultrices Posuere Cubilia Curae
Vitae Est Id Lacus Posuere Scelerisque
Vivamus At Wisi
EOF
    paragraph => [split(/\n\n/, <<'EOF')],
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium.

Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui.

Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. pDonec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero.

Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia.

Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus.

Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi.

Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis.

Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce id purus. Ut varius tincidunt libero. Phasellus dolor. Maecenas vestibulum mollis diam. Pellentesque ut neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

In dui magna, posuere eget, vestibulum et, tempor auctor, justo. In ac felis quis tortor malesuada pretium. Pellentesque auctor neque nec urna. Proin sapien ipsum, porta a, auctor quis, euismod ut, mi. Aenean viverra rhoncus pede. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Ut non enim eleifend felis pretium feugiat. Vivamus quis mi. Phasellus a est. Phasellus magna.

In hac habitasse platea dictumst. Curabitur at lacus ac velit ornare lobortis. Curabitur a felis in nunc fringilla tristique. Morbi mattis ullamcorper velit. Phasellus gravida semper nisi. Nullam vel sem. Pellentesque libero tortor, tincidunt et, tincidunt eget, semper nec, quam. Sed hendrerit. Morbi ac felis. Nunc egestas, augue at pellentesque laoreet, felis eros vehicula leo, at malesuada velit leo quis pede. Donec interdum, metus et hendrerit aliquet, dolor diam sagittis ligula, eget egestas libero turpis vel mi. Nunc nulla. Fusce risus nisl, viverra et, tempor et, pretium in, sapien. Donec venenatis vulputate lorem.

Morbi nec metus. Phasellus blandit leo ut odio. Maecenas ullamcorper, dui et placerat feugiat, eros pede varius nisi, condimentum viverra felis nunc et lorem. Sed magna purus, fermentum eu, tincidunt eu, varius ut, felis. In auctor lobortis lacus. Quisque libero metus, condimentum nec, tempor a, commodo mollis, magna. Vestibulum ullamcorper mauris at ligula. Fusce fermentum. Nullam cursus lacinia erat. Praesent blandit laoreet nibh.

Fusce convallis metus id felis luctus adipiscing. Pellentesque egestas, neque sit amet convallis pulvinar, justo nulla eleifend augue, ac auctor orci leo non est. Quisque id mi. Ut tincidunt tincidunt erat. Etiam feugiat lorem non metus. Vestibulum dapibus nunc ac augue. Curabitur vestibulum aliquam leo. Praesent egestas neque eu enim. In hac habitasse platea dictumst. Fusce a quam. Etiam ut purus mattis mauris sodales aliquam. Curabitur nisi. Quisque malesuada placerat nisl. Nam ipsum risus, rutrum vitae, vestibulum eu, molestie vel, lacus.

Sed augue ipsum, egestas nec, vestibulum et, malesuada adipiscing, dui. Vestibulum facilisis, purus nec pulvinar iaculis, ligula mi congue nunc, vitae euismod ligula urna in dolor. Mauris sollicitudin fermentum libero. Praesent nonummy mi in odio. Nunc interdum lacus sit amet orci. Vestibulum rutrum, mi nec elementum vehicula, eros quam gravida nisl, id fringilla neque ante vel mi. Morbi mollis tellus ac sapien. Phasellus volutpat, metus eget egestas mollis, lacus lacus blandit dui, id egestas quam mauris ut lacus. Fusce vel dui. Sed in libero ut nibh placerat accumsan. Proin faucibus arcu quis ante. In consectetuer turpis ut velit. Nulla sit amet est. Praesent metus tellus, elementum eu, semper a, adipiscing nec, purus. Cras risus ipsum, faucibus ut, ullamcorper id, varius ac, leo. Suspendisse feugiat. Suspendisse enim turpis, dictum sed, iaculis a, condimentum nec, nisi. Praesent nec nisl a purus blandit viverra. Praesent ac massa at ligula laoreet iaculis. Nulla neque dolor, sagittis eget, iaculis quis, molestie non, velit.

Mauris turpis nunc, blandit et, volutpat molestie, porta ut, ligula. Fusce pharetra convallis urna. Quisque ut nisi. Donec mi odio, faucibus at, scelerisque quis, convallis in, nisi. Suspendisse non nisl sit amet velit hendrerit rutrum. Ut leo. Ut a nisl id ante tempus hendrerit. Proin pretium, leo ac pellentesque mollis, felis nunc ultrices eros, sed gravida augue augue mollis justo. Suspendisse eu ligula. Nulla facilisi. Donec id justo. Praesent porttitor, nulla vitae posuere iaculis, arcu nisl dignissim dolor, a pretium mi sem ut ipsum. Curabitur suscipit suscipit tellus.

Praesent vestibulum dapibus nibh. Etiam iaculis nunc ac metus. Ut id nisl quis enim dignissim sagittis. Etiam sollicitudin, ipsum eu pulvinar rutrum, tellus ipsum laoreet sapien, quis venenatis ante odio sit amet eros. Proin magna. Duis vel nibh at velit scelerisque suscipit. Curabitur turpis. Vestibulum suscipit nulla quis orci. Fusce ac felis sit amet ligula pharetra condimentum. Maecenas egestas arcu quis ligula mattis placerat. Duis lobortis massa imperdiet quam. Suspendisse potenti.

Pellentesque commodo eros a enim. Vestibulum turpis sem, aliquet eget, lobortis pellentesque, rutrum eu, nisl. Sed libero. Aliquam erat volutpat. Etiam vitae tortor. Morbi vestibulum volutpat enim. Aliquam eu nunc. Nunc sed turpis. Sed mollis, eros et ultrices tempus, mauris ipsum aliquam libero, non adipiscing dolor urna a orci. Nulla porta dolor. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos.

Pellentesque dapibus hendrerit tortor. Praesent egestas tristique nibh. Sed a libero. Cras varius. Donec vitae orci sed dolor rutrum auctor. Fusce egestas elit eget lorem. Suspendisse nisl elit, rhoncus eget, elementum ac, condimentum eget, diam. Nam at tortor in tellus interdum sagittis. Aliquam lobortis. Donec orci lectus, aliquam ut, faucibus non, euismod id, nulla. Curabitur blandit mollis lacus. Nam adipiscing. Vestibulum eu odio.

Vivamus laoreet. Nullam tincidunt adipiscing enim. Phasellus tempus. Proin viverra, ligula sit amet ultrices semper, ligula arcu tristique sapien, a accumsan nisi mauris ac eros. Fusce neque. Suspendisse faucibus, nunc et pellentesque egestas, lacus ante convallis tellus, vitae iaculis lacus elit id tortor. Vivamus aliquet elit ac nisl. Fusce fermentum odio nec arcu. Vivamus euismod mauris.

In ut quam vitae odio lacinia tincidunt. Praesent ut ligula non mi varius sagittis. Cras sagittis. Praesent ac sem eget est egestas volutpat. Vivamus consectetuer hendrerit lacus. Cras non dolor. Vivamus in erat ut urna cursus vestibulum. Fusce commodo aliquam arcu. Nam commodo suscipit quam. Quisque id odio. Praesent venenatis metus at tortor pulvinar varius.

Aliquam lectus. Donec cursus. Suspendisse potenti. Mauris magna ligula, eleifend sit amet, lobortis nec, sodales eu, erat. Suspendisse adipiscing. Phasellus pharetra, massa a aliquam aliquet, justo orci posuere mauris, id cursus massa nisl in est. Sed egestas erat in pede. Mauris feugiat pretium odio. Praesent aliquam mollis sapien. Integer massa nulla, laoreet id, adipiscing id, condimentum a, lorem. In id purus.

Maecenas consequat. Aenean eget dui. Nullam arcu. In hac habitasse platea dictumst. Aliquam erat volutpat. Sed volutpat. Integer at dui sed sapien cursus commodo. Nunc et metus. Phasellus quam nisi, dictum et, ultricies ut, aliquam nec, mauris. Integer commodo mauris sed pede. Phasellus in nulla eu sem mattis aliquet. Nam id augue. Etiam blandit accumsan lacus. Donec nec nisi.

Etiam dapibus augue ac arcu. Donec eget massa tincidunt dolor gravida suscipit. Integer sapien erat, tincidunt accumsan, vestibulum et, porta consectetuer, enim. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In porttitor, mi id venenatis nonummy, diam neque fermentum mi, ut fringilla eros dolor a libero.

Proin pretium wisi. Mauris egestas. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Maecenas accumsan nunc in nunc. Sed non arcu ac wisi adipiscing posuere. Proin eu leo. Aliquam erat volutpat. Sed ultricies nulla eu tortor. Etiam vitae orci. Morbi elementum nulla et odio ornare tempor.

Sed non augue vel dolor auctor dignissim. Suspendisse mollis ornare ipsum. Integer sodales ultrices ipsum. Ut quis odio ut nibh rhoncus vestibulum. Quisque augue diam, pretium sit amet, imperdiet eget, laoreet quis, wisi. Phasellus quis leo nec risus dapibus tristique. Donec faucibus, ligula at tempor aliquam, dui elit aliquet turpis, eu adipiscing massa metus ac orci. Cras pede. Sed volutpat tempus lacus.
EOF
};

sub paragraph {
    return _data();
}

sub title {
    return _data();
}

sub _data {
    my($a) = $_DATA->{__PACKAGE__->my_caller};
    return $a->[Bivio::Biz::Random->integer(scalar(@$a))];
}


1;
