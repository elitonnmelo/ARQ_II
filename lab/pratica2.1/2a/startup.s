.global _start

.data


.text
_start:
    @ Configuração dos registradores
    ldr r0, =vetor1      @ Carrega o endereço do primeiro vetor em r0
    ldr r1, =vetor2      @ Carrega o endereço do segundo vetor em r1
    ldr r2, =resultado   @ Carrega o endereço onde o resultado será armazenado em r2
    mov r3, #8           @ Configura r3 com o número de elementos (8)

loop:
    @ Carrega elementos dos vetores e soma
    ldr r4, [r0], #4     @ Carrega um elemento de vetor1 e incrementa o ponteiro
    ldr r5, [r1], #4     @ Carrega um elemento de vetor2 e incrementa o ponteiro
    add r6, r4, r5       @ Soma os elementos

    @ Armazena o resultado no vetor resultado
    str r6, [r2], #4     @ Armazena o resultado e incrementa o ponteiro de resultado

    @ Decrementa o contador e verifica se ainda há elementos para somar
    sub r3, r3, #1
	cmp r3, #0
    bne loop

@ Fim do programa
nop

vetor1: .word 1, 2, 3, 4, 5, 6, 7, 8

vetor2: .word 4, 7, 7, 5, 6, 6, 2, 1

resultado: .space 32  @ Espaço para armazenar o resultado (8 palavras de 4 bytes cada)

	
	