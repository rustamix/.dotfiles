# ~/.zshrc — интерактивные шеллы.
# Переменные для login-шеллов живут в ~/.zprofile (там brew shellenv).

# ---------------------------------------------------------------------------
# Homebrew
# ---------------------------------------------------------------------------
# .zprofile выполняется только для login-шеллов, поэтому в nested-шеллах и во
# встроенных терминалах (nvim, Cursor) HOMEBREW_PREFIX пуст. Подстраховываемся.
# Если .zprofile уже отработал — это no-op.
if [[ -z $HOMEBREW_PREFIX && -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ---------------------------------------------------------------------------
# PATH
# ---------------------------------------------------------------------------
# typeset -U держит path уникальным: повторный запуск zsh больше не плодит дубли.
typeset -U path PATH

export GOPATH="$HOME/go"

# Препендим в порядке возрастания приоритета — последний окажется первым.
# /usr/local/go/bin убран намеренно: там go1.22.2, а реально работает
# brew-овский go1.24.6 из /opt/homebrew/bin. Удали саму установку или верни
# строку осознанно.
for _dir in \
  "$HOMEBREW_PREFIX/opt/python@3.11/libexec/bin" \
  "$GOPATH/bin"
do
  [[ -d $_dir ]] && path=("$_dir" $path)
done
unset _dir

# ---------------------------------------------------------------------------
# oh-my-zsh
# ---------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
  git
  golang
  kubectl
  docker
  docker-compose
  brew
  macos
)

# Guard: dotfiles могут раскататься на машину, где omz ещё не поставлен.
[[ -f $ZSH/oh-my-zsh.sh ]] && source "$ZSH/oh-my-zsh.sh"

# ---------------------------------------------------------------------------
# История (после omz — он выставляет свои значения)
# ---------------------------------------------------------------------------
# omz ставит SAVEHIST=10000 при HISTSIZE=50000, то есть на диск уезжала пятая часть.
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS

# ---------------------------------------------------------------------------
# Окружение
# ---------------------------------------------------------------------------
export LANG=en_US.UTF-8
export EDITOR=nvim
export VISUAL=nvim

# ---------------------------------------------------------------------------
# fzf — Ctrl-R по истории, Ctrl-T по файлам
# ---------------------------------------------------------------------------
if command -v fzf >/dev/null; then
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
  source <(fzf --zsh)   # требует fzf >= 0.48; у тебя 0.50.0
fi

# ---------------------------------------------------------------------------
# Автодополнение из истории и подсветка синтаксиса
# ---------------------------------------------------------------------------
# Пока не установлены — строки просто пропускаются:
#   brew install zsh-autosuggestions zsh-syntax-highlighting
# Порядок важен: syntax-highlighting подключается последним.
[[ -f $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ---------------------------------------------------------------------------
# uv (файл идемпотентный, сам добавляет ~/.local/bin в начало PATH)
# ---------------------------------------------------------------------------
[[ -f $HOME/.local/bin/env ]] && source "$HOME/.local/bin/env"

# ---------------------------------------------------------------------------
# Машинно-локальное: токены, пути, всё что не должно уехать в git
# ---------------------------------------------------------------------------
[[ -f $HOME/.zshrc.local ]] && source "$HOME/.zshrc.local"

# ---------------------------------------------------------------------------
# powerlevel10k — сейчас выключен, активна тема robbyrussell выше
# ---------------------------------------------------------------------------
# ~/powerlevel10k и ~/.p10k.zsh на диске есть. Чтобы вернуть:
#   1) ZSH_THEME="" в секции oh-my-zsh
#   2) раскомментировать две строки ниже
#   3) перенести блок instant prompt в САМОЕ НАЧАЛО файла
#
# source ~/powerlevel10k/powerlevel10k.zsh-theme
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
#
# Блок instant prompt (только вместе с включённым p10k, строго первым в файле):
#
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi