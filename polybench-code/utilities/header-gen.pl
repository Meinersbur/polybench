#!/usr/bin/perl

# Generates headers using specification in polybench.spec
#
# Written by Tomofumi Yuki, 11/21 2014
#

use File::Path;

if ($#ARGV != 0) {
   printf("usage perl header-gen.pl output-dir\n");
   exit(1);
}

my $SPECFILE = 'polybench.spec';
my $OUTDIR = $ARGV[0];
my @DATASET_NAMES = ('MINI', 'SMALL', 'MEDIUM', 'LARGE', 'EXTRALARGE');

if (!(-e $OUTDIR)) {
   mkdir $OUTDIR;
}

my %INPUT;
my @keys;

open FILE, $SPECFILE or die;
  while (<FILE>) {
    my $line = $_;
    $line =~ s/\r|\n//g;
    #lines tarting with # is treated as comments
    next if ($line=~/^\s*#/);
    next if ($line=~/^\s*[\r|\n]+$/);
    my @line = split(/\t+/, $line);

    if (!keys %INPUT ) {
       foreach (@line) {
           $INPUT{$_} = [];
       }
       @keys = @line;
    } else {
       for (my $i = 0; $i <= $#line; $i++) {
           push @{$INPUT{$keys[$i]}}, $line[$i] ;
       }
    }
  }

close FILE;

for (my $r = 0; $r <= $#{$INPUT{'kernel'}}; $r++) {
   &generateHeader($r);
}

sub generateHeader() {

   my $row = $_[0];
   my $name = $INPUT{'kernel'}[$row];
   my $category = $INPUT{'category'}[$row];
   my $datatype = $INPUT{'datatype'}[$row];
   my @params = split /\s+/, $INPUT{'params'}[$row];

   #this part needs to be extend for more data types as necessary
   my $printfDesc;
   $printfDesc = '%0.2lf';
   $printfDesc = '%0.2f' if ($datatype eq 'float');
   $printfDesc = '%d' if ($datatype eq 'int');
   my $scalarVal;
   $scalarVal = "x";
   $scalarVal = "x##f" if ($datatype eq 'float');
   my $sqrtFun;
   $sqrtFun = "sqrt(x)";
   $sqrtFun = "sqrtf(x)" if ($datatype eq 'float');
   my $expFun;
   $expFun = "exp(x)";
   $expFun = "expf(x)" if ($datatype eq 'float');
   my $powFun;
   $powFun = "pow(x,y)";
   $powFun = "powf(x,y)" if ($datatype eq 'float');

 
 
   my $headerDef = '_'. uc $name . '_H';
   $headerDef =~ s/-/_/g;

   my $paramDefs;
   foreach $set (@DATASET_NAMES) {
      my @sizes = split /\s+/, $INPUT{$set}[$row]; 
      $paramDefs .= '#  ifdef '.$set."_DATASET\n";
      for (my $i = 0; $i <= $#params; $i++) {
         $paramDefs .= '#   define '.$params[$i].' '.$sizes[$i]."\n";
      }
      $paramDefs .= '#  endif '."\n\n";
   }

   my $paramCheck = '# if';
   my $loopBoundDef = '';
   {
      my $first = 1;
      foreach (@params) {
         $paramCheck.= ' &&' if (!$first);
         $paramCheck .= " !defined($_)";
         $first = 0;
         $loopBoundDef .= '# define _PB_'.$_.' POLYBENCH_LOOP_BOUND('.$_.','.lc $_.')'."\n";
      }
   }

   my $kernelPath = "$OUTDIR/$category/$name";
   if (!(-e $kernelPath)) {
       mkpath $kernelPath;
   }

   open HFILE, ">$kernelPath/$name.h";
print HFILE << "EOF";
#ifndef $headerDef
# define $headerDef

/* Default to LARGE_DATASET. */
# if !defined(MINI_DATASET) && !defined(SMALL_DATASET) && !defined(MEDIUM_DATASET) && !defined(LARGE_DATASET) && !defined(EXTRALARGE_DATASET)
#  define LARGE_DATASET
# endif

$paramCheck
/* Define sample dataset sizes. */
$paramDefs
#endif /* !(@params) */

$loopBoundDef

# ifndef DATA_TYPE
#  define DATA_TYPE $datatype
#  define DATA_PRINTF_MODIFIER "$printfDesc "
#  define SCALAR_VAL(x) $scalarVal
#  define SQRT_FUN(x) $sqrtFun
#  define EXP_FUN(x) $expFun
#  define POW_FUN(x,y) $powFun
# endif



#endif /* !$headerDef */

EOF
     close HFILE;
}

