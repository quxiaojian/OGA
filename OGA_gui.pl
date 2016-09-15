#!/usr/bin/perl -w
use strict;
use Tk;
use Data::Dumper;

my ($m_help_about);

my $mw=MainWindow->new();
$mw->geometry("850x400");
$mw->title("OGA-Organelle Genome Assembly");

##### first create the horizontal menubar
my $mb=$mw->Frame(-relief=>"raised",-bd=>2);
$mb->pack(-side=>"top",-fill=>"both");

# now put in the menubar some menubuttons
my $m_file=$mb->Menubutton(-text=>"File",-underline=>0);
$m_file->pack(-side => "left");
my $m_command=$mb->Menubutton(-text=>"Command",-underline=>0);
$m_command->pack(-side => "left");
my $m_help=$mb->Menubutton(-text=>"Help",-underline=>0);
$m_help->pack(-side=>"left");

#### now create the submenus
# the file menus
$m_file->command(-label=>"Save log",-command=>[\&save,"save"]);
$m_file->separator();
$m_file->command(-label=>"Exit",-underline=>1,-command=>sub{exit;});
# the command submenus
$m_command->command(-label=>"Run",-command=>sub{&run});
# the help submenus
$m_help->command(-label=>"Help",-command=>[\&help,"help"]);


