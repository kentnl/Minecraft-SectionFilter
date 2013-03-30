
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "File::Find" => 0,
    "File::Temp" => 0,
    "Module::Build" => "0.4003",
    "Test::More" => "0.98",
    "strict" => 0
  },
  "configure_requires" => {
    "Module::Build" => "0.4003"
  },
  "dist_abstract" => "Strip/Process magical \247 characters from minecraft",
  "dist_author" => [
    "Kent Fredric <kentfredric\@gmail.com>"
  ],
  "dist_name" => "Minecraft-SectionFilter",
  "dist_version" => "0.1.0",
  "license" => "perl",
  "module_name" => "Minecraft::SectionFilter",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Sub::Exporter::Progressive" => 0,
    "Term::ANSIColor" => 0,
    "perl" => "v5.16.0",
    "utf8" => 0,
    "warnings" => 0
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
