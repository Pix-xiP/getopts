package getopts

import "core:fmt"
import "core:os"
import _t "core:testing"

fake_do_thing :: proc(opt: Option) {
	using optarg_opt
	fmt.println("==================")
	fmt.printf("   => %s/%s was set ", opt.name, opt.alt_name)
	if opt.has_arg == .OPTIONAL_ARGUMENT {
		fmt.printf("With optional value: %v\n", opt.val)
	} else if opt.has_arg == .REQUIRED_ARGUMENT {
		fmt.printf("With required value: %v\n", opt.val)
	} else {
		fmt.printf("with flag set to: %v\n", opt.val)
	}
}

fake_process_opts :: proc(opts: Options) {
	for opt in opts.opts {
		if !opt.set do continue
		switch opt.name { 	// This will always be set only need to check against name
		case "t":
			fake_do_thing(opt)
		case "v":
			fake_do_thing(opt)
		case "w":
			fake_do_thing(opt)
		case "blue":
			fake_do_thing(opt)
		case "not-set":
			fake_do_thing(opt)
		case "red":
			fake_do_thing(opt)
		case:
			fmt.println("Failure")
		}
	}
}
// To test here :>
@(test)
test_getopts :: proc(_: ^_t.T) {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)
		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}
	args: []string = {
		"./testopts",
		"--tester",
		"--vals",
		"1",
		"-w",
		"Some stuff here",
		"--blue=Steve",
		"--red=Help",
		"-t",
	}
	opts := init_opts()
	defer deinit_opts(&opts)
	add_arg(&opts, "t", .NO_ARGUMENT, "tester")
	add_arg(&opts, "v", .OPTIONAL_ARGUMENT, "vals")
	add_arg(&opts, "w", .REQUIRED_ARGUMENT)
	add_arg(&opts, "blue", .REQUIRED_ARGUMENT)
	add_arg(&opts, "red", .REQUIRED_ARGUMENT, "red-ribbon")
	add_arg(&opts, "not-set", .NO_ARGUMENT)

	fmt.println("Options initialised and ready to parse")

	getopt_long(args, &opts)
	fake_process_opts(opts)

	fmt.println("Done!")
}
