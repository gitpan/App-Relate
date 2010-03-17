package App::Relate;
#                                doom@kzsu.stanford.edu
#                                15 Mar 2010


=head1 NAME

App::Relate - simple form of the "relate" script (wrapper around locate)

=head1 SYNOPSIS

   use App::Relate ':all';

   relate( \@search, \@filter );

   relate( \@search, \@filter, $opts );

=head1 DESCRIPTION

relate simplifies the use of locate.

Instead of:

  locate this | egrep "with_this" | egrep "and_this" | egrep -v "but_not_this"

You can type:

  relate this with_this and_this -but_not_this

This module is a simple back-end to implement the relate script.
See L<relate> for user documentation.

=head2 EXPORT

None by default.  The following, on request (or via ':all' tag):

=over

=cut

use 5.008;
use strict;
use warnings;
my $DEBUG = 1;
use Carp;
use Data::Dumper;

require Exporter;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [
  qw(
      relate
    ) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw(  ); # items to export into callers namespace by default.
                      # (don't use this without a very good reason.)
our $VERSION = '0.04';

=item relate

Example usage:

   my $results = relate( \@search_terms, \@filter_terms, $opts );

A more detailed example, searching a test data set:

   my $skipdull = ['~$', '\bRCS\b', '\bCVS\b', '^#', '\.elc$' ];
   my $results =
      relate( [ 'whun' ], $skipdull,
        { test_data => [ '/tmp/whun',
                         '/tmp/tew',
                         '/tmp/thruee',
                         '/etc/whun',
                     ],
          } );

If a "test_data" aref option has been supplied, it will
search that listing rather than doing a locate command
(this is for testing purposes).

Note that the options hash is passed through to the L<locate> routine,
so this routine also supports the "locate" and "database" options.

=cut

sub relate {
  my $searches = shift;
  my $filters  = shift;
  my $opts     = shift;

  my $all_results = $opts->{ all_results };
  my $ignore_case = $opts->{ ignore_case };
  my $test_data    = $opts->{ test_data };
  my $dirs_only   = $opts->{ dirs_only };
  my $files_only  = $opts->{ files_only };
  my $links_only  = $opts->{ links_only };

  my $initial;
  if ( ref( $test_data ) eq 'ARRAY' ) {
    $initial = $test_data;
  } elsif ( $test_data ) {
    carp "The 'test_data' option should be an array reference.";
  } else {
    my $seed = shift @{ $searches };
    $initial = locate( $seed, $opts );
  }

  # dwim upcarets: usually should behave like boundary matches
  my @rules = map{ s{^ \^ (?![/]) }{\\b}xg; $_ } @{ $searches };

  my @set = @{ $initial };
  my @temp;
  # try each search term, winnowing down result on each pass
  if ( not( $ignore_case ) ) {
    foreach my $search ( @rules ) {
      # leading minus means negation
      if ( (my $term = $search) =~ s{ ^ - }{}x ) {
        my $rule = qr{ $term }x;
        @temp = grep { not m{ $rule }x } @set;
      } else {
        my $rule = qr{ $search }x;
        @temp = grep { m{ $rule }x } @set;
      }
      @set = @temp;
      @temp  = ();
    }
  } else { # ignore case
    foreach my $search ( @rules ) {
      # leading minus means negation
      if ( (my $term = $search) =~ s{ ^ - }{}x ) {
        my $rule = qr{ $term }xi;
        @temp = grep { not m{ $rule }x } @set;
      } else {
        my $rule = qr{ $search }xi;
        @temp = grep { m{ $rule }x } @set;
      }
      @set = @temp;
      @temp  = ();
    }
  }

  # pre-compile each filter term
  my @filters;
  if ( not( $ignore_case ) ) {
    @filters = map{ qr{ $_ }x } @{ $filters };
  } else {  # ignore case
    @filters = map{ qr{ $_ }xi } @{ $filters };
  }

  # apply each filter pattern, rejecting what matches
  unless( $all_results ) {
    foreach my $filter ( @filters ) {
      @temp = grep { not m{ $filter }x } @set;
      @set = @temp;
      @temp  = ();
    }
  }

  if( $dirs_only ) {
    @set = grep{ -d $_ } @set;
  } elsif ( $files_only ) {
    @set = grep{ -f $_ } @set;
  } elsif ( $links_only ) {
    @set = grep{ -l $_ } @set;
  }

  return \@set;
}


=item locate

Runs the locate command on the given search term, the "seed".
Also accepts a hashref of options as a second argument.

Define the locate option to something besides 'locate' to run
a different program (note: you may include the path here).

Example:

   my $hits = locate( $seed, { locate => '/usr/local/bin/slocate' } );

=cut

sub locate {
  my $seed     = shift;
  my $opts     = shift;

  my $locate = $opts->{ locate } || 'locate';
  my $database = $opts->{ database };

  my $option_string = '';
  if ( $opts->{ regexp } ) {
    $option_string .= ' -r ';
  }

  if ( $opts->{ ignore_case } ) {
    $option_string .= ' -i ';
  }

  if ( $database ) {
    $option_string .= " -d $database ";
  }

  my $cmd   = qq{ $locate $option_string $seed };
  ($DEBUG) && print STDERR "cmd: $cmd\n";

  my $raw   = qx{ $cmd };
  chomp( $raw );

  my @set = split /\n/, $raw;

  return \@set;
}

1;

=back

=head1 SEE ALSO

See the man page for "locate".

L<App::Relate> is a more complicated version of this project.
It's based on L<List::Filter>, which was intended to allow the
sharing of filters between different projects.

=head1 NOTES

=head1 TODO

=head1 AUTHOR

Joseph Brenner, E<lt>doom@kzsu.stanford.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Joseph Brenner

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 BUGS

See L<relate>.

=cut
