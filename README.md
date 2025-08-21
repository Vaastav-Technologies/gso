# rse (RedStdErr)

`RedStdErr`: Colour stderr red ❤️, to differentiate stdout and stderr, .. and much more ..

`RedStdErr` is a collection of utilities that helps you distinguish **stderr** from **stdout** in your command outputs. It can either colorize stderr in red ❤️, or prefix output lines with labels (`STDOUT:` / `STDERR:`). This makes it easier to debug scripts and commands where both streams are mixed.

---

## Features

* 🔴 **Colorized stderr** by default (stderr shown in red, stdout unchanged)
* 🏷 **Label mode** with `STDOUT:` and `STDERR:` prefixes (useful if the command already uses colors)
* � **Exit code reporting**, always displayed at the end.
* 🤫 Optionally suppress the exit code line with `-q`
* 🎨 Markdown export option planned (`-c`, `--copy`) for documentation workflows

---

## Installation

Simply source the function in your shell (e.g. `~/.bashrc` or `~/.zshrc`).

```bash
# Clone or copy the function definition into your shell config
source /path/to/rse.sh
```

Then reload your shell or run `source ~/.bashrc`.

---

## Usage

```bash
rse command args...                 # stderr in red, stdout normal
rse -h | --help                     # print help
rse -l | --label command args...    # prefix with OUT:/ERR:, useful when colorised output is not desired but still output differentiation is needed.
rse -q | --quiet-exit command args  # suppress [RSE] exit code print
rse -lq | -ql                       # combine both options
```

### Examples

#### Normal run (colorized stderr)

```shell
$ rse ls /doesnotexist
```
```terminaloutput
[31;1mls: cannot access '/doesnotexist': No such file or directory[0m
[RSE] exit code: 2
```

#### Label mode

```shell
$ rse -l ls /doesnotexist
```
```terminaloutput
STDERR: ls: cannot access '/doesnotexist': No such file or directory
[RSE] exit code: 2
```

#### Quiet exit

```shell
$ rse -q ls /doesnotexist
```
```terminaloutput
[31;1mls: cannot access '/doesnotexist': No such file or directory[0m
# (exit code still returned, just not printed)
$ echo $?
2
```

---

## Planned Features

* `--markdown` or `-c, --copy`: emit Markdown-friendly colored HTML output for documentation (e.g. GitHub, MkDocs, Obsidian)
* Packaged distribution (Homebrew / PyPI wrapper) for easy install

---

## License

[MIT License](./LICENSE)
