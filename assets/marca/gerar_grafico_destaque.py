"""Gera o gráfico de destaque 1024x500 da ficha da Google Play Store.

    python assets/marca/gerar_grafico_destaque.py [destino.png]

O Play recorta e sobrepõe elementos sobre esta imagem em alguns lugares da
loja, então o texto fica longe das bordas e a composição não depende de nenhum
canto específico sobreviver.
"""
import sys

from PIL import Image, ImageDraw, ImageFont

from gerar_icone import BG, NEC, marca

L, A = 1024, 500
SS = 3  # supersampling: texto e curvas ficam sem serrilha no downscale

FONTE_BOLD = 'C:/Windows/Fonts/segoeuib.ttf'
FONTE_REG = 'C:/Windows/Fonts/segoeui.ttf'

TINTA = (22, 33, 31)
MEIA_TINTA = (93, 107, 104)


def _maior_que_cabe(texto, caminho, largura, teto):
    """Maior corpo em que `texto` ainda cabe em `largura`.

    Medir em vez de arbitrar: "Estou gastando dentro do que planejei?" é bem
    mais longa que "Conta em Dia", e um tamanho fixo que sirva para uma
    estoura a outra — foi o que encostou o texto na borda na primeira versão.
    """
    for corpo in range(teto, 8, -1):
        f = ImageFont.truetype(caminho, corpo)
        if f.getbbox(texto)[2] <= largura:
            return f
    return ImageFont.truetype(caminho, 8)


def gerar(destino='assets/marca/grafico-destaque-1024x500.png'):
    im = Image.new('RGB', (L * SS, A * SS), BG)
    d = ImageDraw.Draw(im)

    # Faixa vertical sutil atrás da marca: dá peso ao lado esquerdo sem
    # competir com o texto.
    faixa = 340
    d.rectangle([0, 0, faixa * SS, A * SS], fill=(232, 242, 240))

    # A marca vem do mesmo gerador do ícone — se a geometria mudar lá, muda aqui.
    tam = 210 * SS
    m = marca(tam, com_fundo=False)
    im.paste(m, ((faixa * SS - tam) // 2, (A * SS - tam) // 2), m)

    # Margem generosa à direita: o Play recorta e sobrepõe elementos sobre esta
    # imagem em alguns pontos da loja.
    x = 400 * SS
    disponivel = (L - 400 - 56) * SS

    nome = _maior_que_cabe('Conta em Dia', FONTE_BOLD, disponivel, 78 * SS)
    l1 = 'Já paguei o que devia?'
    l2 = 'Estou gastando dentro do que planejei?'
    corpo = min(
        _maior_que_cabe(l1, FONTE_REG, disponivel, 32 * SS).size,
        _maior_que_cabe(l2, FONTE_REG, disponivel, 32 * SS).size,
    )
    linha = ImageFont.truetype(FONTE_REG, corpo)

    # Bloco de texto centralizado no eixo vertical, calculado a partir das
    # alturas reais em vez de posições fixas.
    h_nome = nome.getbbox('Conta em Dia')[3]
    h_linha = linha.getbbox(l1)[3]
    vao1, vao2 = int(26 * SS), int(12 * SS)
    total = h_nome + vao1 + h_linha + vao2 + h_linha
    y = (A * SS - total) // 2

    d.text((x, y), 'Conta em Dia', font=nome, fill=NEC)
    y += h_nome + vao1
    d.text((x, y), l1, font=linha, fill=TINTA)
    y += h_linha + vao2
    d.text((x, y), l2, font=linha, fill=MEIA_TINTA)

    return im.resize((L, A), Image.LANCZOS).save(destino)


if __name__ == '__main__':
    saida = sys.argv[1] if len(sys.argv) > 1 else \
        'assets/marca/grafico-destaque-1024x500.png'
    gerar(saida)
    print(f'gerado: {saida}')
