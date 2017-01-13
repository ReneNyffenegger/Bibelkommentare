#!/usr/bin/perl
#   vi: set local foldmarker={{{,}}}
#
#   Change the links in alle_kapitel.html so that
#   they point to the out directory.
#
#   Unicode problems
#     http://stackoverflow.com/questions/38590498/are-there-any-gotchas-with-openmy-f-encodingutf-8-n?noredirect=1#comment64570147_38590498
use strict;
use warnings;


use lib "$ENV{git_work_dir}/biblisches/kommentare";

# 2016-07-27 use utf8 because § didn't seem to work anymore.
use utf8;
use Getopt::Long;
use Bibel_;
use File::Find;
use File::Copy;
use File::HomeDir;
use Digest::MD5::File qw(file_md5_hex);
use YAML::Tiny;
use File::Copy;


use lib "$ENV{github_root}/Biblisches";
use lib "$ENV{github_root}/notes/scripts/";
use lib "$ENV{github_root}/RN/";
use Bibel;
use notes;
use RN;


# my $seperate_chapters = 1;

my %ftp_file_md5_old;
my %ftp_file_md5_new;
my $ftp_file_md5_file = 'ftp_file_md5.yaml';

my $skip_bible = 0;
Getopt::Long::GetOptions(
    "web"        => \my $web,
    "skip-bible" => \   $skip_bible,
    "file-modif" => \my $file_modif
);

# {{{ go.pl components


my $target_env = $web ? 'web' : 'local';
my $verbose = 0;
RN::init($target_env, $verbose);
my $index_file = RN::url_path_abs_2_os_path_abs('/notes/.index');#  "${notes_input_root}notes/.index";

print "index_file = $index_file\n";

my %index;

die unless -f $index_file;
notes::init($web, 0, $verbose); # 2nd parameter: test
notes::load_index($index_file);


# }}}

my $out_dir = RN::url_path_abs_2_os_path_abs('/Biblisches/Kommentare/');
my $ftp;

if ($web) { # {{{
  RN::copy_url_path_abs_2_os_path("/Biblisches/Kommentare/$ftp_file_md5_file", $ftp_file_md5_file);
} # }}}
else { # {{{

  copy ("$out_dir/$ftp_file_md5_file", $ftp_file_md5_file);
} # }}}

if (-e $ftp_file_md5_file) {
  my $yaml = YAML::Tiny->read($ftp_file_md5_file);
  %ftp_file_md5_old = %{ $yaml->[0] } if $yaml;
}



