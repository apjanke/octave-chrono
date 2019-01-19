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

# Read an INDEX file. Returns hashref:
# {
#   'by_category' => { $category_name => \@category_fcn_names }, 
#   'functions' => \@all_fcn_names
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
        print STDERR "Could not open file $index_file: $!\n";
        exit 1;
    }
    my ($current_category, @all_functions, %categories);
    my $line = <IND>;
    $line = <IND> while ($line =~ /^\s*(#.*)?$/);
    # First line is header
    chomp $line;
    unless ($line =~ /^\s*(\w+)\s+>>\s+(\S.*\S)\s*$/) {
    	die "Invalid header line in INDEX file $index_file: $line";
    }
    my ($toolbox, $toolbox_long) = ($1, $2);
    while (my $line = <IND>) {
    	chomp $line;
    	next if $line =~ /^\s*(#.*)?$/;
    	if ($line =~ /^\S/) {
    		$current_category = $line;
    		$categories{$current_category} ||= [];
    	} else {
    		my $txt = substr ($line, 1);
    		my @functions = split /\s+/, $txt;
    		push (@{$categories{$current_category}}, @functions);
    		push @all_functions, @functions;
    	}
    }
    return {
    	"by_category" => \%categories,
    	"functions" => \@all_functions
    };
}

1;