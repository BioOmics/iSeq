## Install the latest version of iSeq

```bash
version="1.8.0"
wget "https://github.com/BioOmics/iSeq/releases/download/v${version}/iSeq-v${version}.tar.gz"
tar -zvxf "iSeq-v${version}.tar.gz"
cd iSeq-v${version}/bin/
chmod +x iseq
echo 'export PATH=$PATH:'$(pwd) >> ~/.bashrc
source ~/.bashrc
```

Anyway, as long as you install the following dependencies and **add them to the environment variables**, **iSeq** can be used.

- [pigz](https://github.com/madler/pigz) (>=2.8), compressing FASTQ files into gzip format by multiple threads
- [wget](https://www.gnu.org/software/wget/) (>=1.16), downloading files by ftp or http
- [axel](https://github.com/axel-download-accelerator/axel) (>=2.17), downloading files by multiple threads
- [aspera](https://github.com/IBM/aspera-cli) (=4.4.0), downloading files by Aspera
- [sra-tools](https://github.com/ncbi/sra-tools) (>=2.11.0), fetching SRA download links

```{bash}
# all softwares can be installed by conda
conda create -n iseq -c conda-forge -c bioconda pigz wget axel aspera-cli sra-tools
# Check sotfware version
pigz --version | awk 'NR==1{print $2}'
wget --version | awk 'NR==1{print $3}'
axel --version | awk 'NR==1{print $2}'
ascp --version | awk 'NR==2{print $3}'
srapath --version | awk 'NR==2{print $3}'
# Use the following command to check whether dependent software is installed
iseq --version
```

> [!IMPORTANT]
> Using **Ubuntu on Windows**, installing `Wget` through `conda` may lead to "unable to resolve host address", which in turn may prevent `iSeq` from fetching data. You can don't install `wget` by `conda`. Or, this issue also can be resolved by following command:
> ```bash
> conda activate iseq
> # Map the system's built-in wget to the conda environment, ensuring that wget is properly installed.
> ln -sf /usr/bin/wget $(which wget)
> # Including the 'srapath'. you can install SRA Toolkit and then change the path below to your own.
> ln -sf ~/YourPathway/sratoolkit/bin/srapath $(which srapath)

## How to install dependencies from source on Linux/macOS

### 1. pigz

- Source install (non-Root)

```bash
wget https://zlib.net/pigz/pigz.tar.gz
tar -zvxf pigz.tar.gz
cd pigz
make
echo 'export PATH=$PATH:'$(pwd) >> ~/.bashrc
source ~/.bashrc
# Check sotfware version
pigz --version | awk 'NR==1{print $2}'
```

- apt install for Ubuntu (Root permission required)

```bash
sudo apt install pigz
```

- yum install for Centos (Root permission required)

```bash
sudo yum install pigz
```

- brew install for macOS (non-Root)

```bash
brew install pigz
```

### 2. wget

**`wget` is generally included in most Linux distributions and does not need to be installed by ourselves**

- Source install (non-Root)

```bash
wget https://ftp.gnu.org/gnu/wget/wget-latest.tar.gz
tar -zvxf wget-latest.tar.gz
cd wget-1.24.5 # change software version
./configure --prefix=$(pwd)
make
cd src
echo 'export PATH=$PATH:'$(pwd) >> ~/.bashrc
source ~/.bashrc
# Check sotfware version
wget --version | awk 'NR==1{print $3}'
```

- apt install for Ubuntu (Root permission required)

```bash
sudo apt install wget
```

- yum install for Centos (Root permission required)

```bash
sudo yum install wget
```

- brew install for macOS (non-Root)

```bash
brew install wget
```

### 3. axel

- Source install (non-Root)

```bash
# see "https://github.com/axel-download-accelerator/axel/releases" to fetch the latest version of axel
wget https://github.com/axel-download-accelerator/axel/releases/download/v2.17.14/axel-2.17.14.tar.gz
tar -zvxf axel-2.17.14.tar.gz # change software version
cd axel-2.17.14 # change software version
./configure --prefix=$(pwd)
make && make install
echo 'export PATH=$PATH:'$(pwd) >> ~/.bashrc
source ~/.bashrc
# Check sotfware version
axel --version | awk 'NR==1{print $2}'
```

- apt install for Ubuntu (Root permission required)

```bash
sudo apt install axel
```

- yum install for Centos (Root permission required)

```bash
sudo yum install axel
```

- brew install for macOS (non-Root)

```bash
brew install axel
```

### 4. aspera

- Source install (only support non-Root)

```bash
# see "https://www.ibm.com/aspera/connect" to fetch the latest version of aspera
wget https://d3gcli72yxqn2z.cloudfront.net/downloads/connect/latest/bin/ibm-aspera-connect_4.2.8.540_linux_x86_64.tar.gz
tar -zvxf ibm-aspera-connect_4.2.8.540_linux_x86_64.tar.gz # change software version
bash ibm-aspera-connect_4.2.8.540_linux_x86_64.sh # change software version
echo 'export PATH=$PATH:~/.aspera/connect/bin' >> ~/.bashrc
source ~/.bashrc
# Check sotfware version
ascp --version | awk 'NR==2{print $3}'
```

- brew & ruby install for macOS (non-Root)

```bash
brew install ruby
export PATH="$HOMEBREW_PREFIX/opt/ruby/bin:$PATH"
gem install aspera-cli
export PATH="$HOMEBREW_PREFIX/lib/ruby/gems/3.4.0/bin:$PATH"
ascli config ascp install
mkdir -p $HOME/.local/bin
cp $HOME/.aspera/sdk/ascp $HOME/.local/bin
```

### 5. sra-tools

- Source install (non-Root)

```bash
# see "https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current" to choose the appropriate platform
# e.g. for Ubuntu
wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-ubuntu64.tar.gz
tar -zvxf sratoolkit.current-ubuntu64.tar.gz
cd sratoolkit.3.1.0-ubuntu64/bin/ # change software version
echo 'export PATH=$PATH:'$(pwd) >> ~/.bashrc
source ~/.bashrc
# Check sotfware version
srapath --version | awk 'NR==2{print $3}'
```

- brew install for macOS (non-Root)

```bash
brew install sratoolkit
```

## Check iSeq version finally

```bash
iseq --version
```
