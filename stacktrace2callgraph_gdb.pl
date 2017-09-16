#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $FuncPat=qr/^#\d+\s*0x[0-9a-f]+\s+in\s+([^\(@]+)(@| \()/;

my @threads=();
my @frames=();
my %func=();

while(<>){
	if (/^\s*$/){
		if (@frames) {
			push @threads, [@frames];
			@frames=();
		}
		next;
	}elsif (/^Thread/){
	}elsif (/$FuncPat/){
		$func{$1}++;
		push @frames, $1;
	}else {
		die "Illegal input:$_";
	}
}

if (@frames) {
	push @threads, [@frames];
	@frames=();
}

my $dummy="JustA_Dummy_".rand();

#print Dumper(\@threads);

$func{$dummy}=0;
my @func=keys %func;
%func=map{($func[$_], [$_, $func{$func[$_]}])} (0..$#func);
#print Dumper(\%func);

my %callgraph=();

for my $thr (@threads){
	for (my $i=0; $i < $#$thr;$i++){
		my ($callee, $caller)=@{$thr}[$i, $i+1];
		$callgraph{$caller}{"children"}{$callee}++;
		$callgraph{$callee}{"parents"}{$caller}++;
	}
}

#print Dumper(\%callgraph);
print <<'DONE'
		     Call graph (explanation follows)


granularity: each sample hit covers 2 byte(s) no time propagated

index % time    self  children    called     name

DONE
;

for my $f (keys %callgraph){
	my $parents=$callgraph{$f}{"parents"};
	my $children=$callgraph{$f}{"children"};
	
	unless (keys %$parents) {
		$parents->{$dummy}=0;
	}

	printf join "", map{sprintf "       0.00  0.00  %d/%d  %s [%d]\n", $parents->{$_}, $func{$_}[1], $_, $func{$_}[0]} (keys %$parents);
	printf "[%d]  0.00  0.00  0.00  %d  %s [%d]\n", $func{$f}[0], $func{$f}[1], $f, $func{$f}[0];
	printf join "", map{sprintf "       0.00  0.00  %d/%d  %s [%d]\n", $children->{$_}, $func{$_}[1], $_, $func{$_}[0]} (keys %$children);
	printf "----------------------------------\n";
}
print "\f\n";
