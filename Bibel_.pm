package Bibel_;

use warnings;
use strict;

BEGIN {

  print "Copy this Bibel.pm to \\github\\Biblisches\\Bibel.pm\n";

}

sub old_chapter_and_verse {
  my $book    = shift;
  my $chapter = shift;
  my $verse   = shift;
  my $env     = shift; # elb, kjv, ylt, lxx

  if ($book eq '1mo') {

    if ($chapter == 32) {

       return ($chapter, $verse) if $env eq 'lxx';

       return (31, 55) if $verse == 1;

       return (32, $verse-1);
    }

  }
  if ($book eq '2mo') {
    
    return ($chapter, $verse) if $env eq 'lxx';

    if ($chapter ==  7) {

      return (8, 1) if $verse == 26;
      return (8, 2) if $verse == 27;
      return (8, 3) if $verse == 28;
      return (8, 4) if $verse == 29;

    }
    if ($chapter ==  8) {

      return ($chapter, $verse+4);
    }
    if ($chapter == 21) {

      return (22, 1) if $verse == 37;

    }
    if ($chapter == 22) {

      return ($chapter, $verse+1);
    }

  }
  if ($book eq '3mo') {

    if ($chapter == 5) {

      if ($verse >= 20 and $verse <= 26) {
        return (6, $verse - 19);
      }

    }
    if ($chapter == 6) {
      return (6, $verse + 7);
    }

  }
  if ($book eq '4mo') {
    
    if ($chapter == 17) {

      if ($verse >=  1 and $verse <= 15) {
        return (16, 35+$verse);
      }
      if ($verse >= 16 and $verse <= 28) {
        return (17, $verse - 15);
      }

    }
    if ($chapter == 30) {

      if ($verse == 1) {

        return (29, 40);

      }
      
      return (30, $verse -1);

    }

  }
  if ($book eq '5mo') {

    if ($chapter == 12) {

      if ($verse == 32) {

        return (13, 1);

      }

    }
    if ($chapter == 13) {

      if ($verse == 1) {
        return (12, 32)
      }

      if ($verse >= 2 and $verse <= 19) {
        return (13, $verse-1);
      }

    }
    if ($chapter == 23) {

      if ($verse == 1) {
        return (22, 30)
      }

      if ($verse >= 2 and $verse <= 26) {
        return (23, $verse-1);
      }

    }
    if ($chapter == 28) {
      if ($verse == 69) {
        return (29, 1);
      }
    }
    if ($chapter == 29) {
      return (29, $verse+1);
    }

  }
  if ($book eq '1sam'){

#   return ($chapter, $verse) if $env eq 'ylt';

    if ($chapter == 21) {
      if ($verse == 1) {

        return (20, 43);
      }
      if ($verse >= 2 and $verse <= 16) {
        return (21, $verse -1);
      }
      
    }
    if ($chapter == 24) {

      if ($verse == 1) {
        return (23, 29);
      }

      if ($verse >= 2 and $verse <= 23) {

        return (24, $verse -1);

      }

    }

  }
  if ($book eq '2sam'){

    if ($chapter == 19) {
      
      if ($verse == 1) {
        return (18,33);
      }

      return (19, $verse-1);

    }

  }
  if ($book eq '1koe'){

    if ($chapter == 5) {

      if ($verse >= 1 and $verse <= 14) {
        return (4, 20+$verse);
      }

      return (5, $verse -14);

    }

  }
  if ($book eq '2koe'){

    if ($chapter == 12) {

      return (11,21) if $verse == 1;

      return (12, $verse-1);

    }

  }
  if ($book eq '1chr'){

    if ($chapter == 5) {

      if ($verse >= 27 and $verse <= 41) {

       return (6, $verse - 26);

      }

    }
    if ($chapter == 6) {

      return (6, $verse+15);

    }


  }
  if ($book eq '2chr'){

    if ($chapter == 13) {
      return (14, 1) if $verse == 23;
    }
    if ($chapter == 14) {
      return (14, $verse+1);
    }

  }
  if ($book eq 'neh') {

    if ($chapter == 3) {

      if ($verse >= 33 and $verse <= 38) {

        return (4, $verse-32);

      }
    }
    if ($chapter == 4) {

      return (4, $verse+6);
    }
    if ($chapter ==10) {

      return (9, 38) if $verse == 1;

      return (10, $verse-1);
    }

  }
  if ($book eq 'hi') {

    if ($chapter == 40) {

      if ($verse >= 25 and $verse <= 32) {

        return (41, $verse-24);

      }

    }
    if ($chapter == 41) {

      return (41, $verse+8);

    }

  }
  if ($book eq 'ps') {

#   return ($chapter, $verse) if $env eq 'ylt';

    if ($chapter ==  3 or $chapter ==  4 or $chapter ==  5 or $chapter ==   6 or $chapter ==   7 or $chapter ==   8 or
        $chapter ==  9 or $chapter == 12 or $chapter == 18 or $chapter ==  19 or $chapter ==  20 or $chapter ==  21 or
        $chapter == 22 or $chapter == 30 or $chapter == 31 or $chapter ==  34 or $chapter ==  36 or $chapter ==  38 or
        $chapter == 39 or $chapter == 40 or $chapter == 41 or $chapter ==  42 or $chapter ==  44 or $chapter ==  45 or $chapter == 46 or
        $chapter == 47 or $chapter == 48 or $chapter == 49 or                    $chapter ==  51 or $chapter ==  52 or
        $chapter == 53 or $chapter == 54 or $chapter == 55 or $chapter ==  56 or $chapter ==  57 or $chapter ==  58 or
        $chapter == 59 or $chapter == 60 or $chapter == 61 or $chapter ==  62 or $chapter ==  63 or $chapter ==  64 or $chapter == 65
                       or $chapter == 68 or $chapter == 69 or $chapter ==  70 or $chapter ==  75 or $chapter ==  76 or $chapter == 77 or
        $chapter == 80 or $chapter == 81 or $chapter == 83 or $chapter ==  84 or $chapter ==  85 or 
        $chapter == 88 or $chapter == 89 or $chapter == 92 or $chapter == 102 or $chapter == 108 or $chapter == 140 or $chapter == 142) {

      return ($chapter, $verse - 1);

   }

   if ($env eq 'kjv' and $chapter == 67) {

      return ($chapter, $verse - 1);
   }

  }
  if ($book eq 'pred') {

    if ($chapter == 4) {

      if ($verse == 17) {

        return (5, 1);

      }

    }
    if ($chapter == 5) {

      return (5, $verse + 1);
    }

  }
  if ($book eq 'hl') {

    if ($chapter == 7) {

      return (6,13) if $verse == 1;
      return (7, $verse -1);

    }

  }
  if ($book eq 'jes') {

    if ($chapter == 8) {

      return (9,1) if $verse == 23;

    }
    if ($chapter == 9) {

      return (9, $verse+1);
    }
  }
  if ($book eq 'jer') {

    if ($chapter == 8) {

      return (9,1) if $verse == 23;

    }
    if ($chapter == 9) {

      return (9, $verse +1);

    }

  }
  if ($book eq 'hes') {

    if ($chapter == 21) {
    
      return (20, 44+$verse) if $verse >=1 and $verse <= 5;

      return (21, $verse -5);

    }

  }
  if ($book eq 'dan') {

    if ($chapter == 6) {

      return (5,31) if $verse == 1;
      return (6,$verse-1);

    }

  }
  if ($book eq 'hos') {

    if ($chapter == 2) {

      return (1,10) if $verse == 1;
      return (1,11) if $verse == 2;

      return (2, $verse-2);

    }
    if ($chapter ==12) {

      return (11, 12) if $verse == 1;

      return (12, $verse-1);

    }
    if ($chapter ==14) {

      return (13, 16) if $verse == 1;

      return (14, $verse-1);

    }

  }
  if ($book eq 'joe') {

    if ($chapter == 3) {

      return (2, $verse+27) if $verse >=1 and $verse <= 5;

    }
    if ($chapter == 4) {

      return (3, $verse);

    }
  }
  if ($book eq 'jon') {

    if ($chapter == 2) {

      return (1, 17) if $verse == 1;

      return (2, $verse-1);

    }
  }
  if ($book eq 'mi') {

    if ($chapter == 4) {

      return (5, 1) if $verse == 14;

    }
    if ($chapter == 5) {

      return (5, $verse+1);

    }
  }
  if ($book eq 'nah') {

    if ($chapter == 2) {

      return (1, 15) if $verse == 1;

      return (2, $verse-1);

    }
  }
  if ($book eq 'sach') {

    if ($chapter == 2) {

      return (1, 17+$verse) if $verse >= 1 and $verse <= 4;

      return (2, $verse-4);

    }
  }
  if ($book eq 'mal') {

    if ($chapter == 3) {

      return (4, $verse-18) if $verse >= 19 and $verse <= 24;

    }
  }

  return ($chapter, $verse);
}

1;
