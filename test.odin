package getopts

import "core:fmt"
import "core:mem"
import "core:os"
import _t "core:testing"

fake_do_thing :: proc(opt: Option) {
	using optarg_opt
	fmt.println("==================")
	fmt.printf("   => '%s' / '%s' was set ", opt.name, opt.alt_name)
	if opt.has_arg == .OPTIONAL_ARGUMENT {
		fmt.printf("With optional value: %v\n", opt.val)
	} else if opt.has_arg == .REQUIRED_ARGUMENT {
		fmt.printf("With required value: %v\n", opt.val)
	} else {
		fmt.printf("with flag set to: %v\n", opt.val)
	}
}

fake_print_help :: proc(opt: Option) {
	fmt.printf("The %v flag was set with long opt %v\n")
	fmt.printf("This is a fake usage message to simulate a help message\n")
	fmt.printf(
		` progname [OPTION] [VALUE] [FILEPATH]
  - opt           Does some cool opt stuff
  - arg           Does some cool arg stuff 
  - f   -- file   Sets a cool filepath to use!
`,
	)

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
		case "opt-arg":
			fake_do_thing(opt)
		case "red":
			fake_do_thing(opt)
		case "h":
			fake_print_help(opt)
		case "f":
			fake_do_thing(opt)
		case "flag-two":
			fake_do_thing(opt)
		case "flag-three":
			fake_do_thing(opt)
		case "flag-four":
			fake_do_thing(opt)
		case "opt":
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
		"--opt-arg",
		"-t",
	}
	opts := init_opts()
	defer deinit_opts(&opts)
	add_arg(&opts, "t", .NO_ARGUMENT, "tester")
	add_arg(&opts, "v", .OPTIONAL_ARGUMENT, "vals")
	add_arg(&opts, "opt-arg", .OPTIONAL_ARGUMENT)
	add_arg(&opts, "w", .REQUIRED_ARGUMENT)
	add_arg(&opts, "blue", .REQUIRED_ARGUMENT)
	add_arg(&opts, "red", .REQUIRED_ARGUMENT, "red-ribbon")
	add_arg(&opts, "not-set", .NO_ARGUMENT)

	fmt.println("Options initialised and ready to parse")

	getopt_long(args, &opts)
	fake_process_opts(opts)

	fmt.println("Done!")
}

@(test)
test_optionals :: proc(_: ^_t.T) {
	args: []string = {"./testopts", "--flag-one", "--flag-two", "pix-xip", "--opt-arg=1"}
	opts := init_opts()
	defer deinit_opts(&opts)
	add_arg(&opts, "f", .OPTIONAL_ARGUMENT, "flag-one")
	add_arg(&opts, "flag-two", .OPTIONAL_ARGUMENT)
	add_arg(&opts, "opt", .OPTIONAL_ARGUMENT, "opt-arg")

	fmt.println("Options initialised for optional argument test. Parsing")

	getopt_long(args, &opts)
	fake_process_opts(opts)
	fmt.println("Done 'Optional' Test.")
}

@(test)
test_required :: proc(_: ^_t.T) {
	args: []string = {
		"./testopts",
		"-f",
		"pix-xip",
		"--flag-two",
		"11911",
		"-flag-three",
		"path/to/file/for/flag/three",
	}
	opts := init_opts()
	defer deinit_opts(&opts)
	add_arg(&opts, "f", .REQUIRED_ARGUMENT, "flag-one")
	add_arg(&opts, "flag-two", .REQUIRED_ARGUMENT)
	add_arg(&opts, "flag-three", .REQUIRED_ARGUMENT, "f3bby")

	fmt.println("Options initialised for required argument test. Paring")
	getopt_long(args, &opts)
	fake_process_opts(opts)
	fmt.println("Done 'Required' Test")
}
