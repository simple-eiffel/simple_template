note
	description: "Filter: split string and return Nth element (split:delim,N)"

class
	ST_FILTER_SPLIT

inherit
	ST_FILTER

create
	make

feature -- Access

	name: STRING = "split"

feature -- Application

	apply (a_value: STRING; a_args: STRING): STRING
		local
			l_args: LIST [STRING]
			l_delim: STRING
			l_index: INTEGER
			l_parts: LIST [STRING]
		do
			l_args := a_args.split (',')
			if l_args.count >= 2 then
				l_delim := l_args.i_th (1)
				if l_args.i_th (2).is_integer then
					l_index := l_args.i_th (2).to_integer
				else
					l_index := 1
				end
				if l_delim.count = 1 then
					l_parts := a_value.split (l_delim.item (1))
				else
					-- Multi-char delimiter: use simple split
					create {ARRAYED_LIST [STRING]} l_parts.make (1)
					l_parts.extend (a_value)
				end
				if l_index >= 1 and l_index <= l_parts.count then
					Result := l_parts.i_th (l_index)
				else
					Result := ""
				end
			else
				Result := a_value
			end
		end

end