my $frame_indir=$mw->Frame();
$frame_indir->pack(-expand=>1,-fill=>"both",-side=>"top");
my $label_indir=$frame_indir->Label(-text=>"Input Directory: ",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_indir->pack(-side=>"left");
my $indir="";
my $button_indir=$frame_indir->Button(-text=>"Open",-width=>25,-command=>sub{&selectdirectory});
$button_indir->pack(-side=>"left");

#threads
my $frame_threads=$mw->Frame();
$frame_threads->pack(-expand=>1,-fill=>"both",-side=>"top");
my $label_threads=$frame_threads->Label(-text=>"Bowtie mapping threads",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_threads->pack(-side=>"left");
my $threads=8;
my $entry_threads=$frame_threads->Entry(-textvariable=>\$threads,-width=>25,-font=>"Arial 11 bold",-background=>"Orange");
$entry_threads->pack(-side=>"left");

#cpreference
my $frame_cp=$mw->Frame();
$frame_cp->pack(-expand=>1,-fill=>"both",-side=>"top");
my $label_cp=$frame_cp->Label(-text=>"Path to indexed cp reference: ",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_cp->pack(-side=>"left");
my $cpreference=$frame_cp->Button(-text=>"Open",-width=>25);
$cpreference->pack(-side=>"left");
$cpreference->configure(-command=>sub {&loadcpreference});
my $cpref;

#mtreference
my $frame_mt=$mw->Frame();
$frame_mt->pack(-expand=>1,-fill=>"both",-side=>"top");
my $label_mt=$frame_mt->Label(-text=>"Path to indexed mt reference: ",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_mt->pack(-side=>"left");
my $mtreference=$frame_mt->Button(-text=>"Open",-width=>25);
$mtreference->pack(-side=>"left");
$mtreference->configure(-command=>sub {&loadmtreference});
my $mtref;

#organ
my $frame_organ=$mw->Frame();
$frame_organ->pack(-expand=>1,-fill=>'both',-side=>'top');
my $label_organ=$frame_organ->Label(-text=>"cp or mt that you want to assemble",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_organ->pack(-side=>"left");
my $organ="cp";
my $entry_organ=$frame_organ->Entry(-textvariable=>\$organ,-width=>25,-font=>"Arial 11 bold",-background=>"Orange");
$entry_organ->pack(-side=>"left");

#kmer
my $frame_kmer=$mw->Frame();
$frame_kmer->pack(-expand=>1,-fill=>'both',-side=>'top');
my $label_kmer=$frame_kmer->Label(-text=>"Kmer values",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_kmer->pack(-side=>"left");
my $kmer="71,81,91,101,111,121";
my $entry_kmer=$frame_kmer->Entry(-textvariable=>\$kmer,-width=>25,-font=>"Arial 11 bold",-background=>"Orange");
$entry_kmer->pack(-side=>"left");

#ws
my $frame_ws=$mw->Frame();
$frame_ws->pack(-expand=>1,-fill=>'both',-side=>'top');
my $label_ws=$frame_ws->Label(-text=>"Wordsize value or specifically overlap value between two reads",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_ws->pack(-side=>"left");
my $ws=121;
my $entry_ws=$frame_ws->Entry(-textvariable=>\$ws,-width=>25,-font=>"Arial 11 bold",-background=>"Orange");
$entry_ws->pack(-side=>"left");

#number
my $frame_number=$mw->Frame();
$frame_number->pack(-expand=>1,-fill=>'both',-side=>'top');
my $label_number=$frame_number->Label(-text=>"Step number of wordsize saved into memory",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_number->pack(-side=>"left");
my $number=3;
my $entry_number=$frame_number->Entry(-textvariable=>\$number,-width=>25,-font=>"Arial 11 bold",-background=>"Orange");
$entry_number->pack(-side=>"left"); 

#run
my $frame_run=$mw->Frame();
$frame_run->pack(-expand=>1,-fill=>'both',-side=>'top');
my $label_run=$frame_run->Label(-text=>"(Optional) Runs for paired-end reads recruitment",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_run->pack(-side=>"left");
my $run=10000;
my $entry_run=$frame_run->Entry(-textvariable=>\$run,-width=>25,-font=>"Arial 11 bold",-background=>"Orange");
$entry_run->pack(-side=>"left");

#quick
my $frame_quick=$mw->Frame();
$frame_quick->pack(-expand=>1,-fill=>'both',-side=>'top');
my $label_quick=$frame_quick->Label(-text=>"(Optional) Speed argument, (T)rue or F(alse)",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_quick->pack(-side=>"left");
my $quick="F";
my $entry_quick=$frame_quick->Entry(-textvariable=>\$quick,-width=>25,-font=>"Arial 11 bold",-background=>"Orange");
$entry_quick->pack(-side=>"left");

#contact
my $frame_contact=$mw->Frame();
$frame_contact->pack(-expand=>1,-fill=>"both",-side=>"top");
my $label_contact=$frame_contact->Label(-text=>"Email",-width=>80,-anchor=>"w",-font=>"Arial 11 bold",-foreground=>"black",-relief=>"groove");
$label_contact->pack(-side=>"left");
my $email="quxiaojian\@mail.kib.ac.cn";
my $entry_contact=$frame_contact->Entry(-textvariable=>\$email,-width=>25,-font=>"Arial 11 bold",-background=>"Orange");
$entry_contact->pack(-side=>"left");

##run and exit
#my $button_run=$mw->Button(-text=>"Run...",-command=>sub {&run($indir,$threads,$cpref,$mtref,$organ,$kmer,$ws,$number,$run,$quick)});
#$button_run->pack(-side=>"left");
#
#my $button_exit=$mw->Button(-text=>"Exit...",-command=>sub {exit});
#$button_exit->pack(-side=>"right");


MainLoop;


########################################
##subroutines
########################################
sub save {
    my ($arg)=@_;
    print "save: $arg\n";
}

sub help {
    my ($arg)=@_;
    print "help: $arg\n";
}

sub selectdirectory{
	$indir=$mw->chooseDirectory();
	if (defined $indir){
		$label_indir->configure(-text=>$label_indir->cget("-text").$indir);
	}
}

sub loadcpreference {
	my @types = (
				["Reference files",[qw/.fasta .fa/]],
				["All files","*"],
				);
	my $filepath1=$mw->getOpenFile(-filetypes=>\@types) or return ();
	my $filepath2=substr($filepath1,0,rindex($filepath1,"."));
	$cpref=$filepath2;
	$label_cp->configure(-text=>$label_cp->cget("-text").$filepath2);
}

sub loadmtreference {
	my @types = (
				["Reference files",[qw/.fasta .fa/]],
				["All files","*"],
				);
	my $filepath1=$mw->getOpenFile(-filetypes=>\@types) or return ();
	my $filepath2=substr($filepath1,0,rindex($filepath1,"."));
	$mtref=$filepath2;
	$label_mt->configure(-text=>$label_mt->cget("-text").$filepath2);
}

sub run {
	use Tk;
	use Tk::ExecuteCommand;
	use Tk::widgets qw/LabEntry/;

	my $mw=MainWindow->new;
	my $ec=$mw->ExecuteCommand(-text=>"Execute",-entryWidth=>50,-height=>10,-label=>"",)->pack;
	$ec->configure(-command=>"perl OGA.pl -i $indir -t $threads -c $cpref -m $mtref -p $organ -k $kmer -w $ws -s $number -r $run -q $quick");
	my $button=$mw->Button(-text=>"Exit",-command=>sub{exit;})->pack;
	MainLoop;
}

