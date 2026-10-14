# Texturas da cerveja em tela cheia

Todas as imagens desta pasta são **procedurais e originais**, geradas por
`tools/beer_textures/generate.py` (numpy + Pillow, sementes fixas: o script
reproduz exatamente os mesmos arquivos). Nenhuma fotografia, captura de tela ou
asset de terceiros (inclusive de apps de referência) foi usado. Licença: a do
repositório.

| Arquivo | Tamanho | Conteúdo |
|---|---|---|
| `beer_liquid.jpg` | 512×512, opaco, repete nos dois eixos | corpo dourado com variações de profundidade, rastros verticais de gás e pontos de brilho em suspensão |
| `foam.png` | 1024×256 RGBA, repete na horizontal | espuma: microcélulas (Worley), bolhas maiores empacotadas perto do topo com brilho e sombra, transição translúcida e creme para a cerveja (y=0 lado do ar, y=255 lado da cerveja) |
| `condensation.png` | 512×512 RGBA, repete nos dois eixos | gotas e névoa no vidro: reflexo, sombra de refração, quase todo transparente |
| `bubble.png` | 96×64 RGBA | uma bolha de gás como pequena lente, em 64, 16 e 8 px (folha de sprites; as versões pequenas evitam serrilhado sem mipmaps) |

`tools/beer_textures/preview.py` reproduz em numpy a composição do shader
(`shaders/beer.frag`) com estas texturas para avaliar o material **fora** do
Flutter; a imagem gerada não é uma captura do app.
