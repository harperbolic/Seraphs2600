	processor 6502

	include "vcs.h"
	include "macro.h"

	;; start unitialized variable segment at $80
	seg.u Variables
	org $80
P0Height ds 1			; one byte for P0Height
P1Height ds 1


	;; start ROM code segment
	seg code
	org $F000

Reset:
	CLEAN_START

	ldx #$80
	stx COLUBK

	lda #%1111
	sta COLUPF

	lda #10
	sta P0Height
	sta P1Height
	
	;; set TIA registers
	lda #$48
	sta COLUP0

	lda #$C6
	sta COLUP1

	ldy #2
	sty CTRLPF

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

	;; 192 visible scanlines
	REPEAT 10
		sta WSYNC
	REPEND

	;; 10 scoreboard number scanlines
	;; data from array
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

	;; 50 empty scanlines
	REPEAT 50
		sta WSYNC
	REPEND

	;; 10 P0 scanlines
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
	lda PlayerBitmap,Y
	sta GRP1
	sta WSYNC
	iny
	cpy P1Height
	bne LoopP1

	lda #0
	sta GRP1

	;; render remaining scanlines (102)

	REPEAT 102
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