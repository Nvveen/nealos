{ palette, ... }:
let
  c = palette.colors;
in
{
  programs.tmux.extraConfig = ''
    set -as terminal-features ",xterm*:RGB,foot*:RGB,alacritty*:RGB,tmux*:RGB"

    set -g status-position bottom
    set -g status-justify left
    set -g status-interval 5
    set -g status-style "fg=${c.mOnSurfaceVariant},bg=${c.mSurface}"
    set -g status-left-length 26
    set -g status-right-length 70
    set -g status-left "#[fg=${c.mPrimary},bg=${c.mSurface}]▌#[fg=${c.mOnPrimary},bg=${c.mPrimary},bold] #{=18:session_name} #[fg=${c.mPrimary},bg=${c.mSurface}]▐#[default] "
    set -g status-right "#{?client_prefix,#[fg=${c.mSurface} bg=${c.mTertiary} bold] KEY #[default] ,}#{?pane_in_mode,#[fg=${c.mSurface} bg=${c.mSecondary} bold] COPY #[default] ,}#{?window_zoomed_flag,#[fg=${c.mTertiary}] ZOOM #[default] ,}#{?#{e|>=:#{client_width},110},#[fg=${c.mOnSurfaceVariant} bg=${c.mSurfaceVariant}] #{=20:host_short} #[default] ,}#[fg=${c.mPrimary}]▌#[fg=${c.mOnSurface},bg=${c.mSurfaceVariant},bold] %H:%M #[default]#{?#{e|>=:#{client_width},140},#[fg=${c.mOnSurfaceVariant}] %a %d %b ,}"

    setw -g window-status-separator ""
    setw -g window-status-style "fg=${c.mOnSurfaceVariant},bg=${c.mSurface},none"
    setw -g window-status-format "#[fg=${c.mOutline}] #I #[default]#{=20:window_name}#{?window_bell_flag, !,#{?window_activity_flag, +,}} "
    setw -g window-status-current-style "fg=${c.mOnSurface},bg=${c.mSurfaceVariant},none"
    setw -g window-status-current-format "#[fg=${c.mSurface},bg=${c.mPrimary},bold] #I #[fg=${c.mOnSurface},bg=${c.mSurfaceVariant},bold] #{=24:window_name} #[fg=${c.mPrimary},bg=${c.mSurface}]▏#[default]"
    setw -g window-status-activity-style "fg=${c.mTertiary},bg=${c.mSurface},bold"
    setw -g window-status-bell-style "fg=${c.mOnPrimary},bg=${c.mSecondary},bold"
    setw -g window-status-last-style "fg=${c.mSecondary}"

    set -g pane-border-style "fg=${c.mOutline}"
    set -g pane-active-border-style "fg=#{?client_prefix,${c.mTertiary},${c.mPrimary}}"
    set -g pane-border-lines single
    set -g pane-border-status off
    set-hook -g window-layout-changed 'if-shell -F "#{e|>:#{window_panes},1}" "set -w pane-border-status top" "set -w pane-border-status off"'
    set -g pane-border-format "#[fg=${c.mOutline}]─ #[fg=#{?pane_active,${c.mPrimary},${c.mOnSurfaceVariant}},bold]#P #[nobold]#{=18:pane_current_command} #[fg=${c.mOutline}]· #[fg=${c.mOnSurfaceVariant}]#{=30:#{b:pane_current_path}} #[fg=${c.mOutline}]─"
    set -g display-panes-colour "${c.mOutline}"
    set -g display-panes-active-colour "${c.mPrimary}"

    setw -g mode-style "fg=${c.mOnPrimary},bg=${c.mPrimary}"
    set -g message-style "fg=${c.mSurface},bg=${c.mPrimary},bold"
    set -g message-command-style "fg=${c.mOnSurface},bg=${c.mSurfaceVariant},bold"
    set -g clock-mode-colour "${c.mPrimary}"

    set -g popup-style "fg=${c.mOnSurface},bg=${c.mSurface}"
    set -g popup-border-style "fg=${c.mPrimary}"
    set -g popup-border-lines rounded
    set -g menu-style "fg=${c.mOnSurface},bg=${c.mSurface}"
    set -g menu-selected-style "fg=${c.mOnPrimary},bg=${c.mPrimary},bold"
    set -g menu-border-style "fg=${c.mPrimary}"
    set -g menu-border-lines rounded
  '';
}
