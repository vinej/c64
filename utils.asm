maskSetBit:    .byte %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000
maskClearBit:  .byte %11111110, %11111101, %11111011, %11110111, %11101111, %11011111, %10111111, %01111111 

.macro setbit(tbit, adr)  {
    ldx #tbit
    lda maskSetBit,x
    ora adr
    sta adr
}

.macro clearbit(tbit, adr) {
    ldx #tbit
    lda maskClearBit,x
    and adr
    sta adr
}

.macro store(value, adr) {
    lda value 
    sta adr
}

.macro stored(value, adr) {
    lda #value 
    sta adr
}

.macro cmpeq(value, adr, dest) {
    lda #value
    cmp adr
    beq dest
}

.macro cmpne(value, adr, dest) {
    lda #value
    cmp adr
    bne dest
}

.macro andeq(value, adr, dest) {
    lda #value
    and adr
    beq dest
}

.macro andne(value, adr, dest) {
    lda #value
    and adr
    bne dest
}