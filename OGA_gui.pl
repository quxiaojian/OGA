#!/usr/bin/perl -w
use strict;
use Tk;
use Time::HiRes qw(time);
use File::Find;
use File::Copy;
use Term::ProgressBar;
use Data::Dumper;

my $mainwindow=MainWindow->new;
$mainwindow->title("OGA-Organelle Genome Assembly");
$mainwindow->geometry("850x350");

#indir
my $frame_indir=$mainwindow->Frame();
$frame_indir->pack(-expand=>1,-fill=>"both",-side=>"top");
my $label_indir=$frame_indir->Label(-text=>"Input Directory: ",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_indir->pack(-side=>"left");
my $indir="";
my $button_indir=$frame_indir->Button(-text=>"Open",-width=>25,-command=>sub{&selectdirectory});
$button_indir->pack(-side=>"left");

#threads
my $frame_threads=$mainwindow->Frame();
$frame_threads->pack(-expand=>1,-fill=>"both",-side=>"top");
my $label_threads=$frame_threads->Label(-text=>"Bowtie mapping threads",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_threads->pack(-side=>"left");
my $threads=8;
my $entry_threads=$frame_threads->Entry(-textvariable=>\$threads,-width=>25,-font=>"Arial 11 bold",-background=>"Orange");
$entry_threads->pack(-side=>"left");

#cpreference
my $frame_cp=$mainwindow->Frame();
$frame_cp->pack(-expand=>1,-fill=>"both",-side=>"top");
my $label_cp=$frame_cp->Label(-text=>"Path to indexed cp reference: ",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_cp->pack(-side=>"left");
my $cpreference=$frame_cp->Button(-text=>"Open",-width=>25);
$cpreference->pack(-side=>"left");
$cpreference->configure(-command=>sub {&loadcpreference});
my $cpref;

#mtreference
my $frame_mt=$mainwindow->Frame();
$frame_mt->pack(-expand=>1,-fill=>"both",-side=>"top");
my $label_mt=$frame_mt->Label(-text=>"Path to indexed mt reference: ",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_mt->pack(-side=>"left");
my $mtreference=$frame_mt->Button(-text=>"Open",-width=>25);
$mtreference->pack(-side=>"left");
$mtreference->configure(-command=>sub {&loadmtreference});
my $mtref;

#organ
my $frame_organ=$mainwindow->Frame();
$frame_organ->pack(-expand=>1,-fill=>'both',-side=>'top');
my $label_organ=$frame_organ->Label(-text=>"cp or mt that you want to assemble",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_organ->pack(-side=>"left");
my $organ="cp";
my $entry_organ=$frame_organ->Entry(-textvariable=>\$organ,-width=>25,-font=>"Arial 11 bold",-background=>"Orange");
$entry_organ->pack(-side=>"left");

#kmer
my $frame_kmer=$mainwindow->Frame();
$frame_kmer->pack(-expand=>1,-fill=>'both',-side=>'top');
my $label_kmer=$frame_kmer->Label(-text=>"Kmer values",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_kmer->pack(-side=>"left");
my $kmer="71,81,91,101,111,121";
my $entry_kmer=$frame_kmer->Entry(-textvariable=>\$kmer,-width=>25,-font=>"Arial 11 bold",-background=>"Orange");
$entry_kmer->pack(-side=>"left");

#ws
my $frame_ws=$mainwindow->Frame();
$frame_ws->pack(-expand=>1,-fill=>'both',-side=>'top');
my $label_ws=$frame_ws->Label(-text=>"Wordsize value or specifically overlap value between two reads",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_ws->pack(-side=>"left");
my $ws=121;
my $entry_ws=$frame_ws->Entry(-textvariable=>\$ws,-width=>25,-font=>"Arial 11 bold",-background=>"Orange");
$entry_ws->pack(-side=>"left");

#number
my $frame_number=$mainwindow->Frame();
$frame_number->pack(-expand=>1,-fill=>'both',-side=>'top');
my $label_number=$frame_number->Label(-text=>"Step number of wordsize saved into memory",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_number->pack(-side=>"left");
my $number=3;
my $entry_number=$frame_number->Entry(-textvariable=>\$number,-width=>25,-font=>"Arial 11 bold",-background=>"Orange");
$entry_number->pack(-side=>"left"); 

#run
my $frame_run=$mainwindow->Frame();
$frame_run->pack(-expand=>1,-fill=>'both',-side=>'top');
my $label_run=$frame_run->Label(-text=>"(Optional) Runs for paired-end reads recruitment",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_run->pack(-side=>"left");
my $run=10000;
my $entry_run=$frame_run->Entry(-textvariable=>\$run,-width=>25,-font=>"Arial 11 bold",-background=>"Orange");
$entry_run->pack(-side=>"left");

#quick
my $frame_quick=$mainwindow->Frame();
$frame_quick->pack(-expand=>1,-fill=>'both',-side=>'top');
my $label_quick=$frame_quick->Label(-text=>"(Optional) Speed argument, (T)rue or F(alse)",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_quick->pack(-side=>"left");
my $quick="F";
my $entry_quick=$frame_quick->Entry(-textvariable=>\$quick,-width=>25,-font=>"Arial 11 bold",-background=>"Orange");
$entry_quick->pack(-side=>"left");

#contact
my $frame_contact=$mainwindow->Frame();
$frame_contact->pack(-expand=>1,-fill=>"both",-side=>"top");
my $label_contact=$frame_contact->Label(-text=>"Email",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_contact->pack(-side=>"left");
my $email="quxiaojian\@mail.kib.ac.cn";
my $entry_contact=$frame_contact->Entry(-textvariable=>\$email,-width=>25,-font=>"Arial 11 bold",-background=>"Orange");
$entry_contact->pack(-side=>"left");

#run and exit
my $button_run=$mainwindow->Button(-text=>"Run...",-command=>sub {&run($indir,$threads,$cpref,$mtref,$organ,$kmer,$ws,$number,$run,$quick)});
$button_run->pack(-side=>"left");

my $button_exit=$mainwindow->Button(-text=>"Exit...",-command=>sub {exit});
$button_exit->pack(-side=>"right");

MainLoop;


########################################
##subroutines
########################################
sub selectdirectory{
	$indir=$mainwindow->chooseDirectory();
	if (defined $indir){
		$label_indir->configure(-text=>$label_indir->cget("-text").$indir);
	}
}

sub loadcpreference {
	my @types = (
				["Reference files",[qw/.fasta .fa/]],
				["All files","*"],
				);
	my $filepath1=$mainwindow->getOpenFile(-filetypes=>\@types) or return ();
	my $filepath2=substr($filepath1,0,rindex($filepath1,"."));
	$cpref=$filepath2;
	$label_cp->configure(-text=>$label_cp->cget("-text").$filepath2);
}

sub loadmtreference {
	my @types = (
				["Reference files",[qw/.fasta .fa/]],
				["All files","*"],
				);
	my $filepath1=$mainwindow->getOpenFile(-filetypes=>\@types) or return ();
	my $filepath2=substr($filepath1,0,rindex($filepath1,"."));
	$mtref=$filepath2;
	$label_mt->configure(-text=>$label_mt->cget("-text").$filepath2);
}

sub gettime {
	my ($sec,$min,$hour,$day,$mon,$year,$weekday,$yeardate,$savinglightday)=(localtime(time));
	#my %hash=(1=>"Mon",2=>"Tue",3=>"Wed",4=>"Thu",5=>"Fri",6=>"Sat",7=>"Sun");
	$year+=1900;
	$mon=($mon<9)?"0".($mon+1):($mon+1);
	$day=($day<10)?"0$day":$day;
	$hour=($hour<10)?"0$hour":$hour;
	$min=($min<10)?"0$min":$min;
	$sec=($sec<10)?"0$sec":$sec;

	#my $now="$year.$mon.$day $hash{$weekday} $hour:$min:$sec";
	my $now="$year.$mon.$day $hour:$min:$sec";
}

sub extend_seed {
	my ($seed,$ws,$prefix,$overlapped_read)=@_;
	my @sub_seed;
	for (my $i=0;$i<((length $seed)-$ws+1);$i++){
		push @sub_seed,substr($seed,$i,$ws);
	}

	foreach my $key (@sub_seed){
		if (exists $prefix->{$key}){
			foreach (@{$prefix->{$key}}){
				print $overlapped_read "$_\n";
			}
			delete $prefix->{$key};
		}
	}
	@sub_seed=();
}

sub run {
	my ($indir,$threads,$cpref,$mtref,$organ,$kmer,$ws,$number,$run,$quick)=@_;
	my $now1=time;
	print "OGA.pl Organelle Genome Assembly
	Copyright (C) 2016 Xiao-Jian Qu
	Email: quxiaojian\@mail.kib.ac.cn\n\n";

	my $cprefdir=substr ($cpref,0,rindex($cpref,"\/"));
	my $mtrefdir=substr ($mtref,0,rindex($mtref,"\/"));

	my $pattern1="_1.fq";
	my $pattern2="_2.fq";
	my (@filenames1,@filenames2);
	my $target1=sub {
		if (/$pattern1/){
			push @filenames1,"$File::Find::name";
		}
		return;
	};
	find(\&$target1,$indir);
	my $target2=sub {
		if (/$pattern2/){
			push @filenames2,"$File::Find::name";
		}
		return;
	};
	find(\&$target2,$indir);

	while (@filenames1 and @filenames2) {
		my $forward=shift @filenames1;
		my $name1=substr ($forward,0,rindex($forward,"\/"));#dirname
		my $name2=substr ($forward,rindex($forward,"\/")+1,-5);#FC111
		my $reverse=shift @filenames2;

		my $remove;
		if ($organ eq "cp"){
			$remove="mt";
		}elsif($organ eq "mt"){
			$remove="cp";
		}
		my $removed_fq1="$name1/$name2\_1_remove_$remove.fq";
		my $removed_fq2="$name1/$name2\_2_remove_$remove.fq";

		my $s_name1="$name1/seed_reads_$organ.1.fq";
		my $s_name2="$name1/seed_reads_$organ.2.fq";
		my $s_name3="$name1/seed_reads_$remove.1.fq";
		my $s_name4="$name1/seed_reads_$remove.2.fq";

		my $now2=&gettime;
		print "$now2 || Begin dealing with $forward and $reverse!\n";


		########################################
		##mapping
		########################################
		if (!-e $s_name1){
			my $now3=&gettime;
			print "$now3 || Begin mapping of $forward and $reverse for cp reads!\n";

			my $cp_command="bowtie2 -p $threads --very-fast-local "."-x $cpref "."-1 ".$forward." -2 ".$reverse." --al-conc $name1/seed_reads_cp"." -S $cprefdir/$name2\_cp.sam\n";
			system ($cp_command);
			my $rename_command1="mv $name1/seed_reads_cp.1 $name1/seed_reads_cp.1.fq";
			my $rename_command2="mv $name1/seed_reads_cp.2 $name1/seed_reads_cp.2.fq";
			system ($rename_command1);
			system ($rename_command2);

			my $now4=&gettime;
			print "$now4 || Finish mapping of $forward and $reverse for cp reads!\n";
		}
		if (!-e $s_name3){
			my $now5=&gettime;
			print "$now5 || Begin mapping of $forward and $reverse for mt reads!\n";

			my $mt_command="bowtie2 -p $threads --very-fast-local "."-x $mtref "."-1 ".$forward." -2 ".$reverse." --al-conc $name1/seed_reads_mt"." -S $mtrefdir/$name2\_mt.sam\n";
			system ($mt_command);
			my $rename_command3="mv $name1/seed_reads_mt.1 $name1/seed_reads_mt.1.fq";
			my $rename_command4="mv $name1/seed_reads_mt.2 $name1/seed_reads_mt.2.fq";
			system ($rename_command3);
			system ($rename_command4);

			my $now6=&gettime;
			print "$now6 || Finish mapping of $forward and $reverse for mt reads!\n";
		}


		########################################
		##remove_mt_or_cp_from_fq
		########################################
		if (!-e $removed_fq1){
			my $now7=&gettime;
			print "$now7 || Begin removing $remove reads from $forward and $reverse!\n";

			#my $logfile="remove_$remove\_from_fq.log";
			#system ("rm -rf $logfile") if (-e $logfile);
			#open(my $log,">>",$logfile);

			my $seed_forward="$name1/seed_reads_$remove.1.fq";
			my $seed_reverse="$name1/seed_reads_$remove.2.fq";
			open (my $seed1,"<",$seed_forward);
			open (my $seed2,"<",$seed_reverse);
			#open (my $duplicated,">","duplicated.fq");
			my ($header1,$sequence1,$plus1,$quality1,$header2,$sequence2,$plus2,$quality2);
			my (%order,%hashA);
			my $i=0;
			while(defined ($header1=<$seed1>) && defined ($sequence1=<$seed1>) && defined ($plus1=<$seed1>) && defined ($quality1=<$seed1>) && defined ($header2=<$seed2>) && defined ($sequence2=<$seed2>) && defined ($plus2=<$seed2>) && defined ($quality2=<$seed2>)){
				chomp ($header1,$sequence1,$plus1,$quality1,$header2,$sequence2,$plus2,$quality2);
				$order{$header1}=$i++;
				$order{$header2}=$i++;
				$hashA{$header1}=$sequence1."\n".$plus1."\n".$quality1."\n";
				$hashA{$header2}=$sequence2."\n".$plus2."\n".$quality2."\n";
			}
			close $seed1;
			close $seed2;

			open (my $fq1,"<",$forward);
			open (my $fq2,"<",$reverse);
			my ($header3,$sequence3,$plus3,$quality3,$header4,$sequence4,$plus4,$quality4);
			my (%hashB,@array1,@array2);
			my $count=0;
			#print $log "Duplicated rows in files $seed_forward//$seed_reverse and $forward//$reverse!\n";
			while(defined ($header3=<$fq1>) && defined ($sequence3=<$fq1>) && defined ($plus3=<$fq1>) && defined ($quality3=<$fq1>) && defined ($header4=<$fq2>) && defined ($sequence4=<$fq2>) && defined ($plus4=<$fq2>) && defined ($quality4=<$fq2>)){
				chomp ($header3,$sequence3,$plus3,$quality3,$header4,$sequence4,$plus4,$quality4);
				$hashB{$header3}=$sequence3."\n".$plus3."\n".$quality3."\n";
				$hashB{$header4}=$sequence4."\n".$plus4."\n".$quality4."\n";
				unless (defined $order{$header3} && defined $order{$header4}){
					push (@array1,$header3);
					push (@array2,$header4);
				}else{
					$order{$header3}=0;
					$order{$header4}=0;
					#print $duplicated "$header3\n$hashA{$header3}";
					#print $duplicated "$header4\n$hashA{$header4}";
					$count++;
				}
			}
			#print $duplicated "\n";
			#print $log "$count reads\n";
			close $fq1;
			close $fq2;

			my $seed_name=substr($seed_forward,0,rindex($seed_forward,".")-2);#dirnme/seed_reads_$remove
			open (my $unique_seed,">","$seed_name\_unique.fq");
			open (my $unique_fq1,">",$removed_fq1);
			open (my $unique_fq2,">",$removed_fq2);

			#print $log "Unique rows in file $seed_forward and $seed_reverse!\n";
			my $countA=0;
			my %rorder=reverse %order;
			foreach my $key (sort keys %rorder) {
				if ($key>0) {
					print $unique_seed "$rorder{$key}\n$hashA{$rorder{$key}}";
					$countA++;
				}
			}
			#print $log "$countA reads\n";

			#print $log "Unique rows in file $forward and $reverse!\n";
			my $countB=(scalar @array1)+(scalar @array2);
			foreach my $element1 (@array1){
				print $unique_fq1 "$element1\n$hashB{$element1}";
			}
			foreach my $element2 (@array2){
				print $unique_fq2 "$element2\n$hashB{$element2}";
			}
			#print $log "$countB reads\n";
	
			#if ($countA==0 and $countB==0 ){
				#print $log "Two files are identical!!!\n";
			#}
			close $unique_seed;
			close $unique_fq1;
			close $unique_fq2;
			#close $log;
			%order=();
			%hashA=();
			%hashB=();
			@array1=();
			@array2=();
			%rorder=();

			my $uniq_seed_name="$seed_name\_unique.fq";
			system ("rm -rf $uniq_seed_name") if ((-s $uniq_seed_name)==0);
			my $now8=&gettime;
			print "$now8 || Finish removing $remove reads from $forward and $reverse!\n";
		}


		########################################
		##first_assembly
		########################################
		my $spades_dir1="$name1/Spades_$organ\_1";
		my $contig1="$spades_dir1/assembly_graph.fastg";

		if (!-e $contig1){
			my $now9=&gettime;
			print "$now9 || Begin first assembling $s_name1 and $s_name2!\n";

			my $assembly_command="spades.py --careful -1 ".$s_name1." -2 ".$s_name2." -k $kmer "."-o $spades_dir1\n";
			system ($assembly_command);

			my $now10=&gettime;
			print "$now10 || Finish first assembling $s_name1 and $s_name2!\n";
		}


		########################################
		##changing_format_of_fastg
		########################################
		my $contig2="$spades_dir1/assembly_graph.fasta";
		if (!-e $contig2){
			my $now11=&gettime;
			print "$now11 || Begin changing the format of assembly_graph.fastg!\n";

			open(my $contiginput,"<",$contig1);
			open(my $contigoutput,">",$contig2);
			my $line=<$contiginput>;
			print $contigoutput $line;
			while ($line=<$contiginput>){
				chomp $line;
				if ($line=~ /^>/) {
					print $contigoutput "\n".$line."\n";
				}else{
					print $contigoutput $line;
				}
			}
			print $contigoutput "\n";

			my $now12=&gettime;
			print "$now12 || Finish changing the format of assembly_graph.fastg!\n";
		}


		########################################
		##combine_seed_reads
		########################################
		my $seed_reads="$name1/seed_reads.fq";
		my $cnt1;
		my %seed;
		my $now13=&gettime;
		print "$now13 || Begin combing paired-end seed reads!\n";

		open(my $input1,"<",$s_name1) or die $!;
		open(my $input2,"<",$s_name2) or die $!;
		open(my $output1,">",$seed_reads) or die $!;
		my ($header5,$header6,$sequence5,$sequence6,$plus5,$plus6,$quality5,$quality6);
		while (defined($header5=<$input1>) && defined($sequence5=<$input1>) && defined($plus5=<$input1>) && defined($quality5=<$input1>) && defined($header6=<$input2>) && defined($sequence6=<$input2>) && defined($plus6=<$input2>) && defined($quality6=<$input2>)) {
			$header5=~ s/\n|\r//g;
			$sequence5=~ s/\n|\r//g;
			$plus5=~ s/\n|\r//g;
			$quality5=~ s/\n|\r//g;
			$header6=~ s/\n|\r//g;
			$sequence6=~ s/\n|\r//g;
			$plus6=~ s/\n|\r//g;
			$quality6=~ s/\n|\r//g;
			$cnt1++;
			$seed{$header5}=$sequence5."\n".$plus5."\n".$quality5;
			$seed{$header6}=$sequence6."\n".$plus6."\n".$quality6;
			print $output1 "$header5\n$sequence5\n$plus5\n$quality5\n$header6\n$sequence6\n$plus6\n$quality6\n";
		}
		close $input1;
		close $input2;
		close $output1;

		my $now14=&gettime;
		print "$now14 || Finish combing $cnt1 number of paired-end seed reads!\n";


		########################################
		##paired_end_reads_recruitment
		########################################
		my $r_name1="$name1/recruited_reads_$organ.1.fq";
		my $r_name2="$name1/recruited_reads_$organ.2.fq";
		if (!-e $r_name1){
			my $now15=&gettime;
			print "$now15 || Begin paired end reads recruitment of $removed_fq1 and $removed_fq2!\n";

			open(my $input3,"<",$removed_fq1) or die $!;
			open(my $input4,"<",$removed_fq2) or die $!;
			my $seqcount=0;
			while (<$input3>) {
				$seqcount++ if(/^@/);
			}
			seek($input3,0,0);

			my $now16=&gettime;
			print "$now16 || Begin writing memory for $removed_fq1 and $removed_fq2!\n";

			my $progress1=Term::ProgressBar->new({
				count		=>	$seqcount,
				name		=>	'Processing',
				major_char	=>	'=',			# default symbol of major progress bar
				minor_char	=>	'*',			# default symbol of minor progress bar
				ETA			=>	'linear',		# evaluate remain time: undef (default) or linear
				#term_width	=>	100,			# breadth of terminal, full screen (default)
				#remove		=>	0,				# whether the progress bar disappear after the end of this script or not? 0 (default) or 1
				#fh			=>	\*STDOUT,		# \*STDERR || \*STDOUT
			});
			$progress1->lbrack('[');				# left symbol of progress bar
			$progress1->rbrack(']');				# right symbol of progress bar
			$progress1->minor(0);				# close minor progress bar
			#$progress1->max_update_rate(0.5);	# minumum gap time between two updates (s)

			my ($header7,$sequence7,$plus7,$quality7,$header8,$sequence8,$plus8,$quality8);
			my %fq;
			my $cnt2=0;
			my $update1=0;

			while (defined ($header7=<$input3>) && defined ($sequence7=<$input3>) && defined ($plus7=<$input3>) && defined ($quality7=<$input3>) && defined ($header8=<$input4>) && defined ($sequence8=<$input4>) && defined ($plus8=<$input4>) && defined ($quality8=<$input4>)) {
				$header7=~ s/\n|\r//g;
				$sequence7=~ s/\n|\r//g;
				$plus7=~ s/\n|\r//g;
				$quality7=~ s/\n|\r//g;
				$header8=~ s/\n|\r//g;
				$sequence8=~ s/\n|\r//g;
				$plus8=~ s/\n|\r//g;
				$quality8=~ s/\n|\r//g;

				$fq{$header7}=$sequence7."\n".$plus7."\n".$quality7;
				$fq{$header8}=$sequence8."\n".$plus8."\n".$quality8;

				$cnt2++;
				$update1=$progress1->update ($cnt2) if ($cnt2 > $update1);
			}
			$progress1->update ($seqcount) if ($seqcount >= $update1);

			my $now17=&gettime;
			print "$now17 || Finish writing memory for $cnt2 number of $removed_fq1 and $removed_fq2!\n";


			########################################
			##step_number_of_wordsize
			########################################
			my $kmer_number=((length $sequence7)-1-$ws);
			my $step=($kmer_number/($number-1));
			my $count=0;

			for (my $m=0;$m<=$kmer_number;$m+=$step){
				$count++;
				my $to_dir="$name1/reads_per_run_$count";
				system("rm -rf $to_dir") if (-e $to_dir);
				mkdir ($to_dir) if (!-e $to_dir);


				########################################
				##save_fq_into_memory_in_hash_format
				########################################
				my $now18=&gettime;
				print "$now18 || Begin $count writing memory in hash format for $removed_fq1 and $removed_fq2!\n";

				my $progress2=Term::ProgressBar->new({
					count		=>	$seqcount,
					name		=>	'Processing',
					major_char	=>	'=',			# default symbol of major progress bar
					minor_char	=>	'*',			# default symbol of minor progress bar
					ETA			=>	'linear',		# evaluate remain time: undef (default) or linear
					#term_width	=>	100,			# breadth of terminal, full screen (default)
					#remove		=>	0,				# whether the progress bar disappear after the end of this script or not? 0 (default) or 1
					#fh			=>	\*STDOUT,		# \*STDERR || \*STDOUT
				});
				$progress2->lbrack('[');				# left symbol of progress bar
				$progress2->rbrack(']');				# right symbol of progress bar
				$progress2->minor(0);				# close minor progress bar
				#$progress2->max_update_rate(0.5);	# minumum gap time between two updates (s)

				seek ($input3,0,0);
				seek ($input4,0,0);
				my (@array3,@array4);
				my ($header9,$sequence9,$plus9,$quality9,$header10,$sequence10,$plus10,$quality10);
				my %prefix;
				my $cnt3=0;
				my $update2=0;

				if ($quick eq "T"){
					@array3=<$input3>;
					chomp @array3;
					@array4=<$input4>;
					chomp @array4;
					for (my $j=0;$j<=($seqcount*4-4);$j+=4){
						push @{$prefix{substr($array3[$j+1],0,$ws)}},$array3[$j];
						push @{$prefix{substr($array4[$j+1],0,$ws)}},$array4[$j];

						$cnt3++;
						$update2=$progress2->update ($cnt3) if ($cnt3 > $update2);
					}
				}elsif($quick eq "F"){
					while (defined ($header9=<$input3>) && defined ($sequence9=<$input3>) && defined ($plus9=<$input3>) && defined ($quality9=<$input3>) && defined ($header10=<$input4>) && defined ($sequence10=<$input4>) && defined ($plus10=<$input4>) && defined ($quality10=<$input4>)) {
						$header9=~ s/\n|\r//g;
						$sequence9=~ s/\n|\r//g;
						$plus9=~ s/\n|\r//g;
						$quality9=~ s/\n|\r//g;
						$header10=~ s/\n|\r//g;
						$sequence10=~ s/\n|\r//g;
						$plus10=~ s/\n|\r//g;
						$quality10=~ s/\n|\r//g;

						push @{$prefix{substr($sequence9,$m,$ws)}},$header9;
						push @{$prefix{substr($sequence10,$m,$ws)}},$header10;

						$cnt3++;
						$update2=$progress2->update ($cnt3) if ($cnt3 > $update2);
					}
				}
				$progress2->update ($seqcount) if ($seqcount >= $update2);
				@array3=();
				@array4=();

				my $now19=&gettime;
				print "$now19 || Finish $count writing memory in hash format for $removed_fq1 and $removed_fq2!\n";


				########################################
				##extend_contigs
				########################################
				my $now20=&gettime;
				print "$now20 || Begin $count recruiting overlapped reads!\n";

				my $seed=$contig2;
				my $n;
				my %hash0;
				for ($n=1;$n<=$run;$n++) {
					open(my $input5,"<",$seed) or die $!;
					open(my $output2,">>","$name1/header") or die $!;
					my ($header11,$sequence11);

					while (defined ($header11=<$input5>) && defined ($sequence11=<$input5>)) {
						$header11=~ s/\n|\r//g;
						$sequence11=~ s/\n|\r//g;

						extend_seed($sequence11,$ws,\%prefix,$output2);
						(my $complement=$sequence11)=~ tr/ACGTacgt/TGCAtgca/;
						my $reverse_complement=reverse $complement;
						extend_seed($reverse_complement,$ws,\%prefix,$output2);
					}
					close $input5;
					close $output2;

					open (my $overlapped_read1,"<","$name1/header") or die $!;
					open (my $overlapped_read2,">","$to_dir/read$n.fq") or die $!;
					my (%hash1,@array5);
					while (<$overlapped_read1>) {
						$_=~ s/\n|\r//g;

						if (not $hash0{$_}++ and not $seed{$_}){
							$hash1{$_}=$fq{$_};
						}
					}
					foreach (sort keys %hash1) {
						print $overlapped_read2 "$_\n$hash1{$_}\n";
					}
					close $overlapped_read1;
					close $overlapped_read2;
					$seed="$to_dir/read$n.fq";
					%hash1=();
					@array5=();
					unlink("$name1/header");
					last if (-s $seed==0);

					my $now21=&gettime;
					print "$now21 || The $n run finished: ",time-$now1," seconds!\n";
				}
				%hash0=();
				%prefix=();


				########################################
				##combine_all_extended_reads_files
				########################################
				opendir(my $directory2,$to_dir) or die $!;
				my @dir=readdir $directory2;
				close $directory2;
				open (my $single_reads,">>","$name1/single_reads") or die $!;
				foreach my $filename2 (@dir){
					if ($filename2=~ m/fq$/g or $filename2=~ m/fastq$/g){
						open (my $input6,"<","$to_dir/$filename2") or die $!;
						while(<$input6>){
							print $single_reads $_;
						}
						close $input6;
					}
				}
				close $single_reads;
				@dir=();
				#system("rm -rf $to_dir");

				my $now22=&gettime;
				print "$now22 || Finish $count recruiting overlapped reads!\n";
			}
			%seed=();
			close $input3;
			close $input4;
			my $now23=&gettime;
			print "$now23 || Finish all recruiting overlapped reads!\n";


			########################################
			##extract_pe_reads_using_single
			########################################
			my $now24=&gettime;
			print "$now24 || Begin subsequent processing!\n";

			my $now25=&gettime;
			print "$now25 || Begin extracting PE reads using single reads!\n";

			open (my $input7,"<","$name1/single_reads");
			open (my $input8,"<",$seed_reads);
			open (my $output3,">>","$name1/single_reads.fq") or die $!;
			my ($header12,$sequence12,$plus12,$quality12);
			my %hash2;
			while (defined($header12=<$input7>) && defined($sequence12=<$input7>) && defined($plus12=<$input7>) && defined($quality12=<$input7>)){
				$header12=~ s/\n|\r//g;
				$sequence12=~ s/\n|\r//g;
				$plus12=~ s/\n|\r//g;
				$quality12=~ s/\n|\r//g;
				$hash2{$header12}=$sequence12."\n".$plus12."\n".$quality12;
			}
			foreach (keys %hash2){
				print $output3 "$_\n$hash2{$_}\n";
			}
			while(<$input8>){
				print $output3 $_;
			}
			close $input7;
			close $input8;
			close $output3;
			%hash2=();
			unlink("$name1/single_reads");

			open (my $input9,"<","$name1/single_reads.fq") or die $!;
			open (my $output4,">","$name1/recruited_reads.fq") or die $!;
			my ($header13,$sequence13,$plus13,$quality13);
			my (%hash3,%hash4,%hash5);
			my $cnt4;

			while (defined($header13=<$input9>) && defined($sequence13=<$input9>) && defined($plus13=<$input9>) && defined($quality13=<$input9>)){
				$header13=~ s/\n|\r//g;
				#$hash3{substr($header13,0,-6)}++;
				$hash3{substr($header13,0,-1)}++;
				$sequence13=~ s/\n|\r//g;
				$plus13=~ s/\n|\r//g;
				$quality13=~ s/\n|\r//g;
				$hash4{$header13}=$sequence13."\n".$plus13."\n".$quality13;
			}
			foreach my $item3 (keys %hash3) {
				if ($hash3{$item3}==1){
					my $item4=$item3;
					$item4.=" 1:N:0";
					#$item4.="1";
					my $item5=$item3;
					$item5.=" 2:N:0";
					#$item5.="2";

					$hash5{$item4}=$fq{$item4};
					$hash5{$item5}=$fq{$item5};
				}elsif($hash3{$item3}==2){
					my $item6=$item3;
					$item6.=" 1:N:0";
					#$item6.="1";
					my $item7=$item3;
					$item7.=" 2:N:0";
					#$item7.="2";

					$hash5{$item6}=$hash4{$item6};
					$hash5{$item7}=$hash4{$item7};
				}
			}
			foreach (sort keys %hash5) {
				print $output4 "$_\n$hash5{$_}\n";
				$cnt4++;
			}
			close $input9;
			close $output4;
			%hash3=();
			%hash4=();
			%hash5=();
			%fq=();
			unlink("$name1/single_reads.fq");

			my $now26=&gettime;
			print "$now26 || Finish extracting PE reads using single reads!\n";


			########################################
			##split_one_to_two_for_pe_reads
			########################################
			my $now27=&gettime;
			print "$now27 || Begin spliting PE reads into forward and reverse reads!\n";

			open (my $input10,"<","$name1/recruited_reads.fq") or die $!;
			open (my $output5,">",$r_name1) or die $!;
			open (my $output6,">",$r_name2) or die $!;
			my $row;

			while ($row=<$input10>){
				$row=~ s/\n|\r//g;

				if ($. % 8==1) {
					print $output5 "$row\n";
				}
				if ($. % 8==2) {
					print $output5 "$row\n";
				}
				if ($. % 8==3) {
					print $output5 "$row\n";
				}
				if ($. % 8==4) {
					print $output5 "$row\n";
				}

				if ($. % 8==5) {
					print $output6 "$row\n";
				}
				if ($. % 8==6) {
					print $output6 "$row\n";
				}
				if ($. % 8==7) {
					print $output6 "$row\n";
				}
				if ($. % 8==0) {
					print $output6 "$row\n";
				}
			}
			close $input10;
			close $output5;
			close $output6;
			unlink("$name1/recruited_reads.fq");

			my $now28=&gettime;
			print "$now28 || Finish spliting PE reads into forward and reverse reads!\n";
			print "$now28 || Finish subsequent processing!\n";
			print "$now28 || Final statistics >>>\n";

			my $space=" " x 26;
			my $cnt5=($cnt4/2);
			print "$space Raw reads: $cnt2\n";
			print "$space Seed reads: $cnt1\n";
			print "$space Recruited reads: ",$cnt5,"\n";
			print "$space Seed reads plus recruited reads: ",$cnt1+$cnt5,"\n";

			my $now29=&gettime;
			print "$now29 || Finish paired end reads recruitment of $removed_fq1 and $removed_fq2!\n";
	}


		########################################
		##second_assembly
		########################################
		my $spades_dir2="$name1/Spades_$organ\_2";
		my $contig3="$spades_dir2/assembly_graph.fasta";

		if (!-e $contig3){
			my $now30=&gettime;
			print "$now30 || Begin second assembling $r_name1 and $r_name2!\n";

			my $assembly_command="spades.py --careful -1 ".$r_name1." -2 ".$r_name2." -k $kmer "."-o $spades_dir2\n";
			system ($assembly_command);

			my $now31=&gettime;
			print "$now31 || Finish second assembling $r_name1 and $r_name2!\n";
		}
		my $now32=&gettime;
		print "$now32 || Elapsed time for $forward and $reverse: ",time-$now1," seconds!\n";
	}

	my $now33=&gettime;
	print "$now33 || Total elapsed time: ",time-$now1," seconds!\n";
}




__DATA__

=head1 NAME

    OGA.pl Organelle Genome Assembly

=head1 COPYRIGHT

    copyright (C) 2016 Xiao-Jian Qu

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

    Organelle Genome Assembly

=head1 SYNOPSIS

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

=cut