# This class is basically an array, except when you add things to it, or remove them from 
# it, it calls the onAdd and onRemove subroutines

class	EventArray is Array {
	has Code &.onAdd;
	has Code &.onRemove;

	has @!tmplist;
	has $!tmpitem;

	method delete (@array : *@indices ) is export {
		@!tmplist = callsame();
		onRemove(@!tmplist);
		return(@!tmplist);
	}

	multi method pop ( @array: ) is export {
		$!tmpitem = callsame();
		onRemove($!tmpitem);
		return($!tmpitem);
	}

	multi method push ( @array: *@values ) is export {
		onAdd(@values);
		$!tmpitem = callsame();
		return($!tmpitem);
	}

	multi method shift ( @array:  ) is export {
		$!tmpitem = callsame();
		onRemove($!tmpitem);
		return $!tmpitem;
	}

	our Int multi method unshift ( @array: *@values ) is export {
		onAdd(@values);
		$!tmpitem = callsame();
		return $!tmpitem;
	}

	our List multi method splice( @array is rw: Int $offset = 0, Int $size?, *@values ) is export {
		onAdd(@values);
		@!tmplist = callsame();
		onRemove(@!tmplist);
		return(@!tmplist);
	}
	multi method postcircumfix:<[ ]>($contents) {
		die "EventArray doesn't do [] yet!";
	}
}
