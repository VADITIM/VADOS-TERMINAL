# VAD/OS shell integration — emits OSC 133 command-boundary markers and OSC 7
# cwd reports. Loaded via `bash --rcfile` so the user's own .bashrc is sourced
# first, then this appends its hooks.

[ -f ~/.bashrc ] && source ~/.bashrc

# BEL terminates every sequence here, not ST (ESC \). ST is legal and it is
# what this file used to send, but it is two bytes with a backslash as the
# second one, and anything that loses or consumes the ESC — a redraw that
# reprints part of the prompt, a parser reset between the two bytes — leaves
# that backslash on screen as literal text the line editor cannot delete,
# because the shell never typed it. That is the stray `\` the PowerShell
# snippet was fixed for; the cause is not PowerShell's, so neither is the fix.
__vados_osc7() {
  printf '\033]7;file://%s%s\a' "$HOSTNAME" "$PWD"
}

# PROMPT_COMMAND runs after every command, before the next prompt is drawn.
# $? must be captured as the very first statement or it is lost.
__vados_prompt_command() {
  local ec=$?
  printf '\033]133;D;%s\a\033]133;A\a' "$ec"
  __vados_osc7
}

if [[ "$PROMPT_COMMAND" != *__vados_prompt_command* ]]; then
  PROMPT_COMMAND="__vados_prompt_command${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
fi

# Marks the end of the prompt / start of typed input. Appended invisibly via
# \[ \] so bash's line-length calculation ignores it.
PS1="${PS1}"'\[$(printf "\033]133;B\a")\]'
