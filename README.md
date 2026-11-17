# Yui

> Um sistema operacional pessoal baseado em **Arch Linux + Hyprland**, pensado para um dia ser gerenciado 100% por uma IA.
> Nome inspirado na Yui de *Sword Art Online*: a IA que vive dentro do sistema e cuida de quem o usa.

Projeto hobby. Começa como dotfiles + script de instalação; no futuro vira uma ISO.

## Como funciona

A Yui é distribuída como **pacotes Arch** (`yui-*`). Uma máquina com a Yui não precisa deste repo: ela só tem os pacotes, atualizados pelo `pacman`.

| Pacote | Conteúdo |
|---|---|
| `yui-base` | Rede, áudio, Bluetooth e ferramentas básicas |
| `yui-desktop` | Hyprland e os padrões da Yui em `/usr/share/yui`, Waybar, bloqueio, scripts `yui-*` |
| `yui-nvidia` | Suporte a GPUs NVIDIA |

Os padrões ficam em `/usr/share/yui`. As configs do usuário em `~/.config` sempre têm prioridade:
- `~/.config/hypr/hyprland.lua` carrega `/usr/share/yui/hypr/yui.lua` e depois aplica as personalizações do usuário.
- Waybar, hyprlock, hypridle e hyprpaper usam a config do usuário se ela existir; senão, usam a da Yui.

## Estrutura do repo

| Pasta | Conteúdo |
|---|---|
| `desktop/` | Arquivos instalados pelo `yui-desktop` (configs, scripts, ajustes de serviços) |
| `pkgs/` | `PKGBUILD` de cada pacote |
| `iso/` | (futuro) perfil archiso |
| `docs/` | Documentação e decisões |

## Compilar e instalar (desenvolvimento)

```bash
cd pkgs/yui-desktop && makepkg -f
sudo pacman -U yui-desktop-*.pkg.tar.zst
yui-setup          # prepara o ~/.config do usuário (use --reset para voltar aos padrões)
```

## Scripts

| Comando | Função |
|---|---|
| `yui-setup` | Cria o `hyprland.lua` do usuário apontando para os padrões |
| `yui-brightness` | Brilho da tela interna (escolhe o dispositivo certo em notebooks híbridos) |
| `yui-lock` | Bloqueia a tela |
| `yui-power-menu` | Menu de energia |
| `yui-waybar`, `yui-config-run` | Escolhem entre a config do usuário e a padrão |

## Como a sessão sobe

A sessão é **Hyprland (uwsm-managed)** via SDDM. Autostart em 3 camadas:

1. **Serviços systemd de usuário**: waybar, hyprpaper, hypridle, hyprpolkitagent
2. **`/etc/xdg/autostart`** (executado pelo uwsm): nm-applet, blueman-applet
3. **`hl.on("hyprland.start")`** no `hyprland.lua`: cliphist

## Atalhos principais (`Super` = tecla Windows)

| Atalho | Ação |
|---|---|
| `Super+Q` / `Super+R` / `Super+E` | Terminal / lançador / arquivos |
| `Super+C` | Fechar janela |
| `Super+L` | Bloquear tela |
| `Super+F` / `Super+Shift+F` | Tela cheia / maximizar |
| `Super+Shift+setas` | Mover janela |
| `Super+Ctrl+setas` | Redimensionar |
| `Super+Alt+←/→` | Janela para outro monitor |
| `Alt+Tab` / `Super+Tab` | Alternar janelas / workspace anterior |
| `Super+G` | Agrupar em abas |
| `Super+Shift+V` | Histórico da área de transferência |
| `Print` / `Shift+Print` | Print de área (copia) / tela inteira (salva) |

## TODO

- [x] Modelo de pacotes (`yui-base`, `yui-desktop`, `yui-nvidia`)
- [x] Brilho detectado automaticamente (sem config por máquina)
- [ ] Repositório pacman da Yui (GitHub Releases + Actions)
- [ ] Snapshots btrfs (snapper, snap-pac, grub-btrfs)
- [ ] Testar instalação em VM
- [ ] Camada de IA
- [ ] ISO com archiso
