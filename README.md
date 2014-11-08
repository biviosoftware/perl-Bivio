### Bivio OSS Platform

To setup your initial development environment, you can run:

```
curl https://raw.githubusercontent.com/biviosoftware/perl-Bivio/master/setup.sh | bash
```

You can then run apache:

```
~/.bashrc
bivio httpd run_background
```

You can then run the unit and acceptance tests:

```
cd ~/src/biviosoftware/perl-Bivio
bivio test unit .
bivio test acceptance PetShop
```

