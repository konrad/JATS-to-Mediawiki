EXAMPLE_FOLDER=PMC_XML_examples

main(){
	create_folder
	download_files
	unpack_files
}

create_folder(){
    if ! [ -d ${EXAMPLE_FOLDER} ]
    then
        mkdir -p ${EXAMPLE_FOLDER}
    fi
}

download_files(){
    PMC_BASE_URL=ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/
    echo PMC1762412 images, equations, tables, video, sound
    wget -P ${EXAMPLE_FOLDER} -c ${PMC_BASE_URL}aa/e1/PLoS_ONE_2006_Dec_27_1%281%29_e133.tar.gz
    echo PMC3040697 Editorial note
    wget -P ${EXAMPLE_FOLDER} -c ${PMC_BASE_URL}32/0b/BMC_Med_2011_Feb_17_9_17.tar.gz
    echo PMC3003633 Multiple tables
    wget -P ${EXAMPLE_FOLDER} -c ${PMC_BASE_URL}89/4b/Microb_Cell_Fact_2010_Nov_22_9_89.tar.gz
    echo PMC3192425 TaxPub
    wget -P ${EXAMPLE_FOLDER} -c ${PMC_BASE_URL}47/b2/Zookeys_2011_Jul_15_%28119%29_37-52.tar.gz
    echo PMC3192425 Equations
    wget -P ${EXAMPLE_FOLDER} -c ${PMC_BASE_URL}47/b2/Zookeys_2011_Jul_15_%28119%29_37-52.tar.gz
}

unpack_files(){
    for FILE in $(ls ${EXAMPLE_FOLDER}/*)
    do
	tar xzf ${FILE}
	mv $(basename ${FILE} .tar.gz) ${EXAMPLE_FOLDER}
    done
}

main