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

# DocStuff module: common code for mk*.pl in Chrono Octave package

use strict;

package DocStuff;

use File::Basename;

# Read an INDEX file. Returns hashref:
# {
#   "name" => $toolbox_name,
#   "long_name" => $long_toolbox_name,
#   "categories" => \@category_names,
#   "by_category" => { $category_name => \@category_fcn_names }, 
#   "functions" => \@all_fcn_names,
#   "descriptions" => { $function_name => $description }
# }
#
# This is based on a really simple understanding of the INDEX file
# format, with just a header line, category lines, and function/class
# names.
#
# TODO: Implement full INDEX file format based on spec at
# https://octave.org/doc/v4.2.1/The-INDEX-File.html#The-INDEX-File.
sub read_index_file { # {{{1
    my ($index_file    # in path to INDEX file
        )               = @_;

    unless ( open(IND, $index_file) ) {
        die "Error: Could not open INDEX file $index_file: $!\n";
    }
    my ($current_category, @all_functions, @categories, %by_category, %fcn_descrs);
    my $line = <IND>;
    $line = <IND> while ($line =~ /^\s*(#.*)?$/);
    # First line is header
    chomp $line;
    unless ($line =~ /^\s*(\w+)\s+>>\s+(\S.*\S)\s*$/) {
    	die "Error: Invalid header line in INDEX file $index_file: $line\n";
    }
    my ($toolbox, $toolbox_long_name) = ($1, $2);
    while (my $line = <IND>) {
    	chomp $line;
    	next if $line =~ /^\s*(#.*)?$/;
    	if ($line =~ /^\S/) {
    		$current_category = $line;
            push @categories, $current_category unless grep (/^$current_category$/, @categories);
    		$by_category{$current_category} ||= [];
        } elsif ($line =~ /^(\S+)\s*=\s*(\S.*?)\s*$/) {
            my ($fcn, $descr) = ($1, $2);
            $fcn_descrs{$fcn} = $descr;
            push (@{$by_category{$current_category}}, $fcn);
            push @all_functions, $fcn;
    	} else {
    		my $txt = substr ($line, 1);
    		my @functions = split /\s+/, $txt;
    		push (@{$by_category{$current_category}}, @functions);
    		push @all_functions, @functions;
    	}
    }
    return {
        "name" => $toolbox,
        "long_name" => $toolbox_long_name,
        "categories" => \@categories,
    	"by_category" => \%by_category,
    	"functions" => \@all_functions,
        "descriptions" => \%fcn_descrs
    };
}


# Extract the entire main documentation comment from an m-file.
# This grabs the first comment block after an optional initial copyright block.
# It ignores M-code syntax, so if you don't have a file-level comment block,
# it may end up grabbing a comment block from inside one of your functions.
sub extract_description_from_mfile { # {{{1
    my ($mfile) = @_;
    my $retval = '';

    unless (open (IN, $mfile)) {
        die "Error: Could not open file $mfile: $!\n";
    }
    # Skip leading blank lines
    while (<IN>) {
        last if /\S/;
    }
    # First block may be copyright statement; skip it
    if (m/\s*[%\#][\s\#%]* Copyright/) {
        while (<IN>) {
            last unless /^\s*[%\#]/;
        }
    }
    # Skip everything until the next comment block
    while (!/^\s*[\#%]+\s/) {
        $_ = <IN>;
        last if not defined $_;
    }
    # Next comment block is the documentation; strip it and return it
    while (/^\s*[\#%]+\s/) {
        s/^\s*[%\#]+\s//; # strip leading comment characters
        s/[\cM\s]*$//;    # strip trailing spaces.
        $retval .= "$_\n";
        $_ = <IN>;
        last if not defined $_;
    }
    close(IN);
    return $retval;
} # 1}}}

# Extract all Octave Texinfo documentation comments from an m-file
# Returns an arrayref of extracted blocks, with each block being
# a hashref with keys "node" and "block".
sub extract_multiple_texinfo_blocks_from_mfile { # {{{1
    my ($mfile) = @_;
    my $retval = '';
    my $file_node_name = basename($mfile, ('.m'));

    unless (open (IN, $mfile)) {
        die "Error: Could not open file $mfile: $!\n";
    }
    # Skip leading blank lines
    while (<IN>) {
        last if /\S/;
    }
    # First block may be copyright statement; skip it
    if (m/\s*[%\#][\s\#%]* Copyright/) {
        while (<IN>) {
            last unless /^\s*[%\#]/;
        }
    }

    # Okay, now detect all Texinfo comment blocks
    my @blocks;
    my $block; # the current block
    my $in_block = 0;
    my $line;
    my $node;
    while (<IN>) {
        if (/^\s*## -\*- texinfo -\*-/) {
            # block start
            if ($in_block) {
                push @blocks, { node => $node, block => $block};
            }
            # Block output must start with "-*- texinfo -*-" for historical reasons
            $block = "-*- texinfo -*-";
            $in_block = 1;
            # Grab next line so we can detect node name
            $line = <IN>;
            $line = strip_mfile_block_line ($line);
            if ($line =~ /^\s*\@node (\S*)/) {
                $node = $1;
            } else {
                # For back-compatibility, the first block may take the file as its node name
                # Only the first block! Otherwise you'd have collisions.
                if (scalar (@blocks) == 0) {
                    $node = $file_node_name;
                } else {
                    die "Found non-first block with no \@node statement in file $mfile\n";
                }
            }
            $block .= "$line\n";
        } elsif (/^\s*##\s/) {
            if ($in_block) {
                $line = strip_mfile_block_line ($_);
                $block .= "$line\n";
            }
        } else {
            if ($in_block) {
                push @blocks, { node => $node, block => $block};
                $block = "";
                $in_block = 0;
            }
        }
    }
    if ($in_block) {
        push @blocks, { node => $node, block => $block};
        $block = "-*- texinfo -*-";
        $in_block = 0;
    }

    my $n_blocks = scalar @blocks;
    return \@blocks;
} # 1}}}

sub strip_mfile_block_line {
    my ($line) = @_;
    $line =~ s/^\s*##\s?//;   # strip leading comment characters
    $line =~ s/[\cM\s]*$//;   # strip trailing spaces.
    return $line;
}

sub get_package_metadata_from_description_file {
    my $description_file = "../DESCRIPTION";
    unless (open (IN, $description_file)) {
        die "Error: Could not open file $description_file: $!\n";
    }
    my ($key, $value, %defn);
    while (<IN>) {
        chomp;
        next if /^\s*(#.*)?$/; # skip comments
        if (/^ /) {
            die "Error: Failed parsing $description_file: found continuation line before any key line: \"$_\""
                unless $key;
            # continuation line
            my $txt = $_;
            $txt =~ s/^\s+//;
            $value += $txt;
        } elsif (/^(\S+)\s*:\s*(\S.*?)\s*$/) {
            $defn{$key} = $value if $key;
            ($key, $value) = ($1, $2);
        } else {
            die "Error: Failed parsing $description_file: Unparseable line: \"$_\"";
        }
    }
    $defn{$key} = $value if $key;
    return \%defn;
}

1;