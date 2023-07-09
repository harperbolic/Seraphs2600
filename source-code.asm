	processor 6502

	;; include alias
	
	include "vcs.h"
	include "macro.h"

	;; vars, $80-$FF

	seg.u var
	org $80
P0Height byte
P0YPos byte
P0XPos byte

	;; Rom init at $F000

	seg code
	org $F000
Reset:
	CLEAN_START

	ldx #$80
	stx COLUBK

	;; init vars

	lda #180
	sta P0YPos

	lda #11
	sta P0Height

	lda #00
	sta P0XPos

	;; Frame start
	;; Vblank and Vsync

StartFrame:
	lda #2
	sta VBLANK
	sta VSYNC

	;; Vsync

	sta WSYNC
	sta WSYNC
	sta WSYNC

	lda #0
	sta VSYNC

	;; set P0XPos

	lda P0XPos
	and #$7F

	sec

	sta WSYNC
	sta HMCLR

DivideLoop:
	sbc #15
	bcs DivideLoop

	eor #%00000111
	asl
	asl
	asl
	asl
	sta HMP0
	sta RESP0
	sta WSYNC
	sta HMODE

	;; VBLANK

	ldx #192

Scanline:
	txa
	sec
	sbc P0YPos
	cpm P0Height
	cmp P0Height
	bcc LoadBitmap
	lda #0

LoadBitmap:
	tay
	lda p0Bitmap,Y
	sta GRP0

	lda P0Color,Y
	sta COLUP0

	sta WSYNC

	dex
	bne Scanline

	;; Vblank overscan

	lda #2
	sta VBLANK

	REPEAT 30
	sta WSYNC
	REPEND

	lda #0
	sta VLANK

	;; P0Pos

	dec P0YPos
	inc P0XPos

	;; New frame

	jmp StartFrame



	;; bitmaps arrays

	org $FFE7

P0Bitmap:
	.byte #%00000000
	.byte #%01111110
	.byte #%00111110
	.byte #%00111100
	.byte #%00111100
	.byte #%00011000
	.byte #%01111110
	.byte #%10111101
	.byte #%00011000
	.byte #%00100000

P0Color:
	REPEAT 9
	.byte #0
	REPEND

	org $FFFC
	.word Reset
	.word Reset
