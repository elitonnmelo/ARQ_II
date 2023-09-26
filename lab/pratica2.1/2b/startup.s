.global _start

.data


.text
_start:
    @ Configuração dos registradores
    ldr r0, =vetor1      @ Carrega o endereço do vetor em r0
    ldr r1, =menor       @ Carrega o endereço onde o menor elemento será armazenado em r1
    ldr r2, =maior       @ Carrega o endereço onde o maior elemento será armazenado em r2
    ldr r3, =resultado   @ Carrega o endereço onde o resultado será armazenado em r1
    mov r6, #9           @ Configura r6 com o número de elementos (8) para o tamanho do vetor
    mov r7, #9           @ Configura r7 com o número de elementos (8) para o tamanho do vetor

    bl main_loop         @ Chama a função main_loop

maiorElem:
    @pegar o maior elemento do vetor
    cmp r6, #0           @ Verifica se o contador é 0

    beq menorElem        @ Se for, vai para a função menorElem
    sub r6, r6, #1       @ Decrementa o contador
    ldr r4, [r0], #4     @ Carrega um elemento de vetor1 e incrementa o ponteiro
    cmp r4, r2           @ Compara o elemento com o maior elemento do vetor
    bgt maiorElem        @ Se o elemento for maior, armazena ele como o maior elemento
    str r4, [r2]         @ Armazena o maior elemento
    b maiorElem          @ Volta para o início do loop


menorElem:
    
    @pegar o menor elemento do vetor
    cmp r7, #0           @ Verifica se o contador é 0
    beq fim_loop       @ Se for, vai para a função main_loop
    sub r7, r7, #1       @ Decrementa o contador
    ldr r4, [r0], #4     @ Carrega um elemento de vetor1 e incrementa o ponteiro
    cmp r4, r1           @ Compara o elemento com o menor elemento do vetor
    blt menorElem        @ Se o elemento for menor, armazena ele como o menor elemento
    str r4, [r1]         @ Armazena o menor elemento
    b menorElem          @ Volta para o início do loop

fim_loop:
    bx lr                @ Retorna para a função main_loop  

main_loop:
    @chama a funação maiorElem
    bl maiorElem         @ Chama a função maiorElem
    ldr r4, [r1]         @ Carrega o maior elemento
    ldr r5, [r2]         @ Carrega o menor elemento
    add r4, r4, r5       @ Soma o maior e o menor elemento
    str r4, [r3]         @ Armazena o resultado no endereço de resultado
    b fim                @ Vai para o fim do programa


@ Fim do programa
fim:
    nop

vetor1: .word 4, 7, 7, 5, 6, 15, 2, 1  @ Vetor de entrada
maior:     .word 0   @ Aloca espaço para uma variável inteira inicializada com 0
menor:     .word 0   @ Aloca espaço para uma variável inteira inicializada com 0
resultado:   .word 0    @ Aloca espaço para uma variável inteira inicializada com 0