note
	description: "Evaluates expressions including math, strings, and filters"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	ST_EXPRESSION_EVALUATOR

create
	make

feature {NONE} -- Initialization

	make
			-- Create expression evaluator.
		do
			create filters.make (10)
			register_default_filters
		end

feature -- Access

	filters: HASH_TABLE [ST_FILTER, STRING]
			-- Registered filters by name.

feature -- Evaluation

	evaluate (a_expr: STRING; a_context: ST_CONTEXT): STRING
			-- Evaluate expression and return string result.
			-- Supports: variables, math, filters (pipe syntax).
		require
			expr_attached: a_expr /= Void
			context_attached: a_context /= Void
		local
			l_expr: STRING
			l_parts: LIST [STRING]
			l_value: STRING
		do
			l_expr := a_expr.twin
			l_expr.left_adjust
			l_expr.right_adjust

			if l_expr.has ('|') then
				-- Has filters: split and apply
				l_parts := l_expr.split ('|')
				if l_parts.count >= 1 then
					l_value := evaluate_base (l_parts.first, a_context)
					from l_parts.start; l_parts.forth until l_parts.after loop
						l_value := apply_filter (l_value, l_parts.item)
						l_parts.forth
					end
					Result := l_value
				else
					Result := ""
				end
			else
				Result := evaluate_base (l_expr, a_context)
			end
		ensure
			result_attached: Result /= Void
		end

	evaluate_numeric (a_expr: STRING; a_context: ST_CONTEXT): REAL_64
			-- Evaluate expression and return numeric result.
		require
			expr_attached: a_expr /= Void
			context_attached: a_context /= Void
		local
			l_str: STRING
		do
			l_str := evaluate (a_expr, a_context)
			if l_str.is_real then
				Result := l_str.to_real_64
			elseif l_str.is_integer then
				Result := l_str.to_integer
			end
		end

feature -- Filter Registration

	register_filter (a_name: STRING; a_filter: ST_FILTER)
			-- Register a custom filter.
		require
			name_attached: a_name /= Void
			filter_attached: a_filter /= Void
		do
			filters.force (a_filter, a_name.as_lower)
		ensure
			registered: filters.has (a_name.as_lower)
		end

feature {NONE} -- Base Evaluation

	evaluate_base (a_expr: STRING; a_context: ST_CONTEXT): STRING
			-- Evaluate base expression (no filters).
		require
			expr_attached: a_expr /= Void
			context_attached: a_context /= Void
		local
			l_expr: STRING
		do
			l_expr := a_expr.twin
			l_expr.left_adjust
			l_expr.right_adjust

			if is_math_expression (l_expr) then
				Result := evaluate_math (l_expr, a_context)
			elseif is_string_literal (l_expr) then
				Result := extract_string_literal (l_expr)
			elseif is_number_literal (l_expr) then
				Result := l_expr
			else
				-- Variable reference
				Result := resolve_variable (l_expr, a_context)
			end
		ensure
			result_attached: Result /= Void
		end

	evaluate_math (a_expr: STRING; a_context: ST_CONTEXT): STRING
			-- Evaluate mathematical expression.
		require
			expr_attached: a_expr /= Void
		local
			l_left, l_right: REAL_64
			l_op: CHARACTER
			l_pos: INTEGER
			l_left_str, l_right_str: STRING
		do
			-- Find operator (simple left-to-right, no precedence)
			l_pos := find_operator (a_expr)
			if l_pos > 0 then
				l_op := a_expr.item (l_pos)
				l_left_str := a_expr.substring (1, l_pos - 1)
				l_right_str := a_expr.substring (l_pos + 1, a_expr.count)
				l_left_str.adjust
				l_right_str.adjust

				l_left := resolve_numeric (l_left_str, a_context)
				l_right := resolve_numeric (l_right_str, a_context)

				inspect l_op
				when '+' then Result := (l_left + l_right).out
				when '-' then Result := (l_left - l_right).out
				when '*' then Result := (l_left * l_right).out
				when '/' then
					if l_right /= 0 then
						Result := (l_left / l_right).out
					else
						Result := "0"
					end
				when '%%' then
					if l_right.truncated_to_integer /= 0 then
						Result := (l_left.truncated_to_integer \\ l_right.truncated_to_integer).out
					else
						Result := "0"
					end
				else
					Result := a_expr
				end
			else
				Result := resolve_variable (a_expr, a_context)
			end
		ensure
			result_attached: Result /= Void
		end

	resolve_variable (a_name: STRING; a_context: ST_CONTEXT): STRING
			-- Resolve variable from context.
		require
			name_attached: a_name /= Void
			context_attached: a_context /= Void
		local
			l_name: STRING
		do
			l_name := a_name.twin
			l_name.left_adjust
			l_name.right_adjust
			if l_name.starts_with ("$") then
				l_name := l_name.substring (2, l_name.count)
			end
			if attached {STRING} a_context.variable (l_name) as v then
				Result := v
			else
				Result := ""
			end
		ensure
			result_attached: Result /= Void
		end

	resolve_numeric (a_expr: STRING; a_context: ST_CONTEXT): REAL_64
			-- Resolve expression to numeric value.
		require
			expr_attached: a_expr /= Void
		local
			l_str: STRING
		do
			l_str := a_expr.twin
			l_str.adjust
			if l_str.is_real then
				Result := l_str.to_real_64
			elseif l_str.is_integer then
				Result := l_str.to_integer
			else
				-- Try as variable
				l_str := resolve_variable (l_str, a_context)
				if l_str.is_real then
					Result := l_str.to_real_64
				elseif l_str.is_integer then
					Result := l_str.to_integer
				end
			end
		end

