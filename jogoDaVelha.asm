.data
tabuleiro:      .byte '1', '2', '3', '4', '5', '6', '7', '8', '9'  # Tabuleiro do jogo
jogador_atual:  .byte 'X'  # Jogador atual (X ou O)
mensagem_prompt: .asciiz "Jogador "  # Mensagem para solicitar a jogada
mensagem_cont:  .asciiz ", escolha uma posição (1-9): "  # Continuação da mensagem
mensagem_invalida: .asciiz "Movimento inválido. Tente novamente.\n"  # Mensagem de movimento inválido
mensagem_vitoria: .asciiz "Jogador "  # Prefixo da mensagem de vitória
mensagem_vitoria_fim: .asciiz " venceu!\n"  # Sufixo da mensagem de vitória
mensagem_empate: .asciiz "Empate!\n"  # Mensagem de empate
nova_linha:    .asciiz "\n"  # Nova linha
separador:     .asciiz "|"  # Separador do tabuleiro
linha:         .asciiz "-----\n"  # Linha horizontal do tabuleiro

.text
.globl main

main:
    jal loop_do_jogo  # Inicia o loop principal do jogo
    li $v0, 10  # Encerra o programa
    syscall

loop_do_jogo:
    jal imprimir_tabuleiro  # Imprime o tabuleiro
    jal obter_jogada  # Obtém a jogada do jogador atual
    jal verificar_vitoria  # Verifica se houve vitória
    beq $v0, 1, jogo_venceu  # Se houve vitória, vai para a função de vitória
    jal verificar_empate  # Verifica se houve empate
    beq $v0, 1, jogo_empatou  # Se houve empate, vai para a função de empate
    jal trocar_jogador  # Troca o jogador atual
    j loop_do_jogo  # Repete o loop

jogo_venceu:
    jal imprimir_tabuleiro  # Imprime o tabuleiro final
    la $a0, mensagem_vitoria  # Carrega o prefixo da mensagem de vitória
    li $v0, 4
    syscall
    lb $a0, jogador_atual  # Carrega o jogador atual
    li $v0, 11
    syscall
    la $a0, mensagem_vitoria_fim  # Carrega o sufixo da mensagem de vitória
    li $v0, 4
    syscall
    j sair  # Encerra o jogo

jogo_empatou:
    jal imprimir_tabuleiro  # Imprime o tabuleiro final
    la $a0, mensagem_empate  # Carrega a mensagem de empate
    li $v0, 4
    syscall

sair:
    li $v0, 10  # Encerra o programa
    syscall

imprimir_tabuleiro:
    li $t0, 0  # Inicializa o contador de linhas
loop_linha:
    li $t1, 0  # Inicializa o contador de colunas
loop_coluna:
    mul $t2, $t0, 3  # Calcula o índice da linha atual
    add $t2, $t2, $t1  # Adiciona o índice da coluna
    la $t3, tabuleiro  # Carrega o endereço base do tabuleiro
    add $t3, $t3, $t2  # Calcula o endereço do elemento
    lb $a0, 0($t3)  # Carrega o byte do endereço calculado
    li $v0, 11
    syscall

    beq $t1, 2, pular_separador  # Se for a última coluna, pula o separador
    la $a0, separador  # Carrega o separador
    li $v0, 4
    syscall

pular_separador:
    addi $t1, $t1, 1  # Incrementa o contador de colunas
    blt $t1, 3, loop_coluna  # Repete para as próximas colunas

    la $a0, nova_linha  # Carrega a nova linha
    li $v0, 4
    syscall

    beq $t0, 2, pular_linha  # Se for a última linha, pula a linha horizontal
    la $a0, linha  # Carrega a linha horizontal
    li $v0, 4
    syscall

pular_linha:
    addi $t0, $t0, 1  # Incrementa o contador de linhas
    blt $t0, 3, loop_linha  # Repete para as próximas linhas
    jr $ra  # Retorna

obter_jogada:
    la $a0, mensagem_prompt  # Carrega a mensagem de prompt
    li $v0, 4
    syscall
    lb $a0, jogador_atual  # Carrega o jogador atual
    li $v0, 11
    syscall
    la $a0, mensagem_cont  # Carrega a continuação da mensagem
    li $v0, 4
    syscall

    li $v0, 5  # Lê a jogada do jogador
    syscall
    move $t0, $v0

    blt $t0, 1, invalido  # Verifica se a jogada é inválida (menor que 1)
    bgt $t0, 9, invalido  # Verifica se a jogada é inválida (maior que 9)
    subi $t0, $t0, 1  # Ajusta o índice para o tabuleiro (0-8)

    la $t1, tabuleiro  # Carrega o endereço base do tabuleiro
    add $t1, $t1, $t0  # Calcula o endereço do elemento
    lb $t2, 0($t1)  # Carrega o byte do endereço calculado
    blt $t2, '1', invalido  # Verifica se a posição já foi ocupada
    bgt $t2, '9', invalido  # Verifica se a posição já foi ocupada

    lb $t3, jogador_atual  # Carrega o jogador atual
    sb $t3, 0($t1)  # Armazena a jogada no tabuleiro
    jr $ra  # Retorna

