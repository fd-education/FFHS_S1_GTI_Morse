b main
.section .text

main: 

mov sp, #0x8000

@ base-adresses for gpio and timer
.equ BASE, 0x3F200000
.equ BASETIMER, 0x3F003004

@ offsets for gpio registers
.equ GPFSEL0, 0x00
.equ GPFSEL1, 0x04
.equ GPFSEL2, 0x08
.equ GPSET0, 0x1C
.equ GPCLR0, 0x28

@ bit-mask for pins 22, 23, 24 (SHcp, STcp, DS; output, 3x set/clr)
.equ SET_BIT6_9_12, 0x1240
.equ SET_BIT24, 0x1000000
.equ SET_BIT23, 0x800000
.equ SET_BIT22, 0x400000

@ bit-mask for pins 12, 13 (leds; output, 2x set/clr)
.equ SET_BIT6_9, 0x240    
.equ SET_BIT12, 0x1000
.equ SET_BIT13, 0x2000  

@ bit-mask to synchronize pins 6 and 12 (buzzer, green led)
.equ SET_BIT6_12, 0x1040

@ bit-masks for pin 6 (buzzer; output, set/clr)
.equ SET_BIT18, 0x40000
.equ SET_BIT6, 0x40

@----------------------------------------------
@ morse delay values 
@ - 1 UNIT = 1/8 SECOND = dot/space in letter
@ - 3 UNITS = dash/ space between letters
@ - 6 UNITS = space between words (1 UNIT used as a wait for the led)
@ - 7 UNITS = space between words
@----------------------------------------------
.equ ONE_UNIT, 0x1E848
.equ THREE_UNITS, 0x5B8D8
.equ SIX_UNITS, 0xB71B0
.equ SEVEN_UNITS, 0xD59F8


@ general delay values
.equ EIGHTH_SECOND, 0x1E848
.equ QUARTER_SECOND, 0x3D090
.equ HALF_SECOND, 0x7A120
.equ SECOND, 0xF4240

@ bit-masks for international morse-letters and segment activation codes
.equ A, 0x1800C0
.equ B, 0x10201B4  @ 1000000100000000110110100
.equ C, 0x12201E4
.equ D, 0x4200CC
.equ E, 0x4016C
.equ F, 0x120017C
.equ G, 0x4A01C0
.equ H, 0x10001FC
.equ I, 0x1001EC
.equ J, 0x1A8C1F8
.equ K, 0x62C0C0
.equ L, 0x108C1B4
.equ M, 0x1AC1E4
.equ N, 0x12C0CC
.equ O, 0x6AC16C
.equ P, 0x128C17C
.equ Q, 0x18AC1C0
.equ R, 0x48C1FC
.equ S, 0x40C1EC
.equ T, 0x7B5F8
.equ U, 0x61B4C0
.equ V, 0x181B5B4
.equ W, 0x69B5E4
.equ X, 0x183B4CC  @  1 1000 0011 1011 0100 1100 1100
.equ Y, 0x1A3B56C  
.equ Z, 0x10BB57C

@ name-masks for registers (better readability)
wait_time .req r0
base .req r1
offset .req r2
mask .req r3
delay .req r4
letter .req r5    
checksum .req r6

@ Setting up pin 6 (Buzzer)
ldr base, =BASE
ldr offset, =GPFSEL0
ldr mask, =SET_BIT18
str mask, [base, offset]

@ Setting up pins 12 & 13 (LED)
ldr offset, =GPFSEL1
ldr mask, =SET_BIT6_9
str mask, [base, offset]

@ Setting up pins 22, 23 & 24 (Segments)
ldr offset, =GPFSEL2
ldr mask, =SET_BIT6_9_12
str mask, [base, offset]

@------------------------------------------------------------
@ Choose your desired output...
@-----------------------------------------------------------
@b Own_Message
b Hello_World
@b SOS
@b Alphabet

@------------------------------------------------------------
@ Self chosen message
@ Keep the following schema:
@ ldr letter, =<LETTER>
@ bl Create_signal
@ Put 'bl Blank_space' after each complete word.
@ Put 'bl Clear_segment' after the message.
@ 'b END' always stops the output, meaning it has to be 
@the last command after your message and must not be avoided!
@------------------------------------------------------------

Own_Message:
   bl Clear_segment
   b END

SOS:
   bl Clear_segment
   ldr letter, =S
   bl Create_signal
   ldr letter, =O
   bl Create_signal
   ldr letter, =S
   bl Create_signal
   bl Blank_space
   b END

Hello_World:
   ldr letter, =H   
   bl Create_signal
   ldr letter, =E
   bl Create_signal
   ldr letter, =L
   bl Create_signal
   ldr letter, =L
   bl Create_signal
   ldr letter, =O
   bl Create_signal
   bl Blank_space
   ldr letter, =W
   bl Create_signal
   ldr letter, =O
   bl Create_signal
   ldr letter, =R
   bl Create_signal
   ldr letter, =L
   bl Create_signal
   ldr letter, =D
   bl Create_signal
   bl Blank_space
   b END

