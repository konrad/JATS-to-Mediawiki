import sys, os, traceback
import argparse
import requests

def main():
    try:

        # parse command line options
        try:
            # standard flags
            parser = argparse.ArgumentParser(description='')
            parser.add_argument('-t', '--tmpdir', default='tmp/', help='path to temporary directory for purposes of this script')
            parser.add_argument('-x', '--xmlcatalogfiles', default='dtd/catalog-test-jats-v1.xml', help='path to xml catalog files for xsltproc')

            # some boolean flags
            parser.add_argument('--some-bool', dest='somebool', action='store_false', help='some test bool')
            parser.set_defaults(somebool=False)

            # includes arbitrarily long list of keywords, or an input file
            parser.add_argument('-i', '--infile', nargs='?', type=argparse.FileType('r'), default=sys.stdin, help='path to input file')
            parser.add_argument('-o', '--outfile', nargs='?', type=argparse.FileType('w'), default=sys.stdout, help='path to output file')
            parser.add_argument('-a', '--articles', nargs='+', default=None, help='article ID(s), either as DOIs or PMCIDs')

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
        somebool = args.somebool
        tmpdir = arg.tmpdir
        xmlcatalogfiles = args.xmlcatalogfiles
        infile = args.infile
        outfile = args.outfile
        articles = []
        # add articles if passed as option values
        if args.articles:
            articles.extend([to_unicode_or_bust(articles) for article in args.articles])
        # add articles from file or STDIN
        if infile:
            articles.extend([to_unicode_or_bust(line.strip()) for line in infile.readlines()])

        print articles #debug

        # set environment variable for xsltproc and jats dtd
        try:
            cwd = to_unicode_or_bust(os.getcwd())
            os.environ["XML_CATALOG_FILES"]= cwd + "u'/" + to_unicode_or_bust(xmlcatalogfiles)
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
        for article in articles:

            params = {
            }

    except KeyboardInterrupt:
        print "Killed script with keyboard interrupt, exiting..."
    except Exception:
        traceback.print_exc(file=sys.stdout)
    sys.exit(0)

if __name__ == "__main__":
    main()
