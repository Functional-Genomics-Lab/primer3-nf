use LWP::UserAgent;

$file = @ARGV[0];

open (PRIMERS, "$file.txt");
open (OUT, ">$file.hg18");

print OUT "id\tcoordinates\tsequence\tlength\n";
while ($line = <PRIMERS>){
	chomp $line;
	@data = split (/\t/, $line);
	$id = @data[0];
	$primerF = @data[6];
	$primerR = @data[7];
if( (!$primerF) || (!$primerR) ){
        die "Usage <script> <forward primer> <reverse primer>\n";
}

$CGI="http://genome.ucsc.edu/cgi-bin/hgPcr";

$hidden="hgsid=66419828";
$org="org=Human";
$assembly="db=hg18";
$maxsize="wp_size=4000";
$minperfect="wp_perfect=15";
$mingood="wp_good=15";

$forward="wp_f=$primerF";
$reverse="wp_r=$primerR";

$addr = "$CGI?$hidden&$org&$assembly&$maxsize&$minperfect&$mingood&$forward&$reverse";

$content = getPage($addr);
#print $content."\n";
@seq = @{parseHTML($content)};

foreach my $product(@seq){
        ($head, $sequence) = parseSEQ($product);
        $len = length($sequence);
        #print "$head\n";
        #print "$sequence\n";
        #print "length $len\n";
        print "$id\t$head\t$sequence\t$len\n";
        print OUT "$id\t$head\t$sequence\t$len\n";
        sleep(10);
}
}

close (OUT, PRIMERS);

sub parseSEQ{
        my $seq = $_[0];
        my @lines = split(/\n/,$seq);
        my $head = shift @lines;
        ($head) = $head=~/position=([^ "]+)&hgPcrResult=pack/;
        $seq = join "", @lines;
        return($head, $seq);
}

sub parseHTML{
        my $html=$_[0];
        my @entries = split(/<\/PRE>/,$html);
        $html = $entries[0];

        my @seqs=();
        my $sequence;

        ($sequence) = $html =~/<PRE>((.+\n)+)/m;
        #print "seq $sequence\n";
        if($sequence){
                push(@seqs, split(/\n><A /,$sequence));
                #print join "#############\n", @seqs;
        }

        return (\@seqs);
}

sub getPage{
        my $addr=$_[0];

        my $content;
        my $mesg = '';
        my $time = 20;
        my $ua = LWP::UserAgent->new(
                                     timeout => $time
                                    );
        my $response;
        #print "CHECK $addr\n";
        $response = $ua->get($addr);
        if($response->is_success){
                $content=$response->content;
        }else{
                return(0);
        }
        return($content);
}
