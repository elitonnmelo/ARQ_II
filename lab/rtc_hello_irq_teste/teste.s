.equ GPIO1_BASE, 0x4804C000  @ Endereço base do GPIO1
.equ GPIO_SETDATAOUT, 0x194  @ Registrador para ligar o LED
.equ GPIO_CLEARDATAOUT, 0x190  @ Registrador para desligar o LED
.equ GPIO_DATAIN, 0x138  @ Registrador para ler o estado do botão
.equ LED_BIT, 21  @ Bit do LED no registrador de controle
.equ BUTTON_BIT, 22  @ Bit do botão no registrador de controle
.equ GPIO_OE,				0x134
/* UART0 */	
.equ UART0_BASE,			0x44E09000

/* Vetor de interrupção IRQ */
.equ IRQ_VECTOR, 0x4A320000

/* Definições para a interrupção de software (SWI) */
.equ SWI_VECTOR, 0x4A320010
.equ SWI_NUMBER, 0x0  @ Número da interrupção SWI


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


.global _start

.text

_start:
    /* Inicialize o GPIO1 para o LED */
    ldr r0, =GPIO1_BASE
    mov r1, #1 << LED_BIT
    str r1, [r0, #GPIO_OE]  @ Configura o pino como saída

    /* Inicialize o GPIO2 para o botão */
    ldr r0, =GPIO1_BASE
    mov r1, #1 << BUTTON_BIT
    bic r1, r1, r1  @ Configura o pino como entrada
    str r1, [r0, #GPIO_OE]

    /* Configure o vetor de interrupção de software (SWI) */
    //ldr r0, =SWI_VECTOR
    ldr r0, =_swi
	ldr r1, =swi_handler
    str r1, [r0]

    /* Configure o vetor de interrupção IRQ */
    //ldr r0, =IRQ_VECTOR
    ldr r0, =_irq
	ldr r1, =irq_handler
    str r1, [r0]

    /* Inicialize o contador */
    mov r2, #0  @ R2 será nosso contador

main:
    /* Verifique o estado do botão */
    ldr r0, =GPIO1_BASE
    ldr r1, [r0, #GPIO_DATAIN]
    tst r1, #1 << BUTTON_BIT  @ Verifique se o botão está pressionado
    beq button_not_pressed  @ Pule se o botão não estiver pressionado

    /* Se o botão estiver pressionado, ligue o LED */
    bl onLed
    b button_pressed

button_not_pressed:
    /* Se o botão não estiver pressionado, desligue o LED */
    bl offLed

button_pressed:
    /* Aumente o contador */
    add r2, r2, #1

    /* Verifique se o contador atingiu 10 */
    cmp r2, #10
    beq done  @ Se o contador for igual a 10, termine

    /* Aguarde um momento (ajuste esse valor para controlar a velocidade do contador) */
    mov r3, #1000  @ Valor de atraso ajustado
delay_loop:
    subs r3, r3, #1
    bne delay_loop

    /* Faça uma chamada SWI para imprimir o contador */
    mov r0, r2
    swi SWI_NUMBER

    /* Continue no loop principal */
    b main

done:
    /* Se chegarmos aqui, o contador atingiu 10, pare a execução */
    b .

/* Função para ligar o LED */
onLed:
    ldr r0, =GPIO1_BASE
    ldr r1, [r0, #GPIO_SETDATAOUT]
    orr r1, r1, #1 << LED_BIT
    str r1, [r0, #GPIO_SETDATAOUT]
    bx lr

/* Função para desligar o LED */
offLed:
    ldr r0, =GPIO1_BASE
    ldr r1, [r0, #GPIO_CLEARDATAOUT]
    orr r1, r1, #1 << LED_BIT
    str r1, [r0, #GPIO_CLEARDATAOUT]
    bx lr

/* Manipulador da interrupção de software (SWI) */
.swi_handler:
   stmfd sp!, {r0-r3, r12, lr}   @ Salva registros
   mrs r12, cpsr                 @ Salva CPSR
   ldr r0, [lr, #-4]             @ Obtém a instrução SWI
   bic r0, r0, #0xff000000       @ Máscara do número SWI
   cmp r0, #1                    @ Compara com o número SWI desejado
   beq .printMessage             @ Se o número SWI for 1, imprima a mensagem
   bne main                      @ Se o número SWI não for 1, volte para o programa principal
   msr cpsr, r12                 @ Restaura CPSR
   ldmfd sp!, {r0-r3, r12, lr}   @ Restaura registros
   bx lr 

.printInt:
   /* Coloque aqui o código para imprimir a mensagem no terminal */
   /* Por exemplo, use uma chamada de sistema ou uma função de impressão */
   stmfd sp!,{r0-r2,lr}
	adr r0,  #10
	mov r1, r0	

.print:
    ldrb r0,[r1],#1
    and r0, r0, #0xff
    cmp r0, #0
    beq .end_print
    bl .uart_putint
    b .print
    
.end_print:
    ldmfd sp!,{r0-r2,pc}
	bx lr

/********************************************************
UART0 PUTC (Default configuration)  
********************************************************/
/// uartputint
.uart_putint:
    stmfd sp!,{r1-r2,lr}
    ldr r1, =UART0_BASE

.uart_putint_aux:
    stmfd sp!,{r1-r2,lr}
    // pegar o numero começamdo em 0 e incrmentar o contador e depois imprimir ate chegar em 10
    ldr r2, [r1, #0x14]
    and r2, r2, #(1<<5)
    cmp r2, #0
    beq .uart_putint_aux
    
    b .uart_putint_aux
    strb r0, [r1]
    ldmfd sp!,{r1-r2,pc}



/// uartputc
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
UART0 GETC (Default configuration)  
********************************************************/
.uart_getc:
    stmfd sp!,{r1-r2,lr}
    ldr     r1, =UART0_BASE

.wait_rx_fifo:
    ldr r2, [r1, #0x14] 
    and r2, r2, #(1<<0)
    cmp r2, #0
    beq .wait_rx_fifo

    ldrb    r0, [r1]
    ldmfd sp!,{r1-r2,pc}



/* Manipulador da interrupção IRQ */
.irq_handler:
   stmfd sp!, {r0-r3, r11, lr}
   mrs r11, SPSR
   bl .IRQ_Handler 
   dsb 
   msr SPSR, r11
   ldmfd sp!, {r0-r3, r11, lr}
   subs pc, lr, #4