Alphabet:
  ldr letter, =A
  bl Create_signal
  ldr letter, =B
  bl Create_signal
  ldr letter, =C
  bl Create_signal
  ldr letter, =D
  bl Create_signal
  ldr letter, =E
  bl Create_signal
  ldr letter, =F
  bl Create_signal
  ldr letter, =G
  bl Create_signal
  ldr letter, =H
  bl Create_signal
  ldr letter, =I
  bl Create_signal
  ldr letter, =J
  bl Create_signal
  ldr letter, =K
  bl Create_signal
  ldr letter, =L
  bl Create_signal
  ldr letter, =M
  bl Create_signal
  ldr letter, =N
  bl Create_signal
  ldr letter, =O
  bl Create_signal
  ldr letter, =P
  bl Create_signal
  ldr letter, =Q
  bl Create_signal
  ldr letter, =R
  bl Create_signal
  ldr letter, =S
  bl Create_signal
  ldr letter, =T
  bl Create_signal
  ldr letter, =U
  bl Create_signal
  ldr letter, =V
  bl Create_signal
  ldr letter, =W
  bl Create_signal
  ldr letter, =X
  bl Create_signal
  ldr letter, =Y
  bl Create_signal
  ldr letter, =Z
  bl Create_signal
  bl Blank_space
  bl Clear_segment
  b END

@------------------------------------------------------------
@ main loop to create the output
@ first creates output on 7-segm-leds then the morse signal
@------------------------------------------------------------
Create_signal:
  push {lr}
  index .req r9
  tmp .req r10
  mov index, #0

  Determ_loop_Segment:
  add index, index, #1
  bl CheckLSB
  cmp tmp, #1
  bleq Luminate
  blne Skip

  cmp index, #16
  bne Determ_loop_Segment

  bl Display

  Determ_loop_Signal:
  bl CheckLSB

  cmp tmp, #1
  bleq Long_Signal

  cmp tmp, #1
  blne Short_Signal

  ldr wait_time, =EIGHTH_SECOND
  bl Wait

  bl CheckLSB
  cmp tmp, #1    
  bne Determ_loop_Signal

  bl Signal_end
  pop {pc}

CheckLSB:
  push {lr}
  ror letter, #1
  mvn tmp, letter
  add tmp, tmp, #1
  and tmp, letter, tmp
  pop {pc}

@------------------------------------------
@ Helper routines for the 7-segment-leds
@------------------------------------------
Luminate:
  push {lr}
  ldr mask, =SET_BIT24
  bl Pin_high
  bl Shift_pos
  bl Pin_low
  pop {pc}

Skip:
  push {lr}
  ldr mask, =SET_BIT24
  bl Pin_low
  bl Shift_pos
  pop {pc}

Clear_segment:
  push {lr}
  mov r9, #16

  Clearing_loop:
    bl Skip
    sub r9, r9, #1
    cmp r9, #0
    bne Clearing_loop

  bl Display
  pop {pc}

Display:
  push {lr}
  ldr mask, =SET_BIT23
  bl Pos_Edge
  pop {pc}

Shift_pos:
  push {lr}
  ldr mask, =SET_BIT22
  bl Pos_Edge
  pop {pc}

Pos_Edge:
  push {lr}
  bl Pin_high
  bl Pin_low
  pop {pc}

@-------------------------------------------
@ Helper routines for signal leds and buzzer
@-------------------------------------------
Long_Signal:
  push {lr}
  ldr wait_time, =THREE_UNITS
  bl Signal
  pop {pc} 

Short_Signal:
  push {lr}
  ldr wait_time, =ONE_UNIT
  bl Signal
  pop {pc}

Signal:
  push {lr}
  ldr mask, =SET_BIT6_12
  bl Pin_high
  bl Wait
  bl Pin_low
  ldr wait_time, =ONE_UNIT
  bl Wait
  pop {pc}

Blank_space:
  push {lr}
  bl Clear_segment
  bl Signal_end
  ldr wait_time, =SIX_UNITS
  bl Wait
  pop {pc}

Signal_end:
  push {lr}
  ldr mask, =SET_BIT13
  bl Pin_high
  ldr wait_time, =ONE_UNIT
  bl Wait
  bl Pin_low
  bl Wait
  pop {pc}

@-------------------------------------------
@ General helper routines
@-------------------------------------------
Pin_high:
  push {lr}
  ldr offset, =GPSET0
  str mask, [base, offset]
  pop {pc}

Pin_low:
  push {lr}
  ldr offset, =GPCLR0
  str mask, [base, offset]
  pop {pc}

Wait:
    push {lr}
    push {r1 - r5}
    inital_time .req r1
    passed_time .req r3
    time_regiser .req r4
    mov passed_time, #0
    ldr time_regiser, =BASETIMER
    ldr inital_time, [time_regiser]
    delay_loop:
        ldr passed_time, [time_regiser]
        sub passed_time, passed_time, inital_time
        cmp passed_time, wait_time
        bls delay_loop
    .unreq inital_time
    .unreq passed_time
    .unreq time_regiser
    pop {r1 - r5}
    pop {pc}

END:
