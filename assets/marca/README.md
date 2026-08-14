# Marca

Identidade visual do **Conta em Dia** / **Bills on Track**, derivada do que já
existe em `lib/core/theme/` — não é um sistema paralelo.

| Arquivo | O que é |
|---|---|
| `gerar_icone.py` | Gera o ícone em todas as densidades. Rode da raiz: `python assets/marca/gerar_icone.py` |
| `icone-512.png`, `icone-1024.png` | Para loja, README e onde PNG for exigido |
| `icone.svg` | Mesma marca em vetor, do mesmo gerador. Usada na capa do `identidade.html` |
| `identidade.html` | Paleta com as razões WCAG medidas, escala tipográfica, tokens de espaçamento e peças da interface. Abre direto no navegador |

## A marca

**Necessidade forma um C**; **Desejo** e **Investimento** dividem a boca ao meio.
O C vem da rosca 50-30-20 da aba Gráfico, e a Necessidade domina por ser o grupo
que consome a maior parte do mês real — e por ser a cor-semente do app.

**"Livre" não aparece.** O comentário em `enums.dart` é explícito: ele não é grupo
de classificação, é fatia calculada. Representá-lo com a mesma linguagem dos três
grupos seria imprecisão herdada do gráfico.

## Calibragem

Os parâmetros ficam no topo de `gerar_icone.py`, todos independentes:
`BOCA` (abertura do C), `GANHO` e `RECUO` (raios externos do C e das menores),
`FURO` (raio interno, comum às três), `VAO` (respiro) e `ARRED` (raio do canto).

## Quatro coisas que custaram iteração — não desfaça sem saber por quê

- **O raio interno é absoluto**, fração de `R` e não do raio de cada fatia. Como o
  C tem raio externo maior, calcular o furo por fatia produzia um degrau no buraco
  central — era o que fazia o desenho parecer torto.
- **A boca é centrada no eixo horizontal e dividida ao meio.** Divisão fora do eixo
  lê como desalinhamento, não como proporção.
- **O furo faz parte do polígono** (arco externo de ida, interno de volta), não é um
  círculo de fundo pintado por cima — esse truque quebra assim que os raios externos
  diferem entre fatias.

- **Os cantos são arredondados borrando a máscara e limiarizando em 128**, não
  desenhando um traço redondo por cima. O desfoque só desloca as quinas (numa reta
  o gradiente é simétrico e o limiar cai onde a borda estava); o traço por cima
  serrilhava a borda interna do C. Menos arredondamento deixa a forma um pouco mais
  cheia, porque a operação remove massa nas quinas.

Rotação depois de rasterizar foi testada e descartada: reamostra a imagem e destrói
a nitidez da silhueta, que é metade da força de um ícone.

## Ao mudar uma cor

Se alterar `grupo_visual.dart`, atualize as constantes no topo de `gerar_icone.py`
e **recalcule o contraste**: piso de 4,5:1 para texto e 3:1 para elemento gráfico
(RNF-05). Os valores atuais são 5,18:1 (Necessidade), 4,93:1 (Desejo) e 4,83:1
(Investimento) contra o fundo `#F7F9F9`.

As densidades instaladas ficam em `android/app/src/main/res/mipmap-*/`, junto do
`mipmap-anydpi-v26/ic_launcher.xml` (adaptativo, com camada `monochrome` para o
tema Material You).

## O que o gerador escreve

| Saída | Onde | Observação |
|---|---|---|
| `ic_launcher.png` | `mipmap-*` | Ícone legado, com fundo |
| `ic_launcher_foreground.png` | `mipmap-*` | Camada de frente do adaptativo, a 66% (o Android recorta até 1/3) |
| `ic_launcher_monochrome.png` | `mipmap-*` | Silhueta de UMA cor. O Material You descarta a cor e usa só o alfa — reaproveitar a camada colorida acopla as duas sem querer |
| `splash_marca[_escura].png` | `mipmap-*` | Marca do splash, sem fundo. `drawable-night-v21/` escolhe a escura |
| `icone.svg` | `assets/marca/` | Vetor |
| `Icon-App-*.png` (15) | `ios/.../AppIcon.appiconset` | Tamanhos lidos do próprio `Contents.json`. **RGB, sem alfa** — iOS recusa ícone com transparência, o inverso do adaptativo do Android |
| `LaunchImage[@2x,@3x].png` | `ios/.../LaunchImage.imageset` | Marca do launch screen, com transparência (o fundo vem do storyboard) |

**O Android não troca ícone de launcher por tema claro/escuro** — não existe
`mipmap-night`. O único caminho ciente de tema é a camada `monochrome`. O splash
é diferente: ali o fundo muda de verdade, e `values-night/colors.xml` define
`splash_background` como `#0E1514`, a superfície escura real do `ColorScheme`.

O SVG arredonda os cantos por `stroke-linejoin`, o PNG por borrão+limiar. Os dois
não casam com o mesmo valor, daí `ARRED_SVG = 3.5` — fator medido minimizando a
diferença de pixel entre os renders, não deduzido.
