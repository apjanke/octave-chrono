#!/usr/bin/env perl
#
# David Bateman Feb 02 2003
# Andrew Janke 2019
# 
# Extracts the help in texinfo format from *.cc and *.m files for use
# in documentation, and generates the DOCSTRINGS.texi.tmp function doco index.
# Based on make_index script from octave_forge.
#
# Usage:
#
#   mkdoc.pl <outfile> <sourcedir> [<sourcedir> ...]
#
#   <sourcedir> is the the path to a source directory
#
# The dir <sourcedir> is searched recursively for Octave function
# source code files.
#
# The <outfile> is the function doco index file you want to create; typically
# DOCSTRINGS.texi.tmp. This file is a sequence of Texinfo blocks, one per
# input file, separated by ASCII 037 (Unit Separator). The first line in each
# block will contain the identifier for that block (based on the input file
# name), and the subsequent lines are the Texinfo contents extracted from that file.
#
# In M-files, the texinfo doco is located as comment blocks anywhere in
# the file, but following an optional initial Copyright block in each file.
# Each comment block must start with the string "## -*- texinfo -*-" to indicate that it
# is in Texinfo format. The block is all the contiguous lines that start with "## ",
# with optional leading whitespace before the "##". The leading "## "
# and any trailing whitespace are stripped.
#
# In C++ files, the doco blocks are the string arguments to each DEFUN_DLD
# macro.
#
# The found texinfo help blocks are all concatenated, with "\037%s\n" (ASCII US)
# separating each entry. Each entry should be considered one thing that gets
# an entry into the function index in whatever final output help format you
# are using.
#
# Progress messages are written to stdout. Warnings and diagnostics are
# written to stderr.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.    See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>.
# This program is granted to the public domain.
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

BEGIN {
    push @INC, ".";
}

use strict;
use File::Find;
use File::Basename;
use FileHandle;

use DocStuff;

my $outfile = shift @ARGV;
my @srcdirs = @ARGV;

unless (open (OUT, ">", $outfile)) {
    die "Error: Could not open output file $outfile: $!\n";
}
sub emit { # {{{1
    print OUT @_;
} # 1}}}

# Locate all C++ and m-files in current directory
my @m_files = ();
my @cxx_files = ();
find(\&cc_and_m_files, @srcdirs);

sub cc_and_m_files { # {{{1 populates global array @files
    # This prune is probably superfluous -apj
    if ($_ eq "+internal" or $_ eq "private") {
        $File::Find::prune = 1;
    }
    return unless -f and /\.(m|cc)$/;  # .m and .cc files
    my $path = "$File::Find::dir/$_";
    $path =~ s|^[.]/||;
    if (/\.m$/) {
        push @m_files, $path;
    } else {
        push @cxx_files, $path;
    }
} # 1}}}

# Grab help from C++ files
foreach my $file ( @cxx_files ) {
    my $blocks = DocStuff::extract_texinfo_from_cxxfile ($file);
    for my $block (@$blocks) {
        my $function = $$block{node};
        my $desc = $$block{block};
        emit sprintf("\037%s\n%s\n", $function, $desc);
    }
    close (IN);
}

# Grab help from m-files
foreach my $file (@m_files) {
    my $descs = DocStuff::extract_multiple_texinfo_blocks_from_mfile($file);
    if (scalar (@$descs) == 0) {
        printf STDERR "Function/class file %s does not contain texinfo help\n",
                    $file;
    }
    for my $desc (@$descs) {
        my $node_name = $desc->{"node"};
        my $block = $desc->{"block"};
        emit sprintf ("\037%s\n%s\n", $node_name, $block);
    }
}


