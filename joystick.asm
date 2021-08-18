joy_up:     .byte 0
joy_down:   .byte 0
joy_left:   .byte 0
joy_right:  .byte 0
joy_button: .byte 0

joy_dx: .byte 0
joy_dy: .byte 0
joy_fire: .byte 0
joy_jump: .byte 0

.macro readJoystick2() {
    lda $dc00     //;read joystick port 2
    lsr           //;get switch bits
    ror joy_up    //;switch_history = switch_history/2 + 128*current_switch_state
    lsr           //;update the other switches' history the same way
    ror joy_down
    lsr
    ror joy_left
    lsr
    ror joy_right
    lsr
    ror joy_button
}

.macro readJoystick1() {
    lda $dc01     //;read joystick port 1
    lsr           //;get switch bits
    ror joy_up    //;switch_history = switch_history/2 + 128*current_switch_state
    lsr           //;update the other switches' history the same way
    ror joy_down
    lsr
    ror joy_left
    lsr
    ror joy_right
    lsr
    ror joy_button
}

.macro readJoystick() {
        lda #0
        sta joy_fire
        sta joy_jump
        ldy #0       // ; this routine reads and decodes the
        ldx #0       // ; joystick/firebutton input data in
        lda $dc00    // ; get input from port 2 only
        lsr          // ; the accumulator. this least significant
        bcs djr0     // ; 5 bits contain the switch closure
        dey          // ; information. if a switch is closed then it
djr0:   lsr           //   ; produces a zero bit. if a switch is open then
        bcs djr1     // ; it produces a one bit. The joystick dir-
        iny          // ; ections are right, left, forward, backward
djr1:   lsr          //   ; bit3=right, bit2=left, bit1=backward,
        bcs djr2     // ; bit0=forward and bit4=fire button.
        dex         //  ; at rts time dx and dy contain 2's compliment
djr2:   lsr         // ; direction numbers i.e. $ff=-1, $00=0, $01=1.
        bcs djr3    //  ; dx=1 (move right), dx=-1 (move left),
        inx          // ; dx=0 (no x change). dy=-1 (move up screen),
djr3:   lsr         //  ; dy=1 (move down screen), dy=0 (no y change).
        bcs nofire
        lda #1
        sta joy_fire
nofire:
        stx joy_dx      //  ; the forward joystick position corresponds
        sty joy_dy      //  ; to move up the screen and the backward
        tya
        cmp #-1
        bne end
        lda #1
        sta joy_jump
end:

}
 //       rts        //   ; position to move down screen.
                   //   ;
                  //    ; at rts time the carry flag contains the fire
                  //    ; button state. if c=1 then button not pressed.
                  //    ; if c=0 then pressed.