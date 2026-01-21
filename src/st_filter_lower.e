note
	description: "Filter: convert to lowercase"

class
	ST_FILTER_LOWER

inherit
	ST_FILTER

create
	make

feature -- Access

	name: STRING = "lower"

feature -- Application

	apply (a_value: STRING; a_args: STRING): STRING
		do
			Result := a_value.as_lower
		end

end
