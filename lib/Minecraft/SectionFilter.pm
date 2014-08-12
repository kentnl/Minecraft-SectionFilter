use v5.10;
use strict;
use warnings;
use utf8;

package Minecraft::SectionFilter;

# ABSTRACT: Strip/Process magical § characters from minecraft

use Sub::Exporter::Progressive -setup => {
  exports => [qw( translate_sections strip_sections ansi_encode_sections )],
  groups  => {
    default => [qw( strip_sections ansi_encode_sections )],
  },
};

use Carp qw( carp );

=head1 SYNOPSIS

    use Minecraft::SectionFilter;
    while(<$some_stream_of_text>){
        if( $ENV{MODE} eq 'STRIP' ) {
            print(strip_sections($_))
        }
        else {
            print(ansi_encode_sections($_));
        }
    }

=cut

=func translate_sections

Parse a string into a series of elements;

    my (@list) = translate_sections($string)

Resulting list will be a list of hashrefs, either:

    { type => text , content => "the string itself" }

or

    { type => section, section_code => $char }

=cut

sub translate_sections {
  state $section = chr 0xA7;

  my ($line) = @_;
  my (@out);
  while ( length $line > 0 ) {
    if ( $line =~ /^([^$section]+)/ ) {
      push @out, { type => text =>, content => "$1", };
      substr $line, 0, length "$1", q{};
      next;
    }
    if ( $line =~ /^$section(.)/ ) {
      push @out, { type => section =>, section_code => "$1" };
      substr $line, 0, 2, q{};
    }

  }
  return @out;
}

=func strip_sections

Strip section codes from a string.

    my $output = strip_sections( $input );

=cut

sub _section_to_stripped {
  return $_[0]->{content} if $_->{type} eq 'text';
  return q{};
}

sub strip_sections {
  return join q{}, map { _section_to_stripped($_) } translate_sections( $_[0] );
}

sub _ansi_translation_table {
  return state $translation_table = {
    0 => 'black',
    1 => 'blue',
    2 => 'green',
    3 => 'cyan',
    4 => 'red',
    5 => 'magenta',
    6 => 'yellow',
    7 => 'white',
    8 => 'bright_black',
    9 => 'bright_blue',
    a => 'bright_green',
    b => 'bright_cyan',
    c => 'bright_red',
    d => 'bright_magenta',
    e => 'bright_yellow',
    f => 'bright_white',

    l => 'bold',
    m => 'concealed',
    n => 'underscore',
    o => 'reverse',

    r => 'reset',
  };
}

sub _warn { return carp( sprintf '[%s] %s', __PACKAGE__, join q{ }, @_ ) }
sub _warnf { my $format = '[%s] ' . shift; return carp( sprintf $format, __PACKAGE__, @_ ) }

sub _section_to_ansi {
  return $_[0]->{content} unless $_[0]->{type} eq 'section';
  state $colorize = do {
    require Term::ANSIColor;
    \&Term::ANSIColor::color;
  };
  state $trt = _ansi_translation_table();
  my ($code) = $_[0]->{section_code};
  if ( exists $trt->{$code} ) {
    return $colorize->( $trt->{$code} );
  }
  if ( exists $trt->{ lc $code } ) {
    _warnf( 'uppercase section code "%s" (ord=%s)', $_[0]->{section_code}, ord $_[0]->{section_code} );
    return $colorize->( $trt->{ lc $code } );
  }
  _warnf( 'unknown section code "%s" (ord=%s)', $_[0]->{section_code}, ord $_[0]->{section_code} );
  return '<unknown section ' . $_[0]->{section_code} . '>';
}

=func ansi_encode_sections

Translate section codes to Term::ANSIColor color codes.

    STDOUT->print( ansi_encode_sections( $minecraft_string ) );

=cut

sub ansi_encode_sections {
  return join q{}, map { _section_to_ansi($_) } translate_sections( $_[0] );
}

=head1 SEE ALSO

L<Minecraft::RCON|Minecraft::RCON> which has a similar feature, except its not user-acessible/reusable.

=cut

1;
