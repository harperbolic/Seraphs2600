	processor 6502

	include "vcs.h"
	include "macro.h"

	seg code
	org $F000

Start:
	CLEAN_START		; "macro.h" memory clean macro

	;;  Bg luminosity color set (NTSC)

	lda #$8E
	sta COLUBK		; "vcs.h" $09 alias

	jmp Start

	org $FFFC
	.word Start
	.word Start
