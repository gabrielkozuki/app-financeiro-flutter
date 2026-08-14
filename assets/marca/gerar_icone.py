"""Gera o ícone do Conta em Dia em todas as densidades. Rode da raiz do projeto:
    python assets/marca/gerar_icone.py

A marca: Necessidade forma um C, Desejo e Investimento dividem a boca ao meio.
"Livre" não entra — `enums.dart` diz que ele não é grupo de classificação, é
fatia calculada, e representá-lo aqui seria imprecisão herdada do gráfico.
"""
import math
from PIL import Image, ImageDraw, ImageFilter

NEC = (15, 118, 110)   # Necessidade — também a cor-semente do app
DES = (140, 102, 28)   # Desejo
INV = (73, 121, 73)    # Investimento
BG  = (247, 249, 249)  # mesma superfície clara do tema

# Variantes para fundo escuro. As cores normais até passam no piso de 3:1 sobre
# #0E1514 (3,36 a 3,60), mas estas chegam a 6,4-7,7 — vale a diferença no splash.
NEC_E = (47, 170, 158)
DES_E = (201, 154, 63)
INV_E = (125, 181, 125)

SS = 8  # supersampling: cantos de setor serrilham muito mais que arcos

# Geometria da marca. Todos independentes entre si — dá para calibrar um sem
# mexer nos outros.
BOCA  = 130.0   # abertura do C, em graus, centrada no eixo horizontal
GANHO = 1.07    # raio externo do C, relativo ao raio base
RECUO = 0.93    # raio externo das duas fatias menores
FURO  = 0.50    # raio interno, ABSOLUTO — igual para as três (ver README)
VAO   = 9.0     # respiro entre as partes, em graus
ARRED = 0.030   # raio do canto, fração do raio base

# O SVG arredonda por `stroke-linejoin`, o PNG por borrão+limiar — o mesmo ARRED
# rende cantos muito diferentes nos dois. 3,5 é o fator que minimiza a diferença
# de pixel entre os dois renders (medido, não estimado).
ARRED_SVG = 3.5


def _contorno(c, re, ri, a0, a1, n=400):
    """Setor anelar: arco externo de ida, arco interno de volta. O furo faz
    parte da FORMA — pintá-lo por cima com um círculo cria degrau assim que os
    raios externos diferem entre fatias."""
    p = []
    for i in range(n + 1):
        a = math.radians(a0 + (a1 - a0) * i / n)
        p.append((c + re * math.cos(a), c + re * math.sin(a)))
    for i in range(n + 1):
        a = math.radians(a1 + (a0 - a1) * i / n)
        p.append((c + ri * math.cos(a), c + ri * math.sin(a)))
    return p


def _setor(im, c, T, re, ri, a0, a1, cor, k):
    """Arredonda os cantos borrando a máscara e limiarizando em 128.

    Funciona porque o desfoque afeta cada borda de forma diferente: numa reta
    longa o gradiente é simétrico e o limiar cai onde a borda já estava; numa
    quina há menos massa em volta, o gradiente cai antes e o limiar recua. Só
    as quinas se movem. Desenhar um traço arredondado POR CIMA da forma, que
    foi a primeira tentativa, serrilha a borda interna.
    """
    m = Image.new('L', (T, T), 0)
    ImageDraw.Draw(m).polygon(_contorno(c, re, ri, a0, a1), fill=255)
    if k > 0:
        m = m.filter(ImageFilter.GaussianBlur(k)).point(lambda v: 255 if v >= 128 else 0)
    im.paste(Image.new('RGBA', (T, T), cor + (255,)), (0, 0), m)


def marca(t, com_fundo=True, escala=1.0, escuro=False, mono=None):
    """`mono`, se informado, pinta as três partes com a MESMA cor — é o que a
    camada `monochrome` do ícone adaptativo espera (o sistema aplica o próprio
    tom nos themed icons do Material You; o que importa ali é a silhueta)."""
    """`escala` encolhe o desenho para a área segura do ícone adaptativo, que o
    Android recorta em até 1/3 do canvas."""
    T = t * SS
    im = Image.new('RGBA', (T, T), BG + (255,) if com_fundo else (0, 0, 0, 0))
    c = T / 2
    R = T * 0.335 * escala
    ri = R * FURO
    k = R * ARRED
    if mono:
        cores = (mono, mono, mono)
    elif escuro:
        cores = (NEC_E, DES_E, INV_E)
    else:
        cores = (NEC, DES, INV)
    _setor(im, c, T, R * GANHO, ri, BOCA / 2 + VAO / 2, 360 - BOCA / 2 - VAO / 2, cores[0], k)
    _setor(im, c, T, R * RECUO, ri, -BOCA / 2 + VAO / 2, -VAO / 2, cores[1], k)
    _setor(im, c, T, R * RECUO, ri, VAO / 2, BOCA / 2 - VAO / 2, cores[2], k)
    return im.resize((t, t), Image.LANCZOS)


