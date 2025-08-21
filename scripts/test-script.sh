#!/usr/bin/env bash

# test-script.sh
# This script prints a variety of stdout/stderr messages,
# with and without ANSI colors, to help test rse.sh.

# Normal stdout
echo "This is a normal stdout line"

# Normal stderr
echo "This is a normal stderr line" >&2

# Stdout with red color
echo -e "\033[31mThis is red stdout\033[0m"

# Stderr with red color
echo -e "\033[31mThis is red stderr\033[0m" >&2

# Stdout with green color
echo -e "\033[32mThis is green stdout\033[0m"

# Stderr with green color
echo -e "\033[32mThis is green stderr\033[0m" >&2

# Stdout with yellow color
echo -e "\033[33mThis is yellow stdout\033[0m"

# Stderr with yellow color
echo -e "\033[33mThis is yellow stderr\033[0m" >&2

# Stdout with blue color
echo -e "\033[34mThis is blue stdout\033[0m"

# Stderr with blue color
echo -e "\033[34mThis is blue stderr\033[0m" >&2

# Stdout with magenta color
echo -e "\033[35mThis is magenta stdout\033[0m"

# Stderr with magenta color
echo -e "\033[35mThis is magenta stderr\033[0m" >&2

# Stdout with cyan color
echo -e "\033[36mThis is cyan stdout\033[0m"

# Stderr with cyan color
echo -e "\033[36mThis is cyan stderr\033[0m" >&2

# Stdout with bold text
echo -e "\033[1mThis is bold stdout\033[0m"

# Stderr with bold text
echo -e "\033[1mThis is bold stderr\033[0m" >&2

# Mixed stdout + stderr
echo "This is stdout before stderr"
echo "This is stderr after stdout" >&2
echo "This is stdout after stderr"

echo "--- End of test-script.sh output ---"
