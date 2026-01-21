note
	description: "Filter: capitalize first letter"

class
	ST_FILTER_CAPITALIZE

inherit
	ST_FILTER

create
	make

feature -- Access

	name: STRING = "capitalize"

feature -- Application

	apply (a_value: STRING; a_args: STRING): STRING
		do
			if a_value.is_empty then
				Result := ""
			else
				Result := a_value.twin
				Result.put (Result.item (1).as_upper, 1)
			end
		end

end
