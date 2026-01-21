note
	description: "Execution context for template directives - holds variables and provides lookup"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	ST_CONTEXT

create
	make,
	make_from_template

feature {NONE} -- Initialization

	make
			-- Create empty context.
		do
			create variables.make (20)
			create lists.make (10)
		ensure
			variables_empty: variables.is_empty
			lists_empty: lists.is_empty
		end

	make_from_template (a_template: SIMPLE_TEMPLATE)
			-- Create context from existing template variables.
		require
			template_attached: a_template /= Void
		do
			make
			template := a_template
		ensure
			template_set: template = a_template
		end

feature -- Access

	template: detachable SIMPLE_TEMPLATE
			-- Associated template (if any)

	variables: HASH_TABLE [ANY, STRING]
			-- Variable name to value mapping

	lists: HASH_TABLE [ITERABLE [ANY], STRING]
			-- List name to iterable mapping

	variable (a_name: STRING): detachable ANY
			-- Get variable value by name
		require
			name_not_empty: not a_name.is_empty
		do
			Result := variables.item (a_name)
		end

	list (a_name: STRING): detachable ITERABLE [ANY]
			-- Get list by name
		require
			name_not_empty: not a_name.is_empty
		do
			Result := lists.item (a_name)
		end

	has_variable (a_name: STRING): BOOLEAN
			-- Does this context have a variable with given name?
		require
			name_not_empty: not a_name.is_empty
		do
			Result := variables.has (a_name)
		end

	has_list (a_name: STRING): BOOLEAN
			-- Does this context have a list with given name?
		require
			name_not_empty: not a_name.is_empty
		do
			Result := lists.has (a_name)
		end

feature -- Boolean evaluation

	is_truthy (a_value: detachable ANY): BOOLEAN
			-- Is the value considered true for conditionals?
		do
			if a_value = Void then
				Result := False
			elseif attached {BOOLEAN} a_value as b then
				Result := b
			elseif attached {STRING} a_value as s then
				Result := not s.is_empty
			elseif attached {INTEGER} a_value as i then
				Result := i /= 0
			elseif attached {ITERABLE [ANY]} a_value as l then
				-- Check if iterable is non-empty
				Result := across l as ic some True end
			else
				-- Non-void, non-false = true
				Result := True
			end
		end

	evaluate_boolean (a_expression: STRING): BOOLEAN
			-- Evaluate a boolean expression.
			-- Supports: variable names, "not", "and", "or", comparisons
		require
			expression_not_empty: not a_expression.is_empty
		local
			l_expr: STRING
		do
			l_expr := a_expression.twin
			l_expr.left_adjust
			l_expr.right_adjust

			-- Handle "not" prefix
			if l_expr.starts_with ("not ") then
				Result := not evaluate_boolean (l_expr.substring (5, l_expr.count))
			-- Handle "and"
			elseif l_expr.has_substring (" and ") then
				Result := evaluate_and (l_expr)
			-- Handle "or"
			elseif l_expr.has_substring (" or ") then
				Result := evaluate_or (l_expr)
			-- Handle comparisons
			elseif l_expr.has_substring (" = ") then
				Result := evaluate_equal (l_expr)
			elseif l_expr.has_substring (" /= ") then
				Result := evaluate_not_equal (l_expr)
			elseif l_expr.has_substring (" < ") then
				Result := evaluate_less_than (l_expr)
			elseif l_expr.has_substring (" > ") then
				Result := evaluate_greater_than (l_expr)
			elseif l_expr.has_substring (" <= ") then
				Result := evaluate_less_or_equal (l_expr)
			elseif l_expr.has_substring (" >= ") then
				Result := evaluate_greater_or_equal (l_expr)
			else
				-- Simple variable reference
				Result := is_truthy (variable (l_expr))
			end
		end

feature -- Element change

	set_variable (a_name: STRING; a_value: ANY)
			-- Set variable value.
		require
			name_not_empty: not a_name.is_empty
			value_attached: a_value /= Void
		do
			variables.force (a_value, a_name)
		ensure
			variable_set: variables.item (a_name) = a_value
		end

	set_list (a_name: STRING; a_list: ITERABLE [ANY])
			-- Set list value.
		require
			name_not_empty: not a_name.is_empty
			list_attached: a_list /= Void
		do
			lists.force (a_list, a_name)
		ensure
			list_set: lists.item (a_name) = a_list
		end

	clear
			-- Clear all variables and lists.
		do
			variables.wipe_out
			lists.wipe_out
		ensure
			variables_empty: variables.is_empty
			lists_empty: lists.is_empty
		end

