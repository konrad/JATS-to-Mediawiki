## About

jats-to-mediawiki.xsl transforms XML files written in the [NLM/NISO
Journal Archiving Tag Suite][1] XML into [MediaWiki XML][3]. It is a
part of the [Encyclopedia of Original Research (EOR)][4], and we expect
it to be tightly integrated with the [open-access-media-importer][5].

[1]: http://jats.nlm.nih.gov/

[3]: http://www.mediawiki.org/xml/export-0.6/

[4]: http://en.wikiversity.org/wiki/User:OpenScientist/Open_grant_writing_-_Encyclopaedia_of_original_research

[5]: http://en.wikiversity.org/wiki/User:OpenScientist/Open_grant_writing/Wissenswert_2011/Documentation

## Set up your environment

The following command should work in a `bash` shell.

```
# Clone this repository
git clone https://github.com/Klortho/JATS-to-Mediawiki.git
cd JATS-to-Mediawiki

# Get the JATS dtd
mkdir dtd
cd dtd
wget ftp://ftp.ncbi.nlm.nih.gov/pub/jats/archiving/1.0/jats-archiving-dtd-1.0.zip
unzip *.zip
cd ..

# Make sure you have xsltproc
which xsltproc   # should return with the location of your xsltproc command

# Set up XML catalog file
export XML_CATALOG_FILES=`pwd`/dtd/catalog-test-jats-v1.xml
```

## Convert an article

### Automatic

Driver scripts for the JATS-to-Mediawiki conversion library are forthcoming, to be listed here.

### Manual

The following are manual instructions for converting a single article, given its DOI.
It would be fairly easy to script, if you want.

First, you need to find the PMCID for the article.  If you have the DOI (for example,
`10.1371/journal.pone.0010676`) the easiest way to do this is with the [PMC ID converter
API](http://www.ncbi.nlm.nih.gov/pmc/tools/id-converter-api/).  Point your browser at
[http://www.pubmedcentral.nih.gov/utils/idconv/v1.0/?ids=10.1371/journal.pone.0010676&format=json](),
and make a note of the `pmcid` value (in this example, `PMC2873961`).

Next, find the location of the gzip archive file for this article, using the [PMC OA web
service](http://www.ncbi.nlm.nih.gov/pmc/tools/oa-service/).  Point your browser at
[http://www.pubmedcentral.nih.gov/utils/oa/oa.fcgi?id=PMC2873961](), and look for the link with
format `tgz`.

Download that gzip archive with, for example (note the single quotes around the URL):

```
wget 'ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/e7/55/PLoS_One_2010_May_21_5(5)_e10676.tar.gz'
```

Unzip that, and change into that directory.  For example,

```
tar xvfz 'PLoS_One_2010_May_21_5(5)_e10676.tar.gz'
cd 'PLoS_One_2010_May_21_5(5)_e10676'
```

Find the NXML file with `ls *.nxml`.  Now convert it with, for example

```
xsltproc ../jats-to-mediawiki.xsl pone.0010676.nxml > PMC2873961.mw.xml
```

In a browser, go to the `Special:Import` page of your target mediawiki installation, and import it.

You could use the scripts/fetch_samples.sh script to grab several examples
articles, which were used in testing.

## Status

* Pre-alpha

## Documentation

Is on our [Github wiki](https://github.com/Klortho/JATS-to-Mediawiki/wiki).

## Bugs / issues

We're using the [Github issue tracker](https://github.com/Klortho/JATS-to-Mediawiki/issues)
for bug reports and to-do items.

## Contact / Collaborate

Join our [Google Group jats-to-mediawiki](https://groups.google.com/d/forum/jats-to-mediawiki)

## Authors:

* Jeremy Morse
* Chris Maloney
* Konrad Foerstner <konrad@foerstner.org>

## Public domain

This work is in the public domain and may be used and reproduced without
special permission.
