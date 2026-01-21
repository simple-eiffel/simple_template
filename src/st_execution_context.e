note
	description: "Execution context for compiled template rendering"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	ST_EXECUTION_CONTEXT

create
	make

feature {NONE} -- Initialization

	make
			-- Create empty execution context.
		do
			create variables.make (10)
			create sections.make (5)
			create lists.make (5)
			create partials.make (3)
			escape_html := True
			missing_policy := Policy_empty_string
		ensure
			escape_enabled: escape_html
		end

feature -- Access

	variable (a_name: STRING): detachable STRING
			-- Value of variable `a_name`, or Void if not set.
		require
			name_attached: a_name /= Void
		do
			Result := variables.item (a_name)
		end

	section_visible (a_name: STRING): BOOLEAN
			-- Is section `a_name` visible?
		require
			name_attached: a_name /= Void
		do
			if sections.has (a_name) then
				Result := sections.item (a_name)
			elseif lists.has (a_name) then
				if attached lists.item (a_name) as l then
					Result := not l.is_empty
				end
			elseif attached variables.item (a_name) as v then
				Result := not v.is_empty and then
						  not v.same_string ("false") and then
						  not v.same_string ("0")
			end
		end

	list (a_name: STRING): detachable ARRAYED_LIST [HASH_TABLE [STRING, STRING]]
			-- List for `a_name`, or Void if not set.
		require
			name_attached: a_name /= Void
		do
			Result := lists.item (a_name)
		end

	partial (a_name: STRING): detachable ST_COMPILED_TEMPLATE
			-- Partial template for `a_name`, or Void if not registered.
		require
			name_attached: a_name /= Void
		do
			Result := partials.item (a_name)
		end

	escape_html: BOOLEAN
			-- Should HTML be escaped?

	missing_policy: INTEGER
			-- Policy for missing variables.

feature -- Setting

	set_variable (a_name, a_value: STRING)
			-- Set variable `a_name` to `a_value`.
		require
			name_attached: a_name /= Void
			value_attached: a_value /= Void
		do
			variables.force (a_value, a_name)
		ensure
			set: attached variable (a_name) as v and then v.same_string (a_value)
		end

	set_section (a_name: STRING; a_visible: BOOLEAN)
			-- Set section `a_name` visibility.
		require
			name_attached: a_name /= Void
		do
			sections.force (a_visible, a_name)
		end

	set_list (a_name: STRING; a_items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]])
			-- Set list `a_name` to `a_items`.
		require
			name_attached: a_name /= Void
			items_attached: a_items /= Void
		do
			lists.force (a_items, a_name)
		end

	register_partial (a_name: STRING; a_template: ST_COMPILED_TEMPLATE)
			-- Register compiled partial `a_template` with `a_name`.
		require
			name_attached: a_name /= Void
			template_attached: a_template /= Void
		do
			partials.force (a_template, a_name)
		end

	set_escape_html (a_enabled: BOOLEAN)
			-- Enable or disable HTML escaping.
		do
			escape_html := a_enabled
		ensure
			set: escape_html = a_enabled
		end

	set_missing_policy (a_policy: INTEGER)
			-- Set missing variable policy.
		require
			valid_policy: a_policy >= Policy_empty_string and a_policy <= Policy_keep_placeholder
		do
			missing_policy := a_policy
		ensure
			set: missing_policy = a_policy
		end

	clear
			-- Clear all context data.
		do
			variables.wipe_out
			sections.wipe_out
			lists.wipe_out
		end

feature -- Merging

	push_scope (a_vars: HASH_TABLE [STRING, STRING])
			-- Push new variable scope (for list iteration).
		require
			vars_attached: a_vars /= Void
		do
			from a_vars.start until a_vars.after loop
				variables.force (a_vars.item_for_iteration, a_vars.key_for_iteration)
				a_vars.forth
			end
		end

feature -- Constants

	Policy_empty_string: INTEGER = 1
	Policy_raise_exception: INTEGER = 2
	Policy_keep_placeholder: INTEGER = 3

feature {NONE} -- Implementation

	variables: HASH_TABLE [STRING, STRING]
	sections: HASH_TABLE [BOOLEAN, STRING]
	lists: HASH_TABLE [ARRAYED_LIST [HASH_TABLE [STRING, STRING]], STRING]
	partials: HASH_TABLE [ST_COMPILED_TEMPLATE, STRING]

invariant
	variables_attached: variables /= Void
	sections_attached: sections /= Void
	lists_attached: lists /= Void
	partials_attached: partials /= Void

end