invalido:
    la $a0, mensagem_invalida  # Carrega a mensagem de movimento inválido
    li $v0, 4
    syscall
    j obter_jogada  # Repete a obtenção da jogada

verificar_vitoria:
    lb $t0, jogador_atual  # Carrega o jogador atual
    li $t1, 0

verificar_linhas:
    mul $t2, $t1, 3  # Calcula o índice da linha
    la $t3, tabuleiro  # Carrega o endereço base do tabuleiro
    add $t3, $t3, $t2  # Calcula o endereço do elemento
    lb $t4, 0($t3)  # Carrega o byte do endereço calculado
    addi $t3, $t3, 1
    lb $t5, 0($t3)
    addi $t3, $t3, 1
    lb $t6, 0($t3)
    bne $t4, $t0, proxima_linha  # Verifica se há vitória na linha
    bne $t5, $t0, proxima_linha
    bne $t6, $t0, proxima_linha
    li $v0, 1  # Indica vitória
    jr $ra

proxima_linha:
    addi $t1, $t1, 1  # Incrementa o contador de linhas
    blt $t1, 3, verificar_linhas  # Repete para as próximas linhas

    li $t1, 0

verificar_colunas:
    move $t2, $t1  # Move o índice da coluna
    la $t3, tabuleiro  # Carrega o endereço base do tabuleiro
    add $t3, $t3, $t2  # Calcula o endereço do elemento
    lb $t4, 0($t3)  # Carrega o byte do endereço calculado
    addi $t3, $t3, 3
    lb $t5, 0($t3)
    addi $t3, $t3, 3
    lb $t6, 0($t3)
    bne $t4, $t0, proxima_coluna  # Verifica se há vitória na coluna
    bne $t5, $t0, proxima_coluna
    bne $t6, $t0, proxima_coluna
    li $v0, 1  # Indica vitória
    jr $ra

proxima_coluna:
    addi $t1, $t1, 1  # Incrementa o contador de colunas
    blt $t1, 3, verificar_colunas  # Repete para as próximas colunas

verificar_diagonais:
    la $t3, tabuleiro  # Carrega o endereço base do tabuleiro
    lb $t4, 0($t3)  # Carrega o byte do endereço calculado
    addi $t3, $t3, 4
    lb $t5, 0($t3)
    addi $t3, $t3, 4
    lb $t6, 0($t3)
    bne $t4, $t0, verificar_segunda_diagonal  # Verifica a primeira diagonal
    bne $t5, $t0, verificar_segunda_diagonal
    bne $t6, $t0, verificar_segunda_diagonal
    li $v0, 1  # Indica vitória
    jr $ra

verificar_segunda_diagonal:
    la $t3, tabuleiro  # Carrega o endereço base do tabuleiro
    addi $t3, $t3, 2  # Calcula o endereço do elemento
    lb $t4, 0($t3)  # Carrega o byte do endereço calculado
    addi $t3, $t3, 2
    lb $t5, 0($t3)
    addi $t3, $t3, 2
    lb $t6, 0($t3)
    bne $t4, $t0, sem_vitoria  # Verifica a segunda diagonal
    bne $t5, $t0, sem_vitoria
    bne $t6, $t0, sem_vitoria
    li $v0, 1  # Indica vitória
    jr $ra

sem_vitoria:
    li $v0, 0  # Indica que não houve vitória
    jr $ra

verificar_empate:
    li $t0, 0
loop_empate:
    la $t1, tabuleiro  # Carrega o endereço base do tabuleiro
    add $t1, $t1, $t0  # Calcula o endereço do elemento
    lb $t2, 0($t1)  # Carrega o byte do endereço calculado
    blt $t2, '1', nao_digito  # Verifica se a posição está vazia
    bgt $t2, '9', nao_digito
    li $v0, 0  # Indica que não houve empate
    jr $ra
nao_digito:
    addi $t0, $t0, 1  # Incrementa o contador
    blt $t0, 9, loop_empate  # Repete para as próximas posições
    li $v0, 1  # Indica empate
    jr $ra

trocar_jogador:
    lb $t0, jogador_atual  # Carrega o jogador atual
    beq $t0, 'X', definir_O  # Se for X, troca para O
    li $t0, 'X'  # Caso contrário, troca para X
    j troca_concluida
definir_O:
    li $t0, 'O'
troca_concluida:
    sb $t0, jogador_atual  # Armazena o novo jogador
    jr $ra  # Retorna


