note
	description: "#evaluate directive for nested template evaluation"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	ST_EVALUATE_DIRECTIVE

inherit
	ST_DIRECTIVE

create
	make

feature {NONE} -- Initialization

	make (a_expression: STRING)
			-- Create evaluate directive with expression.
			-- Expression can be a variable containing template text.
		require
			expression_not_empty: not a_expression.is_empty
		do
			expression := a_expression
			content := ""
		ensure
			expression_set: expression.same_string (a_expression)
		end

feature -- Access

	directive_name: STRING = "evaluate"

	expression: STRING
			-- Expression to evaluate (variable reference or literal)

feature -- Status

	is_valid: BOOLEAN
			-- Is this directive properly formed?
		do
			Result := not expression.is_empty
		end

feature -- Execution

	execute (a_context: ST_CONTEXT): STRING
			-- Execute evaluation and return rendered result.
		local
			l_template_text: STRING
			l_tpl: SIMPLE_TEMPLATE
		do
			-- Get template text from expression
			l_template_text := resolve_template_text (a_context)

			if not l_template_text.is_empty then
				-- Create nested template and render with same context
				create l_tpl.make_from_string (l_template_text)

				-- Copy variables from context to template
				transfer_context_to_template (a_context, l_tpl)

				Result := l_tpl.render
			else
				Result := ""
			end
		end

feature {NONE} -- Implementation

	resolve_template_text (a_context: ST_CONTEXT): STRING
			-- Resolve expression to template text.
		local
			l_expr: STRING
		do
			l_expr := expression.twin
			l_expr.left_adjust
			l_expr.right_adjust

			if l_expr.starts_with ("$") then
				-- Variable reference
				if attached {STRING} a_context.variable (l_expr.substring (2, l_expr.count)) as v then
					Result := v
				else
					Result := ""
				end
			elseif l_expr.count >= 2 and then l_expr.item (1) = '"' and then l_expr.item (l_expr.count) = '"' then
				-- Quoted literal template
				Result := l_expr.substring (2, l_expr.count - 1)
			else
				-- Unquoted - treat as variable name
				if attached {STRING} a_context.variable (l_expr) as v then
					Result := v
				else
					Result := ""
				end
			end
		ensure
			result_attached: Result /= Void
		end

	transfer_context_to_template (a_context: ST_CONTEXT; a_tpl: SIMPLE_TEMPLATE)
			-- Transfer context variables to template.
		local
			l_vars: HASH_TABLE [ANY, STRING]
		do
			l_vars := a_context.variables
			from
				l_vars.start
			until
				l_vars.after
			loop
				if attached {STRING} l_vars.item_for_iteration as s then
					a_tpl.set_variable (l_vars.key_for_iteration, s)
				elseif attached {BOOLEAN} l_vars.item_for_iteration as b then
					a_tpl.set_section (l_vars.key_for_iteration, b)
				elseif attached l_vars.item_for_iteration as v then
					-- Convert other types to string
					a_tpl.set_variable (l_vars.key_for_iteration, v.out)
				end
				l_vars.forth
			end
		end

invariant
	expression_attached: expression /= Void

end
