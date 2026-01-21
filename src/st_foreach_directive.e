note
	description: "#foreach directive for iteration over collections"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	ST_FOREACH_DIRECTIVE

inherit
	ST_DIRECTIVE

create
	make

feature {NONE} -- Initialization

	make (a_item_name: STRING; a_list_name: STRING)
			-- Create foreach directive.
			-- Syntax: #foreach $item in $list
		require
			item_name_not_empty: not a_item_name.is_empty
			list_name_not_empty: not a_list_name.is_empty
		do
			item_variable := a_item_name
			list_variable := a_list_name
			content := ""
		ensure
			item_set: item_variable.same_string (a_item_name)
			list_set: list_variable.same_string (a_list_name)
		end

feature -- Access

	directive_name: STRING = "foreach"

	item_variable: STRING
			-- Name of iteration variable

	list_variable: STRING
			-- Name of list variable to iterate

feature -- Status

	is_valid: BOOLEAN
			-- Is this directive properly formed?
		do
			Result := not item_variable.is_empty and not list_variable.is_empty and content /= Void
		end

feature -- Execution

	execute (a_context: ST_CONTEXT): STRING
			-- Execute loop and return concatenated results.
		local
			l_list: detachable ITERABLE [ANY]
			l_result: STRING
			l_index: INTEGER
			l_item: ANY
		do
			create l_result.make (content.count * 10)

			-- Try to get list from context
			l_list := a_context.list (list_variable)
			if l_list = Void then
				-- Try variable as iterable
				if attached {ITERABLE [ANY]} a_context.variable (list_variable) as v then
					l_list := v
				end
			end

			if attached l_list as ll then
				l_index := 0
				across ll as ic loop
					l_index := l_index + 1
					l_item := ic

					-- Set loop variables
					a_context.set_variable (item_variable, l_item)
					a_context.set_variable ("loop_index", l_index)
					a_context.set_variable ("loop_first", l_index = 1)

					-- Render content with current item
					l_result.append (render_content_with_item (a_context, l_item))
				end

				-- Set loop_last on last iteration (post-hoc)
				a_context.set_variable ("loop_count", l_index)
			end

			Result := l_result
		end

feature {NONE} -- Implementation

	render_content_with_item (a_context: ST_CONTEXT; a_item: ANY): STRING
			-- Render content template with current item.
		local
			l_content: STRING
		do
			l_content := content.twin

			-- Simple variable substitution for $item_variable
			l_content.replace_substring_all ("$" + item_variable, item_to_string (a_item))
			l_content.replace_substring_all ("${" + item_variable + "}", item_to_string (a_item))

			-- Handle loop_index
			if attached {INTEGER} a_context.variable ("loop_index") as idx then
				l_content.replace_substring_all ("$loop_index", idx.out)
				l_content.replace_substring_all ("${loop_index}", idx.out)
			end

			Result := l_content
		end

	item_to_string (a_item: ANY): STRING
			-- Convert item to string representation.
		do
			if attached {STRING} a_item as s then
				Result := s
			elseif attached {STRING_32} a_item as s32 then
				Result := s32.to_string_8
			else
				Result := a_item.out
			end
		end

invariant
	item_variable_attached: item_variable /= Void
	list_variable_attached: list_variable /= Void

end
