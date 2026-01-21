note
	description: "Filter: replace substring (replace:old,new)"

class
	ST_FILTER_REPLACE

inherit
	ST_FILTER

create
	make

feature -- Access

	name: STRING = "replace"

feature -- Application

	apply (a_value: STRING; a_args: STRING): STRING
		local
			l_parts: LIST [STRING]
			l_old, l_new: STRING
		do
			l_parts := a_args.split (',')
			if l_parts.count >= 2 then
				l_old := l_parts.i_th (1)
				l_new := l_parts.i_th (2)
				Result := a_value.twin
				Result.replace_substring_all (l_old, l_new)
			else
				Result := a_value
			end
		end

end
