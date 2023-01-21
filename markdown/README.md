# btop/markdown

This directory contains markdown format input files used by pandoc to
automatically generate man format man pages. The utility script
[md2man](https://gitlab.com/doctorfree/DoctorFreeScripts/-/blob/master/scripts/md2man.sh)
in the [DoctorFreeScripts repository](https://gitlab.com/doctorfree/DoctorFreeScripts)
is used as a pandoc wrapper.

The man page format output can be found at ../man/man?/<command>.?
For example, the man page output for the `btop` command would be found at
../man/man1/btop.1

## Contents

- [**btop.1.md**](btop.1.md) - Markdown input for auto-generation of the btop man page
