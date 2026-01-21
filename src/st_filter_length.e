note
	description: "Filter: return string length"

class
	ST_FILTER_LENGTH

inherit
	ST_FILTER

create
	make

feature -- Access

	name: STRING = "length"

feature -- Application

	apply (a_value: STRING; a_args: STRING): STRING
		do
			Result := a_value.count.out
		end

end
