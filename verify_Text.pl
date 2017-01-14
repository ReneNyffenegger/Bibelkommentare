#!/usr/bin/perl
use strict;
use warnings;

open my $h, '<', 'Text' or die;

my %books_seen;
my $last_book = '?';
my $last_chapter = 0;
my $cur_abbr_with_ch;
my $cur_v=0;

my $in_v = 0;
my $in_t = 0;   
my $in_c = 0;

my %map_books_abbreviation = ( # {

  '1. Mose'           => '1mo',
  '2. Mose'           => '2mo',
  '3. Mose'           => '3mo',
  '4. Mose'           => '4mo',
  '5. Mose'           => '5mo',
  'Josua'             => 'jos',
  'Richter'           => 'ri',
  'Ruth'              => 'rt',
  '1. Samuel'         => '1sam',
  '2. Samuel'         => '2sam',
  '1. Könige'         => '1koe',
  '2. Könige'         => '2koe',
  '1. Chronik'        => '1chr',
  '2. Chronik'        => '2chr',
  'Esra'              => 'esr',
  'Nehemia'           => 'neh',
  'Esther'            => 'est',
  'Hiob'              => 'hi',
  'Psalm'             => 'ps',
  'Sprüche'           => 'spr',
  'Prediger'          => 'pred',
  'Hohelied'          => 'hl',
  'Jesaja'            => 'jes',
  'Jeremia'           => 'jer',
  'Klagelieder'       => 'kla',
  'Hesekiel'          => 'hes',
  'Daniel'            => 'dan',
  'Hosea'             => 'hos',
  'Joel'              => 'joe',
  'Amos'              => 'am',
  'Obadja'            => 'ob',
  'Jona'              => 'jon',
  'Micha'             => 'mi',
  'Nahum'             => 'nah',
  'Habakuk'           => 'hab',
  'Zephanja'          => 'zeph',
  'Haggai'            => 'hag',
  'Sacharja'          => 'sach',
  'Maleachi'          => 'mal',
  'Matthäus'          => 'mt',
  'Markus'            => 'mk',
  'Lukas'             => 'lk',
  'Johannes'          => 'joh',
  'Apostelgeschichte' => 'apg',
  'Römer'             => 'roem',
  '1. Korinther'      => '1kor',
  '2. Korinther'      => '2kor',
  'Galater'           => 'gal',
  'Epheser'           => 'eph',
  'Philipper'         => 'phil',
  'Kolosser'          => 'kol',
  '1. Thessaloniker'  => '1thes',
  '2. Thessaloniker'  => '2thes',
  '1. Timotheus'      => '1tim',
  '2. Timotheus'      => '2tim',
  'Titus'             => 'tit',
  'Philemon'          => 'phim',
  'Hebräer'           => 'hebr',
  'Jakobus'           => 'jak',
  '1. Petrus'         => '1petr',
  '2. Petrus'         => '2petr',
  '1. Johannes'       => '1joh',
  '2. Johannes'       => '2joh',
  '3. Johannes'       => '3joh',
  'Judas'             => 'jud',
  'Offenbarung'       => 'offb',
); # }


while (my $l = <$h>) {

  if ( my ($book, $chapter) = $l =~ /@(.+) (\d+)/) {

     die if $in_v;
     die if $in_t;
     die if $in_c;

     $in_c = 1;

     my $cur_abbr = $map_books_abbreviation{$book};

     die "book: $book" unless $cur_abbr;

     $cur_abbr_with_ch = "${cur_abbr}-$chapter";

     if ($last_book eq $book) {

       if ($last_chapter >= $chapter) {
         print "Chapter mismatch ($last_chapter < $chapter, $book)\n";
       }

     }
     else {
 
       if (exists $books_seen{$book}) {
         print "$book alread seen\n";
       }

     }

     $last_book    = $book;
     $last_chapter = $chapter;

     $cur_v        = 0;


     $books_seen {$book} = 1;

     next

  }

  if ( my ($book_ch, $v) = $l =~ /^#(\w+-\d+)-(\d+) \{$/) {

    die if $in_v;
    die if $in_t;
    $in_v = 1;

    if ($book_ch ne $cur_abbr_with_ch) {
      print "Mismatch v $book_ch $cur_abbr_with_ch ($.)\n";
    }

    if ($v <= $cur_v) {
      print "Mismatch vv $book_ch $cur_abbr_with_ch $cur_v $v ($.)\n";
    }

    $cur_v = $v;
    next;

  }
  if ($l =~ /^#\}/) {

    die unless $in_c;
    die unless $in_v;
    die if     $in_t;
    $in_v = 0;

    next;

  }
  if ($l =~ /^ \{$/) {
    die unless $in_c;
    die unless $in_v;
    die if     $in_t;
    $in_t = 1;
    next;
  }
  if ($l =~ /^ \}$/) {
    die unless $in_c;
    die unless $in_v;
    die unless $in_t;
    $in_t = 0;
    next;
  }
  if ($l =~ /^#\}/) {
    die unless $in_c;
    die unless $in_v;
    die if     $in_t;
    $in_v = 0;
    next;
  }
  if ($l =~ /^\@\}$/) {
    die unless $in_c;
    die if     $in_v;
    die if     $in_t;
    $in_c = 0;
    next;
  }
  if ($l =~ /^\{/) {
    next;
  }
  if ($l =~ /^\}$/) {
    next;
  }
  die $l . ' @ ' . $. unless $in_c and $in_t and $in_v;
  if ($l =~ /<!--[{}]-->/) {
    next;
  }  
  die unless $in_t;
  die $l . ' @ ' . $. if $l =~ /[{}]/ and $l !~ m,<!--[{}]-->,;

}

close $h;
