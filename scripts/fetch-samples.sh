# This shell script fetches a set of sample articles from PMC, extracts
# them to a subdirectory named 'samples' of the current working directory,
# and renames their download directory to match the PMCID, so they can be
# found easily.

SAMPLEDIR=samples
PMC_BASE_URL=ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/

main(){
  create_folder

  download_file \
      'PMC1762412' \
      'images, equations, tables, video, sound' \
      'aa/e1/' \
      'PLoS_ONE_2006_Dec_27_1%281%29_e133' \
      'PLoS_ONE_2006_Dec_27_1(1)_e133'

  download_file \
      'PMC2270912' \
      'retracted article' \
      'd6/b2/' \
      'PLoS_ONE_2008_Apr_2_3%284%29_e1908' \
      'PLoS_ONE_2008_Apr_2_3(4)_e1908'

  download_file \
      'PMC2467486' \
      'article with corrections' \
      '7e/56/' \
      'PLoS_ONE_2008_Jul_30_3%287%29_e2804' \
      'PLoS_ONE_2008_Jul_30_3(7)_e2804'

  download_file \
      'PMC3003633' \
      'multiple tables' \
      '89/4b/' \
      'Microb_Cell_Fact_2010_Nov_22_9_89' \
      'Microb_Cell_Fact_2010_Nov_22_9_89'

  download_file \
      'PMC3040697' \
      'editorial note' \
      '32/0b/' \
      'BMC_Med_2011_Feb_17_9_17' \
      'BMC_Med_2011_Feb_17_9_17'

  download_file \
      'PMC3192425' \
      'TaxPub, equations' \
      '47/b2/' \
      'Zookeys_2011_Jul_15_%28119%29_37-52' \
      'Zookeys_2011_Jul_15_(119)_37-52'

  download_file \
      'PMC3231133' \
      'long article, equations, figures' \
      '56/cf/' \
      'Sensors_%28Basel%29_2010_Jul_16_10%287%29_6861-6900' \
      'Sensors_(Basel)_2010_Jul_16_10(7)_6861-6900'
}

create_folder(){
    if ! [ -d ${SAMPLEDIR} ]
    then
        mkdir -p ${SAMPLEDIR}
    fi
}

download_file(){
    cd ${SAMPLEDIR}

    echo Downloading $1:  $2
    PMCID=$1
    FTPDIR=$3
    FTPNAME=$4
    LOCALNAME=$5
    wget -c ${PMC_BASE_URL}${FTPDIR}${FTPNAME}.tar.gz \
        --output-document=${PMCID}.tar.gz
    tar xzf ${PMCID}.tar.gz
    mv ${LOCALNAME} ${PMCID}

    cd ..
}

main
