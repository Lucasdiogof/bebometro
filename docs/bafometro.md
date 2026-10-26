# Bafômetro: regra do medidor recreativo

Brincadeira dentro da Resenha. Não mede nada do corpo, não mostra unidade, número, faixa nomeada, veredito nem fala de
dirigir. Nada é gravado: o microfone só entrega a intensidade do som (processada no aparelho, descartada, liberada ao
sair ou ir para segundo plano). Sem microfone, "Segurar para brincar".

## Quem aparece
Participantes do rolê em andamento; sem rolê em andamento, os do último rolê não excluído (`lib/games/data/bafo_roster.dart`).
Uma pessoa: já vem selecionada. Várias: escolhe-se o nome. Sem rolê ou sem participantes: estado simples pedindo para
iniciar um rolê.

## O sopro
Cerca de 1 segundo de som acima de um limiar baixo (0,25) enche a barra (`BreathToy`). A força e a duração **não** mudam o
resultado: só revelam o medidor.

## O índice visual (a única regra)
`nível = n / (n + 4)`, com `n` = pedidos **individuais com álcool** da pessoa naquele rolê (`PartyMeter`).

- Pedidos compartilhados não entram: ninguém disse quanto cada um bebeu, então não viram doses inteiras.
- Pedidos sem álcool, comida e extras não entram.
- A curva só sobe com mais pedidos e nunca chega a 1. Sem limiares, faixas, unidades ou fórmula fisiológica.
- Só lê registros: não altera pedido, estatística nem pagamento, e é independente de qualquer dado financeiro.

A tela mostra o nome da pessoa, o medidor e "Simulação" pequeno junto ao resultado.
