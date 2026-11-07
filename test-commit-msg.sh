#!/bin/bash
# test-commit-msg.sh — tests for the AI-attribution policy in commit-msg.
# Run: bash test-commit-msg.sh
# Each case runs the real hook in a throwaway git repo.

set -u
HOOK="$(cd "$(dirname "$0")" && pwd)/commit-msg"
pass=0
fail=0

# run_case <policy> <agent> <input-file> -> echoes output path
run_case() {
  local policy="$1" agent="$2" input="$3"
  local tdir
  tdir="$(mktemp -d)"
  git init -q "$tdir" 2>/dev/null
  (cd "$tdir" &&
    git config aiattr.policy "$policy" &&
    { [ -z "$agent" ] || git config aiattr.agent "$agent"; })
  cp "$input" "$tdir/MSG"
  (cd "$tdir" && bash "$HOOK" MSG 2>stderr) >/dev/null 2>&1
  echo "$tdir/MSG"
}

check() {
  local name="$1" expect="$2" got="$3"
  if [ "$expect" = "$got" ]; then
    echo "PASS: $name"; pass=$((pass+1))
  else
    echo "FAIL: $name (expected [$expect], got [$got])"; fail=$((fail+1))
  fi
}

# --- fixtures ---------------------------------------------------------------
f_basic="$(mktemp)"
cat > "$f_basic" <<'EOF'
fix: handle empty payload in parser

Co-Authored-by: Alice <alice@example.com>
Co-Authored-By: Claude <noreply@anthropic.com>

🤖 Generated with Claude Code
EOF

f_stamp="$(mktemp)"
cat > "$f_stamp" <<'EOF'
fix: rewrite parser loop

Assisted-by: alpha; mode=generated
Co-Authored-By: Claude <noreply@anthropic.com>
EOF

f_footer_only="$(mktemp)"
cat > "$f_footer_only" <<'EOF'
chore: bump deps

🤖 Generated with Claude Code
EOF

f_comments="$(mktemp)"
printf 'feat: add widget\n\nCo-Authored-By: Claude <noreply@anthropic.com>\n\n# Please enter the commit message\n# lines starting with # are ignored\n' > "$f_comments"

f_badmode="$(mktemp)"
cat > "$f_badmode" <<'EOF'
docs: update readme

Assisted-by: charlie; mode=vibed
Co-Authored-By: Cursor <cursoragent@cursor.com>
EOF

# --- 1. default policy = strip: vendor gone, human co-author kept, no stamp --
out="$(run_case strip "" "$f_basic")"
check "strip: vendor trailer removed" "0" "$(grep -ci 'anthropic\|Claude' "$out")"
check "strip: human co-author kept" "1" "$(grep -ci 'Co-authored-by: Alice' "$out")"
check "strip: no Assisted-by stamp" "0" "$(grep -ci 'Assisted-by' "$out")"

# --- 2. rewrite: vendor ad -> one conformant stamp, human co-author kept ----
out="$(run_case rewrite "alpha" "$f_basic")"
check "rewrite: stamp present" "1" "$(grep -ci '^Assisted-by: alpha$' "$out")"
check "rewrite: vendor removed" "0" "$(grep -ci 'anthropic\|Claude' "$out")"
check "rewrite: human co-author kept" "1" "$(grep -ci 'Co-authored-by: Alice' "$out")"

# --- 3. rewrite with existing stamp: no duplicate ---------------------------
out="$(run_case rewrite "bravo" "$f_stamp")"
check "rewrite+stamp: no dup" "1" "$(grep -ci 'Assisted-by' "$out")"
check "rewrite+stamp: existing kept" "1" "$(grep -ci 'Assisted-by: alpha; mode=generated' "$out")"

# --- 4. footer-only message still gets the stamp ----------------------------
out="$(run_case rewrite "assistant" "$f_footer_only")"
check "rewrite footer-only: stamped" "1" "$(grep -ci '^Assisted-by: assistant$' "$out")"

# --- 5. policy=off: untouched ------------------------------------------------
out="$(run_case off "" "$f_basic")"
check "off: vendor left in place" "2" "$(grep -ci 'Claude' "$out")"
check "off: no stamp" "0" "$(grep -ci 'Assisted-by' "$out")"

# --- 6. non-gating: bad mode= on existing stamp warns, exit 0, stamp kept ----
out="$(run_case rewrite "assistant" "$f_badmode")"
rc_err="$(grep -ci 'non-conformant' "$(dirname "$out")/stderr")"
check "bad mode: warns" "1" "$rc_err"
check "bad mode: existing stamp kept" "1" "$(grep -ci 'Assisted-by: charlie; mode=vibed' "$out")"
check "bad mode: vendor removed" "0" "$(grep -ci 'Cursor' "$out")"

# --- 7. stamp inserted before trailing comment block ------------------------
out="$(run_case rewrite "assistant" "$f_comments")"
stamp_line="$(grep -n '^Assisted-by' "$out" | cut -d: -f1)"
comment_line="$(grep -n '^# Please' "$out" | cut -d: -f1)"
if [ -n "$stamp_line" ] && [ -n "$comment_line" ] && [ "$stamp_line" -lt "$comment_line" ]; then
  check "stamp before comment block" "ok" "ok"
else
  check "stamp before comment block" "ok" "stamp=$stamp_line comment=$comment_line"
fi

# --- 8. subject line untouched ----------------------------------------------
out="$(run_case rewrite "assistant" "$f_basic")"
check "subject preserved" "fix: handle empty payload in parser" "$(head -1 "$out")"

rm -rf "$(dirname "$out")" 2>/dev/null || true
rm -f "$f_basic" "$f_stamp" "$f_footer_only" "$f_comments" "$f_badmode"

echo ""
echo "$pass passed, $fail failed"
[ "$fail" = 0 ]
