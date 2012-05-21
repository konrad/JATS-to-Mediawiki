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
      'PMC3040697' \
      'editorial note' \
      '32/0b/' \
      'BMC_Med_2011_Feb_17_9_17' \
      'BMC_Med_2011_Feb_17_9_17'

  download_file \
      'PMC3003633' \
      'multiple tables' \
      '89/4b/' \
      'Microb_Cell_Fact_2010_Nov_22_9_89' \
      'Microb_Cell_Fact_2010_Nov_22_9_89'

  download_file \
      'PMC3192425' \
      'TaxPub, equations' \
      '47/b2/' \
      'Zookeys_2011_Jul_15_%28119%29_37-52' \
      'Zookeys_2011_Jul_15_(119)_37-52'
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
}

main
