package getopts


import "core:fmt"
import "core:mem"
import "core:os"
import str "core:strings"

optarg_opt :: enum {
	NO_ARGUMENT       = 0,
	REQUIRED_ARGUMENT = 1,
	OPTIONAL_ARGUMENT = 2,
}

optarg_val :: union {
	string,
	bool,
}

Option :: struct {
	name:     string,
	alt_name: string,
	has_arg:  optarg_opt,
	val:      optarg_val,
	set:      bool,
}

Options :: struct {
	opts: [dynamic]Option,
}

strchr :: proc(s, sub: string) -> string {
	offset := str.index(s, sub)
	if offset < 0 do return ""
	return str.clone(s[offset:])
}

@(private = "file")
_progname :: proc(arg: string) -> string {
	temp := strchr(arg, "/")
	if temp != "" do return temp[1:]
	else do return arg
}

init_opts :: proc() -> Options {
	return Options{opts = make([dynamic]Option)}
}

deinit_opts :: proc(o: ^Options) {
	for opt in o.opts {
		if str, ok := opt.val.(string); ok {delete(str)}
	}
	delete(o.opts)
}

add_arg :: proc(o: ^Options, name: string, req: optarg_opt, alt_name: string = "") {
	if o == nil || len(name) == 0 do os.exit(1)
	for opt in o.opts {
		if str.compare(name, opt.name) == 0 || str.compare(name, opt.alt_name) == 0 {
			fmt.fprintf(
				os.stderr,
				"%s: Option %v has already been added",
				_progname(os.args[0]),
				name,
			)
			os.exit(1)
		}
	}
	append(&o.opts, Option{name, alt_name, req, false, false})
}

getopt_long :: proc(args: []string, opts: ^Options) {
	assert(len(opts.opts) != 0, "No options present\n")
	assert(len(args) > 1, "No arguments present\n")

	found: bool
	arg: string
	i: int = 1 // Skip the program name.
	for i < len(args) {
		if str.has_prefix(args[i], "--") {
			arg = args[i][2:]
		} else if str.has_prefix(args[i], "-") {
			arg = args[i][1:]
		} else {
			fmt.fprintf(os.stderr, "%s: Invalid argument | '%v'\n", _progname(args[0]), args[i])
			os.exit(1) // Don't accept args without '-'
		}

		has_equals: string = strchr(arg, "=")
		equals_val: string
		if len(has_equals) != 0 {
			equals_val = has_equals[1:] // Truncate the =
			arg = arg[:len(equals_val) - 1]
		}

		for &opt in opts.opts {
			if str.compare(opt.name, arg) == 0 || str.compare(opt.alt_name, arg) == 0 { 	// Found an argument!
				using optarg_opt
				// Do we need a value?
				if opt.has_arg == .REQUIRED_ARGUMENT || opt.has_arg == .OPTIONAL_ARGUMENT {
					if len(equals_val) == 0 {
						if opt.has_arg == .REQUIRED_ARGUMENT && len(args) < i + 1 {
							// Needs arg ++ no args left.
							fmt.fprintf(
								os.stderr,
								"%s: %v requires an argument",
								_progname(args[0]),
								arg,
							)
							os.exit(1)
						}

						//FIXME: Broke this in my messing around, need to reconsider approach or 
						//check what weird stuff I missed I think.
						// Handle optional:
						if len(args) < i + 1 {
							opt.val = true
						} else if str.has_prefix(args[i + 1], "-") ||
						   str.has_prefix(args[i + 1], "--") {
							// Handle the case of --flag --new_flag=10
							fmt.println("Setting arg", args[i], "to true")
							opt.val = true
						} else {
							opt.val = str.clone(args[i + 1])
							i += 1
						}
						opt.set = true
						found = true
						break
					} else {
						opt.val = str.clone(equals_val)
						opt.set = true
						found = true
						break
					}
				} else { 	// Its just a FLAG to set
					opt.val = true
					opt.set = true
					found = true
					break
				}
			}
		}
		if found != true {
			fmt.println("%s: no argument | %v", _progname(args[0]), arg)
			os.exit(1)
		}
		if len(has_equals) > 0 do delete(has_equals)
		arg = ""
		i += 1
		found = false
	}
}
