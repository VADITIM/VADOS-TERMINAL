# VAD/OS shell integration — emits OSC 133 command-boundary markers and OSC 7
# cwd reports. Loaded via `fish --init-command 'source <file>'`, which runs
# after the user's own config, so this wraps whatever prompt they already have
# rather than replacing it.
#
# BEL terminates every sequence, not ST (ESC \). ST is legal and it is what the
# other snippets used to send, but it is two bytes with a backslash as the
# second one — and anything that loses or consumes the ESC between them leaves
# that backslash on screen as literal text the line editor does not know is
# there, so it cannot be deleted. BEL is one byte and cannot be split.

# The exit code of the command that just finished. Captured in `fish_postexec`
# because that is the only place it exists: by the time the prompt is drawn,
# `$status` is the status of whatever the prompt itself last ran.
set -g __vados_status 0

function __vados_postexec --on-event fish_postexec
    set -g __vados_status $status
end

# Wrap, never clobber. The user's prompt is copied under another name and
# called through, so the markers are added to their prompt instead of it being
# replaced by ours. `functions -q` guards the case where there is none — fish
# ships a default `fish_prompt`, so in practice this always copies something.
if functions -q fish_prompt
    functions --copy fish_prompt __vados_orig_prompt
else
    function __vados_orig_prompt
        printf '%s> ' (prompt_pwd)
    end
end

# D (the previous command's exit code), A (a prompt is starting) and the cwd
# report all go out before the prompt text; B marks the point after it where
# typed input begins. All of it is emitted from inside the prompt function
# rather than from an `--on-event fish_prompt` handler, so the order against
# the prompt's own output is fixed by this file instead of by when fish chooses
# to fire the event.
function fish_prompt
    printf '\033]133;D;%s\a\033]133;A\a\033]7;file://%s%s\a' $__vados_status $hostname $PWD
    __vados_orig_prompt
    printf '\033]133;B\a'
end
