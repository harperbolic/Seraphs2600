	processor 6502

	include "vcs.h"
	include "macro.h"

	seg code
	org $F000

Reset:
	CLEAN_START

	ldx #$80
	stx COLUBK

	lda #$1C
	sta COLUPF

	;; turn VBLANK, VSYNC on
StartFrame:
	lda #2
	sta VBLANK
	STA VSYNC


	;; 3 VSYNC scanlines
	REPEAT 3
		sta WSYNC 
	REPEND
	lda #0
	sta VSYNC

	;; 27 VBLANK scanlines
	REPEAT 37
		sta WSYNC
	REPEND
	lda #0
	sta VBLANK

	;; set CTRLPF for playfield reflection
	ldx #1
	stx CTRLPF

	;; 192 visible scanlines
	;; 7 no PF set scanlines
	ldx #0
	stx PF0
	stx PF1
	stx PF2
	REPEAT 7
		sta WSYNC
	REPEND

	;; set PF(0-2), display 7 scanlines
	ldx #%11100000
	stx PF0
	ldx #%11111111
	stx PF1
	stx PF2
	REPEAT 7
		sta WSYNC
	REPEND

	;; set PF(0-2), display 164 scanlines
	ldx #%01100000
	stx PF0
	ldx #0
	stx PF1
	ldx #%10000000
	stx PF2
	REPEAT 164
		sta WSYNC
	REPEND

	;; set PF(0-2), display 7 scanlines
	ldx #%11100000
	stx PF0
	ldx #%11111111
	stx PF1
	stx PF2
	REPEAT 7
		sta WSYNC
	REPEND

	;; 7 no PF set scanlines
	ldx #0
	stx PF0
	stx PF1
	stx PF2
	REPEAT 7
		sta WSYNC
	REPEND

	;; 30 VBLANK oversan scanlines
	lda #2
	sta VBLANK
	REPEAT 30
		sta WSYNC
	REPEND
	LDA #0
	sta VBLANK

	jmp StartFrame

	org $FFFC
	.word Reset
	.word Reset
