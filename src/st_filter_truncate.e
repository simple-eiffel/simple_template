note
	description: "Filter: truncate string to length (truncate:N)"

class
	ST_FILTER_TRUNCATE

inherit
	ST_FILTER

create
	make

feature -- Access

	name: STRING = "truncate"

feature -- Application

	apply (a_value: STRING; a_args: STRING): STRING
		local
			l_len: INTEGER
		do
			if a_args.is_integer then
				l_len := a_args.to_integer
				if l_len > 0 and l_len < a_value.count then
					Result := a_value.substring (1, l_len) + "..."
				else
					Result := a_value
				end
			else
				Result := a_value
			end
		end

end
