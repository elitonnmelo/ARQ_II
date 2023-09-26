.global _start

.data


.text
_start:
    @ Configuração dos registradores
    ldr r0, =vetor1      @ Carrega o endereço do vetor em r0
    ldr r1, =menor       @ Carrega o endereço onde o menor elemento será armazenado em r1
    ldr r2, =maior       @ Carrega o endereço onde o maior elemento será armazenado em r2

    bl main_loop         @ Chama a função main_loop

maiorElem:
    @pegar o maior elemento do vetor
    cmp r6, #0           @ Verifica se o contador é 0
    beq fim_loop        @ Se for, vai para a função menorElem
    sub r6, r6, #1       @ Decrementa o contador
    ldr r4, [r0], #4     @ Carrega um elemento de vetor1 e incrementa o ponteiro
    cmp r4, r2           @ Compara o elemento com o maior elemento do vetor
    bgt maiorElem        @ Se o elemento for maior, armazena ele como o maior elemento
    str r4, [r2]         @ Armazena o maior elemento
    b maiorElem          @ Volta para o início do loop


menorElem:
    
    @pegar o menor elemento do vetor
    cmp r6, #0           @ Verifica se o contador é 0
    beq fim_loop       @ Se for, vai para a função main_loop
    sub r6, r6, #1       @ Decrementa o contador
    ldr r4, [r0], #4     @ Carrega um elemento de vetor1 e incrementa o ponteiro
    cmp r4, r1           @ Compara o elemento com o menor elemento do vetor
    blt menorElem        @ Se o elemento for menor, armazena ele como o menor elemento
    str r4, [r1]         @ Armazena o menor elemento
    b menorElem          @ Volta para o início do loop

fim_loop:
    bx lr                @ Retorna para a função main_loop  

main_loop:
    @chama a funação maiorElem
    mov r6, #11           @ Configura r6 com o número de elementos (10) para o tamanho do vetor
    bl maiorElem         @ Chama a função maiorElem
    @chama a função menorElem
    mov r6, #11           @ Configura r6 com o número de elementos (10) para o tamanho do vetor
    bl menorElem         @ Chama a função menorElem
    b fim                @ Vai para o fim do programa


@ Fim do programa
fim:
    nop

vetor1:    .word 4, 7, 7, 5, 6, 15, 2, 10, 35, 22  @ Vetor de entrada
maior:     .word 0   @ Aloca espaço para uma variável inteira inicializada com 0
menor:     .word 0   @ Aloca espaço para uma variável inteira inicializada com 0

