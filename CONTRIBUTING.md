# Contributing to GSO

Thank you for considering contributing to **GSO**!

This project is a collection of Bash utilities that help people experiment with CLIs by making it easier to differentiate `stdout` and `stderr` using colors, labels, or markdown formatting. It also surfaces the process exit code without requiring a separate query. We welcome bug reports, feature requests, and code contributions.

---

## How to Contribute

### Reporting Issues

* Use the [issue tracker](./issues) to report bugs or suggest enhancements.
* Please include clear steps to reproduce bugs.
* Share environment details (OS, Bash version).

### Submitting Changes

1. Fork the repository.
2. Create a new branch for your work:

   ```bash
   git checkout -b feature/my-change
   ```
3. Make your edits.
4. Ensure your code follows the existing style.
5. Test your changes with various commands to ensure stdout/stderr handling is correct.
6. Keep your commits as atomic as possible.
7. Commit your work with a clear message, starting with the affected feature:

   ```bash
   # For shell-related changes
   git commit -m "sh: add support for markdown output" -m "<details about the change>"

   # For command-related changes
   git commit -m "cmd: fix argument parsing bug" -m "<details about the fix>"
   ```
8. Push to your fork and open a Pull Request.

### Guidelines

* Keep commits focused and atomic.
* Update documentation if your changes affect usage.
* Add test examples (in `scripts/test-script.sh`) if introducing new functionality.

---

## Development Notes

* Exit codes: always preserve the exit status of the original command.
* Coloring:

  * `stdout` → green (default mode)
  * `stderr` → AS-IS
* Environment variables mimic CLI options but CLI options take precedence.

---

## Code of Conduct

Be respectful and constructive in discussions. We aim for a friendly and collaborative environment.

---

Happy hacking!