feature {NONE} -- Filter Application

	apply_filter (a_value: STRING; a_filter_expr: STRING): STRING
			-- Apply filter to value.
		require
			value_attached: a_value /= Void
			filter_attached: a_filter_expr /= Void
		local
			l_filter_name: STRING
			l_args: STRING
			l_colon_pos: INTEGER
		do
			l_filter_name := a_filter_expr.twin
			l_filter_name.left_adjust
			l_filter_name.right_adjust

			-- Check for filter arguments (filter:arg)
			l_colon_pos := l_filter_name.index_of (':', 1)
			if l_colon_pos > 0 then
				l_args := l_filter_name.substring (l_colon_pos + 1, l_filter_name.count)
				l_filter_name := l_filter_name.substring (1, l_colon_pos - 1)
			else
				l_args := ""
			end

			if attached filters.item (l_filter_name.as_lower) as f then
				Result := f.apply (a_value, l_args)
			else
				-- Unknown filter, return value unchanged
				Result := a_value
			end
		ensure
			result_attached: Result /= Void
		end

feature {NONE} -- Helpers

	is_math_expression (a_expr: STRING): BOOLEAN
			-- Does expression contain math operators?
		do
			Result := a_expr.has ('+') or a_expr.has ('-') or
					  a_expr.has ('*') or a_expr.has ('/') or
					  a_expr.has ('%%')
		end

	is_string_literal (a_expr: STRING): BOOLEAN
			-- Is expression a quoted string?
		do
			Result := a_expr.count >= 2 and then
					  ((a_expr.item (1) = '"' and a_expr.item (a_expr.count) = '"') or
					   (a_expr.item (1) = '%'' and a_expr.item (a_expr.count) = '%''))
		end

	is_number_literal (a_expr: STRING): BOOLEAN
			-- Is expression a number literal?
		do
			Result := a_expr.is_integer or a_expr.is_real
		end

	extract_string_literal (a_expr: STRING): STRING
			-- Extract content from quoted string.
		require
			is_literal: is_string_literal (a_expr)
		do
			Result := a_expr.substring (2, a_expr.count - 1)
		ensure
			result_attached: Result /= Void
		end

	find_operator (a_expr: STRING): INTEGER
			-- Find position of first math operator (outside quotes).
		local
			i: INTEGER
			in_quotes: BOOLEAN
			c: CHARACTER
		do
			from i := 1 until i > a_expr.count or Result > 0 loop
				c := a_expr.item (i)
				if c = '"' or c = '%'' then
					in_quotes := not in_quotes
				elseif not in_quotes then
					if c = '+' or c = '-' or c = '*' or c = '/' or c = '%%' then
						Result := i
					end
				end
				i := i + 1
			end
		end

feature {NONE} -- Default Filters

	register_default_filters
			-- Register built-in filters.
		do
			register_filter ("upper", create {ST_FILTER_UPPER}.make)
			register_filter ("lower", create {ST_FILTER_LOWER}.make)
			register_filter ("capitalize", create {ST_FILTER_CAPITALIZE}.make)
			register_filter ("trim", create {ST_FILTER_TRIM}.make)
			register_filter ("length", create {ST_FILTER_LENGTH}.make)
			register_filter ("default", create {ST_FILTER_DEFAULT}.make)
			register_filter ("reverse", create {ST_FILTER_REVERSE}.make)
			register_filter ("truncate", create {ST_FILTER_TRUNCATE}.make)
			register_filter ("replace", create {ST_FILTER_REPLACE}.make)
			register_filter ("split", create {ST_FILTER_SPLIT}.make)
			register_filter ("join", create {ST_FILTER_JOIN}.make)
			register_filter ("abs", create {ST_FILTER_ABS}.make)
			register_filter ("round", create {ST_FILTER_ROUND}.make)
		end

invariant
	filters_attached: filters /= Void

end
