#!/usr/bin/perl
#
# crap2shellcode  - 11/9/2009 Paul Melson
#
# This script takes stdin from some ascii dump of shellcode
# (i.e. unescape-ed JavaScript sploit) and converts it to
# hex and outputs it in a simple C source file for debugging.
#
# gcc -g3 -o dummy dummy.c
# gdb ./dummy
# (gdb) display /50i shellcode
# (gdb) break main
# (gdb) run
#

use strict;
use warnings;

my $crap;
while($crap=<stdin>) {
  my $hex = unpack('H*', "$crap");

  my $len = length($hex);
  my $start = 0;

  print "#include <stdio.h>\n\n";
  print "static char shellcode[] = \"";

  for (my $i = 0; $i < length $hex; $i+=4) {
    my $a = substr $hex, $i, 2;
    my $b = substr $hex, $i+2, 2;
    print "\\x$b\\x$a";
  }
  print "\";\n\n";
}

print "int main(int argc, char *argv[])\n";
print "{\n";
print "  void (*code)() = (void *)shellcode;\n";
print "  code();\n";
print "  exit(0);\n";
print "}\n";
print "\n";
