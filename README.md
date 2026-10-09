# Driver Para Linux OIA-8386

Driver CUPS para a impressora térmica de etiquetas **OIA-8386** (USB, 203 dpi, linguagem **TSPL**) no Linux. Com ele a impressora aparece como uma impressora comum do sistema e imprime PDFs e qualquer coisa que o CUPS consiga imprimir.

Testado no Nobara (Fedora) com CUPS 2.4. A impressora se identifica por USB como `0416:5011` (Winbond), `MFG:LABEL; MDL:-9X20`.

## Como funciona

A OIA-8386 não entende PostScript nem PDF, só comandos TSPL. O driver faz a ponte:

```
PDF/app → CUPS → Ghostscript (raster) → rastertotspl → TSPL → USB → impressora
```

| Arquivo | Função |
|---|---|
| `rastertotspl` | Filtro CUPS em Python 3 (sem dependências externas). Lê o raster do CUPS (v2/v3, com ou sem compressão), converte a página em bitmap 1 bit e envia como comando TSPL `BITMAP`, junto com `SIZE`, `GAP`, `DENSITY`, `SPEED` etc. |
| `OIA-8386.ppd` | Descrição da impressora para o CUPS: tamanhos de etiqueta, resolução e opções de impressão. Aponta para o filtro `rastertotspl`. |
| `instalar.sh` | Copia o filtro e o PPD para o CUPS, detecta a impressora USB e cria a fila `OIA-8386` como padrão. |
| `desinstalar.sh` | Remove a fila, o filtro e o PPD. |
| `teste-etiqueta.pdf` | Etiqueta de teste 100x150 mm. |

## Requisitos

- CUPS em execução (`systemctl status cups`)
- Python 3 em `/usr/bin/python3`
- Ghostscript (normalmente já vem com o CUPS) para imprimir PDFs
- Impressora ligada e conectada por USB

## Instalação

```bash
git clone https://github.com/reinaldovcaetano/OIA-8386-linux.git
cd OIA-8386-linux
sudo ./instalar.sh
```

O script procura um dispositivo `usb://` e usa o primeiro que parecer uma impressora de etiquetas. Se não achar nenhum, cai em `file:/dev/usb/lp0`. Para ver o que foi usado: `lpstat -v`.

## Uso

Imprimir o teste:

```bash
lp -d OIA-8386 -o PageSize=w100h150 -o fit-to-page teste-etiqueta.pdf
```

Imprimir qualquer PDF em outro tamanho (por exemplo 50x30 mm):

```bash
lp -d OIA-8386 -o PageSize=w50h30 -o fit-to-page etiqueta.pdf
```

A opção `fit-to-page` ajusta o conteúdo ao tamanho da etiqueta. O `PageSize` precisa corresponder à etiqueta que está na impressora.

### Opções

| Opção | Valores | Padrão | Descrição |
|---|---|---|---|
| `PageSize` | `w100h150`, `w100h100`, `w100h50`, `w60h40`, `w50h30`, `w40h20`, `w30h20` e outros | `w100h150` | Tamanho da etiqueta em mm (`w`largura`h`altura). Lista completa: `lpoptions -p OIA-8386 -l` |
| `Darkness` | 0–15 | 8 | Densidade/escurecimento da impressão |
| `PrintSpeed` | 2–6 | 4 | Velocidade em polegadas por segundo |
| `LabelGap` | 0–5 | 2 | Espaço entre etiquetas em mm (0 = contínua) |
| `Rotate180` | `True`/`False` | `False` | Gira a impressão em 180° |

Exemplo:

```bash
lp -d OIA-8386 -o PageSize=w100h150 -o Darkness=10 -o PrintSpeed=3 -o fit-to-page arquivo.pdf
```

Para mudar o padrão da fila: `sudo lpoptions -p OIA-8386 -o Darkness=10`.

## Problemas comuns

- **Etiqueta muito clara ou falhando:** aumente `Darkness` ou reduza `PrintSpeed`.
- **Impressão de cabeça para baixo:** use `-o Rotate180=True`.
- **Etiqueta avança errado / pula etiquetas:** confira `PageSize` e `LabelGap`; calibre os sensores da impressora conforme o manual.
- **Impressora não encontrada:** veja `lsusb` (deve aparecer `0416:5011`) e `lpinfo -v`. Reinstale com a impressora já ligada.
- **Logs do filtro:** `sudo journalctl -u cups` ou `/var/log/cups/error_log`.

## Desinstalação

```bash
sudo ./desinstalar.sh
```

## Limitações

- Imprime sempre como bitmap (tudo vira imagem em preto e branco, com limiar de 50%). Não usa as fontes e códigos de barras nativos do TSPL.
- Resolução fixa de 203 dpi.
- Uma etiqueta por página; as cópias ficam a cargo do CUPS (`-n`).

## Licença

Uso livre. Sem garantias.
