##OGA-Organelle Genome Assembly<br />
Copyright (C) 2016 Xiao-Jian Qu<br />

##CONTACT<br />
quxiaojian@mail.kib.ac.cn<br />

##PREREQUISITES<br />
GNU<br />
Perl<br />
Linux<br />

##GENERAL INTRODUCTION to OGA<br />
OGA(Organelle Genome Assembly) is capable of assembling complete organelle genome using distantly related plant species, or even organelle genes as reference. Three steps will be conducted to assemble organelle genome: (1) mapping raw reads to published cp and mt genomes, then getting raw_remove_mt (raw_remove_cp) by removing mt (cp) reads from raw reads, then acquiring seeds as contigs by assembling mapped cp (mt) reads, (2) recruiting overlapped reads from raw_remove_mt (raw_remove_cp) by extending contigs, then using targetedly recruited overlapped reads as new seeds, and iterate this step until no overlapped reads are recruited, (3) assembling mapped reads plus recruited reads. In the end, you will get a complete circular plastome (mito-genome) when your library are large enough and sequencing depth are deep enough. Specifically, many aspects, such as sequencing quality, kmer numbers, etc could affect final assembly. If no complete circular plastome (mito-genome) are got, you can perform mapping and assembling one or few times to fill gap. This pipeline is applied for enriched chloroplast DNA and total genomic DNA.<br />

##PREPARATIONS<br />
(1) download map software [Bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml), assemble softwares such as [spades](http://bioinf.spbau.ru/spades) or [velvet](https://github.com/dzerbino/velvet), and assembly graph visual software [bandage](https://github.com/rrwick/Bandage). And put all in PATH.<br />
(3) download this repository to your local computer (git clone git://github.com/quxiaojian/OGA.git), and put it in PATH, and make it read, write and executable (chmod -r a+rwx scripts).<br />

You can test OGA.pl by type ~/PATH/TO/OGA.pl, which will show the usage information.<br />
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

##NOTES<br />
(1) Your raw paired-end reads filename should be '''xxx_1'''.fq and '''xxx_2'''.fq, so this script do not need to revise.<br />
(2) The format of "Sequence identifier" (first line of every four lines, beginning with @ symbol) for my own Illumina reads is as follows: @EAS139:136:FC706VJ:2:5:1000:12850 '''1:N:0''' @EAS139:136:FC706VJ:2:5:1000:12850 '''2:N:0'''<br />
(3) The wordsize value in OGA can be set by yourself. The best value maybe '''80%''' of read length. You can try several times for you case.<br />
(4) The step number of wordsize can also be set by yourself. Default value is '''3'''. If your reads quality is not good, you can increase this value a little larger (4,5,6,...).

##TUTORIAL<br />
**First**, indexing your reference (cp or mt).<br />
```
bowtie2-build cp_reference.fasta cp_reference
bowtie2-build mt_reference.fasta mt_reference
```
**Second**, first assembling, recruiting and second assembling
```
OGA.pl -i -t -c -m -p -k -w -s [-r -q]
```
**Third**, visualizing graph using bandage.<br />
