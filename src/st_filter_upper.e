note
	description: "Filter: convert to uppercase"

class
	ST_FILTER_UPPER

inherit
	ST_FILTER

create
	make

feature -- Access

	name: STRING = "upper"

feature -- Application

	apply (a_value: STRING; a_args: STRING): STRING
		do
			Result := a_value.as_upper
		end

end
