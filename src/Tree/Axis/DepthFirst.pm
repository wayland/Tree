role	Tree::Axis::depthfirst is Tree::Axis::Base {
	has $!donefirst = 0;

	my method actself() {
		if($donefirst) {
			take $currentnode;
		} else {
			$donefirst = 1;
		}
	}

	my method descender() {
		if($direction eq ("following" | "any")) {
			my Tree::Node $thisnode;
			my Tree::Node @children;

			$thisnode = $currentnode;
			@children = $currentnode[0..*];
			.actself();
			for @children -> $currentnode {
				.deeper();
			}
			$currentnode = $thisnode;
		}
	}
}

class	Tree::Axis::depthfirst::self does Tree::Axis::Base {
	method	taker() {
		if($direction eq ("self" | "any") {
			take $currentnode;
		}
	}
}

class	Tree::Axis::depthfirst::descendant does Tree::Axis::depthfirst {
	method	taker() {
		.descender();
	}
}

class	Tree::Axis::depthfirst::sibling does Tree::Axis::Base {
	method	taker() {
		my Tree::Node @siblings;

		$currentnode.parent()[] ==> @siblings;
		if($direction eq ("preceding" | "any")) {
			for($currentnode.selfindex-1..0) { take @siblings[$_]; }
		}
		if($direction eq ("following" | "any")) {
			for($currentnode.selfindex+1..@siblings.end()) { take @siblings[$_]; }
		}
	}
}

class	Tree::Axis::depthfirst::ancestor does Tree::Axis::Base {
	method	taker() {
		if($self.direction eq ("preceding" | "any")) {
			my Tree::Node $thisnode;

			$thisnode = $currentnode;
			$currentnode = $currentnode.parent();
			$self.deeper();
			$currentnode = $thisnode;
		}
	}
}

class	Tree::Axis::depthfirst::attribute does Tree::Axis::Base {
	method	taker() {
		for(%attributes) { take $_; }
	}
}

# Hopefully this implements what happens when preceding or following is used with an "any" bearing
class	Tree::Axis::depthfirst::any does Tree::Axis::depthfirst {
	has $!downwards = 1;

	my method setup(Tree::Node $node) {
		$startnode = $node.owner();
		$currentnode = $node;
		$currentdepth = $node.depth();
        }

	method	taker() {
		given $direction {
			when "any" {
				die "Can't have both the direction and the bearing being 'any'";
			}
			when "preceding" {
				if(! $donefirst) {
					.descender();
				}
				.actself();
				$currentnode.shallower();
			}
			when "following" {
				if($downwards) {
					# Descendants
					my $firsttake = ! $donefirst;
					.descender();
					$firsttake and $downwards = 0;
				} else {
					# Ancestors following siblings
					$currentnode.shallower();
				}
			}
			default { die "Unknown direction '$direction'"; }
		}
	}
	method	shallower() {
		my Tree::Node @siblings;

		$thisnode = $currentnode;
		$currentnode = $currentnode.parent();
		$currentnode[] ==> @siblings;

		given $direction {
			when "preceding" {
				for($currentnode.selfindex-1..0) {
					$currentnode = @siblings[$_];
					deeper();
				}
			}
			when "following" {
				for($currentnode.selfindex+1..@siblings.end()) { 
					$currentnode = @siblings[$_];
					deeper();
				}
			}
		}
		.shallower()
		$currentnode = $thisnode;
	}
}
