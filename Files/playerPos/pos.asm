	processor 6502

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; include macros and register alias
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include "vcs.h"
	include "macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; var declaration segment
;; $80 up to $FF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	seg.u var
	org $80
P0Height byte			; one byte for P0Height
PlayerYPos byte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; start ROM code at $F000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	seg code
	org $F000
Reset:
	CLEAN_START

	ldx #$80
	stx COLUBK
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; initialize vars
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	lda #180
	sta PlayerYPos

	lda #11
	sta P0Height
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; start frame - set VBLANK and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:
	lda #2
	sta VBLANK
	sta VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; display 3 VSYNC lines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	REPEAT 3
		sta WSYNC 
	REPEND
	lda #0
	sta VSYNC
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; display 37 VBLANK lines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	REPEAT 37
		sta WSYNC
	REPEND
	
	lda #0
	sta VBLANK
d
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; display 192 visible scanlines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ldx #192

Scanline:
	txa
	sec
	sbc PlayerYPos
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
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; output 30 VBLANK overscan lines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lda #2
	sta VBLANK
	REPEAT 30
		sta WSYNC
	REPEND
	LDA #0
	sta VBLANK

;; Decrease PlayerXPos
	
	dec PlayerYPos

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
