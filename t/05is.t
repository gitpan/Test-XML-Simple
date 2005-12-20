use Test::Tester;
use Test::More tests=>6;
use Test::XML::Simple;

my $xml = <<EOS;
<CATALOG>
  <CD>
    <TITLE>Sacred Love</TITLE>
    <ARTIST>Sting</ARTIST>
    <COUNTRY>USA</COUNTRY>
    <COMPANY>A&amp;M</COMPANY>
    <PRICE>12.99</PRICE>

    <YEAR>2003</YEAR>
  </CD>
</CATALOG>
EOS

@results = run_tests(
    sub {
          xml_is($xml, "//ARTIST", 'Sting', "good node")
    },
    {
       ok=>1,
    }
 );
ok($results[1]->{ok}, 'found node');

@results = run_tests(
    sub {
          xml_is_long($xml, "//ARTIST", 'Sting', "good node")
    },
    {
       ok=>1,
    }
 );
ok($results[1]->{ok}, 'found node');

@results = run_tests(
    sub {
          xml_is($xml, "/CATALOG/CD/ARTIST", 'Sting', "full path")
    },
    {
       ok=>1,
    }
 );
ok($results[1]->{ok}, 'found path');

@results = run_tests(
    sub {
          xml_is_long($xml, "/CATALOG/CD/ARTIST", 'Sting', "full path")
    },
    {
       ok=>1,
    }
 );
ok($results[1]->{ok}, 'found path');

@results = run_tests(
    sub {
          xml_is($xml, "//ARTIST", 'Weird Al', "good node")
    },
    {
       ok=>0,
    }
 );
ok(!$results[1]->{ok}, 'no node');

@results = run_tests(
    sub {
          xml_is($xml, "/CATALOG/CD/ARTIST", 'Weird Al', "full path")
    },
    {
       ok=>0,
    }
 );
ok(!$results[1]->{ok}, 'no path');