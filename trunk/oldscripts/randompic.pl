#!/usr/bin/perl

$formats[$#formats + 1] = "dcp#####.jpg";
$formats[$#formats + 1] = "dsc#####.jpg";
$formats[$#formats + 1] = "dscn####.jpg";
$formats[$#formats + 1] = "mvc-###.jpg";
$formats[$#formats + 1] = "mvc#####.jpg";
$formats[$#formats + 1] = "P101####.jpg";
$formats[$#formats + 1] = "PMDD####.jpg";
$formats[$#formats + 1] = "1##-####.jpg";
$formats[$#formats + 1] = "dscf####.jpg";
$formats[$#formats + 1] = "pdrm####.jpg";
$formats[$#formats + 1] = "IM######.jpg";
$formats[$#formats + 1] = "EX######.jpg";
$formats[$#formats + 1] = "DC####S.jpg";
$formats[$#formats + 1] = "pict####.jpg";

#Flush prints
$|++;

do {
  srand;
  $choice = int(rand ($#formats+1));
  $searchterm = $formats[$choice];
  $searchterm =~ s/\#/digit()/eg;
  $url="http://images.google.com/images?q=${searchterm}&num=1&btnG=Google+Search&as_epq=&as_oq=&as_eq=&imgsz=&as_filetype=jpg&imgc=&as_sitesearch=&imgsafe=off";
  #print "Search url: $url\n";
  $cmd = "lynx --dump \"$url\" | grep http://images.google.com/imgres";
  #print "Command: $cmd\n";
  $result=`$cmd`;
# print $?;
  #print "Result: $result\n";
} while ($result eq "");

$result =~ /http:\/\/images.google.com\/imgres\?imgurl=(.*)\&imgrefurl\=/;
#$link = "http://" . $1;
$link = $1;
print $link;
print "\n";

sub digit {
  return int(rand(10));
}

