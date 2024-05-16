## Stability
iSeq demonstrated high stability, successfully downloading and passing integrity checks for a large number of NGS files from GSA and INSDC-related databases.

## Efficiency

- FTP Channel: Prioritizing ENA's FTP channel, iSeq showed fastest and stable download speeds with Aspera, while supporting parallel downloads with AXEL.
- Cloud Storage: AXEL was faster for AWS Cloud channel from SRA, while Wget was faster for HUAWEI Cloud channel from GSA.
- Gzip-formatted FASTQ Files Download: Directly fetching gzip-formatted FASTQ files proved to be the fastest method, with the option to use "--fastq" and "--gzip" parameters for specific data types. Increasing threads notably improved compression speed.

## Overview
![benchmark_result](https://github.com/BioOmics/iSeq/blob/main/docs/img/benchmark.png)
