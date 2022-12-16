Pawn scripting language
=====

A minimal implementation of Pawn for Hercules.

amx.h;.c and amxaux.c contain almost completely unmodified AMX core. (Pawn abstract machine)
Only modifications are in amx.h: 
- adding line #include "osdefs.h" to amx.h
- adding #include <stdint.h> and fixing some typedefs

Modifications are marked with "MODIFICATION FOR AALTO-2"

Other files that have been customized:

- osdefs.h contains platform specific definitions.
- amxcons.h;.c contain "console" functions
- amxaux.h;.c contain auxiliary functions for example file I/O.
- native.h;.c contain OBC functions offered to Pawn environment.
