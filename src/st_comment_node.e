note
	description: "AST node for comments {{! comment }}"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	ST_COMMENT_NODE

inherit
	ST_NODE

create
	make

feature {NONE} -- Initialization

	make (a_comment: STRING)
			-- Create comment node.
		require
			comment_attached: a_comment /= Void
		do
			comment := a_comment
		ensure
			comment_set: comment = a_comment
		end

feature -- Access

	node_type: STRING = "comment"

	comment: STRING
			-- The comment text (not rendered).

feature -- Execution

	execute (a_context: ST_EXECUTION_CONTEXT): STRING
			-- Comments produce no output.
		do
			Result := ""
		end

invariant
	comment_attached: comment /= Void

end
