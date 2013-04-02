#!/usr/bin/perl
# yet another ltsview
# see https://github.com/naoya/perl-Text-LTSV
# see http://d.hatena.ne.jp/naoya/20130207/1360229220
# usage: ltsview.pl -k time,ua
package LTSV;
use strict;
use warnings;
use Data::Dumper;
use YAML;

sub new {
    my $class = shift;
    my $hash = { fields => undef, hash => undef };
    return bless $hash, $class;
}

sub parse_line {
    my ($self ,$line) = @_;
    chomp $line;
    my %hash = map {split ':', $_, 2 } split "\t", $line;
    $self->{hash} = \%hash;
    return $self;
}

sub output {
    my $self = shift;

    my $row;
    if ($self->{fields}) {
        for (@{$self->{fields}}) {
            $row->{$_} = $self->{hash}->{$_};
        }
    } else {
        $row = $self->{hash};
    }

    my $output = '';
    for (@{$self->{fields}}) {
        $output .= $_ . ":" . $row->{$_} . "\t";
    }
    $output .= "\n";

    return $output;
}

sub fields {
    my ($self , @keys) = @_;
    $self->{fields} = \@keys if @keys;
}

package main;
use strict;
use warnings;
use YAML;
use Getopt::Long;

my $opt = Getopt::Long::Parser->new(
    config => ['no_ignore_case', 'pass_through'],
    );
$opt->getoptions(
    'k|keys=s@'        => \my @keys,
    );


my $parser = LTSV->new;


$parser->fields(map {split ',' } @keys) if @keys;
#print @{$parser->{fields}} ,"\n";exit;

while(<>) {
    $parser->parse_line($_);
    print $parser->output;
}
