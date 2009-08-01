# Tree traversal stuff.  See POD below.  

# Using FeatureFix to mark things that don't work due to not being implemented yet

use	v6;

role	Tree::Axis {
# FeatureFix
#	has $implementation handles *;
	has $implementation;

	method	new(%params) {
		my Str $bearing;
		my Str $route;
		given $params{bearing} {
			when "child" {
				$bearing = "descendant";
				$params{maxdepth} = 1;
			}
			when "parent" {
				$bearing = "ancestor";
				$params{maxdepth} = 1;
			}
			default {
				$bearing = $params{bearing};
			}
		}
		$bearing or die "Error: No bearing provided to Tree::Axis\n";
		$route = $params{route} || "depthfirst";
		$fullimplementationname = "Tree::Axis::$route::$bearing";
# FeatureFix -- this causes strange errors
#		self.implementation = ::$fullimplementationname.new(|$params); } };
	}
}

role	Tree::Axes does Iterator {
	has Tree::Axis @!axes;
	has Tree::Axis $!currentaxis;

=begin pod

=head3 Tree::Axes->new(@axes)

	Tree::Axes->new(<child>);

	Tree::Axes->new(
		<self>,
		\(
			bearing => <sibling>,
			direction => <following>,
		)
	);

The second example above is roughly (in XPath terms) self-or-following-sibling.

Each element of the array of parameters specifies an axis.  Each element of the array can be a Capture, a Pair, or a Str.  The 
Capture is the most complete variant, and the other two are simply abbreviations of it.  

The Capture parameter names are:

=over

=item

bearing: this is the direction within the tree, and can be any of "self", "descendant", "sibling", "ancestor", and  "attribute".  

=item

route: this is basically the search algorithm used; currently only depthfirst is supported, and this is (and will 
remain) the default.  

=item

direction: This is which direction you're going through the search algorithm, and can be any of "self", "following",
"preceding", and "any".  The default is "any".  

=item

depth: the maximum depth of search to use.  The default is Inf

=back

Pair: If the parameter is a pair instead of a Capture, then the key will be the bearing, and the value will be the direction,
with the defaults being as advertised above.

Str: If the parameter is just a string, it is assumed to be a bearing, with the defaults as advertised above

A few special bearings will also be accepted:
 * child uses the descendant implementation with depth 1
 * parent uses the ancestor implementation with depth 1

=end pod

	method	new(@axesspecs) {
		my $capture;
#		@axesspecs ==> map {
			given $_ {
				when Str {
					$capture = \( $bearing => $_ );
				}
				when Pair {
					$capture = \(
						bearing => $_.key();
						direction => $_.value();
					);
				}
				when Capture {
					$capture = $_;
				}
				default { throw "Unknown axis type initialising Tree::Axis"; }
			}
#			Tree::Axis->new(|$capture);
#		} ==> @axes;
	}

#	method prefix:<=>(Tree::Node $node) {
#		gather {
#			foreach(@axes -> $currentaxis) {
#				$currentaxis.treewalk($node);
#			}
#		}
#	}
}

# Decendants must implement .taker()
role	Tree::Axis::Base {
	has Str $.bearing;
	has Str $.direction = "any";
	has Str $.route = "depthfirst";
	has Str $.maxdepth = Inf;
	has Tree::Node $.startnode;

	has Tree::Node $!currentnode;
	has Int $!currentdepth;

	my method setup(Tree::Node $node) {
		$startnode = $node;
		$currentnode = $node;
		$currentdepth = -1;
	}

	method	treewalk(Tree::Node $node) {
		.setup($node);
		.deeper();
	}

	method	deeper() {
		$self.currentdepth++;
		if($self.currentdepth > $self.maxdepth) {
			$self.currentdepth--;
			return;
		}

		$thisnode = $currentnode;
		$self.taker();
		$currentdepth--;
	}
}
