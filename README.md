# About

jats-to-mediawiki.xsl transforms XML files written in the NLM/NISO
Journal Archiving Tag Suite XML [1, 2] into MediaWiki XML [3]. It is a
part of the Encyclopedia of Original Research (EOR).

[1] http://dtd.nlm.nih.gov/

[2] http://jatspan.org/

[3] http://www.mediawiki.org/xml/export-0.6/

# Example (bash shell)
    # Set and env. variable to point to the JATS-To-Mediawiki home,
    # wherever it is that you've put the code.
    $ export JTM_HOME=/~/JATS-To-Mediawiki

    # Get the open-access file list from PMC
    $ wget ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/file_list.txt

    # Find a specific publication file by the PMC ID.
    $ grep PMC3040697 file_list.txt
    32/0b/BMC_Med_2011_Feb_17_9_17.tar.gz BMC Med. 2011 Feb 17; 9:17  PMC3040697

    # Append the filename to the URL ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/
    # and download and unzip this file
    $ wget -c wget -c ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/32/0b/BMC_Med_2011_Feb_17_9_17.tar.gz
    $ tar xzvf BMC_Med_2011_Feb_17_9_17.tar.gz

    # Use an XSLT processor (e.g. xsltproc) to apply the XSL file to the NXML file.
    $ cd BMC_Med_2011_Feb_17_9_17 && \
         xsltproc $JTM_HOME/jats-to-mediawiki.xsl 1741-7015-9-17.nxml > 1741-7015-9-17.mw.xml

    # In a browser, go to the import page of your target mediawiki installation, and import it
    # For example, http://chrisbaloney.com/wiki/index.php/Special:Import

# Status

* Pre-alpha

# Plan

See the [Initial Project Scope page](https://github.com/konrad/JATS-to-Mediawiki/wiki/Initial-Project-Scope)
on the wiki.

# Contact / Collaborate

Please join our [Google Group jats-to-mediawiki](https://groups.google.com/d/forum/jats-to-mediawiki)

# Authors:

* Jeremy Morse
* Chris Maloney
* Konrad Foerstner <konrad@foerstner.org>
