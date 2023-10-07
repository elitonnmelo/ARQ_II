.global _start

.data
dias_por_mes:
    .word 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31  @ Dias por mês em um ano não bissexto

.text
_start:
    @ Defina o valor de "n" nos registradores (exemplo: n = 32)
    ldr r0, =60  @ Valor de "n"

    @ Configure o ano de referência (2023) 
    mov r11, #23

    @ Inicialize os registradores para o cálculo
    mov r9, #0  @ r9 para armazenar o dia
    mov r10, #0  @ r10 para armazenar o mês

    @ Endereço do array com a quantidade de dias por mês
    ldr r1, =dias_por_mes

    @ Loop para calcular o dia e o mês
    loop:
        @ Carrega a quantidade de dias do mês atual
        ldr r2, [r1], #4

        @ Verifica se "n" é menor ou igual ao número de dias do mês atual
        cmp r0, r2
        ble found_date  @ Se for menor ou igual, encontramos o mês

        @ Subtrai o número de dias do mês atual de "n"
        sub r0, r0, r2

        @ Incrementa o mês
        add r10, r10, #1

        @ Vai para o próximo mês
        b loop

    found_date:
        @ O valor em "r0" é o dia
        mov r9, r0

    	@ Adiciona 1 ao mês (para torná-lo base 1)
    	add r10, r10, #1


