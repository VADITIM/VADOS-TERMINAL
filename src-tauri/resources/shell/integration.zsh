# VAD/OS shell integration — emits OSC 133 command-boundary markers and OSC 7
# cwd reports. Loaded as $ZDOTDIR/.zshrc so this must explicitly source the
# user's real .zshrc first (ZDOTDIR override hides it otherwise).

if [ -f ~/.zshrc ]; then
  ZDOTDIR=~ source ~/.zshrc
fi

# BEL terminates every sequence here, not ST (ESC \). ST is legal and it is
# what this file used to send, but it is two bytes with a backslash as the
# second one, and anything that loses or consumes the ESC — a redraw that
# reprints part of the prompt, a parser reset between the two bytes — leaves
# that backslash on screen as literal text the line editor cannot delete,
# because the shell never typed it. That is the stray `\` the PowerShell
# snippet was fixed for; the cause is not PowerShell's, so neither is the fix.
__vados_osc7() {
  printf '\033]7;file://%s%s\a' "$HOST" "$PWD"
}

# precmd runs right before the prompt is drawn — previous command's exit code
# is still live, so capture it first.
__vados_precmd() {
  local ec=$?
  printf '\033]133;D;%s\a\033]133;A\a' "$ec"
  __vados_osc7
}

# preexec runs once the user has submitted a command, right before it executes.
__vados_preexec() {
  printf '\033]133;C\a'
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd __vados_precmd
add-zsh-hook preexec __vados_preexec

# Marks the end of the prompt / start of typed input.
PS1="${PS1}"'%{$(printf "\033]133;B\a")%}'
