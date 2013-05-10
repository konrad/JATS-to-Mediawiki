## About

jats-to-mediawiki.xsl transforms XML files written in the [NLM/NISO
Journal Archiving Tag Suite][1] XML into [MediaWiki XML][3]. It is a
part of the [Encyclopedia of Original Research (EOR)][4], and we expect
it to be tightly integrated with the [open-access-media-importer][5].

[1]: http://jats.nlm.nih.gov/

[3]: http://www.mediawiki.org/xml/export-0.6/

[4]: http://en.wikiversity.org/wiki/User:OpenScientist/Open_grant_writing_-_Encyclopaedia_of_original_research

[5]: http://en.wikiversity.org/wiki/User:OpenScientist/Open_grant_writing/Wissenswert_2011/Documentation

## Example (bash):

    # Get the open-access file list from PMC
    $ wget ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/file_list.txt

    # Find a specific publication file by the PMC ID.
    $ grep PMC3040697 file_list.txt
    32/0b/BMC_Med_2011_Feb_17_9_17.tar.gz BMC Med. 2011 Feb 17; 9:17  PMC3040697

    # Append the filename to the URL ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/
    # and download and unzip this file
    $ wget -c wget -c ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/32/0b/BMC_Med_2011_Feb_17_9_17.tar.gz
    $ tar xzvf BMC_Med_2011_Feb_17_9_17.tar.gz

    # Use an XSLT processor (e.g. xsltproc) to apply the XSL file to the .nxml file.
    $ cd BMC_Med_2011_Feb_17_9_17
    $ ls *.nxml
    1741-7015-9-17.nxml
    $ xsltproc $JTM/jats-to-mediawiki.xsl 1741-7015-9-17.nxml > PMC3040697.mw.xml

In a browser, go to the import page of your target mediawiki installation, and import it.

You could use the scripts/fetch_samples.sh script to grab several examples
articles, which were used in testing.

## Status

* Pre-alpha

## Documentation

Is on our [Github wiki](https://github.com/konrad/JATS-to-Mediawiki/wiki).

## Bugs / issues

We're using the [Github issue tracker](https://github.com/konrad/JATS-to-Mediawiki/issues)
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