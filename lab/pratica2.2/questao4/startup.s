.global _start

.data
dias_por_mes: .word 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31  @ Dias por mês em um ano não bissexto

dias_por_mes_bissexto: .word 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31  @ Dias por mês em um ano bissexto
.text
_start:
    @ Defina o valor de "n" nos registradores (exemplo: n = 32)
    ldr r0, =60  @ Valor de "n"

    @ Configure o ano de referência (ex: y = 2023) 
    ldr r11, =2022

    @ Inicialize os registradores para o cálculo
    mov r9, #0  @ r9 para armazenar o dia
    mov r10, #0  @ r10 para armazenar o mês e r11 para armazenar o ano

    @ Verifica se o ano é bissexto
    and r3, r11, #3 @ r3 = r11 & 3 (resto da divisão por 4)
	cmp r3, #0  @ Se o resto for igual a 0, é bissexto
    bne nao_bissexto @ Se o resto for diferente de 0, não é bissexto
    b bissexto  @ Se o resto for igual a 0, é bissexto

    @ Se o ano não for bissexto, carregue o array com a quantidade de dias por mês em um ano
    nao_bissexto:
        ldr r1, =dias_por_mes
    @ Loop para calcular o dia e o mês de um ano nao bissexto
    nao_bissexto_loop:

        @ Carrega a quantidade de dias do mês atual
        ldr r2, [r1], #4

        @ Verifica se "n" é menor ou igual ao número de dias do mês atual
        cmp r0, r2
        bls found_date  @ Se for menor ou igual, encontramos o mês

        @ Subtrai o número de dias do mês atual de "n"
        sub r0, r0, r2

        @ Incrementa o mês
        add r10, r10, #1

        @ Vai para o próximo mês
        b nao_bissexto_loop

    @ Se o ano for bissexto, carregue o array com a quantidade de dias por mês em um ano
    bissexto:
        ldr r1, =dias_por_mes_bissexto
    @ Loop para calcular o dia e o mês de um ano bissexto
    bissexto_loop:

        @ Carrega a quantidade de dias do mês atual
        ldr r2, [r1], #4

        @ Verifica se "n" é menor ou igual ao número de dias do mês atual
        cmp r0, r2
        //bls found_date  @ Se for menor ou igual, encontramos o mês
        ble found_date  @ Se for menor ou igual, encontramos o mês

        @ Subtrai o número de dias do mês atual de "n"
        sub r0, r0, r2

        @ Incrementa o mês
        add r10, r10, #1

        @ Vai para o próximo mês
        b bissexto_loop

    found_date:
        @ O valor em "r0" é o dia
        mov r9, r0

    	@ Adiciona 1 ao mês (para torná-lo base 1)
    	add r10, r10, #1


