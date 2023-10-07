/* Clock TRM 8.1.12.1 */
.equ CM_PER_GPIO1_CLKCTRL,	0x44e000AC 

/* GPIO TRM 25.4.1*/
.equ GPIO1,					0x4804C000
.equ GPIO_OE,				0x4804C134
.equ GPIO_SETDATAOUT,		0x4804C194
.equ GPIO_CLEARDATAOUT,		0x4804C190

/*Módulo de Controle */
.equ CNTMDL_BASE,       	0x44E10854

/*CONTROL MODULE*/
.equ CNTMDL_BASE,               0x44E10940
.equ GPIO2_RXD0,                0x990

//////////////////////////////////////////


.equ INTC_BASE, 0x48200000


/* CPSR */
.equ CPSR_I,   0x80
.equ CPSR_F,   0x40
.equ CPSR_IRQ, 0x12
.equ CPSR_USR, 0x10
.equ CPSR_FIQ, 0x11
.equ CPSR_SVC, 0x13
.equ CPSR_ABT, 0x17
.equ CPSR_UND, 0x1B
.equ CPSR_SYS, 0x1F

/* Vector table */
_vector_table:
    ldr   pc, _reset     /* reset - _start           */
    ldr   pc, _undf      /* undefined - _undf        */
    ldr   pc, _swi       /* SWI - _swi               */
    ldr   pc, _pabt      /* program abort - _pabt    */
    ldr   pc, _dabt      /* data abort - _dabt       */
    nop                  /* reserved                 */
    ldr   pc, _irq       /* IRQ - read the VIC       */
    ldr   pc, _fiq       /* FIQ - _fiq               */

_reset: .word _start
_undf:  .word 0x4030CE24 /* undefined               */
_swi:   .word 0x4030CE28 /* SWI                     */
_pabt:  .word 0x4030CE2C /* program abort           */
_dabt:  .word 0x4030CE30 /* data abort              */
         nop
_irq:   .word 0x4030CE38  /* IRQ                     */
_fiq:   .word 0x4030CE3C  /* FIQ                     */


/* Startup Code */
_start:

    /* Set V=0 in CP15 SCTRL register - for VBAR to point to vector */
    mrc    p15, 0, r0, c1, c0, 0    // Read CP15 SCTRL Register
    bic    r0, #(1 << 13)           // V = 0
    mcr    p15, 0, r0, c1, c0, 0    // Write CP15 SCTRL Register

    /* Set vector address in CP15 VBAR register */
    ldr     r0, =_vector_table
    mcr     p15, 0, r0, c12, c0, 0  //Set VBAR

    /* init */
    mrs r0, cpsr
    bic r0, r0, #0x1F            // clear mode bits
    orr r0, r0, #CPSR_SVC        // set SVC mode
    orr r0, r0, #(CPSR_F)        // disable FIQ
    and r0, r0, #~(CPSR_I)       // enable IRQ
    msr cpsr, r0


    /* IRQ Handler */
    ldr r0, =_irq
    ldr r1, =.irq_handler
    str r1, [r0]

   //////////////////////////////////////////
   ldr r1, =_swi
   ldr r0, =.swi_handler
   str r1, [r0]

   bl .gpio_setup
   //////////////////////////////////////////
    bl main

    b .
////////////////////////////////////
.main:
   swi 1
	b .main

////////////////////////////////////
.irq_handler:
        stmfd sp!, {r0-r3, r11, lr}
        mrs R11, SPSR

        bl IRQ_Handler 

        DSB 
        MSR SPSR, R11
        LDMFD SP!, {R0-R3, R11, LR}
        SUBS PC, LR, #4




.fiq_handler:
   b .fiq_handler      // infinite loop
.undefined_handler:
   b .undefined_handler      // infinite loop
.swi_handler:
   stmfd sp!, {r0-r3, r12, lr}   @ save registers
   mrs r12, cpsr                 @ save CPSR
   ldr r0 [lr, #-4]              @ get SWI instruction
   bic r0, r0, #0xff000000       @ mask SWI number
   cmp r0, #1                    @ compare with SWI number
   beq .onLed                    @ if SWI number is 1, turn on led
   b .offLed                     @ else, turn off led
   msr cpsr, r12                 @ restore CPSR
   ldmfd sp!, {r0-r3, r12, lr}   @ restore registers
   bx lr

.prefetch_handler:
   b .prefetch_handler      // infinite loop
.data_handler:
   b .data_handler      // infinite loop




/////////////////////////////////////////////////

.onLed:
   ldr r0, =GPIO_SETDATAOUT
   ldr r1, =(1<<21)
   str r1, [r0]
   bx lr

.offLed:
   ldr r0, =GPIO_CLEARDATAOUT
   ldr r1, =(1<<21)
   str r1, [r0]
   bx lr

.buttonToggle:
   ldr r0, =GPIO_DATAIN    @ GPIO_DATAIN
   ldr r1, [r0]            @ read GPIO_DATAIN
   and r1, r1, #(1<<21)    @ mask button
   cmp r1, #(1<<21)        @ compare with button
   beq .onLed              @ if button pressed, turn on led
   b .offLed               @ else, turn off led

.gpio_setup:
    /* set clock for GPIO1, TRM 8.1.12.1.31 */
    ldr r0, =0x44e00000
    add r0, #0xAC
    mov r2, #1
    lsl r1, r2, #1
    lsl r3, r2, #18
    orr r1, r1, r3
    str r1, [r0]

    ldr r0, =CNTMDL_BASE
    mov r1, #7
    str r1, [r0]

    /* set pin 21 for output, led USR0, TRM 25.3.4.3 */
    ldr r0, =GPIO_OE
    ldr r1, [r0]
    bic r1, r1, #(1<<21)
    str r1, [r0]
    
    bx lr
