; Seraph's 2600
; 2023 Furigam 
; Designer: Harperbolic

; Original Game by SadSocket


	
	processor 6502	
	include "vcs.h"
	include "macro.h"

;===============================================================================
; C O N S T A N T S
;===============================================================================

; LFSR seed initial value 
RAND_SEED	= $c4

; Colors
BLACK		= $00
WHITE		= $0F
PURPLE		= $15
RED		= $04

; Y-axis
P0_HEIGHT	= 9	
P1_HEIGHT	= 9

;===============================================================================
; V A R I A B L E S
;===============================================================================
	
	seg.u var
	org $80

; X-axis
P0XPos	    	byte
P0YPos		byte
P1XPos		byte
P1YPos		byte
P0SpritePtr	word
P0ColorPtr	word
P1SpritePtr	word
P1ColorPtr	word

;===============================================================================
; R O M - I N I T
;===============================================================================
	

	seg   code
	org   $F000
Reset:
	CLEAN_START

	lda #10
	sta P0YPos
	lda 60
	sta P0XPos

	lda   #83
	sta   P1XPos
	lda   #53
	sta   P1YPos



	lda   #<P0Sprite
	sta   P0SpritePtr
	lda   #>P0Sprite
	sta   P0SpritePtr+1

	lda   #<P0Color
	sta   P0ColorPtr
	lda   #>P0Sprite
	sta   P0ColorPtr+1

	lda   #<P1Sprite
	sta   P1SpritePtr
	lda   #>P1Sprite
	sta   P1SpritePtr+1

	lda   #<P1Color
	sta   P1ColorPtr
	lda   #>P1Color
	sta   P1ColorPtr+1
	
;===============================================================================
; S T A R T - F R A M E
;===============================================================================

StartFrame:
	;; Pre Vblank Subroutines

	lda   P0YPos
	ldy   #0
	jsr   SetObjectXPos

	lda   P1YPos
	ldy   #1
	jsr   SetObjectXPos

	sta   WSYNC
	sta HMOVE

	;; VSYNC-VBLANK

	lda   #2
	sta   VBLANK
	sta   VSYNC
	sta   WSYNC
	sta   WSYNC
	sta   WSYNC

	lda   #0
	sta   VSYNC
	REPEAT 37
	sta WSYNC
	REPEND
	sta VBLANK
	
	;; Visible scanlines
VisibleLines:
	;; PF and BK settings
	lda   #$FF
	sta   COLUBK

	lda   #0
	sta   COLUPF

	lda   #%00000001
	sta   CTRLPF

	lda   #$F0
	sta   PF0
	lda   #$FC
	sta   PF1
	lda   #0
	sta   PF2
.ScanlineLoop:
.AreWeInsideP0:
	txa
	sec
	sbc   P0YPos
	cmp   P0_HEIGHT
	bcc   .DrawP0
	lda   #0
.DrawP0:
	tay
	lda   (P0SpritePtr),Y
	sta   WSYNC
	sta   GRP0
	lda   (P0ColorPtr),Y
	sta COLUP0
.AreWeInsideP1:
	tax
	sec
	sbc   P0YPos
	cmp   P0_HEIGHT
	bcc   .DrawP1
	lda   #0
.DrawP1:
	tay
	lda   (P1SpritePtr),Y
	sta   WSYNC
	sta   GRP1
	lda   (P1ColorPtr),Y
	sta   COLUP1

	dex
	bne   .ScanlineLoop

	;; overscan
	lda   #2
	sta   VBLANK
	REPEAT 30
		sta WSYNC
	REPEND
	lda #0
	sta VBLANK

	;; joystick inputs tests

CheckP0Up:
	lda #%00010000
	bit SWCHA
	bne CheckP0Down
	
CheckP0Down:
	lda #%00100000
	bit SWCHA
	bne CheckP0Left
	
CheckP0Left:
	lda #%01000000
	bit SWCHA
	bne CheckP0Right

	dec P0XPos
	
CheckP0Right:
	lda #%10000000
	bit SWCHA
	bne NullInput

	inc P0XPos
	
NullInput:
	
	;; New frame
	
	jmp StartFrame

;===============================================================================
; S U B R O U T I N E S
;===============================================================================
SetObjectXPos subroutine
	sta   WSYNC
	sec
.Div15Loop:
	sbc   #15
	bcs   .Div15Loop
	eor   #7
	asl
	asl
	asl
	asl
	sta   HMP0,Y
	sta   RESP0,Y
	rts
	
;===============================================================================
; L O O K U P - T A B L E S
;===============================================================================
P0Sprite:
	.byte #%01111110	;---00---
	.byte #%00111110	;---00---
	.byte #%00111100	;0-0000-0
	.byte #%00111100	;-000000-
	.byte #%00111100	;---00---
	.byte #%00011000	;--0000--
	.byte #%01111110	;--0000--
	.byte #%10111101	;--0000--
	.byte #%00011000	;--00000-
	.byte #%00011000	;-000000-
	.byte #%00010000

P1Sprite:
	.byte #%01000010
	.byte #%10011001
	.byte #%10011001
	.byte #%01100110
	.byte #%00111100
	.byte #%00100100
	.byte #%00011000
	.byte #%00100100
	.byte #%01111110
	
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

P1Color:
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
