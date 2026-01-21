note
	description: "Filter: join with separator (for list values)"

class
	ST_FILTER_JOIN

inherit
	ST_FILTER

create
	make

feature -- Access

	name: STRING = "join"

feature -- Application

	apply (a_value: STRING; a_args: STRING): STRING
			-- For simple strings, just returns the value.
			-- Join is more useful when applied to lists in directive context.
		do
			Result := a_value
		end

end
