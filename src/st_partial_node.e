note
	description: "AST node for partial inclusion {{>partial}}"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	ST_PARTIAL_NODE

inherit
	ST_NODE

create
	make

feature {NONE} -- Initialization

	make (a_name: STRING)
			-- Create partial node for `a_name`.
		require
			name_attached: a_name /= Void
			name_not_empty: not a_name.is_empty
		do
			name := a_name
		ensure
			name_set: name = a_name
		end

feature -- Access

	node_type: STRING = "partial"

	name: STRING
			-- Partial template name.

feature -- Execution

	execute (a_context: ST_EXECUTION_CONTEXT): STRING
			-- Render partial template.
		do
			if attached a_context.partial (name) as p then
				Result := p.render (a_context)
			else
				Result := ""
			end
		end

invariant
	name_attached: name /= Void
	name_not_empty: not name.is_empty

end
