.global _start

.data


.text
_start:
    @ configurando instruções  para ativar o modo thumb
    mrs r0, cpsr
    orr r0, 0x10
    msr cpsr, r0
    


    @ Configuração dos registradores
    ldr r0, =vetor1      @ Carrega o endereço do primeiro vetor em r0
    ldr r1, =vetor2      @ Carrega o endereço do segundo vetor em r1
    ldr r2, =resultado   @ Carrega o endereço onde o resultado será armazenado em r2
    mov r3, #10           @ Configura r3 com o número de elementos (8)

loop:
    @ Carrega elementos dos vetores e soma
    ldr r4, [r0]    @ Carrega um elemento de vetor1 e incrementa o ponteiro
    ldr r5, [r1]     @ Carrega um elemento de vetor2 e incrementa o ponteiro
    mov r6, r4
    add r6, r5       @ Soma os elementos

    @ Armazena o resultado no vetor resultado
    str r6, [r2]     @ Armazena o resultado e incrementa o ponteiro de resultado
    add r0, #4
    add r1, #4
    add r2, #4
    
    @ Decrementa o contador e verifica se ainda há elementos para somar
    sub r3, #1
	cmp r3, #0
    bne loop

@ Fim do programa
nop

vetor1: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

vetor2: .word 4, 5, 6, 7, 8, 9, 10, 11, 12, 13

resultado: .space 40  @ Espaço para armazenar o resultado (8 palavras de 4 bytes cada)

	
	