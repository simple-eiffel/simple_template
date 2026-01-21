note
	description: "Pre-compiled template for fast rendering"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	ST_COMPILED_TEMPLATE

create
	make

feature {NONE} -- Initialization

	make (a_nodes: ARRAYED_LIST [ST_NODE])
			-- Create compiled template from AST nodes.
		require
			nodes_attached: a_nodes /= Void
		do
			nodes := a_nodes
			create source_hash.make_empty
		ensure
			nodes_set: nodes = a_nodes
		end

feature -- Access

	nodes: ARRAYED_LIST [ST_NODE]
			-- AST nodes representing the template.

	source_hash: STRING
			-- Hash of source template (for cache validation).

	node_count: INTEGER
			-- Total number of nodes in the AST.
		do
			Result := nodes.count
		end

feature -- Status

	is_empty: BOOLEAN
			-- Is the template empty?
		do
			Result := nodes.is_empty
		end

feature -- Rendering

	render (a_context: ST_EXECUTION_CONTEXT): STRING
			-- Render template with given context.
			-- This is the fast path - no parsing required.
		require
			context_attached: a_context /= Void
		do
			create Result.make (256)
			across nodes as n loop
				Result.append (n.execute (a_context))
			end
		ensure
			result_attached: Result /= Void
		end

	render_with_vars (a_vars: HASH_TABLE [STRING, STRING]): STRING
			-- Convenience: render with just variables.
		require
			vars_attached: a_vars /= Void
		local
			ctx: ST_EXECUTION_CONTEXT
		do
			create ctx.make
			from a_vars.start until a_vars.after loop
				ctx.set_variable (a_vars.key_for_iteration, a_vars.item_for_iteration)
				a_vars.forth
			end
			Result := render (ctx)
		ensure
			result_attached: Result /= Void
		end

feature -- Setting

	set_source_hash (a_hash: STRING)
			-- Set source hash for cache validation.
		require
			hash_attached: a_hash /= Void
		do
			source_hash := a_hash
		ensure
			hash_set: source_hash = a_hash
		end

feature -- Debug

	dump: STRING
			-- Debug representation of AST.
		do
			create Result.make (100)
			Result.append ("ST_COMPILED_TEMPLATE (" + node_count.out + " nodes)%N")
			across nodes as n loop
				Result.append ("  [" + n.node_type + "]%N")
			end
		ensure
			result_attached: Result /= Void
		end

invariant
	nodes_attached: nodes /= Void
	source_hash_attached: source_hash /= Void

end
