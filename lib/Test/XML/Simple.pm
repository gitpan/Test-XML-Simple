package Test::XML::Simple;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';

use Test::Builder;
use Test::More;
use XML::XPath;

my $Test = Test::Builder->new();
my $Xml;
my $last_xml_string = "";

sub import {
   my $self = shift;
   my $caller = caller;
   no strict 'refs';
   *{$caller.'::xml_valid'}      = \&xml_valid;
   *{$caller.'::xml_node'}       = \&xml_node;
   *{$caller.'::xml_is'}         = \&xml_is;
   *{$caller.'::xml_is_deeply'}  = \&xml_is_deeply;
   *{$caller.'::xml_like'}       = \&xml_like;

   $Test->exported_to($caller);
   $Test->plan(@_);
}

sub xml_valid($;$) {
  my ($xml, $comment) = @_;
  my $parsed_xml = _valid_xml($xml);
  return 0 unless $parsed_xml;

  ok $parsed_xml, $comment;
}

sub _valid_xml {
  my $xml = shift;
  return $Xml if defined($xml) and $xml eq $last_xml_string;

  return $Test->diag("XML is not defined") unless defined $xml;
  return $Test->diag("XML is missing")     unless $xml;
  return $Test->diag("string can't contain XML: no tags") 
    unless ($xml =~ /</ and $xml =~/>/);
  eval {$Xml = XML::XPath->new(xml=>$xml)};
  $@ ? return $Test->diag($@)
     : return $Xml;
}

sub _find {
  my ($xml_xpath, $xpath) = @_;
  my $nodeset = $xml_xpath->find($xpath);
  return $Test->diag("Couldn't find $xpath") unless @$nodeset;
  wantarray ? @$nodeset : $nodeset;
}
  

sub xml_node($$;$) {
  my ($xml, $xpath, $comment) = @_;

  my $parsed_xml = _valid_xml($xml);
  return 0 unless $parsed_xml;

  my $nodeset = _find($parsed_xml, $xpath);
  return 0 if !$nodeset;

  ok(scalar $nodeset->get_nodelist, $comment);
}

sub xml_is($$$;$) {
  my ($xml, $xpath, $value, $comment) = @_;

  my $parsed_xml = _valid_xml($xml);
  return 0 unless $parsed_xml;

  my $nodeset = _find($parsed_xml, $xpath);
  return 0 if !$nodeset;

  foreach my $node ($nodeset->get_nodelist) {
    is($node->getChildNodes->[0]->toString,
       $value, $comment);
  }
}

sub xml_is_deeply($$$;$) {
  my ($xml, $xpath, $candidate, $comment) = @_;

  my $parsed_xml = _valid_xml($xml);
  return 0 unless $parsed_xml;

  my $candidate_xp = XML::XPath->new(xml=>$candidate);
  is($parsed_xml->findnodes_as_string($xpath), 
     $candidate_xp->findnodes_as_string('/'),
     $comment);
}

sub xml_like($$$;$) {
  my ($xml, $xpath, $regex, $comment) = @_;

  my $parsed_xml = _valid_xml($xml);
  return 0 unless $parsed_xml;

  my $nodeset = _find($parsed_xml, $xpath);
  return 0 if !$nodeset;

  foreach my $node ($nodeset->get_nodelist) {
    like($node->getChildNodes->[0]->toString,
         $regex, $comment);
  }
}

1;
__END__

=head1 NAME

Test::XML::Simple - easy testing for XML

=head1 SYNOPSIS

  use Test::XML::Simple tests=>5;
  xml_valid $xml, "Is valid XML";
  xml_node $xml, "/xpath/expression", "specified xpath node is present";
  xml_is, $xml, '/xpath/expr', "expected value", "specified text present";
  xml_like, $xml, '/xpath/expr', qr/expected/, "regex text present";

  # Not yet implemented:
  # xml_is_deeply, $xml, '/xpath/expr', $hash, "structure and contents match";
  # xml_like_deeply would be nice too...

=head1 DESCRIPTION

C<Test::XML::Simple> is a very basic class for testing XML. It uses the XPath
syntax to locate nodes within the XML. You can also check all or part of the
structure vs. an XML fragment.

=head1 AUTHOR

Joe McMahon, E<lt>mcmahon@cpan.orgE<gt>

=head1 LEGAL

Copyright (c) 2005 by Yahoo!

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself, either Perl version 5.6.1 or, at
your option, any later version of Perl 5 you may have available.

=head1 SEE ALSO

L<XML::XPath>, L<Test::More>, L<Test::Builder>.


=cut
