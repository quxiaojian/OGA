##OGA-Organelle Genome Assembly<br />
Copyright (C) 2016 Xiao-Jian Qu<br />

##Contact<br />
quxiaojian@mail.kib.ac.cn<br />

##Prerequisites<br />
Perl<br />
Linux<br />

##General Introduction to OGA<br />
OGA(Organelle Genome Assembly) is capable of assembling complete organelle genome using distantly related species, or even organelle genes as reference. Three steps will be conducted to assemble organelle genome: (1) mapping raw reads to published cp and mt genomes, then getting raw_remove_mt (raw_remove_cp) by removing mapped mt (cp) reads from raw reads, then acquiring seeds as contigs by first assembling mapped cp (mt) reads, (2) recruiting overlapped reads from raw_remove_mt (raw_remove_cp) by extending contigs, then using targetedly recruited overlapped reads as new seeds, and iterate this step until no overlapped reads are recruited, (3) second assembling recruited reads. In the end, you will get a complete circular plastome (mito-genome) when your library is large enough and sequencing depth is deep enough. Specifically, many aspects, such as sequencing quality, repeats, etc could affect final assembly. If no complete circular plastome (mito-genome) are got, you can perform mapping and assembling one or few times to fill gap. This pipeline can be applied for assembling organelle genome from enriched chloroplast DNA and total genomic DNA.<br />

![OGA flowchart](https://github.com/quxiaojian/OGA/blob/master/OGA.png)

##Preparations<br />
(1) download map software [Bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml), assemble softwares such as [spades](http://bioinf.spbau.ru/spades) or [velvet](https://github.com/dzerbino/velvet), and assembly graph visual software [bandage](https://github.com/rrwick/Bandage). And put all in PATH.<br />
```
vim ~/.bashrc
export PATH=/home/xxx/bowtie2:$PATH
export PATH=/home/xxx/spades:$PATH
export PATH=/home/xxx/bandage:$PATH
source ~/.bashrc
```
(2) download this repository to your local computer, and put it in PATH. Make it read, write and executable.<br />
```
git clone https://github.com/quxiaojian/OGA.git
vim ~/.bashrc
export PATH=/home/xxx/OGA/scripts:$PATH
source ~/.bashrc
chmod a+rwx OGA.pl
```

You can test OGA.pl by type OGA.pl, which will show the usage information.<br />
```
Usage:
        OGA.pl -i -t -c -m -p -k -w -s [-r -q]
        Copyright (C) 2016 Xiao-Jian Qu
        Please contact me <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

        [-h -help]           help information.
        [-i -indir]          input dir for multiple subdirs containing paired-end reads (default: Reads).
        [-t -threads]        bowtie mapping threads (default: 8).
        [-c -cpref]          reference of indexed cp (default: cp_reference).
        [-m -mtref]          reference of indexed mt (default: mt_reference).
        [-p -organelle]      cp or mt that you want to assemble (default: cp).
        [-k -kmer]           kmer value (default: 71,81,91,101,111,121).
        [-w -wordsize]       wordsize value or specifically overlap value between two reads (default: 121).
        [-s -stepnumber]     step number of wordsize saved into memory (default: 3).
        [-r -run]            runs for reads recruitment (default: 10000).
        [-q -quick]          speed argument, T consume large memory and less time, F consume small memory and more time (default: F).
```

##Test##<br />
**First**, indexing reference sequence (cp and mt).<br />
```
bowtie2-build cp.fasta cp
bowtie2-build mt.fasta mt
```
**Second**, mapping, first assembling, recruiting and second assembling.<br />
```
OGA.pl -i test/reads/ -t 8 -c test/reference/cp -m test/reference/mt -p cp -k 81,101,121 -w 121 -s 3
```
or
```
OGA_gui.pl
```
![gui version of OGA](https://github.com/quxiaojian/OGA/blob/master/OGA_gui.png)

**Third**, visualizing assembly graph using bandage.<br />

##Notes<br />
(1) Your raw paired-end reads filename should be xxx_1.fq and xxx_2.fq, so this script do not need to revise.<br />
(2) The wordsize value (-w) in OGA can be set by yourself. The best value maybe 80% (-w 121) of read length (paired-end reads, 150 bp). If your reads quality is not good, you can decrease this value a little smaller (-w 101).<br />
(3) The step number of wordsize (-s) can also be set by yourself. If your reads quality is not good, you can increase this value a little larger (-s 5).

##Similar scripts<br />
[MITObim](https://github.com/chrishah/MITObim)<br />
My script is same to MITObim in steps of mapping, assembly. But the step of extension is different. MITObim uses the reads mapping to extend, so it will be time-consuming. However, OGA uses reads recruitment based on overlap between contig end and raw reads to extend, it is quicker than reads mapping.

[GetOrganelle](https://github.com/Kinggerm/GetOrganelle)<br />
Thanks to Jianjun Jin for giving me good suggestions!

[ARC](https://github.com/ibest/ARC)<br />
[ORG.Asm](https://git.metabarcoding.org/org-asm/org-asm/wikis/home)<br />
[NOVOPlasty](https://github.com/ndierckx/NOVOPlasty)<br />

