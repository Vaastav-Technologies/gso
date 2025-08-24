# gso (GreenStdOut)

`GreenStdOut`: Colour stdout green 💚, to differentiate stdout and stderr, .. and much more ..

`GreenStdOut` is a collection of utilities that helps you distinguish **stdout** from **stderr** in your command outputs. It can either colorize stdout in green 💚, or prefix output lines with labels (`OUT:`). This makes it easier to debug scripts and commands where both streams are mixed.

---

## Features

* 🟢 green **Colorized stdout** by default (stdout shown in green, stderr unchanged)
* 🏷 **Label mode** with `OUT:` prefix (useful if the command already uses colors)
* � **Exit code reporting**, always displayed at the end.
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

```bash
gso command args...                 # stderr in red, stdout normal
gso -h | --help                     # print help
gso -l | --label command args...    # prefix with OUT:, useful when colorised output is not desired but still output differentiation is needed.
gso -q | --quiet-exit command args  # suppress [GSO] exit code print
gso -lq | -ql                       # combine both options
```

### Examples

#### Normal run (colorized stdout)

```shell
$ gso ls . /doesnotexist
```
```terminaloutput
[32;1mcurrent directory contents[0m
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
<span style="color:red">[GSO]</span> exit code: 0
</pre>
```

#### Quiet exit

```shell
$ gso -q ls . /doesnotexist
```
```terminaloutput
[32;1current directory contents[0m
ls: cannot access '/doesnotexist': No such file or directory
# (exit code still returned, just not printed)
$ echo $?
2
```

---

## License

[MIT License](./LICENSE)
