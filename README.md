# About

jats-to-mediawiki.xsl transforms XML files written in the NLM/NISO
Journal Archiving Tag Suite XML [1, 2] into MediaWiki XML [3]. It is a
part of the Encyclopedia of Original Research (EOR).

[1] http://dtd.nlm.nih.gov/

[2] http://jatspan.org/

[3] http://www.mediawiki.org/xml/export-0.6/

# Example

    # Get the file list:
    wget ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/file_list.txt

    # Find publication file by the PMC ID e.g.
    $ grep PMC3040697 file_list.txt 
    32/0b/BMC_Med_2011_Feb_17_9_17.tar.gz	BMC Med. 2011 Feb 17; 9:17	PMC3040697

    # Append the filename to the URL ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/
    # and download and unzip this file
    $ wget -c ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/aa/e1/PLoS_ONE_2006_Dec_27_1%281%29_e133.tar.gz
    $ tar xzf PLoS_ONE_2006_Dec_27_1\(1\)_e133.tar.gz

    # Use a XSLT processor (e.g. xsltproc) to apply the XSL file to the NXML file
    $ cd PLoS_ONE_2006_Dec_27_1\(1\)_e133/ && \
         xsltproc ../jats-to-mediawiki.xsl pone.0000133.nxml > mediawiki_import.xml

# Status

* Pre-alpha

# Plan

See the [Initial Project Scope page](https://github.com/konrad/JATS-to-Mediawiki/wiki/Initial-Project-Scope)
on the wiki.

# Contact / Collaborate

Please join our [Google Group jats-to-mediawiki](https://groups.google.com/forum/?fromgroups#!forum/jats-to-mediawiki)

# Authors:

* Jeremy Morse
* Chris Maloney
* Konrad Foerstner <konrad@foerstner.org>
