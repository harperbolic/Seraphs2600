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

	lda #%1111
	sta COLUPF
	
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
	REPEAT 10
		sta WSYNC
	REPEND

	ldy #0
LoopScoreboard:
	lda NumberBitmap,Y
	sta PF1
	sta WSYNC
	iny
	cpy #10			; compares y register with #10 (z-flag set)
	bne LoopScoreboard

	lda #0
	sta PF1
	REPEAT 50
		sta WSYNC
	REPEND
	
	ldy #0
LoopP0:	
	lda PlayerBitmap,Y
	sta GRP0
	sta WSYNC
	iny
	cpy P0Height
	bne LoopP0

	lda #0
	sta GRP0

	;; 10 P1 scanlines
	ldy #0
LoopP1:
	;; 
	lda PlayerBitmap,Y
	sta GRP1
	sta WSYNC
	iny
	cpy P0Height
	bne LoopP1

	lda #0
	sta GRP1

	;; render remaining scanlines (102)

	REPEAT 102
		sta WSYNC
	REPEND
	
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

	jmp StartFrame

	;; player numberarray
	org $FFE8
PlayerBitmap:			
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
	
	;; scoreboard number array
	org $FFF2
NumberBitmap:
	.byte #%00001110
	.byte #%00001110
	.byte #%00000010
	.byte #%00001110
	.byte #%00001110
	.byte #%00001000
	.byte #%00001000
	.byte #%00001000
	.byte #%00001110
	.byte #%00001110

	org $FFFC
	.word Reset
	.word Reset
