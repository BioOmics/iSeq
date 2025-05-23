## iSeq使用方法 
- 中文纯手打，英文是由ChatGPT翻译的😀
```{bash}
$ iseq --help

Usage:
  iseq -i accession [options]

Required option:
  -i, --input     [text|file]   Single accession or a file containing multiple accessions.
                                Note: Only one accession per line in the file.

Optional options:
  -m, --metadata                Skip the sequencing data downloads and only fetch the metadata for the accession.
  -g, --gzip                    Download FASTQ files in gzip format directly (*.fastq.gz).
                                Note: if *.fastq.gz files are not available, SRA files will be downloaded and converted to *.fastq.gz files.
  -q, --fastq                   Convert SRA files to FASTQ format.
  -t, --threads   int           The number of threads to use for converting SRA to FASTQ files or compressing FASTQ files (default: 8).
  -e, --merge     [ex|sa|st]    Merge multiple fastq files into one fastq file for each Experiment, Sample or Study.
                                ex: merge all fastq files of the same Experiment into one fastq file. Accession format: ERX, DRX, SRX, CRX.
                                sa: merge all fastq files of the same Sample into one fastq file. Accession format: ERS, DRS, SRS, SAMC, GSM.
                                st: merge all fastq files of the same Study into one fastq file. Accession format: ERP, DRP, SRP, CRA.
  -d, --database  [ena|sra]     Specify the database to download SRA sequencing data (default: ena).
                                Note: new SRA files may not be available in the ENA database, even if you specify "ena".
  -p, --parallel  int           Download sequencing data in parallel, the number of connections needs to be specified, such as -p 10.
                                Note: breakpoint continuation cannot be shared between different numbers of connections.
  -a, --aspera                  Use Aspera to download sequencing data, only support GSA/ENA database.
  -s, --speed     int           Download speed limit (MB/s) (default: 1000 MB/s).
  -o, --output    text          The output directory. If not exists, it will be created (default: current directory).
  -h, --help                    Show the help information.
  -v, --version                 Show the script version.
```

### 1. `-i`, `--input`

输入你想下载的accession，首先获取accession的metadata，然后逐一对包含在内的Run ID进行下载。v1.1.0版本之后可以接收文件输入，每行一个accession。这个文件最好在linux下通过vim编辑，要不然从windows上传的话可能文字编码有问题影响下载（如win通常是`CR LF`, 而Linux能识别的是`LF`格式的）。

```bash
iseq -i PRJNA211801
```

目前支持以下5个数据库的6种数据格式，支持的accession前缀如下：

| Databases | BioProject | Study | BioSample | Sample | Experiment | Run  |
| --------- | ---------- | ----- | --------- | ------ | ---------- | ---- |
| **GSA**   | PRJC       | CRA   | SAMC      | \      | CRX        | CRR  |
| **SRA**   | PRJNA      | SRP   | SAMN      | SRS    | SRX        | SRR  |
| **ENA**   | PRJEB      | ERP   | SAME      | ERS    | ERX        | ERR  |
| **DDBJ**  | PRJDB      | DRP   | SAMD      | DRS    | DRX        | DRR  |
| **GEO**   | GSE        | \     | GSM       | \      | \          | \    |

其中对于来自于GEO数据库的两种数据格式`GSE/GSM`，会直接获取到与之关联的`PRJNA/SAMN`，然后获取到包含在内的Run ID并进行测序数据的下载。因此，本质上还是从SRA数据库中下载测序数据。

以下是一些例子：

| Accession Type | Prefixes                       | Example                                                     |
| -------------- | ------------------------------ | ----------------------------------------------------------- |
| BioProject     | PRJEB, PRJNA, PRJDB, PRJC, GSE | PRJEB42779, PRJNA480016, PRJDB14838, PRJCA000613, GSE122139 |
| Study          | ERP, DRP, SRP, CRA             | ERP126685, DRP009283, SRP158268, CRA000553                  |
| BioSample      | SAMD, SAME, SAMN, SAMC         | SAMD00258402, SAMEA7997453, SAMN06479985, SAMC017083        |
| Sample         | ERS, DRS, SRS, GSM             | ERS5684710, DRS259711, SRS2024210, GSM7417667               |
| Experiment     | ERX, DRX, SRX, CRX             | ERX5050800, DRX406443, SRX4563689, CRX020217                |
| Run            | ERR, DRR, SRR, CRR             | ERR5260405, DRR421224, SRR7706354, CRR311377                |

总之，无论你的accession是6种数据格式的哪一种，最终都会对其中包含的Run ID逐一下载并检查文件的md5值，如果md5值和公共数据库中的不一致，则会进行至多3轮的重新下载。如果在3次尝试内下载并校验成功，则会将文件名存入`success.log`中，否则，下载失败，文件名将会存入`fail.log`中。

### 2. `-m`, `--metadata `

只下载accession的样本信息，跳过测序数据的下载。

```bash
iseq -i PRJNA211801 -m
iseq -i CRR343031 -m
```

因此，无论使用不使用`-m`参数，accession的样本信息都会被获取到，如果metadata获取不到的话，iSeq程序会退出，不会执行后续下载。