my   $out_bible;
my   $kap_tab_div_required = 0;
my   $index_bible;
unless ($skip_bible) { # {{{

  $index_bible = RN::open_url_path_abs('/Biblisches/Kommentare/index.html');
  print $index_bible '<!DOCTYPE html>
  <html>
  <head>
    <meta content="text/html;charset=utf-8" http-equiv="Content-Type">
    <title>Kommentare zur Bibel</title>
  </head>
  <body>';
  
  
open (my $eigene_uebersetzung, '<:unix:encoding(UTF-8)', "$ENV{github_root}Bibeluebersetzungen/tq84.bibel"                )or die "could not open $ENV{github_root}Bibeluebersetzungen/tq84.bibel";
open (my $elberfelder        , '<:unix:encoding(UTF-8)', "$ENV{github_root}Bibeluebersetzungen/elb1905.bibel"             )or die;
open (my $sch2k              , '<:unix:encoding(UTF-8)', "$ENV{git_work_dir}biblisches/kommentare/uebersetzungen/sch2k.bibel" )or die "$!";
open (my $ylt                , '<', "$ENV{github_root}/Bibeluebersetzungen/ylt.bibel"   )or die;
open (my $interlinear        , '<:unix:encoding(UTF-8)', "$ENV{github_root}Bibeluebersetzungen/interlinear.bibel") or die;

  # open (my $lxx                , '<', 'C:\github\Bibeluebersetzungen\lxx.bibel'   )or die;  # LXX raw ge-downloaded von http://bibel.myvnc.com/septuaginta.html
  
  
  my $kjv = 1;
  
  if ($kjv) {
    undef $kjv;
    open ($kjv                , '<', "$ENV{github_root}/Bibeluebersetzungen/kjv.bibel" )             or die;
  }
  
  my   $div_t_akku = '';
  
  my   $current_book_no = 1;
  
  my   $in_kommentare;
  my   $verse_done;
  my   $line;
  
  
  my   $skip_start = 1;
  my   $dont_read_next_line = 0;
  my   $elb_text;
  my   $sch2k_text;
  my   $kjv_text;
  my   $ylt_text;
  my   $inl_text; # Interlinear
  # my   $lxx_text;
  
  
  my   $current_book   ;
  my   $current_chapter;
  my   $current_verse  ;
  my   $current_text   ;
  my   $modification   ;
  my   $modification_class;

 # {{{
  open $in_kommentare , '<:unix:encoding(UTF-8)', "$ENV{github_root}Bibelkommentare/Text" or die "Text (IN)";


my $current_chapter_QQ   = -1;
my $current_book_name = "";
my $print_bible_text  = 0;
my $at = 1;

  while (my $bibel_text = <$eigene_uebersetzung>) { # {{{

    if ($bibel_text =~ m!^# Buch: (.+)!) { # {{{
       $current_book_name = $1;
       $current_book_name = 'Psalm' if $current_book_name eq 'Psalmen';
    } # }}}

    next unless $bibel_text =~ m!^(\w+)-(\d+)-(\d+)\|([^|]+)\|(.*)!; # {{{
  
       $current_book     = $1;
       $current_chapter  = $2;
       $current_verse    = $3;
       $current_text     = $4;
       $modification     = $5;
     # }}}
 

    if ($current_book eq 'mt') {$at = 0};
  
    $modification_class='mod_n'; # {{{
    if ($modification =~ m/# *m/) {
      $modification_class = 'mod_m';
    }
    elsif ($modification =~ m/# *M/) {
      $modification_class = 'mod_M';
    }
    elsif ($modification =~ m/# *O/) {
      $modification_class = 'mod_O';
    }
    elsif ($modification =~ m/# *T/) {
      $modification_class = 'mod_T';
    }
    elsif ($modification =~ m/#/) {
       die "Modification $modification @ $current_book-$current_chapter-$current_verse";
    } # }}}

  
      if ($current_verse == 1) {
         open_html("${current_book}_$current_chapter", "$current_book_name $current_chapter", $current_book, $current_chapter);
      }
  

    if ($current_verse == 1) { # {{{
  
    
        $current_chapter_QQ = $current_chapter ;
        print $out_bible "  </div><!-- kap-tab -->\n" if $kap_tab_div_required;
        print $out_bible "  <div class='kap-tab'>\n";
    
        $kap_tab_div_required = 1;
  
    } # }}}
  
    my $schlachter_line = '';
    while ( !$schlachter_line or $schlachter_line =~ /^#/) { # {{{
       $schlachter_line = <$sch2k>;
       chomp($schlachter_line);
    }
      $schlachter_line =~ m!(\w+)-(\d+)-(\d+)\|([^|]*)\|! or die "$schlachter_line didn't match on line $.";
      my $sch2k_book    = $1;
      my $sch2k_chapter = $2;
      my $sch2k_verse   = $3;
         $sch2k_text    = $4;
  
      die "$sch2k_book $current_book Sch2k $sch2k_chapter $sch2k_verse Current: $current_chapter $current_verse" unless $sch2k_book eq $current_book and $sch2k_chapter == $current_chapter and $sch2k_verse == $current_verse; # }}}
  
    my $elberfelder_line = <$elberfelder>;
    if ($elberfelder_line) { # {{{
      (my $old_chapter, my $old_verse) = Bibel_::old_chapter_and_verse($current_book, $current_chapter, $current_verse, 'elb');
      $elberfelder_line =~ m!(\w+)-(\d+)-(\d+)\|([^|]*)\|! or die;
    
      my $elb_book    = $1;
      my $elb_chapter = $2;
      my $elb_verse   = $3;
         $elb_text    = $4;
  
    
      die "$elb_book $current_book Elb: $elb_chapter $elb_verse Old: $old_chapter $old_verse Current: $current_chapter $current_verse" unless $elb_book eq $current_book and $elb_chapter == $old_chapter and $elb_verse == $old_verse;
  
    } # }}}
  
    my $kjv_line;
    if ($kjv) { # {{{
      (my $old_chapter, my $old_verse) = Bibel_::old_chapter_and_verse($current_book, $current_chapter, $current_verse, 'kjv');
       $kjv_line = <$kjv>;
       $kjv_line = <$kjv> if $kjv_line =~ /^#/;
  
  #    $kjv_line =~ m!([^,]+),(\d+),(\d+),'(.*)'$!;
       $kjv_line =~ m!([^-]+)-(\d+)-(\d+)\|([^|]*)|$!;
  
       my $kjv_book   = $1;
       my $kjv_chapter= $2;
       my $kjv_verse  = $3;
          $kjv_text   = $4;
  
  
      die "$kjv_book $current_book KJV: $kjv_chapter $kjv_verse Old: $old_chapter $old_verse Current: $current_chapter $current_verse" unless $kjv_book eq $current_book and $kjv_chapter == $old_chapter and $kjv_verse == $old_verse;
  
  
    } # }}}

    my $ylt_line; # {{{
    {
      (my $old_chapter, my $old_verse) = Bibel_::old_chapter_and_verse($current_book, $current_chapter, $current_verse, 'ylt');
       $ylt_line = <$ylt>;
       $ylt_line = <$ylt> if $ylt_line =~ /^#/;
  
       $ylt_line =~ m!([^-]+)-(\d+)-(\d+)\|([^|]*)|$!;
  
       my $ylt_book   = $1;
       my $ylt_chapter= $2;
       my $ylt_verse  = $3;
          $ylt_text   = $4;
  
  
      die "$ylt_book $current_book YLT: $ylt_chapter $ylt_verse Old: $old_chapter $old_verse Current: $current_chapter $current_verse" unless $ylt_book eq $current_book and $ylt_chapter == $old_chapter and $ylt_verse == $old_verse;
  
  
    } # }}}

    my $inl_line; # {{{
    unless ($at) {
      (my $old_chapter, my $old_verse) = Bibel_::old_chapter_and_verse($current_book, $current_chapter, $current_verse, 'ylt');
       $inl_line = <$interlinear>;
       $inl_line = <$interlinear> if $inl_line =~ /^#/;
  
       $inl_line =~ m!([^-]+)-(\d+)-(\d+)\|([^|]*)|$!;
  
       my $inl_book   = $1;
       my $inl_chapter= $2;
       my $inl_verse  = $3;
          $inl_text   = $4;
  
  
      die "$inl_book $current_book INL: $inl_chapter $inl_verse Old: $old_chapter $old_verse Current: $current_chapter $current_verse" unless $inl_book eq $current_book and $inl_chapter == $old_chapter and $inl_verse == $old_verse;
  
  
    } # }}}
  

    # {{{ Substitutions on tq84 Text
    
    unless ($web) {
      # Eigene Übersetzung sollte HERR, nicht Jehova enthalten..
      # die "$current_text $current_book : $current_chapter-$current_verse" if $current_text =~ /Jehova/;
      $current_text =~ s|Jehova|<span class='todo'><b>Jehova</b></span>|g;
    }
    
    $current_text = HERR_zu_Jehova($current_text);
  
  
    die "HERR $current_book : $current_chapter-$current_verse\n$current_text" if $current_text =~ /HERR/;
    die "GOTT $current_book : $current_chapter-$current_verse\n$current_verse" if $current_text =~ /GOTT/;
  
   # }}}

   # {{{ Wörter
   $current_text =~ s/\bwider\b/gegen/g;
 
   $current_text =~ s/\bChristo\b/Christus/g;
   $current_text =~ s/\bChristum\b/Christus/g;
   $current_text =~ s/\bJesu\b/Jesus/g;
 
   $current_text =~ s/\bselbige(.)?\b/diese$1/g;
   $current_text =~ s/\bdaselbst\b/dort/g;
 
   $current_text =~ s/\b([Vv])on dem /$1om /g;
   $current_text =~ s/\b([Ii])n dem /$1m /g;
   $current_text =~ s/\b([Aa])n dem /$1m /g;
   $current_text =~ s/\b([Bb])ei dem /$1eim /g;

   $current_text =~ s/in\{!\} dem/in dem/g;
   $current_text =~ s/\b([Bb])ei\{!\} dem/$1ei dem/g;

   # }}}
  
   # {{{ Instruktionen 
   
   $current_text =~ s|{SH: (\d+) ([^}]+)}|<a class="strongs" href="https://www.blueletterbible.org/lang/lexicon/lexicon.cfm?Strongs=H$1&amp;t=KJV">($2)</a>|g;
   $current_text =~ s|{SG: (\d+) ([^}]+)}|<a class="strongs" href="https://www.blueletterbible.org/lang/lexicon/lexicon.cfm?Strongs=G$1&amp;t=KJV">($2)</a>|g;
