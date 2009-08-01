# Grammar for Datapath.  Waiting on protoregexes.  

grammar	Tree::Grammar {
	rule Tree	{ <PathExpr>	};
	rule PathExpr	{ <NodeSpecifier>? <StepExpr>+ | <NodeSpecifier> };

	proto token NodeSpecifier {};
	multi token NodeSpecifier:sym<√>		{ <sym> };	# root node
	multi token NodeSpecifier:sym<⤋>		{ <sym> };	# this node (context node, current working node, etc)
	multi token NodeSpecifier:sym<⤊>		{ <sym> };	# that node

	rule StepExpr	{ <AxisStep>? <QName> <PerlExpr>?	};
	rule AxisStep	{ <ShortAxisSpec>+ | '/' <AxisSpec>? };

	rule ShortAxisSpec { <ShortAxisSpecOperator> <ShortAxisSpecOpModifier>* };

	proto token ShortAxisSpecOperator {}
	multi token ShortAxisSpecOperator:sym<⫢>	{ <sym> };	# attribute
	multi token ShortAxisSpecOperator:sym<∘>	{ <sym> };	# self
	multi token ShortAxisSpecOperator:sym<⊤>	{ <sym> };	# preceding-sibling
	multi token ShortAxisSpecOperator:sym<⫧>	{ <sym> };	# preceding
	multi token ShortAxisSpecOperator:sym<⊢>	{ <sym> };	# parent
	multi token ShortAxisSpecOperator:sym<⊩>	{ <sym> };	# ancestor
	multi token ShortAxisSpecOperator:sym<⊥>	{ <sym> };	# following-sibling
	multi token ShortAxisSpecOperator:sym<⫨>	{ <sym> };	# following
	multi token ShortAxisSpecOperator:sym<⊣>	{ <sym> };	# child
	multi token ShortAxisSpecOperator:sym<⫣>	{ <sym> };	# descendant

	proto token ShortAxisSpecOpModifier {};
	multi token ShortAxisSpecOpModifier:sym<⚭>	{ <sym> };	# overlapping
	multi token ShortAxisSpecOpModifier:sym<⩹>	{ <sym> };	# perspective
	multi token ShortAxisSpecOpModifier:sym<⊗>	{ <sym> };	# not-perspective

	rule AxisSpec { '⦃' <AxisName> (<AxisOp> <AxisName> )* '⦄' }; 

	proto token AxisName {};
	multi token AxisName:sym<attribute>	{ <sym> };
	multi token AxisName:sym<self>		{ <sym> };
	multi token AxisName:sym<preceding-sibling> { <sym> };
	multi token AxisName:sym<preceding>	{ <sym> };
	multi token AxisName:sym<parent>	{ <sym> };
	multi token AxisName:sym<ancestor>	{ <sym> };
	multi token AxisName:sym<following-sibling> { <sym> };
	multi token AxisName:sym<following>	{ <sym> };
	multi token AxisName:sym<child>		{ <sym> };
	multi token AxisName:sym<descendant>	{ <sym> };

	proto token AxisOp {};
	multi token AxisOp:sym<∪>	{ <sym> };
	multi token AxisOp:sym<∩>	{ <sym> };
	multi token AxisOp:sym<∖>	{ <sym> };

	rule QName	{ <Prefix> ':' <LocalPart> | <LocalPart> };
	rule Prefix	{ <NameOrWildCard> };
	rule LocalPart	{ <NameOrWildCard> };
	rule NameOrWildCard { '*' | <NCName> };

}
