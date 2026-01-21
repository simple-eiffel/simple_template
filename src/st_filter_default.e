note
	description: "Filter: provide default value if empty"

class
	ST_FILTER_DEFAULT

inherit
	ST_FILTER

create
	make

feature -- Access

	name: STRING = "default"

feature -- Application

	apply (a_value: STRING; a_args: STRING): STRING
		do
			if a_value.is_empty then
				Result := a_args
			else
				Result := a_value
			end
		end

end