#ph   $current_text =~ s|{z: ([a-zA-Z0-9_-]+) ([^}]+)}|
#ph    my $val;
#ph    if (IstZusatzPublic($1)) {
#ph       $val = "<a class='z' href='$1.html'>($2)</a>";
#ph    }
#ph    else {
#ph      if ($web) {
#ph        $val = "";
#ph      }
#ph      $val = "<a class='todo' href='$1.html'>($2)</a>";
#ph    }
#ph    $val;
#ph    |eg;

   $current_text =~ s|{Z: ([^}]+)}|<a class="fn" href="$1.html"><sup>*</sup></a>|g;
   $current_text =~ s|\[\[|<i>[|g;
   $current_text =~ s|\]\]|]</i>|g;
   $current_text =~ s| -$||g;

   if ($web) {
     $current_text =~ s|{TODO:[^}]*}||g;
   }
   else {
     $current_text =~ s|{TODO:\s*([^}]*)}|<span class='todo'>[$1]</span>|g;
   }
   
   
   # }}}


   # }}}

    while ($dont_read_next_line or $line = <$in_kommentare>) { # {{{
    
      chomp $line;
      next if $line =~ m!^{|^}!;
  
      $skip_start = 0 if $line =~ m!\@1. Mose!;
      next if $skip_start;
    

      if ($line eq '#}') {
        $line = '      </div>';
        $verse_done = 1;
      }
      else {
        $verse_done = 0;
      }
    
    
      $line =~ s/<!--.*-->//g; 
      next if $line =~ m!^@!;  # Start of chapter
  
  
      if ($line =~ m!^#([^-]+)-(\d+)-(\d+) \{$!) { # {{{
    
        my $b1  = $1; my $c1  = $2; my $v1  = $3;
    
    
        if ($b1 ne $current_book or $c1 ne $current_chapter_QQ or $v1 ne $current_verse) { # {{{
    
          $dont_read_next_line = 1;
    
    
          print $out_bible verse_element($current_book, $current_chapter, $current_verse); # "<div class='v' id='I$current_book-$current_chapter-$current_verse'><div class='n'>$verse_id</div> <!-- Inserted Verse -->\n";
          print_verse();
          print $out_bible "</div> <!-- Inserted Verse end -->\n";
          goto VERSE_DONE;
    
        } # }}}
        else { # {{{
          $dont_read_next_line = 0;
          $print_bible_text = 1;
        } # }}}
    
    
        $line = verse_element($b1, $c1, $v1);
    
      } # }}}
      else { # {{{
        $dont_read_next_line = 0;
      } # }}}
    
    
      $line =~ s!href='http://bibel.renenyffenegger.ch/([^_]+)_(\d+)\.html#v(\d+)'>!
        replace_link($1, $2, $3);
      !ge;
    
      $line =~ s!class='kom' href='#I([^-]+)-(\d+)-(\d+)'>!
        "class='kom' " . replace_link($1, $2, $3);
      !ge;

      $line = modify_out_line($line);
    
      if ($line eq ' {') { # {{{
    
        die "$div_t_akku" if $div_t_akku;
    
        $line       = "        <div class='t'>";
        $div_t_akku = $line
    
      } # }}}
      elsif ($div_t_akku) { # {{{
    
        if ($line eq ' }') {
          $div_t_akku .= '        </div>';
        }
        else {
          $div_t_akku .= $line;
        }
    
        if ($line eq ' }') {

    
          if ($div_t_akku =~ m/TODO/ or $div_t_akku =~ /'u'/) { # {{{
    
    
            if (!$web) {
              $div_t_akku =~ s|>|><span class='akkutodo'>AKKU_TODO</span> |;
    
              print $out_bible $div_t_akku;
            }
    
          } # }}}
          else { # {{{
             print $out_bible $div_t_akku;
    
          } # }}}
    
          $div_t_akku = '';
    
        }
      } # }}}
      else { # {{{
        print $out_bible "$line\n";;
      } # }}}
  
      if ($print_bible_text) { # {{{
          print_verse();
        $print_bible_text = 0;
      } # }}}
  
      goto VERSE_DONE if $verse_done;
    } # }}}
  
  VERSE_DONE:
  } # }}}



