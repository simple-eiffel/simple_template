note
	description: "Filter: trim whitespace"

class
	ST_FILTER_TRIM

inherit
	ST_FILTER

create
	make

feature -- Access

	name: STRING = "trim"

feature -- Application

	apply (a_value: STRING; a_args: STRING): STRING
		do
			Result := a_value.twin
			Result.left_adjust
			Result.right_adjust
		end

end
