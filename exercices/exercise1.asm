	processor 6502
	seg Code
	org $F000
	
Start:
	lda #$82
	ldx #82
	ldy $82

	org $FFFC
	.word Start
	.word Start
