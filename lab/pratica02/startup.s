/* Clock TRM 8.1.12.1 */
.equ CM_PER_GPIO1_CLKCTRL,	0x44e000AC 

/* Watch Dog Timer */
.equ WDT_BASE, 				0x44E35000

/* UART0 */	
.equ UART0_BASE,			0x44E09000



/* gpio */
.equ GPIO_OE,				0x4804C134
.equ GPIO1_SETDATAOUT,		0x4804C194
.equ GPIO1_CLEARDATAOUT,	0x4804C190	

/*Módulo de Controle */
.equ CNTMDL_BASE,       	0x44E10854

/*CONTROL MODULE*/
.equ CNTMDL_BASE,               0x44E10940
.equ GPIO2_RXD0,                0x990


/* cpsr */
.equ CPSR_I,	0x80
.equ CPSR_F,	0x40
.equ CPSR_IRQ,	0x12
.equ CPSR_USR,	0x10
.equ CPSR_FIQ,	0x11
.equ CPSR_SVC,	0x13
.equ CPSR_ABT,	0x17
.equ CPSR_UND,	0x18
.equ CPSR_SYS,	0x1F

/* init */
_start:
	mrs r0, cpsr
	bic r0, r0, #0x1F @ clear mode bits
	orr r0, r0, #0x13 @ set SVC mode
	orr r0, r0, #0xC0 @ disable FIQ and IRQ
	msr cpsr, r0
	
	/* 8bl .cod_hexa */
	bl .gpio_setup
	bl .disable_wdt
	
.main_loop:
	bl .print_hexa
	bl .delay
	bl .contagem_led
	bl .delay
	b .main_loop
/*print a int
.print_int:
	stmfd sp!, {r0-r2, lr}
	
.print_i:	

.end_print_int:
	ldmfd sp!, {r0-r2, pc}
_end:*/




/******************************************************
contagem
********************************************************/
.contagem_led:
	stmfd sp!,{r0-r2,lr}
	mov r6, #0xf

    mov r1, #(1<<21) //carregando os valores do gpio  realizando um deslocamento dos gpio 21 ate  gpio 24
    mov r7, #1 //deslocamento do gpio para fazer a sequencia do hexa
XL:

	ldr r0, =GPIO1_SETDATAOUT
	str r1, [r0] 
	bl .delay 
	ldr r0, =GPIO1_CLEARDATAOUT 
	str r1, [r0] 

    add r1, r1, r7, LSL #21 //(deslocamento do gpio para fazer a sequencia do hexa )incremento do valor em hexa de 1 ate 15 em binario
	sub r6, r6, #1 //decremento do contador
	
	cmp r6, #0x0 //comparacao do contador com 0
	bne XL //se for diferente de 0, volta para o XL

	ldmfd sp!,{r0-r2,pc}
	bx lr


/*******************************************************
print_hexa
*******************************************************/

/********************************************************
func: .print
desc: Imprime uma string até o '\0'
uso: R0 -> Endereço da string
/********************************************************/

.print_hexa:
	stmfd sp!,{r0-r2,lr}
	adr r0, contagem
	mov r1, r0	

.print:

    ldrb r0,[r1],#1
    and r0, r0, #0xff
    cmp r0, #0
    beq .end_print
    bl .uart_putc
    b .print
    
.end_print:
    ldmfd sp!,{r0-r2,pc}
	bx lr
/********************************************************/

/********************************************************
func: .delay
desc: Gera um atraso de 1 segundo
********************************************************/
.delay:
	stmfd sp!,{r0-r2,lr}
	ldr r1, =0x0fffffff
.wait:
	subs r1, r1, #1
    cmp r1, #0
    bne .wait
	ldmfd sp!,{r0-r2,pc}
	bx lr
/******************************************************/

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


    /* set pin 21, 22, 23 and 24 for output, led USR0, TRM 25.3.4.3 */
    ldr r0, =GPIO_OE
    ldr r1, [r0]
    bic r1, r1, #(1<<21)
    bic r1, r1, #(1<<22)
    bic r1, r1, #(1<<23)
    bic r1, r1, #(1<<24)
    str r1, [r0]
    bx lr

/********************************************************
UART0 PUTC (Default configuration)  
********************************************************/
.uart_putc:
    stmfd sp!,{r1-r2,lr}
    ldr     r1, =UART0_BASE

.wait_tx_fifo_empty:
    ldr r2, [r1, #0x14] 
    and r2, r2, #(1<<5)
    cmp r2, #0
    beq .wait_tx_fifo_empty

    strb    r0, [r1]
    ldmfd sp!,{r1-r2,pc}

/********************************************************
  WDT disable sequence (see TRM 20.4.3.8):
    1- Write XXXX AAAAh in WDT_WSPR.
    2- Poll for posted write to complete using WDT_WWPS.W_PEND_WSPR. (bit 4)
    3- Write XXXX 5555h in WDT_WSPR.
    4- Poll for posted write to complete using WDT_WWPS.W_PEND_WSPR. (bit 4)
    
  Registers (see TRM 20.4.4.1):
    WDT_BASE -> 0x44E35000
    WDT_WSPR -> 0x44E35048
    WDT_WWPS -> 0x44E35034
********************************************************/
.disable_wdt: 
    /* TRM 20.4.3.8 */
    stmfd sp!,{r0-r1,lr}
    ldr r0, =WDT_BASE
    
    ldr r1, =0xAAAA
    str r1, [r0, #0x48]
    bl .poll_wdt_write

    ldr r1, =0x5555
    str r1, [r0, #0x48]
    bl .poll_wdt_write

    ldmfd sp!,{r0-r1,pc}

.poll_wdt_write:
    ldr r1, [r0, #0x34]
    and r1, r1, #(1<<4)
    cmp r1, #0
    bne .poll_wdt_write
    bx lr


	

contagem: .asciz "0123456789ABCDEF\n\r"
hello: .asciz "Hello World!\n\r"
prox_linha: .asciz "\n\r"