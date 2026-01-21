note
	description: "AST node for variable substitution {{variable}}"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	ST_VARIABLE_NODE

inherit
	ST_NODE

create
	make

feature {NONE} -- Initialization

	make (a_name: STRING; a_escape: BOOLEAN)
			-- Create variable node for `a_name`.
			-- If `a_escape` is True, HTML escape the output.
		require
			name_attached: a_name /= Void
			name_not_empty: not a_name.is_empty
		do
			name := a_name
			escape_html := a_escape
		ensure
			name_set: name = a_name
			escape_set: escape_html = a_escape
		end

feature -- Access

	node_type: STRING = "variable"

	name: STRING
			-- Variable name to substitute.

	escape_html: BOOLEAN
			-- Should output be HTML escaped?

feature -- Execution

	execute (a_context: ST_EXECUTION_CONTEXT): STRING
			-- Substitute variable value.
		local
			l_value: detachable STRING
		do
			l_value := a_context.variable (name)
			if l_value /= Void then
				if escape_html and a_context.escape_html then
					Result := html_escape (l_value)
				else
					Result := l_value
				end
			else
				inspect a_context.missing_policy
				when {ST_EXECUTION_CONTEXT}.Policy_keep_placeholder then
					if escape_html then
						Result := "{{" + name + "}}"
					else
						Result := "{{{" + name + "}}}"
					end
				else
					Result := ""
				end
			end
		end

feature {NONE} -- Implementation

	html_escape (a_value: STRING): STRING
			-- HTML escape `a_value`.
		require
			value_attached: a_value /= Void
		local
			i: INTEGER
			c: CHARACTER
		do
			create Result.make (a_value.count)
			from i := 1 until i > a_value.count loop
				c := a_value.item (i)
				inspect c
				when '&' then Result.append ("&amp;")
				when '<' then Result.append ("&lt;")
				when '>' then Result.append ("&gt;")
				when '"' then Result.append ("&quot;")
				when '%'' then Result.append ("&#39;")
				else Result.append_character (c)
				end
				i := i + 1
			end
		ensure
			result_attached: Result /= Void
		end

invariant
	name_attached: name /= Void
	name_not_empty: not name.is_empty

end
