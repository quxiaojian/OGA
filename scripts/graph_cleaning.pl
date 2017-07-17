#!/usr/bin/perl -w
use strict;
use Data::Dumper;

print "Please input the blast database filename:";
my $db=<STDIN>;
chomp $db;

print "Please input the minumum coverage value:";
my $cov_min=<STDIN>;
chomp $cov_min;
print "Please input the maximum coverage value:";
my $cov_max=<STDIN>;
chomp $cov_min;

open(my $ag_input,"<","assembly_graph.fastg");
open(my $ag_output,">","assembly_graph.fasta");
my $ag_row=<$ag_input>;
print $ag_output $ag_row;
while ($ag_row=<$ag_input>){
	chomp $ag_row;
	if ($ag_row=~ /^>/) {
		print $ag_output "\n".$ag_row."\n";
	}else{
		print $ag_output $ag_row; 
	}
}
print $ag_output "\n";
close $ag_input;
close $ag_output;

my $makeblastdb_command="makeblastdb.exe -in $db -hash_index -dbtype nucl";
my $blastn_command="blastn.exe -task blastn -query assembly_graph.fasta -db $db -outfmt 6 -evalue 0.0001 -out blast";
system($makeblastdb_command);
system($blastn_command);

open(my $input1,"<","assembly_graph.fasta");
open(my $input2,"<","blast");
open(my $output1,">","assembly_graph1.fastg");
open(my $output2,">","assembly_graph2.fastg");

my ($header1,$sequence);
my (%hash1,%hash2,%hash3);
while (defined($header1=<$input1>) and defined($sequence=<$input1>)) {
    chomp ($header1,$sequence);
    $hash1{$header1}=$sequence;
}
#print Dumper \%hash1;

my $row;
while (defined($row=<$input2>)){
    chomp $row;
    my $header2=(split /\t/,$row)[0];
	$hash2{">$header2"}++;
    my $cov=$1 if (($header2=~ /_cov_(\d+.\d+)/g) or ($header2=~ /_cov_(\d+)/g));
    if ($cov > $cov_min and $cov < $cov_max){
		$hash3{">$header2"}++;
	}
}
#print Dumper \%hash2;
#print Dumper \%hash3;

foreach my $key (keys %hash2) {
	print $output1 "$key\n$hash1{$key}\n";
}
foreach my $key (keys %hash3){
    print $output2 "$key\n$hash1{$key}\n";
}

close $input1;
close $input2;
close $output1;
close $output2;
unlink("assembly_graph.fasta");
