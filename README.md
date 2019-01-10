**OGA--Organelle Genome Assembler**<br />
Copyright (C) 2019 Xiao-Jian Qu<br />

**Contact**<br />
quxiaojian@sdnu.edu.cn<br />

**Prerequisites**<br />
Perl 5, Linux<br />
Bowtie2<br />
SPAdes<br />
Bandage<br />
local BLAST+<br />

**Introduction**<br />
OGA(Organelle Genome Assembler) is capable of assembling complete organelle genome using distantly related species, or even organelle genes as reference. Four steps will be conducted to assemble organelle genome (plastome as example): (1) mapping raw reads to cp reference (optionally, excluding the influence of mt reads by removing mapped mt reads from raw reads); (2) first assembling mapped cp reads to contigs; (3) using contigs as seeds to recruit overlapped reads from raw reads (optionally, raw reads after removing mapped mt reads), then using recruited overlapped reads as new seeds, and iterating this step until no overlapped reads are recruited; (4) second assembling mapped plus recruited reads to scaffolds. In the end, you will get a complete plastome (mt genome) when library size is large enough and sequencing coverage is high enough. Specifically, many aspects, such as sequencing quality, repeats, etc could affect final assembly. This pipeline can be applied for assembling organelle genome from enriched chloroplast DNA and total genomic DNA.<br />

![OGA flowchart](https://github.com/quxiaojian/OGA/blob/master/OGA.png)

**Preparations**<br />
(1) download map software [Bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml), assemble software [SPAdes](http://cab.spbu.ru/software/spades/), assembly graph visualization software [Bandage](https://github.com/rrwick/Bandage), and local BLAST+ software [BLAST+](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download). And put all in PATH.<br />
```
vim ~/.bashrc
export PATH=/xxx/xxx/Bowtie2:$PATH
export PATH=/xxx/xxx/SPAdes:$PATH
export PATH=/xxx/xxx/Bandage:$PATH
export PATH=/xxx/xxx/BLAST+:$PATH
source ~/.bashrc
```
(2) download this repository to your local computer, and put it in PATH. Make it read, write and executable.<br />
```
git clone https://github.com/quxiaojian/OGA.git
vim ~/.bashrc
export PATH=/xxx/xxx/OGA/scripts:$PATH
source ~/.bashrc
chmod a+rwx OGA.pl
chmod a+rwx graph_cleaning.pl
chmod a+rwx OGA_gui.pl
```

You can test OGA.pl by type OGA.pl, which will show the usage information.<br />
```
Usage:
    OGA.pl -i -t -c -m -p -e -k -w -s
    Copyright (C) 2019 Xiao-Jian Qu
    Please contact me <quxiaojian@sdnu.edu.cn>, if you have any bugs or questions.

    [-h -help]           help information.
    [-i -indir]          (default: reads) input directory containing subdirectories with paired-end reads.
    [-t -threads]        (default: 8) bowtie mapping threads.
    [-c -cpref]          (default: cp) indexed cp reference.
    [-m -mtref]          (default: mt) indexed mt reference.
    [-p -organelle]      (default: cp) cp or mt that you want to assemble.
    [-e -exclude]        (default: y) y or n, exclude the influence of mt/cp reads on assembling cp/mt respectively.
    [-k -kmer]           (default: 81,101,121) kmer value.
    [-w -wordsize]       (default: 121) wordsize value or specifically overlap value between two reads.
    [-s -stepnumber]     (default: 3) step number of wordsize saved into memory.
```

**Test**<br />
(1) indexing reference sequence (cp and mt).<br />
```
bowtie2-build cp.fasta cp
bowtie2-build mt.fasta mt
```
(2) mapping, first assembling, recruiting and second assembling.<br />
```
OGA.pl -i test/reads/ -t 8 -c test/reference/cp -m test/reference/mt -p cp -e y -k 81,101,121 -w 121 -s 3
```
or
```
OGA_gui.pl
```
![update gui version of OGA](https://github.com/quxiaojian/OGA/blob/master/OGA_gui.png)

(3) visualizing assembly graph using bandage.<br />
The script graph_cleaning.pl can assist you filter above assembly result (assembly_graph.fastg) by blast and coverage.<br />
```
Usage:
    graph_cleaning.pl -f -d -i -a
    Copyright (C) 2019 Xiao-Jian Qu
    Please contact <quxiaojian@sdnu.edu.cn>, if you have any bugs or questions.

    [-h -help]         help information.
    [-f -fastg]        required: (default: assembly_graph.fastg) spades assembly result.
    [-d -db]           required: (default: reference.fasta) reference sequence in fasta format.
    [-i -min]          required: (default: 50) minimum allowed coverage.
    [-a -max]          required: (default: 10000) maximum allowed coverage.
```

**Notes**<br />
(1) Your raw paired-end reads filename should be xxx_1.fq and xxx_2.fq, or xxx_1.fq.gz and xxx_2.fq.gz, so this script do not need to revise.<br />
(2) The wordsize value (-w) in OGA can be set by yourself. The best value maybe 80% (-w 121) of read length (paired-end reads, 150 bp). If your reads quality is not good, you can decrease this value a little smaller (-w 101).<br />
(3) The step number of wordsize (-s) can also be set by yourself. If your reads quality is not good, you can increase this value a little larger (-s 5).

**Similar scripts**<br />
[MITObim](https://github.com/chrishah/MITObim)<br />
My script is same to MITObim in steps of mapping, assembly. But the step of extension is different. MITObim uses the reads mapping to extend, so it will be time-consuming. However, OGA uses reads recruitment based on overlap between contig end and raw reads to extend, it is quicker than reads mapping.<br />
[ARC](https://github.com/ibest/ARC)<br />
[ORG.Asm](https://git.metabarcoding.org/org-asm/org-asm/wikis/home)<br />
[NOVOPlasty](https://github.com/ndierckx/NOVOPlasty)<br />
[GetOrganelle](https://github.com/Kinggerm/GetOrganelle)<br />
Thanks to Jianjun Jin for giving me good suggestions!

**Citation**<br />
If you use OGA in you scientific research, please cite:<br />
OGA<br />
https://github.com/quxiaojian/OGA<br />
Bowtie2<br />
Langmead B, Salzberg S. Fast gapped-read alignment with Bowtie 2. Nature Methods. 2012, 9:357-359.<br />
SPAdes<br />
Bankevich A., Nurk S., Antipov D., Gurevich A., Dvorkin M., Kulikov A. S., Lesin V., Nikolenko S., Pham S., Prjibelski A., Pyshkin A., Sirotkin A., Vyahhi N., Tesler G., Alekseyev M. A., Pevzner P. A. SPAdes: A New Genome Assembly Algorithm and Its Applications to Single-Cell Sequencing. Journal of Computational Biology. 2012, 19(5):455-477.<br />
Bandage<br />
Wick R.R., Schultz M.B., Zobel J. & Holt K.E. Bandage: interactive visualisation of de novo genome assemblies. Bioinformatics. 2015, 31(20), 3350-3352.<br />
