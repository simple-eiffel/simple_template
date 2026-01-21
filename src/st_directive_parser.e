note
	description: "Parser for template directives (#if, #foreach, #across, etc.)"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	ST_DIRECTIVE_PARSER

create
	make

feature {NONE} -- Initialization

	make
			-- Create parser.
		do
			last_error := ""
		end

feature -- Access

	last_error: STRING
			-- Last parse error (empty if none)

feature -- Status

	has_error: BOOLEAN
			-- Did last parse have an error?
		do
			Result := not last_error.is_empty
		end

feature -- Parsing

	parse_if (a_text: STRING): detachable ST_IF_DIRECTIVE
			-- Parse #if directive from text.
			-- Format: #if <condition> then ... #else ... #end
		require
			text_not_empty: not a_text.is_empty
		local
			l_start, l_end, l_else: INTEGER
			l_condition, l_content, l_else_content: STRING
			l_then_pos: INTEGER
		do
			last_error := ""

			-- Find #if start
			l_start := a_text.substring_index ("#if ", 1)
			if l_start = 0 then
				l_start := a_text.substring_index ("#if%T", 1)
			end

			if l_start > 0 then
				-- Find "then" keyword
				l_then_pos := a_text.substring_index (" then", l_start)
				if l_then_pos = 0 then
					l_then_pos := a_text.substring_index ("%Nthen", l_start)
				end

				-- Find #end
				l_end := find_matching_end (a_text, l_start)

				if l_then_pos > 0 and l_end > 0 then
					-- Extract condition (between "#if " and " then")
					l_condition := a_text.substring (l_start + 4, l_then_pos - 1)
					l_condition.left_adjust
					l_condition.right_adjust

					-- Find #else if present
					l_else := a_text.substring_index ("#else", l_then_pos)
					if l_else > 0 and l_else < l_end then
						-- Has else block
						l_content := a_text.substring (l_then_pos + 5, l_else - 1)
						l_else_content := a_text.substring (l_else + 5, l_end - 1)

						create Result.make (l_condition)
						Result.set_content (l_content)
						Result.set_else_content (l_else_content)
					else
						-- No else block
						l_content := a_text.substring (l_then_pos + 5, l_end - 1)

						create Result.make (l_condition)
						Result.set_content (l_content)
					end
				else
					if l_then_pos = 0 then
						last_error := "Missing 'then' keyword in #if directive"
					else
						last_error := "Missing #end for #if directive"
					end
				end
			end
		end

	parse_foreach (a_text: STRING): detachable ST_FOREACH_DIRECTIVE
			-- Parse #foreach directive from text.
			-- Format: #foreach $item in $list loop ... #end
		require
			text_not_empty: not a_text.is_empty
		local
			l_start, l_end, l_loop: INTEGER
			l_header, l_content: STRING
			l_item_name, l_list_name: STRING
			l_in_pos: INTEGER
		do
			last_error := ""

			-- Find #foreach start
			l_start := a_text.substring_index ("#foreach ", 1)

			if l_start > 0 then
				-- Find "loop" keyword
				l_loop := a_text.substring_index (" loop", l_start)
				if l_loop = 0 then
					l_loop := a_text.substring_index ("%Nloop", l_start)
				end

				-- Find #end
				l_end := find_matching_end (a_text, l_start)

				if l_loop > 0 and l_end > 0 then
					-- Extract header (between "#foreach " and " loop")
					l_header := a_text.substring (l_start + 9, l_loop - 1)
					l_header.left_adjust
					l_header.right_adjust

					-- Parse "$item in $list"
					l_in_pos := l_header.substring_index (" in ", 1)
					if l_in_pos > 0 then
						l_item_name := l_header.substring (1, l_in_pos - 1)
						l_list_name := l_header.substring (l_in_pos + 4, l_header.count)

						-- Remove $ prefix if present
						if l_item_name.starts_with ("$") then
							l_item_name := l_item_name.substring (2, l_item_name.count)
						end
						if l_list_name.starts_with ("$") then
							l_list_name := l_list_name.substring (2, l_list_name.count)
						end

						l_item_name.left_adjust; l_item_name.right_adjust
						l_list_name.left_adjust; l_list_name.right_adjust

						-- Extract content
						l_content := a_text.substring (l_loop + 5, l_end - 1)

						create Result.make (l_item_name, l_list_name)
						Result.set_content (l_content)
					else
						last_error := "Invalid #foreach syntax - expected '$item in $list'"
					end
				else
					if l_loop = 0 then
						last_error := "Missing 'loop' keyword in #foreach directive"
					else
						last_error := "Missing #end for #foreach directive"
					end
				end
			end
		end

	parse_across (a_text: STRING): detachable ST_ACROSS_DIRECTIVE
			-- Parse #across directive from text.
			-- Format: #across $iterable as $cursor loop ... #end
		require
			text_not_empty: not a_text.is_empty
		local
			l_start, l_end, l_loop: INTEGER
			l_header, l_content: STRING
			l_iterable_name, l_cursor_name: STRING
			l_as_pos: INTEGER
		do
			last_error := ""

			-- Find #across start
			l_start := a_text.substring_index ("#across ", 1)

			if l_start > 0 then
				-- Find "loop" keyword
				l_loop := a_text.substring_index (" loop", l_start)
				if l_loop = 0 then
					l_loop := a_text.substring_index ("%Nloop", l_start)
				end

				-- Find #end
				l_end := find_matching_end (a_text, l_start)

				if l_loop > 0 and l_end > 0 then
					-- Extract header (between "#across " and " loop")
					l_header := a_text.substring (l_start + 8, l_loop - 1)
					l_header.left_adjust
					l_header.right_adjust

					-- Parse "$iterable as $cursor"
					l_as_pos := l_header.substring_index (" as ", 1)
					if l_as_pos > 0 then
						l_iterable_name := l_header.substring (1, l_as_pos - 1)
						l_cursor_name := l_header.substring (l_as_pos + 4, l_header.count)

						-- Remove $ prefix if present
						if l_iterable_name.starts_with ("$") then
							l_iterable_name := l_iterable_name.substring (2, l_iterable_name.count)
						end
						if l_cursor_name.starts_with ("$") then
							l_cursor_name := l_cursor_name.substring (2, l_cursor_name.count)
						end

						l_iterable_name.left_adjust; l_iterable_name.right_adjust
						l_cursor_name.left_adjust; l_cursor_name.right_adjust

						-- Extract content
						l_content := a_text.substring (l_loop + 5, l_end - 1)

						create Result.make (l_iterable_name, l_cursor_name)
						Result.set_content (l_content)
					else
						last_error := "Invalid #across syntax - expected '$iterable as $cursor'"
					end
				else
					if l_loop = 0 then
						last_error := "Missing 'loop' keyword in #across directive"
					else
						last_error := "Missing #end for #across directive"
					end
				end
			end
		end

	parse_include (a_text: STRING): detachable ST_INCLUDE_DIRECTIVE
			-- Parse #include directive from text.
			-- Format: #include "path" or #include $variable
		require
			text_not_empty: not a_text.is_empty
		local
			l_start: INTEGER
			l_end: INTEGER
			l_path: STRING
		do
			last_error := ""

			-- Find #include start
			l_start := a_text.substring_index ("#include ", 1)

			if l_start > 0 then
				-- Find end of line or end of string
				l_end := a_text.index_of ('%N', l_start + 9)
				if l_end = 0 then
					l_end := a_text.count + 1
				end

				-- Extract path expression
				l_path := a_text.substring (l_start + 9, l_end - 1)
				l_path.left_adjust
				l_path.right_adjust

				if not l_path.is_empty then
					create Result.make (l_path)
				else
					last_error := "Empty path in #include directive"
				end
			end
		end

	parse_evaluate (a_text: STRING): detachable ST_EVALUATE_DIRECTIVE
			-- Parse #evaluate directive from text.
			-- Format: #evaluate $variable or #evaluate "literal template"
		require
			text_not_empty: not a_text.is_empty
		local
			l_start: INTEGER
			l_end: INTEGER
			l_expr: STRING
		do
			last_error := ""

			-- Find #evaluate start
			l_start := a_text.substring_index ("#evaluate ", 1)

			if l_start > 0 then
				-- Find end of line or end of string
				l_end := a_text.index_of ('%N', l_start + 10)
				if l_end = 0 then
					l_end := a_text.count + 1
				end

				-- Extract expression
				l_expr := a_text.substring (l_start + 10, l_end - 1)
				l_expr.left_adjust
				l_expr.right_adjust

				if not l_expr.is_empty then
					create Result.make (l_expr)
				else
					last_error := "Empty expression in #evaluate directive"
				end
			end
		end

	has_directive (a_text: STRING): BOOLEAN
			-- Does text contain any directives?
		do
			Result := a_text.has_substring ("#if ") or
					  a_text.has_substring ("#foreach ") or
					  a_text.has_substring ("#across ") or
					  a_text.has_substring ("#include ") or
					  a_text.has_substring ("#evaluate ")
		end

feature {NONE} -- Implementation

	find_matching_end (a_text: STRING; a_start: INTEGER): INTEGER
			-- Find matching #end for directive starting at a_start.
			-- Handles nested directives.
		local
			l_depth: INTEGER
			l_pos: INTEGER
		do
			l_depth := 1
			l_pos := a_start + 1

			from until l_pos > a_text.count or l_depth = 0 loop
				-- Check for nested directive start
				if l_pos + 3 <= a_text.count then
					if a_text.substring (l_pos, l_pos + 3).same_string ("#if ") or
					   a_text.substring (l_pos, l_pos + 8).same_string ("#foreach ") or
					   a_text.substring (l_pos, l_pos + 7).same_string ("#across ") then
						l_depth := l_depth + 1
					end
				end

				-- Check for #end
				if l_pos + 3 <= a_text.count then
					if a_text.substring (l_pos, l_pos + 3).same_string ("#end") then
						l_depth := l_depth - 1
						if l_depth = 0 then
							Result := l_pos
						end
					end
				end

				l_pos := l_pos + 1
			end
		end

end
