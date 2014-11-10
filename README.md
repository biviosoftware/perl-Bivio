### Bivio OSS Platform (BOP)

bOP is an open source application development framework primarily
focused on information systems.  The architecture is layered, so you
can use just a little bit, the whole thing, or somewhere in between.

#### CAVEAT

BOP uses many other FOSS packates.  Unfortunately, we haven't created
a convenient way for the general public to import them.  If you would
like to use BOP,
[please contact us](http://www.bivio.biz/pub/contact), and we will do
our best to help you get setup.

#### Development setup

Once BOP and its prerequisites are installed globally, you can setup a
personal development environment with: 

```
curl https://raw.githubusercontent.com/biviosoftware/perl-Bivio/master/setup.sh | bash
. ~/.bashrc
```

Run the web server:

```
bivio httpd run_background
```

You can run the unit and acceptance tests:

```
cd ~/src/biviosoftware/perl-Bivio
bivio test unit .
bivio test acceptance PetShop
```
