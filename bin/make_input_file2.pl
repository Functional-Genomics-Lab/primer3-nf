#!/usr/bin/perl
$seq_file_name = shift(@ARGV);

if (!open(SEQ_FILE, $seq_file_name)) {
     print STDERR "Can't not open file $seq_file_name\n";
}

<SEQ_FILE>;
print <<"EOF";
PRIMER_NUM_RETURN=5
PRIMER_OPT_SIZE=20
PRIMER_MIN_SIZE=18
PRIMER_MAX_SIZE=25
PRIMER_OPT_TM=60.0
PRIMER_MIN_TM=57.0
PRIMER_MAX_TM=63.0
PRIMER_MAX_DIFF_TM=2
PRIMER_MIN_GC=40.0
PRIMER_MAX_GC=60.0
PRIMER_MAX_POLY_X=5
PRIMER_SALT_CONC=50.0
PRIMER_DNA_CONC=50.0
PRIMER_NUM_NS_ACCEPTED=0
PRIMER_MAX_END_STABILITY=9
PRIMER_SELF_ANY=8
PRIMER_SELF_END=3
EOF

while($_ = <SEQ_FILE>){
     chomp ($_);
     ($seq_id, $seq) = split(/[\n]/);
     $len = length($seq);
     print "PRIMER_SEQUENCE_ID=${encode_id}_${seq_id}\n";
     print "TARGET=100,", $len-200, "\n";
     print "SEQUENCE=$seq\n";
     print "PRIMER_PRODUCT_SIZE_RANGE=", $len - 200, "-$len\n";
     print "=\n";
}

close(SEQ_FILE);
