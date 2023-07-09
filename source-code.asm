 	processor 6502

	;; include alias
	
	include "vcs.h"
	include "macro.h"

;; var $80 - $FF

	seg.u var
	org $80
P0Height byte			; one byte for P0Height
P0YPos byte
P0XPos	byte	

	;; init ROM at $F000

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
	
	;; enable VBLANK and VSYNC

StartFrame:
	lda #2
	sta VBLANK
	sta VSYNC

	;; VSYNC

	REPEAT 3
		sta WSYNC 
	REPEND
	lda #0
	sta VSYNC
	
	;; Set P0XPos

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
	sta HMOVE

	;; VBLANK
	
	REPEAT 35
		sta WSYNC
	REPEND

	lda #0
	sta VBLANK
	
	;; visible scanlines

	ldx #192

Scanline:
	txa
	sec
	sbc P0YPos
	cmp P0Height
	bcc LoadBitmap
	lda #0

LoadBitmap:
	tay
	lda P0Bitmap,Y
	sta GRP0

	lda P0Color,Y
	sta COLUP0

	sta WSYNC
	
	dex
	bne Scanline
	
	;; VBLANK overscan

	lda #2
	sta VBLANK
	REPEAT 30
		sta WSYNC
	REPEND
	LDA #0
	sta VBLANK

	;; decrease P0Pos
	
	dec P0YPos
	inc P0XPos

	;; New frame
	
	jmp StartFrame

	;; player numberarray
	org $FFE7
P0Bitmap:
	.byte #%00000000
	.byte #%01111110	;---0----
	.byte #%00111110	;---00---
	.byte #%00111100	;0-0000-0
	.byte #%00111100	;-000000-
	.byte #%00111100	;---00---
	.byte #%00011000	;--0000--
	.byte #%01111110	;--0000--
	.byte #%10111101	;--0000--
	.byte #%00011000	;--00000-
	.byte #%00100000	;-000000-

P0Color:
	.byte #0
	.byte #0
	.byte #0
	.byte #0
	.byte #0
	.byte #0
	.byte #0
	.byte #0
	.byte #0
	.byte #0
	
	org $FFFC
	.word Reset
	.word Reset
