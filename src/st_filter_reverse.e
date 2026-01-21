note
	description: "Filter: reverse string"

class
	ST_FILTER_REVERSE

inherit
	ST_FILTER

create
	make

feature -- Access

	name: STRING = "reverse"

feature -- Application

	apply (a_value: STRING; a_args: STRING): STRING
		local
			i: INTEGER
		do
			create Result.make (a_value.count)
			from i := a_value.count until i < 1 loop
				Result.append_character (a_value.item (i))
				i := i - 1
			end
		end

end