feature {NONE} -- Implementation

	evaluate_and (a_expr: STRING): BOOLEAN
			-- Evaluate AND expression.
		local
			l_pos: INTEGER
			l_left, l_right: STRING
		do
			l_pos := a_expr.substring_index (" and ", 1)
			if l_pos > 0 then
				l_left := a_expr.substring (1, l_pos - 1)
				l_right := a_expr.substring (l_pos + 5, a_expr.count)
				Result := evaluate_boolean (l_left) and evaluate_boolean (l_right)
			end
		end

	evaluate_or (a_expr: STRING): BOOLEAN
			-- Evaluate OR expression.
		local
			l_pos: INTEGER
			l_left, l_right: STRING
		do
			l_pos := a_expr.substring_index (" or ", 1)
			if l_pos > 0 then
				l_left := a_expr.substring (1, l_pos - 1)
				l_right := a_expr.substring (l_pos + 4, a_expr.count)
				Result := evaluate_boolean (l_left) or evaluate_boolean (l_right)
			end
		end

	evaluate_equal (a_expr: STRING): BOOLEAN
			-- Evaluate equality comparison.
		local
			l_pos: INTEGER
			l_left, l_right: STRING
			l_left_val, l_right_val: detachable ANY
		do
			l_pos := a_expr.substring_index (" = ", 1)
			if l_pos > 0 then
				l_left := a_expr.substring (1, l_pos - 1)
				l_right := a_expr.substring (l_pos + 3, a_expr.count)
				l_left.left_adjust; l_left.right_adjust
				l_right.left_adjust; l_right.right_adjust

				l_left_val := resolve_value (l_left)
				l_right_val := resolve_value (l_right)

				if l_left_val = Void and l_right_val = Void then
					Result := True
				elseif l_left_val /= Void and l_right_val /= Void then
					if attached {STRING} l_left_val as ls and attached {STRING} l_right_val as rs then
						Result := ls.same_string (rs)
					elseif attached {INTEGER} l_left_val as li and attached {INTEGER} l_right_val as ri then
						Result := li = ri
					else
						Result := l_left_val.is_equal (l_right_val)
					end
				end
			end
		end

	evaluate_less_than (a_expr: STRING): BOOLEAN
			-- Evaluate less than comparison.
		local
			l_pos: INTEGER
			l_left, l_right: STRING
			l_left_val, l_right_val: detachable ANY
		do
			l_pos := a_expr.substring_index (" < ", 1)
			if l_pos > 0 then
				l_left := a_expr.substring (1, l_pos - 1)
				l_right := a_expr.substring (l_pos + 3, a_expr.count)
				l_left.left_adjust; l_left.right_adjust
				l_right.left_adjust; l_right.right_adjust

				l_left_val := resolve_value (l_left)
				l_right_val := resolve_value (l_right)

				if attached {INTEGER} l_left_val as li and attached {INTEGER} l_right_val as ri then
					Result := li < ri
				elseif attached {STRING} l_left_val as ls and attached {STRING} l_right_val as rs then
					Result := ls < rs
				end
			end
		end

	evaluate_greater_than (a_expr: STRING): BOOLEAN
			-- Evaluate greater than comparison.
		local
			l_pos: INTEGER
			l_left, l_right: STRING
			l_left_val, l_right_val: detachable ANY
		do
			l_pos := a_expr.substring_index (" > ", 1)
			if l_pos > 0 then
				l_left := a_expr.substring (1, l_pos - 1)
				l_right := a_expr.substring (l_pos + 3, a_expr.count)
				l_left.left_adjust; l_left.right_adjust
				l_right.left_adjust; l_right.right_adjust

				l_left_val := resolve_value (l_left)
				l_right_val := resolve_value (l_right)

				if attached {INTEGER} l_left_val as li and attached {INTEGER} l_right_val as ri then
					Result := li > ri
				elseif attached {STRING} l_left_val as ls and attached {STRING} l_right_val as rs then
					Result := ls > rs
				end
			end
		end

	evaluate_not_equal (a_expr: STRING): BOOLEAN
			-- Evaluate not equal comparison.
		local
			l_pos: INTEGER
			l_left, l_right: STRING
			l_converted: STRING
		do
			l_pos := a_expr.substring_index (" /= ", 1)
			if l_pos > 0 then
				l_left := a_expr.substring (1, l_pos - 1)
				l_right := a_expr.substring (l_pos + 4, a_expr.count)
				l_converted := l_left + " = " + l_right
				Result := not evaluate_equal (l_converted)
			end
		end

	evaluate_less_or_equal (a_expr: STRING): BOOLEAN
			-- Evaluate less than or equal comparison.
		local
			l_pos: INTEGER
			l_left, l_right: STRING
			l_converted: STRING
		do
			l_pos := a_expr.substring_index (" <= ", 1)
			if l_pos > 0 then
				l_left := a_expr.substring (1, l_pos - 1)
				l_right := a_expr.substring (l_pos + 4, a_expr.count)
				l_converted := l_left + " > " + l_right
				Result := not evaluate_greater_than (l_converted)
			end
		end

	evaluate_greater_or_equal (a_expr: STRING): BOOLEAN
			-- Evaluate greater than or equal comparison.
		local
			l_pos: INTEGER
			l_left, l_right: STRING
			l_converted: STRING
		do
			l_pos := a_expr.substring_index (" >= ", 1)
			if l_pos > 0 then
				l_left := a_expr.substring (1, l_pos - 1)
				l_right := a_expr.substring (l_pos + 4, a_expr.count)
				l_converted := l_left + " < " + l_right
				Result := not evaluate_less_than (l_converted)
			end
		end

	resolve_value (a_token: STRING): detachable ANY
			-- Resolve a token to its value.
			-- Could be a variable name, quoted string, or integer literal.
		local
			l_token: STRING
		do
			l_token := a_token.twin
			l_token.left_adjust
			l_token.right_adjust

			if l_token.is_empty then
				Result := Void
			elseif l_token.item (1) = '"' and l_token.item (l_token.count) = '"' then
				-- Quoted string literal
				Result := l_token.substring (2, l_token.count - 1)
			elseif l_token.is_integer then
				-- Integer literal
				Result := l_token.to_integer
			else
				-- Variable reference
				Result := variable (l_token)
			end
		end

invariant
	variables_attached: variables /= Void
	lists_attached: lists /= Void

end
