use	v6;

use	Tree;

class	XML::Element does Tree::Element {
}

class	XML::ToTree {
	has XML::Element $!currnode;

	multi method element($match, $tag) {
		say "tag is $tag, element is " ~ $match<name>;
		given $tag {
			when 'opentag' {
#				my $newelement = XML::Element.new(
#					name => $match<name>,
#					parent => $currnode,
#				);
#				$currnode = $newelement;
			}
			when 'closetag' {
#				$currnode = $currnode.parent;
			}
			default { die "Unknown tag for element: '$tag'"; }
		}
	}

	multi method attribute($match) {
		say "attribute " ~ $match<name> ~ " is " ~ $match<value>;
#		$currnode{$match<name>} = $match<value>;
	}
}
