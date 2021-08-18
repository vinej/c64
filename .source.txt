BasicUpstart2(mainProg)

my: *=$1000 "main"

#import "constant.asm"
#import "irq.asm"
#import "keyboard.asm"
#import "joystick.asm"
#import "io.asm"


trust: .byte 1
maxTrust: .byte 5

spaceVelocityX: .byte 0
spaceVelocityY: .byte 0
spaceGravityJump: .byte 25
spaceGravity: .byte 1
spaceIsJump: .byte 0
spaceIsJumpUp: .byte 0
spaceisJumpDown: .byte 0
spaceJumpdY: .byte 0

fireIsActivate: .byte 0
fireVelocityX: .byte 8
fireVelocityY: .byte 0
fireSpanMax: .byte 20
fireSpan: .byte 0

spriteON: .byte 1
rockVelocity: .byte 2

rockdX: .byte 1
rockdY: .byte 0

firedY: .byte 0

spriteMultiPlex: .byte  0
spriteIsMultiplex: .byte 0


// 16 sprite
// 1 and 2 player
// 3 and 4 fire
// 5 to 16 alien

// r = rayon
// F = force  M/A  
//a.X = F * Math.Sin(r);
//a.Y = F * Math.Cos(r);
//Then update your velocity:
// here dt always 1 (1/60) or (1/50)
//v.X = v.X + a.X * dt;
//v.Y = v.Y + a.Y * dt;
//Finally, update your new position:
//screenpos.X = screenpos.X + v.X * dt;
//screenpos.Y = screenpos.Y + v.Y * dt;
setTrust:
	// delta is always 1
	// the trust is 1 2 or 3
	// velocity = trust
	lda joy_fire
	cmp #1
	bne velo   
	// here fire is on
	clc
	lda trust
	adc #1
	sta trust
	// check for trust - maxTrust
	cmp maxTrust
	bne velo
	// max put it back to 1
	lda #1
	sta trust
velo:
	lda trust
	sta spaceVelocityX
	rts

