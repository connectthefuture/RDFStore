#!/usr/local/bin/perl -I ../lib
##############################################################################
# 	Copyright (c) 2000 All rights reserved
#	Alberto Reggiori <areggiori@webweaving.org>
#
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer. 
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
#
# 3. All advertising materials mentioning features or use of this
#    software must display the following acknowledgment:
#    This product includes software developed by the University of
#    California, Berkeley and its contributors.
#
# 4. Neither the name of the University nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# 5. Products derived from this software may not be called "RDFStore"
#    nor may "RDFStore" appear in their names without prior written
#    permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ====================================================================
#
# This software consists of work developed by Alberto Reggiori and was originally
# based on public domain software written at the Stanford University Database
# Group by Sergey Melnik.
# For more information on the RDF API Draft work, 
# please see <http://www-db.stanford.edu/~melnik/rdf/api.html>
#
##############################################################################

# this is the script to actually run the RDF Schema generator

use Carp;
use RDFStore;
use RDFStore::Stanford::Vocabulary::Generator;
    
my $f = new RDFStore::NodeFactory();
my @schemas = ();

my ($outputDirectory, $packageClass, $namespace, $factoryStr);
      
# parse options
while (my $opt = shift @ARGV) {
	if($opt =~ /\-d/) {
		$outputDirectory = shift @ARGV;
	} elsif($opt =~ /\-o/) {
		$packageClass = shift @ARGV;
	} elsif($opt =~ /\-s/) {
		push @schemas,shift @ARGV;
	} elsif($opt =~ /\-n/) {
		$namespace = shift @ARGV;
	} elsif($opt =~ /\-f/) {
		$factoryStr = shift @ARGV;
	};
};

if(scalar(@schemas) == 0) {
	print STDERR "Usage: Generator  [-d <output directory>] [-o <output class name>] [-n <namespace>] [-f <node factory class name>] {-s <schema file or URL>}+\n"."If -d is not specified, generated class will be printed to standard output.\n";
	exit(1);
};

my $generator = new RDFStore::Stanford::Vocabulary::Generator();
$packageClass = $generator->{DEFAULT_PACKAGE_CLASS}
	unless(defined $packageClass);

my $all;
foreach my $schemaURL (@schemas) {
	$namespace = $schemaURL
		unless(defined $namespace);

	my $p=new RDFStore::Parser::SiRPAC( ErrorContext => 2, 
				Style => 'RDFStore::Parser::Styles::MagicTie',
				NodeFactory	=> $f,
				Source	=> $namespace );

	my $m = $p->parsefile($schemaURL);
	print STDERR "Reading schema from ".$schemaURL."\n";

        if(!(defined $all)) {
        	#$all = $m->find(); #tricky get a VirtualModel here :-) otherwise it would be a type-cast
        	$all = $m;
        } else {
        	$all->unite($m);
	};
#print $all->toStrawmanRDF(),"\n";
};

print STDERR "Total statements: ".$all->size(),"\n";


$outputDirectory .= '/'
        unless( (not(defined $outputDirectory)) || ($outputDirectory eq '') || ($outputDirectory =~ /\s+/) || ($outputDirectory =~ /\/$/) );

$generator->createVocabulary($packageClass, $all, $namespace, $outputDirectory, $factoryStr) or
	die "Could not generate vocabulary";