print $index_bible '</body>
</html>';

RN::close_($index_bible);
# }}}

sub print_verse { # {{{

  die $current_text if $current_text =~ /}|{/;

  if ($web) {
    print $out_bible "  <div class='b'>$current_text</div>\n";
  }
  if (! $web ) {
    print $out_bible "  <div class='b $modification_class'>$current_text</div>\n";

    print $out_bible "  <div class='sch2k'>$sch2k_text</div>\n";
    print $out_bible "  <div class='elb'>$elb_text</div>\n";
    print $out_bible "  <div class='kjv'>$kjv_text</div>\n";
    print $out_bible "  <div class='ylt'>$ylt_text</div>\n";
    print $out_bible "  <div class='inl'>$inl_text</div>\n" unless $at;
  }
} # }}}

write_html_footer('offb', 22);  # Last converted book

if ($web) {
  ftp_put('BibelKommentare.css');
}
else {
  copy 'BibelKommentare.css', $out_dir or die "Could not copy BibelKommentare.css to $out_dir";
}

close_html();
close $in_kommentare;


} # }}}


write_md5_yaml();


sub write_html_header { # {{{

  my $title = shift;
  my $book  = shift;

  my $target_script;


    $target_script = "  target = buch + '_' + kapitel + '.html#I' + buch + '-' + kapitel + '-' + vers_nr;";

  print $out_bible <<"E";
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN' 'http://www.w3.org/TR/html4/loose.dtd'> 
<html>
<head><!--{-->
  <title>Kommentare zur Bibel: $title</title>
  <meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>
  <link rel="stylesheet" type="text/css" href="BibelKommentare.css"/>
<script type="text/JavaScript">
<!--

var shift_is_pressed = 0;

function key_(down, e) {

  if (!e) {
    e = window.event;
  }

  var key;
  if (e.which) {
    key = e.which
  }
  else {
    key = e.keyCode
  }


  if (key == 16) {
    if (down) {
       shift_is_pressed = 1;
       console.log('key = SHIFT, down = ' + down + ', setting shift_is_pressed to 1');
    }
    else {
       shift_is_pressed = 0;
       console.log('key = SHIFT, down = ' + down + ', setting shift_is_pressed to 0');
    }
  }
  else if (key == 71 && shift_is_pressed && !down) {
     
      console.log("shift_is_pressed and key == 'g' and not down");

      document.getElementById('vers_eingabe_div' ).style.visibility = 'visible';
      document.getElementById('vers_eingabe_text').value = '';
      document.getElementById('vers_eingabe_text').focus();

  }

}
function goToAnchor() {  // http://stackoverflow.com/a/22145810/180275
    console.log('goToAnchor') 
    hash = document.location.hash;
    if (hash !="") {
        setTimeout(function() {
            if (location.hash) {
                window.scrollTo(0, 0);
                window.location.href = hash;
            }
        }, 1);
    }
    else {
        return false;
    }
}
function vers_eingabe_go() {
  var vers = document.getElementById('vers_eingabe_text').value;
  var re   = /(\\w+) +(\\w+) +(\\w+)/;
  var matches;
  if (matches = re.exec(vers)) {

    var buch    = matches[1];
    var kapitel = matches[2];
    var vers_nr = matches[3];

    var target;

    $target_script

    document.getElementById('vers_eingabe_div' ).style.visibility = 'hidden';
    console.log('target = ' + target);

    window.location.href = target;

  }
  else {
    console.log("regular expression didn't match");
  }
}

document.onkeydown = function(e) { key_(1, e); }
document.onkeyup   = function(e) { key_(0, e); }
window.onload = goToAnchor;

//-->

</script>
</head><!--}-->
<body>
<div id="vers_eingabe_div" style="visibility:hidden;position:fixed;background-color:yellow;width:180px;height: 80px; z-index:99">
  <form action="javascript:vers_eingabe_go()">
    <input id="vers_eingabe_text" type="text" style="position:absolute; top:20px; left:20px">
  </form>
</div>
E


  print $out_bible "<div id='kapitel'><table summary='...'><tr><td id='kap-name'>$title</td>";

  my $anzahl_kap = Bibel::AnzahlKapitel($book);

  if ($anzahl_kap > 1) {

    print $out_bible "<td class='title-sep'>&nbsp;</td><td>";
    for my $k (1 .. $anzahl_kap) {
      print $out_bible "<a href='${book}_$k.html'>$k</a> ";
    }
    print $out_bible "</td>";

  }
  print $out_bible "<td class='title-sep'>&nbsp;</td><td><a href='index.html'>Index</a></td>";
  
  print $out_bible "</tr></table></div>";

  print $out_bible "<div id='top'>&nbsp;</div>";


} # }}}

