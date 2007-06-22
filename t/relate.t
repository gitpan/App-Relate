# Test file created outside of h2xs framework.
# Run this like so: `perl relate.t'
#   doom@kzsu.stanford.edu     2004/05/28 06:29:19

#########################

use warnings;
use strict;
$|=1;
use File::Basename;
use Data::Dumper;

use FindBin qw($Bin);

use File::Locate::Harder;

use Test::More;
my $total_count;
BEGIN { $total_count = 8;
        plan tests => $total_count };

use Test::Trap qw( trap $trap );

my $DEBUG = 0;

# program to test

my $test_bin = $Bin;
my $prog_bin = "$Bin/..";

my $prog = "$prog_bin/relate";

ok(1, "Traditional: If we made it this far, we're ok.");

# skip all tests if there is no locate installation
SKIP:
{
  my $obj;
  my @r = trap {
    $obj = File::Locate::Harder->new();
  };
  if ( my $err_mess = $trap->die ) {
    my $expected_err_mess =
      "File::Locate::Harder is not working. " .
        "Problem with 'locate' installation?";
    $expected_err_mess =~ s{ \s+? }{ \\s+ }gx;

    unless ( $err_mess =~ qr{ $expected_err_mess }x) {
      die "$err_mess";
    }
    my $how_many = $total_count - 2; # all remaining tests
    skip "Problem with installation of 'locate'", $how_many;
  }

  my (@lines, $cmd, @expected);


 SKIP:
  {                             #2,#3
    # Using a baby slocate database for testing: t/dat/db/dummies.db
    # Indexing the files located here:           t/dat/dummies

    my $db_loc = "$Bin/dat/db";
    my $tree   = "$Bin/dat/dummies";
    my $db     = "$db_loc/dummies.db";
    my $loc    = $tree;

    # create dummies.db, tracking the dummy files in the $tree:

    my $flh = File::Locate::Harder->new( db => undef );
    my $why = '';
    if ( not(
             $flh->create_database( $tree, $db )
            ) ) {
      $why = "Could not create locate database $db";
    } elsif ( not( $flh->probe_db ) ) {
      $why = "Can't get File::Locate::Harder to work with $db";
    }
    if ($why) {
      my $how_many = 2;
      skip $why, $how_many;
    }

  SKIP:
    {                           #2
      my @lines = ();
      my @terms = qw( sky );
      my $search_string = join ' ', @terms;
      my $cmd   = "$prog -D $db $search_string";
      ($DEBUG) && print STDERR "cmd: $cmd", "\n";

      my $how_many = 1;
      foreach my $term (@terms) {
        if ($loc =~ m/$term/i) {
          skip "tests invalid because $term matches the path, $loc", $how_many;
          last;
        }
      }

      chomp(
            @lines = sort grep { !/^$/ } qx($cmd)
           );
      my @expected = ( "$Bin/dat/dummies/Obscure/thesky" );
      is_deeply( \@lines, \@expected, "relate sky");
    }                           # end skip - term matches path

  SKIP:
    {                           #3
      @lines = ();
      my @terms = qw( Else -foah -tew -thu );
      my $search_string = join ' ', @terms;
      $cmd = "$prog -D $db $search_string";
      ($DEBUG) && print STDERR "cmd: $cmd", "\n";

      my $how_many = 1;
      foreach my $term (@terms) {
        if ($loc =~ m/$term/i) {
          skip "tests invalid because $term matches the path, $loc", $how_many;
          last;
        }
      }

      chomp(
            @lines = sort grep { !/^$/ } qx($cmd)
           );
      @expected = ( "$Bin/dat/dummies/Elsewhere",
                    "$Bin/dat/dummies/Elsewhere/wun",
                  );
      @expected = sort @expected;
      is_deeply( \@lines, \@expected, "relate with subtraction");
    }                           # end skip - term matches path
  }                        # end skip - couldn't create locate db

 SKIP:
  {                             #4, 5
    my $db_loc = "$Bin/dat/db";
    my $tree = "$Bin/dat/dorks";
    my $db = "$db_loc/dorks.db";
    my $loc = $tree;

    # create dorks.db, tracking the files in "dorks" (the $tree):
    my $flh = File::Locate::Harder->new( db => undef );
    my $why = '';
    if ( not(
             $flh->create_database( $tree, $db )
            ) ) {
      $why = "Could not create locate database $db";
    } elsif ( not( $flh->probe_db ) ) {
      $why = "Can't get File::Locate::Harder to work with $db";
    }
    if ($why) {
      my $how_many = 2;
      skip $why, $how_many;
    }

    my (@result, $cmd, @expected);

  SKIP:
    {                           #4
      @result = ();
      my @terms = qw( Politicians bio );
      my $search_string = join ' ', @terms;
      $cmd = "$prog -D $db $search_string";
      ($DEBUG) && print STDERR "cmd: $cmd", "\n";

      my $how_many = 1;
      foreach my $term (@terms) {
        if ($loc =~ m/$term/i) {
          skip "tests invalid because $term matches the path, $loc", $how_many;
          last;
        }
      }

      chomp(
            @result = sort grep { !/^$/ } qx($cmd)
           );
      @expected = ( "$Bin/dat/dorks/Politicians/decidedly.bio",
                    "$Bin/dat/dorks/Politicians/funny-hats.bio",
                  );
      @expected = sort @expected;
      is_deeply( \@result, \@expected, "relate basic two term search");
    }                           # end skip - term matches path

  SKIP:
    {                           #5
      @result = ();
      my @terms = qw( check Politicians pl );
      my $search_string = join ' ', @terms;
      $cmd = "$prog -D $db $search_string";
      ($DEBUG) && print STDERR "cmd: $cmd", "\n";

      my $how_many = 1;
      foreach my $term (@terms) {
        if ($loc =~ m/$term/i) {
          skip "tests invalid because $term matches the path, $loc", $how_many;
          last;
        }
      }

      chomp(
            @result = sort grep { !/^$/ } qx($cmd)
           );
      @expected = ( "$Bin/dat/dorks/Politicians/check-lips.pl",
                  );
      @expected = sort @expected;
      is_deeply( \@result, \@expected, "relate basic three term search");
    }                           # end skip - term matches path
  }                        # end skip - couldn't create locate db

 SKIP:
  {                             #6, #7, #8
    my $db_loc = "$Bin/dat/db";
    my $tree = "$Bin/dat/oink";
    my $db = "$db_loc/oink.db";
    my $loc = $tree;

    # create oink.db, tracking the files in "oink" (the $tree):
    my $flh = File::Locate::Harder->new( db => undef );
    my $why = '';
    if ( not(
             $flh->create_database( $tree, $db )
            ) ) {
      $why = "Could not create locate database $db";
    } elsif ( not( $flh->probe_db ) ) {
      $why = "Can't get File::Locate::Harder to work with $db";
    }
    if ($why) {
      my $how_many = 2;
      skip $why, $how_many;
    }

    my (@result, $cmd, @expected);

  SKIP:
    {                           #6
      @result = ();
      my @terms = qw( fragmented -txt );
      my $search_string = join ' ', @terms;
      $cmd = "$prog -D $db $search_string";
      ($DEBUG) && print STDERR "cmd: $cmd", "\n";

      my $how_many = 1;
      foreach my $term (@terms) {
        if ($loc =~ m/$term/i) {
          skip "tests invalid because $term matches the path, $loc", $how_many;
          last;
        }
      }

      chomp(
            @result = sort grep { !/^$/ } qx($cmd)
           );
      @expected = ( "$tree/tree_son/zzz/ZZZ/fragmented_target",
                    "$tree/tree_son/zzz/ZZZ/fragmented_target/unchained_earth.TXT",
                  );
      @expected = sort @expected;
      is_deeply( \@result, \@expected, "relate: one term positive, one negative");
    }                           # end skip - term matches path

  SKIP:
    {                           #7
      @result = ();
      my @terms = qw( son tree );
      my $search_string = join ' ', @terms;
      if ($DEBUG) {
        $cmd = "$prog -d -D $db $search_string";
        print STDERR "cmd: $cmd", "\n";
      } else {
        $cmd = "$prog -D $db $search_string";
      }

      my $how_many = 1;
      foreach my $term (@terms) {
        if ($loc =~ m/$term/i) {
          skip "tests invalid because $term matches the path, $loc", $how_many;
          last;
        }
      }

      chomp(
            @result = sort grep { !/^$/ } qx($cmd)
           );
      @expected = (
                   "$tree/tree_son",
                   "$tree/tree_son/none_dare_call_it",
                   "$tree/tree_son/republicanism",
                   "$tree/tree_son/zzz",
                   "$tree/tree_son/zzz/bushed_whacked",
                   "$tree/tree_son/zzz/world_crime_league",
                   "$tree/tree_son/zzz/ZZZ",
                   "$tree/tree_son/zzz/ZZZ/fragmented_target",
                   "$tree/tree_son/zzz/ZZZ/fragmented_target/shards_of_dog.txt",
                   "$tree/tree_son/zzz/ZZZ/fragmented_target/helpful_tweezers.txt",
                   "$tree/tree_son/zzz/ZZZ/fragmented_target/shameful_geezers.txt",
                   "$tree/tree_son/zzz/ZZZ/fragmented_target/unchained_earth.TXT",
                   "$tree/tree_son/zzz/ZZZ/fragmented_target/fragmented_target.txt",
                   "$tree/tree_son/zzz/ZZZ/fragmented_target.txt",
                   "$tree/tree_son/zzz/ZZZ/splintered_reason.txt",
                  );
      @expected = sort @expected;
      ($DEBUG) && print STDERR "result: ". Dumper( \@result ) , "\n";
      is_deeply( \@result, \@expected, "relate basic :skipdull");
    }                           # end skip - term matches path

  SKIP:
    {                           #8
      @result = ();
      my @terms = qw( son tree );
      my $search_string = join ' ', @terms;
      $cmd = "$prog -a -D $db $search_string";

      ($DEBUG) && print STDERR "cmd: $cmd", "\n";

      my $how_many = 1;
      foreach my $term (@terms) {
        if ($loc =~ m/$term/i) {
          skip "tests invalid because $term matches the path, $loc", $how_many;
          last;
        }
      }

      chomp(
            @result = sort grep { !/^$/ } qx($cmd)
           );
      @expected = (
                   "$tree/tree_son",
                   "$tree/tree_son/none_dare_call_it",
                   "$tree/tree_son/republicanism",
                   "$tree/tree_son/zzz",
                   "$tree/tree_son/zzz/bushed_whacked",
                   "$tree/tree_son/zzz/world_crime_league",
                   "$tree/tree_son/zzz/ZZZ",
                   "$tree/tree_son/zzz/ZZZ/fragmented_target",
                   "$tree/tree_son/zzz/ZZZ/fragmented_target/shards_of_dog.txt",
                   "$tree/tree_son/zzz/ZZZ/fragmented_target/helpful_tweezers.txt",
                   "$tree/tree_son/zzz/ZZZ/fragmented_target/shameful_geezers.txt",
                   "$tree/tree_son/zzz/ZZZ/fragmented_target/unchained_earth.TXT",
                   "$tree/tree_son/zzz/ZZZ/fragmented_target/fragmented_target.txt",
                   "$tree/tree_son/zzz/ZZZ/fragmented_target.txt",
                   "$tree/tree_son/zzz/ZZZ/fragmented_target.txt~",
                   "$tree/tree_son/zzz/ZZZ/#fragmented_target.txt#",
                   "$tree/tree_son/zzz/ZZZ/splintered_reason.txt",
                   "$tree/tree_son/zzz/ZZZ/RCS",
                   "$tree/tree_son/zzz/ZZZ/RCS/splintered_reason.txt,v",
                   "$tree/tree_son/zzz/ZZZ/splintered_reason.txt~",
                  );
      @expected = sort @expected;
      ($DEBUG) && print STDERR "result: ". Dumper( \@result ) , "\n";
      is_deeply( \@result, \@expected, "relate shut off default filter");
    } # end skip - term matches path
  } # end skip - couldn't create locate db
} # end skip -- problem with installation of locate



### end main code ###