.macro clearscreenMem(color) {
	lda color
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

myIRQM:
	saveAXY()
	clearIRQ()
	jsr main
	restoreAXY()
	rti       // Return From Interrupt, this will load into the Program Counter register the address
			  //;where the CPU was when the interrupt condition arised which will make the CPU continue
			  //;the code it was interrupted at also restores the status register of the CPU
// END

checkJump:
	// already jumping
	lda #1
	cmp spaceIsJump
	beq end

	lda joy_jump
	cmp #1
	bne end

	// set going up for now
	lda #1
	sta spaceIsJumpUp
	sta spaceIsJump
	lda #0
	sta spaceisJumpDown

	// activate going up
	lda #1
	sta spaceVelocityY

	lda #1
	sta spaceGravity

	lda #-1
	sta spaceJumpdY
	jmp end
nojump:
end:
    rts

checkFire:
    // is already active go end
	lda #1
	cmp fireIsActivate
	beq endf

	// if fire pressed
	lda #1
	cmp joy_fire
	bne endf

	// fire is pressed, activate fire
	lda #1
	sta fireIsActivate
	lda fireSpanMax
	sta fireSpan
	//; enable sprite fire
    lda #2
    ora $d015
	sta $d015

	//; set x and y position from player
    lda $d000
    sta $d002
	lda $d001
    sta $d003

	lda $d010 // check if bit 9 is on for the player
	and #1
	beq endf

	lda #2   // yes, set bit 9 on for fire
	ora $d010
	sta $d010
endf:
    rts

endFire:
	lda #1
	cmp fireIsActivate
	bne end2

	dec fireSpan
	bne stopEdge

	// hide fire
    lda #253
    and $d015
	sta $d015
	lda #0
	sta fireIsActivate
	jmp end2

stopEdge:
	lda #2 
	and $d010
	bne end2
	
	lda #2
	cmp $d002
	bcc end2
	// hide fire
    lda #253
    and $d015
	sta $d015
	lda #0
	sta fireIsActivate
	jmp end2
end2:
	rts
	
adjustJump:
	// is jumping
	lda #1
	cmp spaceIsJump
	bne end3

	// is going up
	lda #1
	cmp spaceIsJumpUp
	bne down

	// still up, but check max
	inc spaceGravity
	lda spaceGravityJump
	// if not max end
	cmp spaceGravity
	bne end3

	lda #0
	sta spaceIsJumpUp
	lda #1
	sta spaceisJumpDown
	lda #1
	sta spaceJumpdY
	dec spaceGravity
	dec spaceGravity

	jmp end3
down:
	//	is going down
	lda #1
	cmp spaceisJumpDown
	bne end3

	dec spaceGravity
	bne end3

	lda #0
	sta spaceIsJumpUp
	sta spaceisJumpDown
	sta spaceIsJump
	sta spaceVelocityY
	sta spaceJumpdY
	jmp end3
end3:

setSpaceVelocity:
	lda trust
	sta spaceVelocityX
	lda #1
	sta spaceVelocityY
	rts

.macro setSpriteMultiplexing() {
	lda #0
	cmp spriteIsMultiplex
	beq on

	// here is on
	inc spriteMultiPlex
	lda #12
	cmp spriteMultiPlex
	bne end

	dec $07f8
	dec $07f9
	lda #0
	sta spriteMultiPlex
	dec spriteIsMultiplex
	jmp end
on:
	inc spriteMultiPlex
	lda #12
	cmp spriteMultiPlex
	bne end
	inc $07f8
	inc $07f9
	lda #0
	sta spriteMultiPlex
	inc spriteIsMultiplex
	jmp end
end:
}

main:
/*
	readKeyboard() // kb_a, kb_x, kb_y

	lda kb_a
	cmp kb_nokey
	beq start

	lda kb_a
	sta screen
	ldx kb_x
	stx screen+1
	ldy kb_y
	sty screen+2
*/
start:
	setSpriteMultiplexing()
	readJoystick()
	//jsr checkJump
	//jsr adjustJump
	jsr endFire
	jsr checkFire
	jsr setSpaceVelocity
	moveSprite($d000, $d001, joy_dx, joy_dy, spaceVelocityX, spaceVelocityY, 1, 254)
	//moveSprite($d002, $d003, rockdX , rockdY, rockVelocity, fireVelocityY, 2, 253)
	moveSprite($d002, $d003, fireIsActivate , firedY, fireVelocityX, fireVelocityY, 2, 253)
end5:
	rts

mainProg: 	{
	clearscreen(3)
	// share color 1
	lda #3
	sta $d025

	//share color 2
	lda #4
	sta $d026

	// sprite color
	lda #5
	sta $d027
	sta $d028
	sta $d029

	// sprite player $80 and $81
	lda #$80
    sta $07f8

	// sprite fire $82 &83
	lda #$82
	sta $07f9

    //; enable sprite player
    lda #$1
    sta $d015

    //; set x and y position of player
    lda #$1
    sta $d000
	lda #$80
    sta $d001

	// clear bit 9 at the start of player, nuage and fire
	lda #254
	and $d010

	setIRQ(255,myIRQM)
	rts
}

// 1  1  
// 2  2
// 3  4
// 4  8
// 5  16
// 6  32


.macro moveSprite(adX, adY, dx, dy, velocityX, velocityY, spriteMaskOn, spriteMaskOff) {
  	// dt = 1/50 
	// speed = 50 pt / seconde
	//         1 pt par frame
	lda #-1
	cmp dx
	beq spriteLeft
	lda #1
	cmp dx
	beq spriteRight
	jmp movedy
spriteLeft:
	lda adX                      // go left
	sbc velocityX
	sta adX
	bcs movedy                   // if no carry, ok
	lda #spriteMaskOn            // here we went to 256 to 0 or more if bit 9 is already set
	and $d010
	bne Bit9Set                  // yes
	lda #spriteMaskOn            // no, set bit 9 of the sprite
	ora $d010
	sta $d010
	lda #64+22	                 // put the sprite at the right 
	sta adX
	jmp movedy
Bit9Set:
	lda #spriteMaskOff		     // unset the bit
	and $d010
	sta $d010
	lda #255			         // set the sprite at 255
	sta adX
	jmp movedy
spriteRight: 
	clc
	lda velocityX
	adc adX
	sta adX
	// if carry, means that we went from 256 to 1
	// we only need to set the bit9 to 1
	bcs right9Bit			      // we when > 255 if carry == 1

	// here the carry is not set, but if the bit9 is set, when we are at 64
	// we must unset the bit9 and put 1
	cmp #64+22                    // if adX less than a
	bcc movedy                    // yes, do nothing

	lda #spriteMaskOn             // if bit 9 set
	and $d010
	beq movedy                    // bit9 not set do nothing

	lda #spriteMaskOff			  // yes, unset the bit 9
	and $d010
	sta $d010
	lda #1			              // set the sprite at pos 1
	sta adX
	jmp movedy
right9Bit:
	lda #spriteMaskOn               // set the bit 9, adX is already at the right place
	ora $d010
	sta $d010
movedy:
	lda #-1
	cmp dy
	beq spriteUp
	lda #1
	cmp dy
	beq spriteDown
	jmp end
spriteDown:
	clc
	lda velocityY
	adc adY   // 23
	sta adY
	cmp #256-6   // adY < 256-8 : 248     
	bne end
	lda #23
	sta adY
	jmp end
spriteUp:
	lda adY
	sbc velocityY
	sta adY
	cmp #23      // adY < 28
	bne end    
	lda #256-6  // yes, but at athe bottom
	sta adY
end:
}


* = $2000 "sprite"
    .byte $FF,$FF,$FF // 1
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$00,$FF
    .byte $FF,$00,$FF // 10
    .byte $FF,$00,$FF
    .byte $FF,$00,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF // 20
    .byte $FF,$FF,$FF
    .byte $FF

    .byte $FF,$FF,$FF // 1
    .byte $FF,$FF,$FF 
    .byte $FF,$FF,$FF 
    .byte $FF,$FF,$FF 
    .byte $FF,$FF,$FF 
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF //10
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF
    .byte $FF,$FF,$FF // 20
    .byte $FF,$FF,$FF
    .byte $FF

	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$FF,$FF
	.byte $00,$FF,$FF
	.byte $00,$FF,$FF
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00

	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $FF,$00,$00
	.byte $FF,$FF,$00
	.byte $FF,$FF,$FF
	.byte $FF,$FF,$00
	.byte $FF,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00,$00,$00
	.byte $00





