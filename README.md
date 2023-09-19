# getopts
A Odin command line argument parser, loosely based on the getopts_long.

# Usage

Checking the test.odin file is probably the easiest way to see how it works in action!

Init and Deinit the Options pointer.

Add arguments as required 

``getopt_long()`` will then parse the args into the options pointer.
It will parse the following formats:
 - `-f`
 - `-f 1`
 - `--flag`
 - `--flag value`
 - `--flag=value`
 - `-flag value`
 - `-flag=value`



## Example:
```odin
opts := init_opts()
defer deinit_opts(&opts)
{ // Scoping for easy scope of using.
  using optarg_opt
  add_arg(&opts, "flag", .NO_ARGUMENT)
  add_arg(&opts, "opt-argument", .OPTIONAL_ARGUMENT)
  add_arg(&opts, "required", .REQUIRED_ARGUMENT)
  add_arg(&opts, "h", .NO_ARGUMENT, "help") // Alternative name // long_opt
  add_arg(&opts, "m", .OPTIONAL_ARGUMENT, "my_flag_here")

}
getopt_long(os.args, &opts)
// Parse opts:
for opt in opts.opts {
  if ! opt.set do continue // allows to skip non set options.
  switch opt.name { // name will always be set, don't have to check both
    case "flag":
      // Something
    case "required":
      // Something else 
    case:
      // default? Usage!
  }  
}
```
### Bugs
Just open a PR or an issue!

### Contributions
Am always open to any improvements people might want think of!
