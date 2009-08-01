# The roles here model a Tree.  The comments are based on comparing the functionality with 
# Perl5's XML::LibXML
#
# The purpose is not to simulate the DOM, but merely to ensure that all required 
# functionality exists

# NeedsWork: means it needs work
# OpWorks: means that it needs to be changed when operators work
# FeatureFix means it's waiting on another feature (eg. feeds)

# The following functionality is not currently supported (but maybe should be)
# -	Schemas & Namespaces (can currently simply be done by putting a ':' in the name)
# -	Text / Serialisation / Encoding (only if I can figure out a generic way to do it)

# The following XML::LibXML things will be left to specific classes as being XML-specific (unless someone proves me wrong about the usefulness of these):
# -	Adoption (should happen automatically)
# -	Creation (should happen by calling new, and passing in an owner)
# -	Other XML-specific stuff (see Tree/Document)

use	v6;

use	EventArray;

role	Tree::Node {...}
role	Tree::Axes {...}

# Tree is the DOM Document
role	Tree does Tree::Node {
	has Tree::Node $treeroot;	# documentElement, setDocumentElement
	has Tree::Node $cwn;		# Current Working Node, much like current working directory (cwd); this is a cursor

# Not currently supported (see above):
# -	Schemas & Namespaces: createInternalSubset, createExternalSubset, externalSubset, internalSubset, setExternalSubset, setInternalSubset, removeExternalSubset, removeInternalSubset
# -	Text / Serialisation / Encoding : encoding, actualEncoding, setEncoding, compression, setCompression, toString*, serialize*, toFH, toFile, toStringHTML, serialize_html, is_valid, validate

# XML specific (see above):
# -	Creation: createDocument, createElement, createElementNS, createTextNode, createComment, 
#	createAttribute, createAttributeNS, createDocumentFragment, create, createProcessingInstruction, 
#	createEntityReference
# -	Adoption: importNode, adoptNode
# -	The find functionality of Node can do these: getElementsByTagName, getElementsByTagNameNS, getElementsByLocalName, getElementById
# -	XPath optimisation: indexElements
# -	XML version: version
# -	Indicates XML standalone: standalone, setStandalone
}

# Descendants need to:
# -	implement .pathelement()
role	Tree::Node does Array does Hash {
	##### Public Attributes
	has Str $.name;
	has Tree::Node $.parent;
	has Tree $.owner;
	has Int	$selfindex;

#	method new() {
#		my $object = $class.bless(*, |%_)
# Next line doesn't work in Rakudo
#		if(%_<parent> :exists()) {
#			push $object.parent[], $object;
#			$object.owner = $parent.owner;
#		}
#
#		return $object;
#	}

	##### Operators
	# XML isEqual
	# NeedsWork
	bool method infix:<==>(Tree::Node $self, Tree::Node $other) {
		
	}

	# Private Attributes
	has EventArray of Tree::Node @!children handles <Array List Container>;
	# Needswork: How do we make this check the owner and set $selfindex?

	# PathStep separation operator
	#$htmlobject /html/body//p/{ /a/ and .name eq "#SampleName" } ==> @anchors;
	multi method resolveaxes(Tree::Node @nodes: Matcher $test) {
		my Tree::Axes $axes;
		my $realtest;
		my $usetest;

		if ($test.ref() eq Pair) {
			$axes = Tree::Axes.new($test.key());
			$realtest = $test.value();
		} else {
			$axes = Tree::Axes.new('child');
			$realtest = $test;
		}
		given $realtest {
			when Code {
				$usetest = $realtest;
			}
			when Str {
				$usetest = { /$realtest/ };
			}
		}
# FeatureFix
#		@nodes ==> map { =$axes ==> grep $usetest; };
	}
	# Uses descendant axis
	method doubleslash(Tree::Node @parents: Matcher $test) {
# OpWorks
#	multi method postfix:<//>(Tree::Node @parents: Matcher $test) {
		my $newtest = (<child> => $test);
		@parents / $newtest;
	}

# May not needs this any more
	# Hopefully we can get this to act as a grep; then it will do filters (findnode, find, findvalue)
#	method postcircumfix:<{ }>(Block $selector, $node) {
#	method postcircumfix:<{ }>(Block $selector, $node(s)) {
#		grep $selector $nodes;
#	}

	method	path() {
		$.parent.path() ~ self.pathelement();
	}

	method	depth() {
		$.parent.depth() + 1;
	}

# The following functionality can be simulated as follows:
# -	nodeType: Can be replaced with $obj.WHAT or something
# -	isSameNode: hopefully === can do this
# -	cloneNode: with the is copy trait

# Not currently supported (see above):
# -	Text / Serialisation / Encoding : nodeValue, textContent, normalize, toString*, serialize*, line_number
# -	Schemas & Namespaces: localname, prefix, namespaceURI, lookupNamespaceURI, lookupNamespacePrefix, getNamespaces
}

# Implementors need to initialise $!defaultattributename
role	Tree::Element does Tree::Node {
	has Tree::Node %.attributes;	# hasAttributes, attributes, hasAttribute, setAttribute, getAttribute, 
					# getAttributeNode, removeAttribute

	has Str $!defaultattributename; # Hopefully initialised by constructor

	method	pathelement() {
		self.attributes{$!defaultattributename};
	}

# Not currently supported (see above):
# -	Schemas & Namespaces: setAttributeNS, setAttributeNS, getAttributeNodeNS, removeAttributeNS, hasAttributeNS, 
#	getChildrenByTagNameNS, getChildrenByLocalName, getElementsByTagNameNS, getElementsByLocalName, setNamespace, 
#	setNamespaceDeclURI, setNamespaceDeclPrefix
# -	Text / Serialisation / Encoding : appendWellBalancedChunk, appendText, appendTextNode, appendTextChild
}


role	Tree::Attribute does Tree::Node {
	has $.value;	# getValue, value, setValue

	method pathelement() {
		"attribute::" ~ $.name;
	}

# Implemented by Tree::Node:
# -	getOwnerElement
#
# Not currently supported (see above):
# -	Schemas & Namespaces: setNamespace
# -	Text / Serialisation / Encoding : serializeContent, isId
}

# This would be the ancestor for things like Text, Comment, CDATASection and things like that
role	Tree::Block does Tree::Node {
	has $.type;
	has $.value;

	method	pathelement() {
		return $.type ~ "()";
	}
}

# Just plain not currently implemented:
# -	PI (processing instruction; what's this again?)
# -	XPathContext (probably won't need this)
# Roles not implemented:
# -	Text / Serialisation / Encoding : Text, Comment, CDATASection
# -	Schemas & Namespaces: Namespace, DTD, RelaxNG, Schema
# XML-specific:
# -	DocumentFragment
