export executable "cat";

import "std.zig";

// Things to do to make this work:
// * isize instead of usize for things
// * var args printing
// * update std API
// * !void type
// * defer
// * !return
// * !! operator
// * make main return !void
// * how to reference error values (!void).Invalid ? !Invalid ?
// * ~ is bool not, not !
// * cast err type to string

pub fn main(args: [][]u8) !void => {
    const exe = args[0];
    var catted_anything = false;
    for (arg, args[1...]) {
        if (arg == "-") {
            catted_anything = true;
            !return cat_stream(stdin);
        } else if (arg[0] == '-') {
            return usage(exe);
        } else {
            var is: InputStream;
            is.open(arg, OpenReadOnly) !! (err) => {
                stderr.print("Unable to open file: {}", ([]u8])(err));
                return err;
            }
            defer is.close();

            catted_anything = true;
            !return cat_stream(is);
        }
    }
    if (~catted_anything) {
        !return cat_stream(stdin)
    }
}

fn usage(exe: []u8) !void => {
    stderr.print("Usage: {} [FILE]...\n", exe);
    return !Invalid;
}

fn cat_stream(is: InputStream) !void => {
    var buf: [1024 * 4]u8;

    while (true) {
        const bytes_read = is.read(buf);
        if (bytes_read < 0) {
            stderr.print("Unable to read from stream: {}", ([]u8)(is.err));
            return is.err;
        }

        const bytes_written = stdout.write(buf[0...bytes_read]);
        if (bytes_written < bytes_read) {
            stderr.print("Unable to write to stdout: {}", ([]u8)(stdout.err));
            return stdout.err;
        }
    }
}
