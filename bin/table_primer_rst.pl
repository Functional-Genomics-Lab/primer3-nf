#!/usr/bin/perl
$p3out_file_name = shift(@ARGV);

if (!open(P3_FILE, $p3out_file_name)) {
     print STDERR "Can't not open file $p3out_file_name\n";
}

$/ = "=\n";

print "ID\tLeft Primer StartP\tLeft Primer EndP\tRight Primer StartP\tRight Primer EndP\tLength of PCR\t";
print "Left Primer\tRight Primer\tPCR\n";

while($_ = <P3_FILE>) {
     $primer_id = "";
     for ($i = 0; $i < 5; $i++) {
       $primer_left_seq[$i] = "";
       $primer_right_seq[$i] = "";
       $primer_product_size[$i] = "";
     }

     if ($_ =~ m/PRIMER_SEQUENCE_ID=(\S+)/) {
       $primer_id = $1;
     }
     if ($_ =~ m/SEQUENCE=(\S+)/) {
       $seq = $1;
     }

     if ($_ =~ m/PRIMER_LEFT_SEQUENCE=(\S+)/) {
         $primer_left_seq[0] = $1;
     }
     for ($i = 1; $i < 5; $i++) {
       if ($_ =~ m/PRIMER_LEFT_${i}_SEQUENCE=(\S+)/) {
         $primer_left_seq[$i] = $1;
       }
     }

     if ($_ =~ m/PRIMER_RIGHT_SEQUENCE=(\S+)/) {
	$primer_right_seq[0] = $1;
     }
     for ($i = 1; $i < 5; $i++) {
       if ($_ =~ m/PRIMER_RIGHT_${i}_SEQUENCE=(\S+)/) {
  	  $primer_right_seq[$i] = $1;
       }
     }

     if ($_ =~ m/PRIMER_PRODUCT_SIZE=(\S+)/) {
	$primer_product_size[0] = $1;
     }
     for ($i = 1; $i < 5; $i++) {
       if ($_ =~ m/PRIMER_PRODUCT_SIZE_$i=(\S+)/) {
	  $primer_product_size[$i] = $1;
       }
     }

     if ($_ =~ m/PRIMER_LEFT=(\d+),(\d+)/) {
        $primer_left_pos[0] = $1;
        $primer_left_size[0] = $2;
        $pcr[0] = substr($seq, $primer_left_pos[0], $primer_product_size[0]);
     }
     for ($i = 1; $i < 5; $i++) {
       if ($_ =~ m/PRIMER_LEFT_$i=(\d+),(\d+)/) {
          $primer_left_pos[$i] = $1;
          $primer_left_size[$i] = $2;
          $pcr[$i] = substr($seq, $primer_left_pos[$i], $primer_product_size[$i]);
       }
     }
     if ($_ =~ m/PRIMER_RIGHT=(\d+),(\d+)/) {
        $primer_right_pos[0] = $1;
        $primer_right_size[0] = $2;
     }
     for ($i = 1; $i < 5; $i++) {
       if ($_ =~ m/PRIMER_RIGHT_$i=(\d+),(\d+)/) {
          $primer_right_pos[$i] = $1;
          $primer_right_size[$i] = $2;
       }
     }

     for ($i = 0; $i < 5; $i++) {
     if ($primer_left_seq[$i] eq "") {next;}
       $primer_left_start_pos = $primer_left_pos[$i] + 1;
       $primer_left_end_pos = $primer_left_pos[$i] + $primer_left_size[$i];
       $primer_right_end_pos = $primer_right_pos[$i] + 1;
       $primer_right_start_pos = $primer_right_pos[$i] - $primer_right_size[$i] + 2;
       print "$primer_id\t$primer_left_start_pos\t$primer_left_end_pos\t$primer_right_start_pos\t$primer_right_end_pos\t";
       print "$primer_product_size[$i]\t$primer_left_seq[$i]\t$primer_right_seq[$i]\t$pcr[$i]\n";
     }
}

close(P3_FILE);
