#!/usr/bin/perl
use Sort::Key::Natural qw(natsort);
%DETAILSREF = '';
%DETAILSALL = '';
%DETAILSALT = '';
%DETAILSQUAL = '';
@LIBS = (1321,1322,1323,1324,1325,1326,1327,1328,1330,1331,1332,1333,1334,1335,1336,1337);
open (INPUT,"<",$ARGV[0]);
open (OUT,">List_Of_SNPS.txt");
open (OUT2,">Matrix_Of_SNPS.txt");
open (OUT3,">Output_Of_SNPS.txt");

print OUT "Chrom\tPosition\tLibrary_id\tQuality\tReference\tAlternate\n";
print OUT2 "Library\t";
print OUT3 "Library\tSNPsconcat\n";
while (<INPUT>){
    @alldetails = split "\t";
    @libraries = split(",",$alldetails[0]);
    $chrom = $alldetails[1];
    $position = $alldetails[2];
    @ref = split(",",$alldetails[3]);
    @alt = split(",",$alldetails[4]);
    @quality = split(",",$alldetails[5]);
    foreach my $no (0..$#libraries){
        $DETAILSREF{$chrom}{$position}{$libraries[$no]} = $ref[$no];
        $DETAILSALT{$chrom}{$position}{$libraries[$no]} = $alt[$no];
        $DETAILSQUAL{$chrom}{$position}{$libraries[$no]} = $quality[$no];
    }
}
foreach $chr2 (natsort keys %DETAILSREF){
    if (length($chr2)>1){
        foreach $post2 (natsort keys %{$DETAILSREF{$chr2}}){
            print OUT2 "$chr2:$post2\t";
	    foreach $lib2 (natsort keys %{$DETAILSREF{$chr2}{$post2}}){
                print OUT "$chr2\t$post2\t$lib2\t$DETAILSQUAL{$chr2}{$post2}{$lib2}\t";
                print OUT "$DETAILSREF{$chr2}{$post2}{$lib2}\t$DETAILSALT{$chr2}{$post2}{$lib2}\n";
	        undef @failedref;
		foreach my $lib3 (natsort @LIBS){
                    if ($lib2 == $lib3){
			$DETAILSALL{$lib3}{$chr2}{$post2}= $DETAILSALT{$chr2}{$post2}{$lib2};
			$tempresult = $DETAILSREF{$chr2}{$post2}{$lib2};
		    }elsif (exists $DETAILSALT{$chr2}{$post2}{$lib3}){
			$DETAILSALL{$lib3}{$chr2}{$post2}= $DETAILSALT{$chr2}{$post2}{$lib3};
                        $tempresult = $DETAILSREF{$chr2}{$post2}{$lib3};
		    }else {
			push(@failedref, $lib3);
		    }
		}
		foreach my $libs (@failedref){
		    $DETAILSALL{$libs}{$chr2}{$post2} = $tempresult;
		}
		undef $tempresult;
            }
        }
    }
}
print OUT2 "\n";

foreach my $lib4 (@LIBS){
    print OUT2 "$lib4\t";
    print OUT3 "$lib4\t";
    foreach $chr3 (natsort keys %{$DETAILSALL{$lib4}}){
        foreach $post3 (natsort keys %{$DETAILSALL{$lib4}{$chr3}}){
            print OUT2 "$DETAILSALL{$lib4}{$chr3}{$post3}\t";
	    print OUT3 "$DETAILSALL{$lib4}{$chr3}{$post3}";
        }
    }
    print OUT2 "\n";
    print OUT3 "\n";
}
