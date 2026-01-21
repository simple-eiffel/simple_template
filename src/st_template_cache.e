note
	description: "Cache for compiled templates"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	ST_TEMPLATE_CACHE

create
	make

feature {NONE} -- Initialization

	make (a_capacity: INTEGER)
			-- Create cache with maximum `a_capacity` entries.
		require
			positive_capacity: a_capacity > 0
		do
			max_capacity := a_capacity
			create cache.make (a_capacity)
			create compiler.make
			hits := 0
			misses := 0
		ensure
			capacity_set: max_capacity = a_capacity
			empty: is_empty
		end

feature -- Access

	item (a_key: STRING): detachable ST_COMPILED_TEMPLATE
			-- Cached template for `a_key`, or Void if not cached.
		require
			key_attached: a_key /= Void
		do
			Result := cache.item (a_key)
		end

	get_or_compile (a_key: STRING; a_source: STRING): ST_COMPILED_TEMPLATE
			-- Get cached template or compile and cache it.
		require
			key_attached: a_key /= Void
			source_attached: a_source /= Void
		do
			if attached cache.item (a_key) as cached then
				hits := hits + 1
				Result := cached
			else
				misses := misses + 1
				Result := compiler.compile (a_source)
				put (a_key, Result)
			end
		ensure
			result_attached: Result /= Void
			cached: has (a_key)
		end

	get_or_compile_file (a_path: STRING): ST_COMPILED_TEMPLATE
			-- Get cached template for file or compile and cache it.
		require
			path_attached: a_path /= Void
			path_not_empty: not a_path.is_empty
		do
			if attached cache.item (a_path) as cached then
				hits := hits + 1
				Result := cached
			else
				misses := misses + 1
				Result := compiler.compile_from_file (a_path)
				put (a_path, Result)
			end
		ensure
			result_attached: Result /= Void
			cached: has (a_path)
		end

	max_capacity: INTEGER
			-- Maximum number of cached templates.

	count: INTEGER
			-- Number of cached templates.
		do
			Result := cache.count
		end

	hits: INTEGER
			-- Number of cache hits.

	misses: INTEGER
			-- Number of cache misses.

	hit_rate: REAL
			-- Cache hit rate (0.0 to 1.0).
		local
			total: INTEGER
		do
			total := hits + misses
			if total > 0 then
				Result := (hits / total).truncated_to_real
			end
		end

feature -- Status

	is_empty: BOOLEAN
			-- Is the cache empty?
		do
			Result := cache.is_empty
		end

	is_full: BOOLEAN
			-- Is the cache at capacity?
		do
			Result := cache.count >= max_capacity
		end

	has (a_key: STRING): BOOLEAN
			-- Is `a_key` cached?
		require
			key_attached: a_key /= Void
		do
			Result := cache.has (a_key)
		end

feature -- Modification

	put (a_key: STRING; a_template: ST_COMPILED_TEMPLATE)
			-- Cache `a_template` with `a_key`.
			-- Evicts oldest entry if at capacity.
		require
			key_attached: a_key /= Void
			template_attached: a_template /= Void
		do
			if is_full and then not has (a_key) then
				evict_one
			end
			cache.force (a_template, a_key)
		ensure
			cached: has (a_key)
		end

	remove (a_key: STRING)
			-- Remove `a_key` from cache.
		require
			key_attached: a_key /= Void
		do
			cache.remove (a_key)
		ensure
			removed: not has (a_key)
		end

	clear
			-- Clear all cached templates.
		do
			cache.wipe_out
		ensure
			empty: is_empty
		end

	reset_stats
			-- Reset hit/miss counters.
		do
			hits := 0
			misses := 0
		ensure
			hits_zero: hits = 0
			misses_zero: misses = 0
		end

feature {NONE} -- Implementation

	cache: HASH_TABLE [ST_COMPILED_TEMPLATE, STRING]
			-- Cached templates by key.

	compiler: ST_TEMPLATE_COMPILER
			-- Compiler for creating new templates.

	evict_one
			-- Evict one entry from cache (simple FIFO strategy).
		require
			not_empty: not is_empty
		do
			cache.start
			if not cache.after then
				cache.remove (cache.key_for_iteration)
			end
		ensure
			one_less: cache.count = old cache.count - 1
		end

invariant
	cache_attached: cache /= Void
	compiler_attached: compiler /= Void
	positive_capacity: max_capacity > 0
	valid_count: count <= max_capacity
	non_negative_hits: hits >= 0
	non_negative_misses: misses >= 0

end
