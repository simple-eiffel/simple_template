note
	description: "AST node for section {{#section}}...{{/section}}"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	ST_SECTION_NODE

inherit
	ST_NODE

create
	make

feature {NONE} -- Initialization

	make (a_name: STRING; a_children: ARRAYED_LIST [ST_NODE]; a_inverted: BOOLEAN)
			-- Create section node for `a_name` with `a_children` content.
			-- If `a_inverted` is True, render when section is falsy.
		require
			name_attached: a_name /= Void
			name_not_empty: not a_name.is_empty
			children_attached: a_children /= Void
		do
			name := a_name
			children := a_children
			inverted := a_inverted
		ensure
			name_set: name = a_name
			children_set: children = a_children
			inverted_set: inverted = a_inverted
		end

feature -- Access

	node_type: STRING
		do
			if inverted then
				Result := "inverted_section"
			else
				Result := "section"
			end
		end

	name: STRING
			-- Section name.

	children: ARRAYED_LIST [ST_NODE]
			-- Child nodes to render when section is active.

	inverted: BOOLEAN
			-- Is this an inverted section ({{^...}})?

feature -- Execution

	execute (a_context: ST_EXECUTION_CONTEXT): STRING
			-- Render section based on context.
		local
			l_visible: BOOLEAN
			l_list: detachable ARRAYED_LIST [HASH_TABLE [STRING, STRING]]
		do
			create Result.make (100)

			l_visible := a_context.section_visible (name)
			l_list := a_context.list (name)

			if inverted then
				-- Inverted: render if NOT visible
				if not l_visible then
					Result := render_children (a_context)
				end
			else
				-- Normal section
				if attached l_list as ll and then not ll.is_empty then
					-- List iteration
					across ll as ic loop
						a_context.push_scope (ic)
						Result.append (render_children (a_context))
					end
				elseif l_visible then
					-- Simple truthy section
					Result := render_children (a_context)
				end
			end
		end

feature {NONE} -- Implementation

	render_children (a_context: ST_EXECUTION_CONTEXT): STRING
			-- Render all child nodes.
		do
			create Result.make (100)
			across children as c loop
				Result.append (c.execute (a_context))
			end
		ensure
			result_attached: Result /= Void
		end

invariant
	name_attached: name /= Void
	name_not_empty: not name.is_empty
	children_attached: children /= Void

end
