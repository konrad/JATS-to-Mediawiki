import sys, os, traceback
import argparse
import requests

def main():
    try:

        # parse command line options
        try:
            # standard flags
            parser = argparse.ArgumentParser(description='Command-line interface to jats-to-mediawiki.xslt, a script to manage conversion of articles (documents) from JATS xml format to MediaWiki markup, based on DOI or PMCID')
            parser.add_argument('-t', '--tmpdir', default='tmp/', help='path to temporary directory for purposes of this script')
            parser.add_argument('-x', '--xmlcatalogfiles', default='dtd/catalog-test-jats-v1.xml', help='path to xml catalog files for xsltproc')

            # includes arbitrarily long list of keywords, or an input file
            parser.add_argument('-i', '--infile', nargs='?', type=argparse.FileType('r'), default=sys.stdin, help='path to input file', required=False)
            parser.add_argument('-o', '--outfile', nargs='?', type=argparse.FileType('w'), default=sys.stdout, help='path to output file', required=False)
            parser.add_argument('-a', '--articleids', nargs='+', default=None, help='an article ID or article IDs, either as DOIs or PMCIDs')

            args = parser.parse_args()

            print args #debug

        except:
            print 'Unable to parse options, use the --help flag for usage information'
            sys.exit(-1)

        '''
        Unicode handling
        (decode to unicode early, use unicode everywhere, encode late to string such as when
        writing to disk or print)
        '''
        # Use this function to decode early
        def to_unicode_or_bust( obj, encoding='utf-8-sig'):
            if isinstance(obj, basestring):
                if not isinstance(obj, unicode):
                    obj = unicode(obj, encoding)
                return obj
        # use .encode('utf-8') to encode late

        # Handle and convert input values
        tmpdir = args.tmpdir
        xmlcatalogfiles = args.xmlcatalogfiles
        infile = args.infile
        outfile = args.outfile
        articleids = []
        # add articleids if passed as option values
        if args.articleids:
            articleids.extend([to_unicode_or_bust(articleid) for articleid in args.articleids])
        # add articleids from file or STDIN
        if not sys.stdin.isatty() or infile.name != "<stdin>":
            articleids.extend([to_unicode_or_bust(line.strip()) for line in infile.readlines()])
            print "trying to read"

        print articleids #debug

        # set environment variable for xsltproc and jats dtd
        try:
            cwd = to_unicode_or_bust(os.getcwd())
            os.environ["XML_CATALOG_FILES"] = cwd + to_unicode_or_bust("/") + to_unicode_or_bust(xmlcatalogfiles)
        except:
            print 'Unable to set XML_CATALOG_FILES environment variable'
            sys.exit(-1)

        # create temporary directory for zips
        tmpdir = cwd + to_unicode_or_bust(tmpdir)
        try:
            if not os.path.exists(tmpdir):
                os.makedirs(tmpdir)
        except:
            print 'Unable to find or create temporary directory'
            sys.exit(-1)

        # define the params for the query
        for articleid in articleids:

            params = {
            }

            if articleid:
                print articleid.encode('utf-8')

    except KeyboardInterrupt:
        print "Killed script with keyboard interrupt, exiting..."
    except Exception:
        traceback.print_exc(file=sys.stdout)
    sys.exit(0)

if __name__ == "__main__":
    main()
