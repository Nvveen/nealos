set -p fish_complete_path "$argv[1]/share/fish/vendor_completions.d"
set -p PATH "$argv[1]/bin"
alias ltm lazy-tmux

function assert_completion --argument-names line expected
    set -l candidates (complete -C "$line" | string split -f 1 \t)
    if not contains -- "$expected" $candidates
        printf 'Missing completion %s for %s; got: %s\n' "$expected" "$line" "$candidates" >&2
        return 1
    end
end

function assert_no_completion --argument-names line forbidden
    set -l candidates (complete -C "$line" | string split -f 1 \t)
    if contains -- "$forbidden" $candidates
        printf 'Unexpected completion %s for %s\n' "$forbidden" "$line" >&2
        return 1
    end
end

for command in lazy-tmux ltm
    assert_completion "$command re" restore; or exit 1
    assert_completion "$command save --scr" --scrollback-lines; or exit 1
    assert_completion "$command picker --ses" --sessions-only; or exit 1
    assert_completion "$command config " gen; or exit 1
    assert_completion "$command config gen --" --path; or exit 1
    assert_completion "$command integrations " repair; or exit 1
    assert_completion "$command integrations setup " codex; or exit 1
    assert_completion "$command integrations setup claude --" --uninstall; or exit 1
    assert_completion "$command integrations repair --" --id; or exit 1
    assert_completion "$command agent-session --agent c" claude; or exit 1
    assert_completion "$command agent-session --agent=c" --agent=claude; or exit 1
    assert_completion "$command bootstrap --session " last; or exit 1
    assert_completion "$command hook theme --theme d" dark; or exit 1
    assert_completion "$command help re" restore; or exit 1

    assert_no_completion "$command config show --" --path; or exit 1
    assert_no_completion "$command list --" --scrollback; or exit 1
    assert_no_completion "$command restore --session " --help; or exit 1
    assert_no_completion "$command save --scrollback-lines " --scrollback; or exit 1
end

set -l test_dir "$TMPDIR/lazy-tmux-completion-tests"
mkdir -p "$test_dir/project one"
touch "$test_dir/config.toml"
for command in lazy-tmux ltm
    assert_completion "$command save --data-dir $test_dir/pro" "$test_dir/project one/"; or exit 1
    assert_completion "$command config gen --path $test_dir/conf" "$test_dir/config.toml"; or exit 1
    assert_no_completion "$command save --data-dir $test_dir/" "$test_dir/config.toml"; or exit 1
end

echo 'PASS: Fish completion discovery, commands, contextual flags, nested commands, values, paths, and ltm'
