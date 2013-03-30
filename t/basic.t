
use strict;
use warnings;
use utf8;

use Test::More;
use Minecraft::SectionFilter;
use Term::ANSIColor qw( color );

my $sample = "§fhelloworld§4test§rdone";

subtest direct => sub {
  is( Minecraft::SectionFilter::strip_sections($sample), 'helloworldtestdone', "Strip works" );
  is(
    Minecraft::SectionFilter::ansi_encode_sections($sample),
    color('bright_white') . 'helloworld' . color('red') . 'test' . color('reset') . 'done',
    "Colorise works"
  );

};

subtest exports => sub {
  is( strip_sections($sample), 'helloworldtestdone', "Strip works" );
  is(
    ansi_encode_sections($sample),
    color('bright_white') . 'helloworld' . color('red') . 'test' . color('reset') . 'done',
    "Colorise works"
  );

};
done_testing();
