.segment "HEADER"
  .byte "NES"
  .byte $1A
  .byte $02 ; 2 * 16KB PRG ROM
  .byte $01 ; 1 * 8KB CHR ROM
  .byte %00000000 ; MAPPER AND MIRRORING
  .byte $00
  .byte $00
  .byte $00
  .byte $00
  .byte $00, $00, $00, $00, $00


.segment "ZEROPAGE"
.segment "STARTUP"


RESET:
  SEI ; DISABLE ALL INTERRUPTS
  CLD ; DISABLE DECIMAL MODE

  ; DISABLE SOUND IRQ
  LDX #$40
  STX $4017

  ; INITIALIZE STACK REGISTER
  LDX #$FF
  TXS

  INX ; #$FF + 1 => #$00

  ; ZERO OUT THE PPU REGISTERS
  STX $2000
  STX $2001

  STX $4010


:
  BIT $2002
  BPL :-


CLEARMEN:
  STA $0000, X ; $0000 => $00FF
  STA $0100, X ; $0100 => $01FF
  STA $0300, X ; $0300 => $03FF
  STA $0400, X ; $0400 => $04FF
  STA $0500, X ; $0500 => $05FF
  STA $0600, X ; $0600 => $06FF
  STA $0700, X ; $0700 => $07FF

  LDA #$FF
  STA $0200, X ; $0200 => $02FF
  LDA #$00

  INX
  BNE CLEARMEN

; WAIT FOR VBLANK
:
  BIT $2002
  BPL :-

  LDA #$02
  STA $4014
  NOP

  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006

  LDX #$00

LOADPALETTES:
  LDA PALETTEDATA, X
  STA $2007
  INX
  CPX #$20
  BNE LOADPALETTES

  LDX #$00


LOADSPRITES:
  LDA SPRITEDATA, X
  STA $0200, X
  INX 
  CPX #$20 ; PPU OAM
  BNE LOADSPRITES

; ENABLE INTERRUPTS
  CLI 

  LDA #%10010000
  STA $2000
  LDA #%00011110
  STA $2001


LOOP:
  JMP LOOP


NMI:
  LDA #$02
  STA $4014
  RTI ; RTS


PALETTEDATA:
  .byte $24,$29,$1A,$0F,$24,$36,$17,$0f,$24,$30,$21,$0f,$24,$27,$17,$0F  ; BACKGROUND PALETTE DATA
  .byte $FF,$30,$26,$05  ; SPRITE PALETTE DATA

SPRITEDATA:
  ;; HELLO
  .byte $30, $11, $00, $30
  .byte $30, $0E, $00, $3A
  .byte $30, $15, $00, $44
  .byte $30, $15, $00, $4E
  .byte $30, $18, $00, $58

  ;; NES
  .byte $40, $17, $00, $30
  .byte $40, $0E, $00, $3A
  .byte $40, $1C, $00, $44


.segment "VECTORS"
  .word NMI
  .word RESET


.segment "CHARS"  
  .incbin "sprites.chr"
