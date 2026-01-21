note
	description: "Abstract base class for template AST nodes"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ST_NODE

feature -- Access

	node_type: STRING
			-- Type identifier for this node.
		deferred
		ensure
			result_attached: Result /= Void
		end

feature -- Execution

	execute (a_context: ST_EXECUTION_CONTEXT): STRING
			-- Execute this node and return rendered output.
		require
			context_attached: a_context /= Void
		deferred
		ensure
			result_attached: Result /= Void
		end

end
