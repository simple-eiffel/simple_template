note
	description: "#include directive for static file inclusion"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	ST_INCLUDE_DIRECTIVE

inherit
	ST_DIRECTIVE

create
	make

feature {NONE} -- Initialization

	make (a_path_expression: STRING)
			-- Create include directive with path expression.
			-- Path can be literal "file.txt" or variable $path_var
		require
			path_not_empty: not a_path_expression.is_empty
		do
			path_expression := a_path_expression
			content := ""
			base_directory := ""
		ensure
			path_set: path_expression.same_string (a_path_expression)
		end

feature -- Access

	directive_name: STRING = "include"

	path_expression: STRING
			-- Path expression (literal or variable reference)

	base_directory: STRING
			-- Base directory for relative paths

feature -- Configuration

	set_base_directory (a_dir: STRING)
			-- Set base directory for relative path resolution.
		require
			dir_not_void: a_dir /= Void
		do
			base_directory := a_dir
		ensure
			base_set: base_directory.same_string (a_dir)
		end

feature -- Status

	is_valid: BOOLEAN
			-- Is this directive properly formed?
		do
			Result := not path_expression.is_empty
		end

feature -- Execution

	execute (a_context: ST_CONTEXT): STRING
			-- Execute include and return file contents.
		local
			l_path: STRING
			l_full_path: STRING
			l_file: PLAIN_TEXT_FILE
		do
			-- Resolve path (literal or variable)
			l_path := resolve_path (a_context)

			if is_safe_path (l_path) then
				-- Build full path
				if not base_directory.is_empty then
					l_full_path := base_directory + "/" + l_path
				else
					l_full_path := l_path
				end

				-- Read file contents
				create l_file.make_with_name (l_full_path)
				if l_file.exists and then l_file.is_readable then
					l_file.open_read
					create Result.make (l_file.count.max (1))
					from
					until
						l_file.end_of_file
					loop
						l_file.read_line
						Result.append (l_file.last_string)
						if not l_file.end_of_file then
							Result.append_character ('%N')
						end
					end
					l_file.close
				else
					Result := ""
					-- Could set error in context here
				end
			else
				-- Path traversal attempt or absolute path - return empty
				Result := ""
			end
		end

feature {NONE} -- Implementation

	resolve_path (a_context: ST_CONTEXT): STRING
			-- Resolve path expression to actual path.
		local
			l_expr: STRING
		do
			l_expr := path_expression.twin
			l_expr.left_adjust
			l_expr.right_adjust

			if l_expr.starts_with ("$") then
				-- Variable reference
				if attached {STRING} a_context.variable (l_expr.substring (2, l_expr.count)) as v then
					Result := v
				else
					Result := ""
				end
			elseif l_expr.count >= 2 and then l_expr.item (1) = '"' and then l_expr.item (l_expr.count) = '"' then
				-- Quoted literal
				Result := l_expr.substring (2, l_expr.count - 1)
			else
				-- Unquoted literal
				Result := l_expr
			end
		ensure
			result_attached: Result /= Void
		end

	is_safe_path (a_path: STRING): BOOLEAN
			-- Is the path safe (no traversal, no absolute)?
		do
			Result := not a_path.is_empty and then
					  not a_path.has_substring ("..") and then
					  (a_path.count > 0 implies a_path.item (1) /= '/') and then
					  (a_path.count >= 2 implies not (a_path.item (2) = ':'))
		end

invariant
	path_expression_attached: path_expression /= Void
	base_directory_attached: base_directory /= Void

end
