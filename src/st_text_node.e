note
	description: "AST node for plain text content"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	ST_TEXT_NODE

inherit
	ST_NODE

create
	make

feature {NONE} -- Initialization

	make (a_text: STRING)
			-- Create text node with `a_text` content.
		require
			text_attached: a_text /= Void
		do
			text := a_text
		ensure
			text_set: text = a_text
		end

feature -- Access

	node_type: STRING = "text"

	text: STRING
			-- The literal text content.

feature -- Execution

	execute (a_context: ST_EXECUTION_CONTEXT): STRING
			-- Return the text as-is.
		do
			Result := text
		end

invariant
	text_attached: text /= Void

end
