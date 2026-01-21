note
	description: "Base class for template directives (#if, #foreach, #across, etc.)"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ST_DIRECTIVE

feature -- Access

	directive_name: STRING
			-- Name of this directive (e.g., "if", "foreach", "across")
		deferred
		ensure
			result_attached: Result /= Void
			result_not_empty: not Result.is_empty
		end

	content: STRING
			-- Content between directive start and end
		attribute
		end

	has_else_block: BOOLEAN
			-- Does this directive support an else block?
		do
			Result := False
		end

	else_content: detachable STRING
			-- Content of else block (if any)
		attribute
		end

feature -- Status

	is_valid: BOOLEAN
			-- Is this directive properly formed?
		deferred
		end

feature -- Execution

	execute (a_context: ST_CONTEXT): STRING
			-- Execute directive and return result
		require
			context_attached: a_context /= Void
			is_valid: is_valid
		deferred
		ensure
			result_attached: Result /= Void
		end

feature -- Element change

	set_content (a_content: STRING)
			-- Set the content.
		require
			content_attached: a_content /= Void
		do
			content := a_content
		ensure
			content_set: content = a_content
		end

	set_else_content (a_content: STRING)
			-- Set the else content.
		require
			content_attached: a_content /= Void
			supports_else: has_else_block
		do
			else_content := a_content
		ensure
			else_content_set: else_content = a_content
		end

invariant
	content_attached: content /= Void

end
