note
	description: "Performance benchmarks for simple_template"
	author: "Larry Rix"

class
	PERFORMANCE_BENCHMARKS

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize benchmarks.
		do
		end

feature -- Benchmarks

	run_all
			-- Run all benchmarks and print results.
		do
			print ("%N=== Performance Benchmarks ===%N")
			print ("(Run 'time simple_template.exe' externally for timing)%N%N")
			benchmark_simple_render
			benchmark_compiled_render
			benchmark_cache_performance
			benchmark_filter_chain
			benchmark_expression_evaluation
			benchmark_large_template
			print ("%N=== Benchmarks Complete ===%N")
		end

	benchmark_simple_render
			-- Benchmark simple variable substitution.
		local
			i: INTEGER
			template: SIMPLE_TEMPLATE
			result_str: STRING
		do
			create template.make_from_string ("Hello {{name}}, welcome to {{place}}!")
			template.set_variable ("name", "World")
			template.set_variable ("place", "Eiffel")

			from i := 1 until i > Iterations loop
				result_str := template.render
				i := i + 1
			end

			print ("Simple render: " + Iterations.out + " iterations OK%N")
		end

	benchmark_compiled_render
			-- Benchmark compiled template rendering.
		local
			i: INTEGER
			template: SIMPLE_TEMPLATE
			result_str: STRING
		do
			create template.make_from_string ("Hello {{name}}, welcome to {{place}}!")
			template.set_variable ("name", "World")
			template.set_variable ("place", "Eiffel")

			-- Pre-compile
			template.compile.do_nothing

			from i := 1 until i > Iterations loop
				result_str := template.render_compiled
				i := i + 1
			end

			print ("Compiled render: " + Iterations.out + " iterations OK%N")
		end

	benchmark_cache_performance
			-- Benchmark cache hit vs miss performance.
		local
			i: INTEGER
			cache: ST_TEMPLATE_CACHE
			compiled: detachable ST_COMPILED_TEMPLATE
		do
			create cache.make (100)

			-- First: cache misses (compile)
			from i := 1 until i > Cache_iterations loop
				compiled := cache.get_or_compile ("template_" + i.out, "Hello {{name}} #" + i.out)
				i := i + 1
			end

			-- Second: cache hits
			from i := 1 until i > Cache_iterations loop
				compiled := cache.get_or_compile ("template_" + i.out, "Hello {{name}} #" + i.out)
				i := i + 1
			end

			print ("Cache: " + cache.hits.out + " hits, " + cache.misses.out + " misses%N")
		end

	benchmark_filter_chain
			-- Benchmark filter application.
		local
			i: INTEGER
			evaluator: ST_EXPRESSION_EVALUATOR
			ctx: ST_CONTEXT
			result_str: STRING
		do
			create evaluator.make
			create ctx.make

			ctx.set_variable ("text", "hello world")

			-- Single filter
			from i := 1 until i > Iterations loop
				result_str := evaluator.evaluate ("text | upper", ctx)
				i := i + 1
			end

			print ("Single filter: " + Iterations.out + " iterations OK%N")

			-- Filter chain
			from i := 1 until i > Iterations loop
				result_str := evaluator.evaluate ("text | upper | reverse | trim", ctx)
				i := i + 1
			end

			print ("Filter chain x3: " + Iterations.out + " iterations OK%N")
		end

	benchmark_expression_evaluation
			-- Benchmark math expression evaluation.
		local
			i: INTEGER
			evaluator: ST_EXPRESSION_EVALUATOR
			ctx: ST_CONTEXT
			result_str: STRING
		do
			create evaluator.make
			create ctx.make

			ctx.set_variable ("x", "10")
			ctx.set_variable ("y", "5")

			-- Simple variable
			from i := 1 until i > Iterations loop
				result_str := evaluator.evaluate ("x", ctx)
				i := i + 1
			end

			print ("Variable lookup: " + Iterations.out + " iterations OK%N")

			-- Math expression
			from i := 1 until i > Iterations loop
				result_str := evaluator.evaluate ("x + y", ctx)
				i := i + 1
			end

			print ("Math expression: " + Iterations.out + " iterations OK%N")
		end

	benchmark_large_template
			-- Benchmark rendering a large template.
		local
			i, j: INTEGER
			template: SIMPLE_TEMPLATE
			large_template: STRING
			result_str: STRING
		do
			-- Create template with 100 variables
			create large_template.make (5000)
			from j := 1 until j > 100 loop
				large_template.append ("Item {{item_" + j.out + "}}: ${{price_" + j.out + "}}%N")
				j := j + 1
			end

			create template.make_from_string (large_template)
			from j := 1 until j > 100 loop
				template.set_variable ("item_" + j.out, "Product " + j.out)
				template.set_variable ("price_" + j.out, (j * 10).out + ".99")
				j := j + 1
			end

			from i := 1 until i > Large_iterations loop
				result_str := template.render
				i := i + 1
			end

			print ("Large template (100 vars): " + Large_iterations.out + " iterations OK%N")
		end

feature {NONE} -- Implementation

	Iterations: INTEGER = 10000
			-- Number of iterations for micro-benchmarks.

	Cache_iterations: INTEGER = 1000
			-- Number of iterations for cache benchmarks.

	Large_iterations: INTEGER = 1000
			-- Number of iterations for large template benchmarks.

end
