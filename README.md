# About

jats-to-mediawiki.xsl transforms XML files written in the NLM/NISO Journal
Archiving Tag Suite (also called the NLM DTDs) [1] into MediaWiki
XML [3]. 

It is derived from the jpub3-html.xsl [4] file that can be
obtained from NCBI at
ftp://ftp.ncbi.nih.gov/pub/archive_dtd/tools/jpub3-preview-xslt.zip

It is a part of the COASPedia project [5].

[1] http://dtd.nlm.nih.gov/

[2] http://jatspan.org/

[3] http://www.mediawiki.org/xml/export-0.6/

[4] http://dtd.nlm.nih.gov/tools/tools.html

[5] http://www.science3point0.com/coaspedia/index.php/Welcome

Author: Konrad Foerstner <konrad@foerstner.org>

# Example

        # Get the file list:
        ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/file_list.txt

        # Find publication file by the PMC ID e.g. 
        $ grep PMC2935419 file_list.txt
        82/e8/Bioinformatics-26-18-2935419.tar.gz	Bioinformatics. 2010 Sep 15; 26(18):i540-i546	PMC2935419

        # append the this to the URL ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/ 
        #  => ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/82/e8/Bioinformatics-26-18-2935419.tar.gz
        # and download this file
        $ wget ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/82/e8/Bioinformatics-26-18-2935419.tar.gz
        
        # Untar the file
        $ tar xzf Bioinformatics-26-18-2935419.tar.gz
        * Use a XSLT processor (e.g. xsltproc) to apply the XSL file to the NXML file
        $ cd Bioinformatics/26-18/pi540-2935419/ \
           && xsltproc ../../../jats-to-mtediawiki.xsl btq391.nxml > ../../../test.txt \
           && cd ../../../

	# Now Copy the text into a MediaWiki page to render it into HTML

# Status

* Pre-alpha

# Plan

* We support the current version (3.0) of NLM Archiving and Interchange
  DTD as there are existing tool that can convert files in older
  versions to the current one: http://dtd.nlm.nih.gov/tools/tools.html

# Contact / Collaborate

Please join our Google Group jats-to-mediawiki, here:
https://groups.google.com/forum/?fromgroups#!forum/jats-to-mediawiki

