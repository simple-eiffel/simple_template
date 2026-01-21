note
	description: "#across directive for Eiffel-style iteration"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	ST_ACROSS_DIRECTIVE

inherit
	ST_DIRECTIVE

create
	make

feature {NONE} -- Initialization

	make (a_iterable_name: STRING; a_cursor_name: STRING)
			-- Create across directive.
			-- Syntax: #across $iterable as $cursor loop ... #end
		require
			iterable_name_not_empty: not a_iterable_name.is_empty
			cursor_name_not_empty: not a_cursor_name.is_empty
		do
			iterable_variable := a_iterable_name
			cursor_variable := a_cursor_name
			content := ""
		ensure
			iterable_set: iterable_variable.same_string (a_iterable_name)
			cursor_set: cursor_variable.same_string (a_cursor_name)
		end

feature -- Access

	directive_name: STRING = "across"

	iterable_variable: STRING
			-- Name of iterable variable

	cursor_variable: STRING
			-- Name of cursor variable (used as $cursor.item)

feature -- Status

	is_valid: BOOLEAN
			-- Is this directive properly formed?
		do
			Result := not iterable_variable.is_empty and not cursor_variable.is_empty and content /= Void
		end

feature -- Execution

	execute (a_context: ST_CONTEXT): STRING
			-- Execute across loop and return concatenated results.
		local
			l_iterable: detachable ITERABLE [ANY]
			l_result: STRING
			l_index: INTEGER
			l_item: ANY
			l_content: STRING
		do
			create l_result.make (content.count * 10)

			-- Try to get iterable from context
			l_iterable := a_context.list (iterable_variable)
			if l_iterable = Void then
				if attached {ITERABLE [ANY]} a_context.variable (iterable_variable) as v then
					l_iterable := v
				end
			end

			if attached l_iterable as li then
				l_index := 0
				across li as ic loop
					l_index := l_index + 1
					l_item := ic

					-- Set cursor variable (the item itself)
					a_context.set_variable (cursor_variable, l_item)
					a_context.set_variable (cursor_variable + ".item", l_item)
					a_context.set_variable ("cursor_index", l_index)

					-- Render content with current cursor
					l_content := content.twin

					-- Replace cursor_index FIRST (before cursor variable to avoid partial matches)
					l_content.replace_substring_all ("$cursor_index", l_index.out)
					l_content.replace_substring_all ("${cursor_index}", l_index.out)

					-- Then replace cursor variable references
					l_content.replace_substring_all ("$" + cursor_variable + ".item", item_to_string (l_item))
					l_content.replace_substring_all ("${" + cursor_variable + ".item}", item_to_string (l_item))
					l_content.replace_substring_all ("$" + cursor_variable, item_to_string (l_item))
					l_content.replace_substring_all ("${" + cursor_variable + "}", item_to_string (l_item))

					l_result.append (l_content)
				end
			end

			Result := l_result
		end

feature {NONE} -- Implementation

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
	iterable_variable_attached: iterable_variable /= Void
	cursor_variable_attached: cursor_variable /= Void

end
