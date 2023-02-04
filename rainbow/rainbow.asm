	processor 6502

	include "vcs.h"
	include "macro.h"

	seg code
	org $F000

Start:
	CLEAN_START

	;; VBLANK and VSYNC on to start a new frame
NextFrame:
	lda #2
	sta VBLANK
	sta VSYNC		; wait for the next scanlins

	;; VSYNC 3 lines
	sta WSYNC
	sta WSYNC		; scanline++
	sta WSYNC

	lda #0
	sta VSYNC

	;; TIA 37 VBLANK scanlines
	ldx #37
	
LoopVBLANK:
	sta WSYNC
	dex
	bne LoopVBLANK

	lda #0
	sta VBLANK		; VBLANK off

	;; 192 visibles scanlines render
	ldx #192
LoopVisible:
	stx COLUBK		; bg color --> rainbow loop
	sta WSYNC
	dex
	bne LoopVisible

	;; 30 overscan scanlines render
	lda #2
	sta VBLANK

	ldx #30
LoopOverscan:	
	sta WSYNC
	dex
	bne LoopOverscan
	
	jmp NextFrame

	;; ROM completion
	org $FFFC
	.word Start
	.word Start
