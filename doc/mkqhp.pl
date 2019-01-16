#!/usr/bin/env perl
#
# Andrew Janke 2019
#
# Converts a Texinfo file to a QHelp .qhp index int its generated
# HTML files.
#
# Usage:
#
#   mkqhp.pl <texifile> <outfile>
#
#   <texifile> is the input .texi file
#   <outfile> is the file to write to
#
# Maps each node in the Texinfo document to its corresponding node
# HTML file. Builds a QHelp index for them matching that hierarchy.

use strict;
use File::Basename;
use Text::Wrap;
use FileHandle;
use IPC::Open3;
use POSIX ":sys_wait_h";

my $package = "chrono";
my $debug = 0;
my $verbose = 0;

my %level_map = (
	"top" => 1,
	"chapter" => 2,
	"section" => 3,
	"subsection" => 4,
	"subsubsection" => 5
);

my $file = shift @ARGV;
my $outfile = shift @ARGV;

unless (open (IN, $file)) {
    print STDERR "Error: Could not open input file $file\n";
    exit 1;
}
unless (open (OUT, ">", $outfile)) {
	print STDERR "Error: Could not open output file $file\n";
	exit 1;
}

my $preamble = <<EOS;
<?xml version="1.0" encoding="UTF-8"?>
<QtHelpProject version="1.0">
    <namespace>octave.community.$package</namespace>
    <virtualFolder>doc</virtualFolder>
    <filterSection>
        <toc>
EOS
print OUT $preamble;

# TOC section

my @files;
my $level = 0;
my $indent = "        ";
while (my $line = <IN>) {
	chomp $line;
	next unless ($line =~ /^\s*\@node +(.*?)(,|$)/);
	my $node_name = $1;
	my $next_line = <IN>;
	chomp $next_line;
	unless ($next_line =~ /^\s*\@(\S+) +(.*)/) {
		die "Error: Failed parsing section line for node '$node_name': $next_line";
	}
	my ($section_type, $section_title) = ($1, $2);
	my $section_level = $level_map{$section_type};
	my $section_qhelp_title = $section_title =~ s/@\w+{(.*?)}/\1/rg;
	my $html_title = $node_name =~ s/\s/-/gr;
	$html_title = "index" if $html_title eq "Top";
	my $html_file = "$html_title.html";
	unshift @files, $html_file;
	print "Node: '$node_name' ($section_type): \"$section_title\" => \"$section_qhelp_title\""
	    . " (level $section_level),  HTML: $html_file\n"
	    if $verbose;
	die "Error: Unrecognized section type: $section_type\n" unless $section_level;
	if ($section_level == $level) {
		# close last node as sibling
		print OUT $indent . ("    " x $level) . "</section>\n";
	} elsif ($section_level > $level) {
		# leave last node open as parent
		if ($section_level > $level + 1) {
			die "Skip in section levels at node $node_name ($level to $section_level)";
		}
	} elsif ($section_level < $level) {
		# close last two nodes
		my $levels_up = $level - $section_level;
		while ($level > $section_level) {
			print OUT $indent . ("    " x $level--) . "</section>\n";
		}
		print OUT $indent . ("    " x $level) . "</section>\n";
	}
	print OUT $indent . ("    " x $section_level) 
	    . "<section title=\"$section_qhelp_title\" ref=\"html/$html_file\">\n";
	print OUT $indent . ("    " x $section_level) 
	    . "    <!-- orig_title=\"$section_title\" node_name=\"$node_name\" -->\n"
	    if $debug;
	$level = $section_level;
}
while ($level > 1) {
	print OUT $indent . ("    " x $level--) . "</section>\n";
}
# Include the all-on-one-page version
print OUT $indent . ("    " x $level) 
    . "<section title=\"Entire Manual in One Page\" ref=\"$package.html\"/>\n"
    . $indent . "</section>\n";
print OUT <<EOS;
        </toc>
        <keywords>
        </keywords>
        <files>
EOS

# Files section

print OUT "            <file>$package.html</file>\n";
foreach my $file (@files) {
	print OUT "            <file>html/$file</file>\n";
}

# Closing
print OUT <<EOS;
        </files>
    </filterSection>
</QtHelpProject>

EOS
