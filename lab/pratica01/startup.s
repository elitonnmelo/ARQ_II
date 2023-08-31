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

/* init */
_start:
    mrs r0, cpsr
    bic r0, r0, #0x1F @ clear mode bits
    orr r0, r0, #0x13 @ set SVC mode
    orr r0, r0, #0xC0 @ disable FIQ and IRQ
    msr cpsr, r0
	
	bl .gpio_setup
/***************************************/
.main_loop:	

    ldr r0, =GPIO_CLEARDATAOUT
    ldr r1, =(1<<21)
    str r1, [r0]
	bl .delay

    ldr r0, =GPIO_SETDATAOUT
    ldr r1, =(1<<21)
    str r1, [r0]
    bl .delay
	/* logical 1 turns on the led, TRM 25.3.4.2.2.2 */
	
    
    
	b .main_loop
/***************************************/

.delay:
	ldr r1, =0xffffffff
.wait:
	sub r1, r1, #1
    cmp r1, #0
    bne .wait
/***************************************/
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




