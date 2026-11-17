# Yui

> Um sistema operacional pessoal baseado em **Arch Linux + Hyprland**, pensado para um dia ser gerenciado 100% por uma IA.
> Nome inspirado na Yui de *Sword Art Online*: a IA que vive dentro do sistema e cuida de quem o usa.

Projeto hobby. Começa como dotfiles + script de instalação; no futuro vira uma ISO.

## Estrutura

| Pasta | Conteúdo |
|---|---|
| `packages/` | Listas de pacotes: `base.txt` (pacman), `aur.txt` (yay), `nvidia.txt` |
| `dotfiles/` | Configs do `~`, organizadas para o [GNU stow](https://www.gnu.org/software/stow/) |
| `hosts/` | Ajustes específicos de cada máquina (monitores, brilho, GPU) |
| `system/` | Arquivos de `/etc` |
| `iso/` | (futuro) perfil archiso |
| `docs/` | Documentação, atalhos, decisões |

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

- [ ] `install.sh` idempotente (pacotes + stow + serviços)
- [ ] Mover o que é da máquina para `hosts/notebook` (intel_backlight, monitores)
- [ ] Tirar o caminho absoluto do `hyprpaper.conf`
- [ ] Testar instalação em VM
- [ ] Camada de IA
- [ ] ISO com archiso
