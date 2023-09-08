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
	
	;; Init frame

StartFrame:
	;; Pre Vblank Subroutines

	
	
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

	sta WSYNC
	sta HMCLR
	
	sec

DivideLoop:
	sbc #15
	bcs DivideLoop

	eor #7
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
	
        REPEAT 160
        sta WSYNC  ;160 empty scanlines
        REPEND

        ldy #17

DrawBitmap:
	lda P0Bitmap,Y
	sta GRP0      

	lda P0Color,Y  
	sta COLUP0    

	sta WSYNC      

	dey
	bne DrawBitmap 

	lda #0
	sta GRP0       

        
	;; VBLANK overscan

	lda #2
	sta VBLANK
	REPEAT 30
		sta WSYNC
	REPEND
	LDA #0
	sta VBLANK

	;; joystick inputs tests

CheckP0Up:
	lda #%00010000
	bit SWCHA
	bne CheckP0Down

	inc P0XPos
	
CheckP0Down:
	lda #%00100000
	bit SWCHA
	bne CheckP0Left

	dec P0XPos
	
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

	;; player numberarray
	org $FFE7
P0Bitmap:
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
