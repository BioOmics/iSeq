#!/bin/bash

if command -v iseq >/dev/null 2>&1; then
    sleep 0
else
    echo "iseq is not installed"
    echo "Please install iseq first"
    echo "conda create -n iseq -c conda-forge -c bioconda iseq"
    exit 1
fi

calculate_time_difference() {
    start_time=$1
    end_time=$2
    method=$3
    diff=$((end_time - start_time))
    echo -e "${method}\t${diff}"
}

# Create a directory to store the downloaded files
if [ ! -d "iseq" ]; then
    mkdir iseq
fi



cd ./iseq
# =======================================ENA=============================================
for ((i=1; i<=20; i++)); do
    # SRX3662754 (SE, 540 MB)
    SRX=SRX3662754
    # CRX917377 (SE, 540 MB)
    CRX=CRX917377

    # Perform tests for ENA FTP download by Wget
    start=$(date +%s)
    iseq -i $SRX
    end=$(date +%s)
    calculate_time_difference $start $end "Wget" >> ../timeENA.log
    rm -rf *


    # Perform tests for ENA FTP download by Aspera
    start=$(date +%s)
    iseq -i $SRX -a
    end=$(date +%s)
    calculate_time_difference $start $end "Aspera" >> ../timeENA.log
    rm -rf *


    # Perform tests for ENA FTP download by 10 parallel by AXEL
    start=$(date +%s)
    iseq -i $SRX -p 10
    end=$(date +%s)
    calculate_time_difference $start $end "AXEL" >> ../timeENA.log
    rm -rf *
# =======================================ENA=============================================

# =======================================SRA=============================================
    # Perform tests for SRA HTTPS download by Wget
    start=$(date +%s)
    iseq -i $SRX -d sra
    end=$(date +%s)
    calculate_time_difference $start $end "Wget" >> ../timeSRA.log
    rm -rf *


    # Perform tests for SRA HTTPS download by AXEL
    start=$(date +%s)
    iseq -i $SRX -d sra -p 10
    end=$(date +%s)
    calculate_time_difference $start $end "AXEL" >> ../timeSRA.log
    rm -rf *
# =======================================SRA=============================================

# =======================================ENA FQ/FQ.GZ====================================
    # Perform tests to compare the time taken for directly downloading fq.gz files versus downloading fq files and then compressing them into fq.gz.
    start=$(date +%s)
    iseq -i $SRX -a -q
    end=$(date +%s)
    calculate_time_difference $start $end "--fastq" >> ../timeFQ.log
    rm -rf *


    start=$(date +%s)
    iseq -i $SRX -a -q -g
    end=$(date +%s)
    calculate_time_difference $start $end "--fastq+gzip" >> ../timeFQ.log
    rm -rf *

    start=$(date +%s)
    iseq -i $SRX -a -g
    end=$(date +%s)
    calculate_time_difference $start $end "--gzip" >> ../timeFQ.log
    rm -rf *
# =======================================ENA FQ/FQ.GZ====================================


# =======================================GSA FTP=============================================
    # Perform tests for GSA FTP download by Wget
    start=$(date +%s)
    iseq -i $CRX -m
    wget ftp://download.big.ac.cn/gsa2/CRA014342/CRR1007729/CRR1007729.fq.gz
    end=$(date +%s)
    calculate_time_difference $start $end "Wget" >> ../timeGSAFTP.log
    rm -rf *


    # Perform tests for GSA FTP download by AXEL
    start=$(date +%s)
    iseq -i $CRX -m
    axel -n 10 -a -c ftp://download.big.ac.cn/gsa2/CRA014342/CRR1007729/CRR1007729.fq.gz
    end=$(date +%s)
    calculate_time_difference $start $end "AXEL" >> ../timeGSAFTP.log
    rm -rf *

    # Perform tests for GSA FTP download by Aspera
    start=$(date +%s)
    iseq -i $CRX -m
    wget https://ngdc.cncb.ac.cn/gsa/file/downFile?fileName=download/aspera01.openssh -O .asperaGSA.openssh --quiet
    ascp -P 33001 -i .asperaGSA.openssh -QT -l 1000m -k1 -d aspera01@download.cncb.ac.cn:gsa2/CRA014342/CRR1007729/CRR1007729.fq.gz .
    end=$(date +%s)
    calculate_time_difference $start $end "Aspera" >> ../timeGSAFTP.log
    rm -rf *
# =======================================GSA HUAWEI_CLOUD=============================================
    # Perform tests for GSA HUAWEI_CLOUD download by AXEL
    start=$(date +%s)
    iseq -i $CRX -m
    axel -n 10 -a -c https://cncb-gsa.obs.cn-north-4.myhuaweicloud.com/data/gsapub/CRA014342/CRR1007729/CRR1007729.fq.gz
    end=$(date +%s)
    calculate_time_difference $start $end "AXEL" >> ../timeGSAHW.log
    rm -rf *

    # Perform tests for GSA HUAWEI_CLOUD download by Wget
    start=$(date +%s)
    iseq -i $CRX -m
    wget https://cncb-gsa.obs.cn-north-4.myhuaweicloud.com/data/gsapub/CRA014342/CRR1007729/CRR1007729.fq.gz
    end=$(date +%s)
    calculate_time_difference $start $end "Wget" >> ../timeGSAHW.log
    rm -rf *
done
cd ..