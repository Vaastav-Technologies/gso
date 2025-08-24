# gso (GreenStdOut)

`GreenStdOut`: Colour stdout green 💚, to differentiate stdout and stderr, .. and much more ..

`GreenStdOut` is a collection of utilities that helps you distinguish **stdout** from **stderr** in your command outputs. It can either colorize stdout in green 💚, or prefix output lines with labels (`OUT:`), or wrap everything in Markdown/HTML spans. This makes it easier to debug scripts and commands where both streams are mixed.

---

## Features

* 🟢 **Colorized stdout** by default (stdout shown in green, stderr unchanged)
* 🏷 **Label mode** with `OUT:` prefix for each line in stdout (useful if the command already uses colors)
* 📝 **Markdown mode** with `<pre>` and HTML spans for stdout
* 🎯 **Exit code reporting**, always displayed at the end
* 🤫 Optionally suppress the exit code line with `-q`

---

## Installation

Simply source the function in your shell (e.g. `~/.bashrc` or `~/.zshrc`).

```bash
# Clone or copy the function definition into your shell config
source /path/to/gso.sh
```

Then reload your shell or run `source ~/.bashrc`.

---

## Usage

#### Command outline

```shell
gso [-hq][-l|-m] <command> <command-args-and-opts>
```

```bash
gso command args...                # stdout in green, stderr normal
gso -h                             # print help and exit
gso -l command args...             # prefix OUT: labels per line for stdout, useful when colourised output is not desired but still output differentiation is needed.
gso -q                             # suppress [GSO] exit code print
gso -m command args...             # output formatted in markdown (HTML spans) inside <pre>

# Options:
#   -l and -m are mutually exclusive
```

### Examples

#### Normal run (colorized stdout)

```shell
$ gso ls . /doesnotexist
```

```terminaloutput
current directory contents
ls: cannot access '/doesnotexist': No such file or directory
[GSO] exit code: 2
```

#### Label mode

```shell
$ gso -l ls . /doesnotexist
```

```terminaloutput
OUT: current directory contents
ls: cannot access '/doesnotexist': No such file or directory
[GSO] exit code: 2
```

#### Markdown mode

```shell
$ gso -m ls . /doesnotexist
```

```terminaloutput
<pre>
<span style="color:green">current directory contents</span>
ls: cannot access '/doesnotexist': No such file or directory
<span style="color:red">[GSO]</span> exit code: 2
</pre>
```

#### Quiet exit

```shell
$ gso -q ls . /doesnotexist
```

```terminaloutput
current directory contents
ls: cannot access '/doesnotexist': No such file or directory
# (exit code still returned, just not printed)
$ echo $?
2
```

---

## Environment Variables

Environment variables can be used to set the shell mode at the start. They mimic the short CLI options, but CLI options take priority.

* `GSO_NOEXIT` → `-q`
* `GSO_LBL` → `-l`
* `GSO_MD` → `-m`

---

## License

[MIT License](./LICENSE)

---

## Contributing

Check our [contribution guide](./CONTRIBUTING.md).