def _caminho_svg(c, re, ri, a0, a1, k):
    """Mesmo setor, em vetor. Aqui o arredondamento vem de `stroke-linejoin`,
    não do borrão: o traço de largura `k` engorda a forma em k/2 para todo lado,
    então o caminho é desenhado ENCOLHIDO de k/2 para terminar no tamanho certo.

    Foi o traço-por-cima que serrilhou no raster; em vetor não há rasterização
    intermediária, o mesmo truque sai limpo.

    `k` já chega multiplicado por ARRED_SVG: o borrão gaussiano arredonda MUITO
    mais que o próprio sigma, então casar os dois é calibração, não fórmula.
    """
    re_, ri_ = re - k / 2, ri + k / 2
    d_out = math.degrees(math.asin(min(1, (k / 2) / re_)))
    d_in = math.degrees(math.asin(min(1, (k / 2) / ri_)))
    o0, o1 = a0 + d_out, a1 - d_out
    i0, i1 = a0 + d_in, a1 - d_in
    pt = lambda r, a: (c + r * math.cos(math.radians(a)),
                       c + r * math.sin(math.radians(a)))
    grande = 1 if (a1 - a0) > 180 else 0
    return ('M {:.2f} {:.2f} A {:.2f} {:.2f} 0 {} 1 {:.2f} {:.2f} '
            'L {:.2f} {:.2f} A {:.2f} {:.2f} 0 {} 0 {:.2f} {:.2f} Z').format(
        *pt(re_, o0), re_, re_, grande, *pt(re_, o1),
        *pt(ri_, i1), ri_, ri_, grande, *pt(ri_, i0))


def marca_svg(t=512, com_fundo=True, escuro=False):
    c = t / 2
    R = t * 0.335
    ri, k = R * FURO, R * ARRED * ARRED_SVG
    cores = (NEC_E, DES_E, INV_E) if escuro else (NEC, DES, INV)
    partes = [
        (R * GANHO, BOCA / 2 + VAO / 2, 360 - BOCA / 2 - VAO / 2, cores[0]),
        (R * RECUO, -BOCA / 2 + VAO / 2, -VAO / 2, cores[1]),
        (R * RECUO, VAO / 2, BOCA / 2 - VAO / 2, cores[2]),
    ]
    linhas = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {t} {t}" '
              f'role="img" aria-label="Ícone do Conta em Dia">']
    if com_fundo:
        linhas.append(f'<rect width="{t}" height="{t}" fill="#{BG[0]:02X}{BG[1]:02X}{BG[2]:02X}"/>')
    for re, a0, a1, cor in partes:
        h = '#{:02X}{:02X}{:02X}'.format(*cor)
        linhas.append(
            f'<path d="{_caminho_svg(c, re, ri, a0, a1, k)}" fill="{h}" '
            f'stroke="{h}" stroke-width="{k:.2f}" stroke-linejoin="round"/>')
    linhas.append('</svg>')
    return '\n'.join(linhas)


def gerar_ios():
    """Lê os tamanhos do próprio `Contents.json` em vez de repetir a lista aqui:
    o catálogo é a fonte da verdade e muda entre versões do Xcode.

    **Ícone de iOS não pode ter canal alfa** — o envio é recusado. É o oposto do
    adaptativo do Android, que exige transparência na camada de frente. Daí o
    `convert('RGB')` no fim, e não um `com_fundo` diferente.
    """
    import json
    base = 'ios/Runner/Assets.xcassets'
    cat = f'{base}/AppIcon.appiconset'
    with open(f'{cat}/Contents.json', encoding='utf-8') as f:
        imagens = json.load(f)['images']

    tamanhos = {}
    for i in imagens:
        px = round(float(i['size'].split('x')[0]) * int(i['scale'][0]))
        tamanhos[i['filename']] = px
    for nome, px in sorted(tamanhos.items(), key=lambda x: x[1]):
        marca(px).convert('RGB').save(f'{cat}/{nome}')

    # Launch screen: a marca sobre a cor de fundo do storyboard, então aqui SIM
    # com transparência. 1x = 128 pt, as mesmas do splash do Android.
    for sufixo, px in [('', 128), ('@2x', 256), ('@3x', 384)]:
        marca(px, com_fundo=False).save(
            f'{base}/LaunchImage.imageset/LaunchImage{sufixo}.png')
    return len(tamanhos)


if __name__ == '__main__':
    with open('assets/marca/icone.svg', 'w', encoding='utf-8') as f:
        f.write(marca_svg() + '\n')
    marca(1024).save('assets/marca/icone-1024.png')
    marca(512).save('assets/marca/icone-512.png')
    for pasta, px in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96),
                      ('xxhdpi', 144), ('xxxhdpi', 192)]:
        marca(px).save(f'android/app/src/main/res/mipmap-{pasta}/ic_launcher.png')
    for pasta, px in [('mdpi', 108), ('hdpi', 162), ('xhdpi', 216),
                      ('xxhdpi', 324), ('xxxhdpi', 432)]:
        marca(px, com_fundo=False, escala=0.66).save(
            f'android/app/src/main/res/mipmap-{pasta}/ic_launcher_foreground.png')
        # Themed icon (Material You): silhueta de UMA cor, o sistema tinge.
        marca(px, com_fundo=False, escala=0.66, mono=(0, 0, 0)).save(
            f'android/app/src/main/res/mipmap-{pasta}/ic_launcher_monochrome.png')

    # Marca do splash: sem fundo, para a layer-list centralizar sobre a cor do
    # tema. A variante escura usa as cores claras (ver NEC_E/DES_E/INV_E).
    for pasta, px in [('mdpi', 128), ('hdpi', 192), ('xhdpi', 256),
                      ('xxhdpi', 384), ('xxxhdpi', 512)]:
        marca(px, com_fundo=False).save(
            f'android/app/src/main/res/mipmap-{pasta}/splash_marca.png')
        marca(px, com_fundo=False, escuro=True).save(
            f'android/app/src/main/res/mipmap-{pasta}/splash_marca_escura.png')

    n = gerar_ios()
    print(f'ícone, monochrome e splash gerados em todas as densidades '
          f'(+{n} ícones de iOS e a LaunchImage)')
