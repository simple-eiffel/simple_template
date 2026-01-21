note
	description: "#if...#else...#end directive for conditional template processing"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	ST_IF_DIRECTIVE

inherit
	ST_DIRECTIVE
		redefine
			has_else_block
		end

create
	make

feature {NONE} -- Initialization

	make (a_condition: STRING)
			-- Create with condition expression.
		require
			condition_not_empty: not a_condition.is_empty
		do
			condition := a_condition
			content := ""
		ensure
			condition_set: condition.same_string (a_condition)
		end

feature -- Access

	directive_name: STRING = "if"

	condition: STRING
			-- Boolean condition expression

feature -- Status

	has_else_block: BOOLEAN = True
			-- #if supports #else

	is_valid: BOOLEAN
			-- Is this directive properly formed?
		do
			Result := not condition.is_empty and content /= Void
		end

feature -- Execution

	execute (a_context: ST_CONTEXT): STRING
			-- Execute conditional and return appropriate content.
		local
			l_result: BOOLEAN
		do
			l_result := a_context.evaluate_boolean (condition)

			if l_result then
				Result := content
			elseif attached else_content as ec then
				Result := ec
			else
				Result := ""
			end
		end

invariant
	condition_attached: condition /= Void

end
