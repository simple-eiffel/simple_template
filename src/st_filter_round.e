note
	description: "Filter: round number to N decimal places (round:N)"

class
	ST_FILTER_ROUND

inherit
	ST_FILTER

create
	make

feature -- Access

	name: STRING = "round"

feature -- Application

	apply (a_value: STRING; a_args: STRING): STRING
		local
			l_num: REAL_64
			l_places: INTEGER
			l_factor: REAL_64
			i: INTEGER
		do
			if a_value.is_real or a_value.is_integer then
				l_num := a_value.to_real_64
				if a_args.is_integer then
					l_places := a_args.to_integer
				else
					l_places := 0
				end
				if l_places <= 0 then
					Result := l_num.rounded.out
				else
					-- Compute 10^l_places
					l_factor := 1
					from i := 1 until i > l_places loop
						l_factor := l_factor * 10
						i := i + 1
					end
					l_num := (l_num * l_factor).rounded / l_factor
					Result := l_num.out
				end
			else
				Result := a_value
			end
		end

end