sub write_html_footer { # {{{

  my $buch    = shift;
  my $kapitel = shift;

  if ($kapitel > 1) {
    print $out_bible "<a href='${buch}_" . ($kapitel -1) . ".html'>Kapitel " . ($kapitel - 1) . "</a> ";
  }
  if ($kapitel < Bibel::AnzahlKapitel($buch)) {
    print $out_bible "<a href='${buch}_" . ($kapitel +1) . ".html'>Kapitel " . ($kapitel + 1) . "</a> ";
  }

print $out_bible <<E
</div> <!-- kap-tab -->
</body>
</html>
E

} # }}}


my $last_opened_html_file;
my $last_buch;
my $last_kapitel;
sub open_html { # {{{

  $kap_tab_div_required = 0;

  my $filename = shift;
  my $title    = shift;
  my $book     = shift;
  my $kapitel  = shift;

  if ($out_bible) {
     write_html_footer($last_buch, $last_kapitel);
     close_html();
  }

  $last_opened_html_file = "$filename.html";
  $last_buch             = $book;
  $last_kapitel          = $kapitel;


  $out_bible = RN::open_url_path_abs("/Biblisches/Kommentare/$filename.html");

  write_html_header($title, $book);

  print $index_bible "<a href='$filename.html'>$title</a><br>";

} # }}}

