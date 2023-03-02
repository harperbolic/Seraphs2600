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
P0Height equ 10
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

	lda #9
	sta P0Height

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sets VBLANK and VSYNC
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

	sta WSYNC
	sta GRP0

	lda P0Color,Y

	sta COLUP0

	dex
	bne Scanline
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; output 30 VBLANK overscan lines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Overscan:
	lda #2
	sta VBLANK
	REPEAT 30
		sta WSYNC
	REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; decremente Y-coord each frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	dec PlayerYPos

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; next frame loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	jmp StartFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; bitmaps lookup table
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0Bitmap:			
	.byte #%00010000	;---0----
	.byte #%00011000	;---00---
	.byte #%00111100	;0-0000-0
	.byte #%01111110	;-000000-
	.byte #%00011000	;---00---
	.byte #%00111100	;--0000--
	.byte #%00111100	;--0000--
	.byte #%00111100	;--0000--
	.byte #%00111110	;--00000-
	.byte #%01111110	;-000000-

P0Color:
	.byte #$06
	.byte #$06
	.byte #$06
	.byte #$06
	.byte #$06
	.byte #$06
	.byte #$06
	.byte #$06
	.byte #$06
	.byte #$06

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; complete ROM size
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	org $FFFC
	.word Reset
	.word Reset
