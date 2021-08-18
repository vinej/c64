hello:
.text "hello world"
.byte 0

second: .byte 0

lineinput: .fill 255,0

.macro cursorxy(x,y) {
	ldx #x
	ldy #y
	clc
	jsr PLOT
}

.macro clearscreen(color) {
	lda #color
	sta BORDER_COLOR
	sta BACKGROUP_COLOR1
	ldx #0
	lda #SPACE
loop:  
	sta screen,x
	sta screen + $100,x
	sta screen + $200,x
	sta screen + $300,x
	dex
	bne loop
}

// put a string at the current cursor position
.macro print(str) {
	ldx #$0
loop:
	lda str,X
	beq exit
	jsr CHROUT
	inx
	beq exit   // if x roll to zero, overload, probably missing 0 end of string
	jmp loop
exit:
}


// print a string at x,y on the screen
.macro printxy(x,y,str) {
	cursorxy(x,y)
	print(str)
}

// input a string and put the resust at the dest
.macro inputxy(x,y,dest) {
	cursorxy(x,y)
	ldy #0
RD:
	jsr CHRIN

	sta lineinput,y // save char

	cmp #13  // return put 0 and exit
	beq putzero

	iny             // next char
	jsr RD          // read input

putzero:
	lda #0
	sta lineinput,y
	jsr exit

exit:
}