sub close_html { # {{{

  close $out_bible;

  if (is_file_modified("$out_dir/$last_opened_html_file")) {

    if ($^O eq 'linux') {
      system ("tid $out_dir/$last_opened_html_file" ) and print "\n in $last_opened_html_file\n";
    }
    else {
      system ("tid $out_dir\\$last_opened_html_file" ) and print "\n in $last_opened_html_file.html\n";
    }

    if ($web) {
  
      RN::copy_os_path_2_url_path_abs("$out_dir/$last_opened_html_file", "/Biblisches/Kommentare/$last_opened_html_file");
  
    }
  }

} # }}}

sub HERR_zu_Jehova { # {{{

  my $text = shift;

  $text =~ s/<a href='([^']*)HERR([^']*)'/<a href="$1qqqq$2"/g;

  $text =~ s/des HERRN/Jehovas/g;
  $text =~ s/Des HERRN/Jehovas/g;
  $text =~ s/\b[Dd]er <i>HERR/<i>Jehova/g;
  $text =~ s/\b[Dd]er HERR/Jehova/g;
  $text =~ s/[Dd]e[mn] HERRN/Jehova/g;
  $text =~ s/zum HERRN/zu Jehova/g;
  $text =~ s/im HERRN/in Jehova/g;
  $text =~ s/Im HERRN/In Jehova/g;
  $text =~ s/([Vv])om HERRN/$1on Jehova/g;
  $text =~ s/beim HERRN/bei Jehova/g;
  $text =~ s/am HERRN/an Jehova/g;
  $text =~ s/HERR\b/Jehova/g;

  $text =~ s/GOTTES/Jehovas/g;

  $text =~ s/dem\{!\} HERRN/dem Jehova/g;

  $text =~ s/GOTT\b/Jehova/g;

  $text =~ s/qqqq/HERR/g;
  return $text;

} # }}}

sub replace_link { # {{{ Same Code as in c:\github\Biblisches\vers.pl (This one with href=)
  my $book    = shift;
  my $chapter = shift;
  my $verse   = shift;

  my $x =  Bibel::LinkHref($book, $chapter, $verse, 1) . '>'; # 4th parameter: seperate_chatpers
  return $x;

} # }}}

sub replace_link_full { # {{{

  my $buch     = shift;
  my $kap      = shift;
  my $vers     = shift;

  my $opts     = {};
  if (@_) {
    $opts -> {vers_bis} = shift;
  }

  if ($buch =~ s/^\+//) {
    $opts -> {class} = 'kom';

    if ($buch =~ s/^V//) {
      $opts -> {vers} = 1;
    }
  }
  elsif ($buch =~ s/^V//) {
      $opts -> {vers} = 1;
  }
  else {
    $opts -> {class} = 'vrs';
  }

  return Bibel::Link($buch, $kap, $vers, $opts);

} # }}}

sub ftp_put { # {{{

  my $file = shift;

  return unless is_file_modified($file);

  print "Put $file\n";
  $ftp -> put("$file") or die "Could not put $file";

} # }}}

sub write_md5_yaml { # {{{

  my $yaml = new YAML::Tiny (\%ftp_file_md5_new);

  $yaml -> write($ftp_file_md5_file);

  if ($web) {
    ftp_put($ftp_file_md5_file);
  }
  else {
    print "copy $ftp_file_md5_file, $out_dir/$ftp_file_md5_file\n";
    copy($ftp_file_md5_file, "$out_dir/$ftp_file_md5_file");
  }
  unlink $ftp_file_md5_file;

} # }}}

sub is_file_modified { # {{{

  my $file = shift;

  my $md5 = file_md5_hex($file) or die "file_md5_hex $file\n";
  $ftp_file_md5_new{$file} = $md5;

  if (exists $ftp_file_md5_old{$file}) {


    if ($ftp_file_md5_old{$file} eq $md5) {
      print "file is not modified $file\n" if $file_modif;
      return 0;
    }

    print "file is modified $file\n" if $file_modif;

  }
  else {
    print "unknown $file\n" if $file_modif;
  }


# print "key does not exist $file\n";
# $ftp_file_md5{$file} = $md5;
  return 1;

} # }}}

sub verse_element { # {{{

    my $b = shift;
    my $c = shift;
    my $v = shift;

    my $vers_id;

    $vers_id = $v;

    return  "<div class='v' id='I$b-$c-$v'><div class='n'>$vers_id</div>";
} # }}}

sub modify_out_line { # {{{

  my $line = shift;

  1 while ($line =~ s/§([^-]+)-(\w+)-(\w+)(-(\w+))?/replace_link_full($1, $2, $3, $5)/ge);

  $line = notes::replace_notes_link($line, '');
   
  $line = HERR_zu_Jehova($line);

  return $line;

} # }}}

sub os_to_perl { # {{{ Copied from go.pl

  my $filename_os = shift;
  if ($^O eq 'MSWin32') {
    return decode('latin-1', $filename_os);
  }
  else {
    return decode('utf-8', $filename_os);
  }

} # }}}
