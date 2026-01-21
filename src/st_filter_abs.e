note
	description: "Filter: absolute value of number"

class
	ST_FILTER_ABS

inherit
	ST_FILTER

create
	make

feature -- Access

	name: STRING = "abs"

feature -- Application

	apply (a_value: STRING; a_args: STRING): STRING
		local
			l_num: REAL_64
		do
			if a_value.is_real then
				l_num := a_value.to_real_64.abs
				Result := l_num.out
			elseif a_value.is_integer then
				Result := a_value.to_integer.abs.out
			else
				Result := a_value
			end
		end

end