> [!NOTE]
> **注意1**：如果检索的accession在SRA/ENA/DDBJ/GEO数据库中，iSeq会首先在ENA数据库中进行检索，如果可以检索到样本信息，则会通过[ENA API](https://www.ebi.ac.uk/ena/portal/api/swagger-ui/index.html)下载`TSV`格式的metadata，通常有191列。但是，有些最新在SRA数据库中公开的数据可能不会及时同步到ENA数据库中。因此，如果一旦无法在ENA数据库中获取到metadata的信息，则直接通过[SRA Database Backend](https://trace.ncbi.nlm.nih.gov/Traces/sra-db-be/)下载`CSV`格式的metadata，通常有30列。为了和TSV格式保持一致，会通过`sed -i 's/,/\t/g'`的方式改为TSV格式，如何单个字段含有逗号，可能会造成列的混乱。最终，你将得到名字为`${accession}.metadata.tsv`的样本信息。

> [!NOTE]
>**注意2**：如果检索的accession在GSA数据库中，iSeq会通过GSA的[getRunInfo](https://ngdc.cncb.ac.cn/gsa/search/getRunInfo)接口获取样本信息,下载`CSV`格式的metadata，通常有25列，上述得到的metadata信息会被保存为`${accession}.metadata.csv`文件。为了补充更加详细的metadata信息，iSeq会自动通过GSA的[exportExcelFile](https://ngdc.cncb.ac.cn/gsa/file/exportExcelFile)接口获取accession所属的Project的metadata信息，下载`XLSX`格式的metadata，通常有3个sheet，分别是`Sample`, `Experiment`, `Run`。最终得到的metadata信息会被保存为`${accession}.metadata.xlsx`文件。总而言之，你最终将得到名字为`${accession}.metadata.csv`和`CRA*.metadata.xlsx`的样本信息。

### 3. `-g`, `--gzip`

直接下载gzip格式的FASTQ文件，如果不能直接下载，则会下载SRA文件并通过多线程分解和压缩转换为gzip格式。

```bash
iseq -i SRR1178105 -g
```

由于`GSA`数据库直接存储的格式大多数为`gzip`格式，因此，如果检索的accession来自于`GSA`数据库，无论是否使用`-g` 参数都可以直接下载`gzip`格式的FASTQ文件。如果accession来自于`SRA/ENA/DDBJ/GEO`数据库，那么iSeq会首先访问`ENA`数据库，如果可以直接下载`gzip`格式的FASTQ文件，则会直接下载，否则，会下载`SRA`文件并通过`fasterq-dump`工具转换为`FASTQ`, 然后通过`pigz`工具对`FASTQ`文件进行压缩，最终得到`gzip`格式的FASTQ文件。

### 4. `-q`, `--fastq`

将下载完成的SRA文件分解为多个未压缩的FASTQ格式。

```bash
iseq -i SRR1178105 -q
```

该参数只有在accession来自于`SRA/ENA/DDBJ/GEO`数据库，并且下载的文件为SRA文件时才有效。总之，SRA文件下载完成后，iSeq会通过`fasterq-dump`工具转换为`FASTQ`文件，除此之外，可以通过`-t`参数指定转换的线程数。

> [!NOTE]
> **注意1**：`-q`在下载单细胞数据,尤其对于scATAC-Seq数据，可以很好的分解出`I1`, `R1`, `R2`, `R3`四个文件。而如果通过`-g`参数直接下载FASTQ文件，只会得到`R1`, `R3`两个文件（如：[SRR13450125](https://www.ebi.ac.uk/ena/browser/view/SRR13450125)），这可能会导致后续数据分析时出现问题。

> [!NOTE]
> **`注意2`**：`-q`和`-g`同时使用的时候，会先下载SRA文件，然后通过`fasterq-dump`工具转换为`FASTQ`文件，最后通过`pigz`压缩为gzip格式。并不是直接下载gzip格式的FASTQ文件，这对获取全面的单细胞数据非常有用。

### 5. `-t`, `--threads`

指定分解SRA文件为FASTQ文件或者压缩FASTQ文件的线程数，默认为8。

```bash
iseq -i SRR1178105 -q -t 10
```

考虑到测序数据一般都是大文件，因此，可以通过`-t`参数指定分解的线程数，但是，线程数不是越多越好，因为线程数过多会导致CPU或者IO负载过高，尤其是`fasterq-dump`会占用大量IO，从而影响其他任务的执行。

### 6. `-e`, `--merge`

将Experiment中的多个FASTQ文件合并为一个FASTQ文件。 v1.1.0版本之后，不仅可以对同一个Experiment中的多个FASTQ文件合并，还可以选择不用的参数对Sample (-e sa)或者Study (-e st)进行合并。

```bash
iseq -i SRX003906 -g -e ex
```

虽然大多数情况下，一个Experiment仅包含一个Run，但是有些测序数据中的Experiment中可能包含多个Run（如[SRX003906](https://www.ebi.ac.uk/ena/browser/view/SRX003906), [CRX020217](https://ngdc.cncb.ac.cn/gsa/search?searchTerm=CRX020217)），因此，可以通过`-e`参数将Experiment中的多个FASTQ文件合并为一个FASTQ文件。考虑到双端测序时，`fastq_1`和`fastq_2`文件需要同时合并且对应行号的序列名需要保持一致，因此，iSeq会按照相同的顺序合并多个FASTQ文件。最终，对于单端测序数据会生成一个文件：`SRX*.fastq.gz`，对于双端测序数据会生成两个文件：`SRX*_1.fastq.gz`和`SRX*_2.fastq.gz`。对于Sample (-e sa)或者Study (-e st)同理。

> [!NOTE]
> **注意1**：如果accession是Run ID，则不能使用`-e`参数，反正就是你想合并的时候，输入的accession必须大于等于要合并的那一级所需要的accession。目前，iSeq支持合并gzip压缩和未压缩的FASTQ文件，对于bam文件和tar.gz文件等暂不支持合并。

> [!NOTE]
> **注意2**：正常情况下，一个Experiment仅包含一个Run时，相同的Run应该有相同的前缀。如`SRR52991314_1.fq.gz`和`SRR52991314_2.fq.gz`都有相同的前缀名`SRR52991314`，此时，iSeq会直接重命名为`SRX*_1.fastq.gz`和`SRX*_2.fastq.gz`。但是有例外的情况，如[CRX006713](https://ngdc.cncb.ac.cn/gsa/search?searchTerm=CRX006713)中包含有一个Run为`CRR007192`，但是该Run包含多个前缀名不同的文件，此时，iSeq会直接重命名为`SRX*_原本的文件名`，如这里将直接重命名为：`CRX006713_CRD015671.gz`和`CRX006713_CRD015672.gz`。

### 7. `-d`, `--database`

指定下载SRA文件的数据库，支持`ena`和`sra`两种数据库。

```bash
iseq -i SRR1178105 -d sra 
```

通常情况下，iSeq默认会自动检测可用的数据库，所以不需要指定`-d`参数。但是，有些SRA文件可能在ENA数据库中下载速度较慢，此时可以通过`-d sra`强制指定从SRA数据库下载数据。

> [!NOTE]
> **注意**：如果在ENA数据库中没有找到对应的SRA文件，即使指定了`-d ena`参数，iSeq依旧会自动切换到SRA数据库进行下载。

### 8. `-p`, `--parallel`

开启多线程下载，需要指定下载的线程数。

```bash
iseq -i PRJNA211801 -p 10
```

考虑到`wget`在部分情况下下载速度较慢，因此，可以通过`-p`参数让`iSeq`调用`axel`工具进行多线程下载。

> [!NOTE]
> **注意1**：多线程下载的断点续传功能只能在同一个线程内有效，即如果在第一次下载时使用了`-p 10`参数，那么在第二次下载时也需要使用`-p 10`参数，否则无法实现断点续传。

> [!NOTE]
> **注意2**：如上，iSeq将全程保持10个连接进行下载，因此在下载的过程中你将多次看到相同的`Connection * finished`弹出，这是因为有些连接下载完成后会立即释放，然后重新建立新的连接进行下载。

### 9. `-a`, `--aspera`

使用Aspera进行下载。

```bash
iseq -i PRJNA211801 -a -g
```

由于`Aspera`下载速度较快，因此，可以通过`-a`参数让`iSeq`调用`ascp`工具进行下载。可惜的是，目前仅有`GSA`和`ENA`数据库支持`Aspera`下载，`NCBI SRA`数据库由于广泛采用了`Google Cloud` 和 `AWS Cloud`技术以及其他原因（请看[Avoid-using-ascp](https://github.com/ncbi/sra-tools/wiki/Avoid-using-ascp-directly-for-downloads)），暂无法使用`Aspera`进行下载。

> [!NOTE]
> **注意1**：在访问`GSA`数据库时，如果存在`HUAWEI Cloud`的下载链接，`iSeq`会优先通过`HUAWEI Cloud`通道下载，即使使用了`-a`参数，`iSeq`也会自动切换到`HUAWEI Cloud`下载。这么做的原因是`HUAWEI Cloud`下载速度更快和稳定。因此，在下载`GSA`数据时，推荐使用`-a`参数，这样如果访问不到`HUAWEI Cloud`通道，通过`Aspera`通道下载速度也不慢，否则，只能通过`wget`或者`axel`进行下载，而这两种方式下载速度较慢。

> [!NOTE]
> **注意2**：由于`Aspera`需要key文件，因此，`iSeq`会自动在`conda`环境或者`~/.aspera`目录下查找key文件，如果没有找到，则无法下载。

### 10. `-o`, `--output`

v1.1.0之后可以选择输出文件的位置，如果不存在相应的文件夹，则创建

```bash
iseq -i SRR931847 -o PRJNA211801
```

### 11. `-s`, `--speed`

v1.2.0之后可以选择限速下载，单位是MB/s
```bash
iseq -i SRR931847 -s 10
```

### 12 `-k`, `--skip-md5`

v1.9.2之后可以选择跳过md5文件完整性检验。当你初次跳过后想再次进行md5检验，只需要删除-k参数后，执行相同的代码就可以了。



