use Test::Builder::Tester tests=>4;
use Test::More;
use Test::XML::Simple;

my $totally_invalid = <<EOS;
yarrgh there be no XML here
EOS

my $broken_xml = <<EOS;
<imatag> but this isn't good<nomatch>
EOS

my $valid = <<EOS;
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

test_out("not ok 1 - XML is not defined");
test_fail(+1);
xml_valid(undef, "no xml");
test_test('undef');

test_out("not ok 1 - string can't contain XML: no tags");
test_fail(+1);
xml_valid($totally_invalid, "invalid xml");
test_test('non-XML string');

test_out("ok 1 - good xml");
xml_valid($valid, "good xml");
test_test('good xml');

test_out("not ok 1 - :2: parser error : Premature end of data in tag nomatch line 1\n# \n# ^\n# :2: parser error : Premature end of data in tag imatag line 1\n# \n# ^");
test_fail(+1);
xml_valid($broken_xml, "invalid xml");
test_test(title=>'bad XML', skip_err=>1);
