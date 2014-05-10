#!/bin/bash

#####
# Provides simple bash interface to jats-to-mediawiki.xslt
#####

# Make sure you have xsltproc
command -v xsltprocfoo >/dev/null 2>&1 || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }

# Set up XML catalog file
export XML_CATALOG_FILES=`pwd`/dtd/catalog-test-jats-v1.xml
