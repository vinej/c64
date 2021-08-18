.const audio = $D400

hf: .byte 0
lf: .byte 0
dr: .byte 0

song: .byte 25,177,250,28,214,250
      .byte 25,177,250,28,214,250
      .byte 25,177,125,28,214,125
      .byte 32,94,750,25,177,250
      .byte 28,214,250,19,63,250
      .byte 19,63,250,19,63,250
      .byte 21,154,63,24,63,63
      .byte 25,177,250,24,63,125
      .byte 19,63,250,-1,-1,-1

playit:
    // volume max
    lda #$0F
    sta $d418

    // hf note
    lda #24
    sta $d401
    // lf note
    lda #177
    sta $d400 

    // play note
    lda #$11
    sta $d404

    rts
