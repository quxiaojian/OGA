#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Data::Dumper;

my $global_options=&argument();
my $fastg=&default("assembly_graph.fastg","fastg");
my $db=&default("cp.fasta","db");
my $cov_min=&default("100","min");
my $cov_max=&default("10000","max");


open(my $ag_input,"<",$fastg);
open(my $ag_output,">","assembly_graph.fasta");
my $ag_row=<$ag_input>;
print $ag_output $ag_row;
while ($ag_row=<$ag_input>){
	$ag_row=~ s/\r|\n//g;
	if ($ag_row=~ /^>/) {
		print $ag_output "\n".$ag_row."\n";
	}else{
		print $ag_output $ag_row;
	}
}
#print $ag_output "\n";
close $ag_input;
close $ag_output;

my $osname=$^O;
if ($osname eq "MSWin32") {
	system("makeblastdb.exe -in $db -hash_index -dbtype nucl");
	system("blastn.exe -task blastn -query assembly_graph.fasta -db $db -outfmt 6 -evalue 0.0001 -out blast");
}elsif ($osname eq "cygwin") {
	system("makeblastdb -in $db -hash_index -dbtype nucl");
	system("blastn -task blastn -query assembly_graph.fasta -db $db -outfmt 6 -evalue 0.0001 -out blast");
}elsif ($osname eq "linux") {
	system("makeblastdb -in $db -hash_index -dbtype nucl");
	system("blastn -task blastn -query assembly_graph.fasta -db $db -outfmt 6 -evalue 0.0001 -out blast");
}elsif ($osname eq "darwin") {
	system("makeblastdb -in $db -hash_index -dbtype nucl");
	system("blastn -task blastn -query assembly_graph.fasta -db $db -outfmt 6 -evalue 0.0001 -out blast");
}

open(my $input1,"<","assembly_graph.fasta");
open(my $input2,"<","blast");
open(my $output1,">","assembly_graph1.fastg");
open(my $output2,">","assembly_graph2.fastg");

my ($header1,$sequence);
my (%hash1,%hash2,%hash3);
while (defined($header1=<$input1>) and defined($sequence=<$input1>)) {
	$header1=~ s/\r|\n//g;
	$sequence=~ s/\r|\n//g;
    $hash1{$header1}=$sequence;
}
close $input1;
#print Dumper \%hash1;

my $row;
while (defined($row=<$input2>)){
	$row=~ s/\r|\n//g;
    my $header2=(split /\t/,$row)[0];
	my $header3;
	if ($header2=~ /;$/) {
		$header3=">".$header2;
	}elsif ($header2!~ /;$/) {
		$header3=">".$header2.";";
	}
	$hash2{$header3}++;
    my $cov=$1 if (($header2=~ /_cov_(\d+.\d+)/g) or ($header2=~ /_cov_(\d+)/g));
    if ($cov > $cov_min and $cov < $cov_max){
		$hash3{$header3}++;
	}
}
close $input2;
#print Dumper \%hash2;
#print Dumper \%hash3;

foreach my $key1 (keys %hash2) {
	print $output1 "$key1\n",$hash1{$key1},"\n";
}
close $output1;
foreach my $key2 (keys %hash3){
	print $output2 "$key2\n",$hash1{$key2},"\n";
}
close $output2;
unlink("assembly_graph.fasta");
unlink("blast");


sub argument{
	my @options=("help|h","fastg|f:s","db|d:s","min|i:i","max|a:i");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'h'} or $options{'help'});
	if(!exists $options{'fastg'}){
		print "***ERROR: No fastg is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'db'}){
		print "***ERROR: No db is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'min'}){
		print "***ERROR: No min is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'max'}){
		print "***ERROR: No max is assigned!!!\n";
		exec ("pod2usage $0");
	}
	return \%options;
}

sub default{
	my ($default_value,$option)=@_;
	if(exists $global_options->{$option}){
		return $global_options->{$option};
	}
	return $default_value;
}


__DATA__

=head1 NAME

    graph_cleaning.pl

=head1 COPYRIGHT

    copyright (C) 2018 Xiao-Jian Qu

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head1 DESCRIPTION

    graph_cleaning

=head1 SYNOPSIS

    graph_cleaning.pl -f -d -i -a
    Copyright (C) 2018 Xiao-Jian Qu
    Please contact <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]         help information.
    [-f -fastg]        required: (default: assembly_graph.fastg) spades assembly result.
    [-d -db]           required: (default: cp.fasta) chloroplast reference in fasta format.
    [-i -min]          required: (default: 100) minimum allowed coverage.
    [-a -max]          required: (default: 10000) maximum allowed coverage.

=cut
