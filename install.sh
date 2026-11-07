#!/bin/bash
# install.sh — install the assisted-by commit-msg hook.
#
# Usage: ./install.sh [--policy strip|rewrite|off] [--agent NAME]
#
# Installs to ~/.assisted-by/commit-msg and chains it via a hooks wrapper so
# any existing core.hooksPath hooks keep working. See README.md.

set -euo pipefail

DEST="$HOME/.assisted-by"
POLICY="strip"
AGENT=""
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

while [ $# -gt 0 ]; do
  case "$1" in
    --policy) POLICY="$2"; shift 2 ;;
    --agent)  AGENT="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

mkdir -p "$DEST"
cp "$SRC_DIR/commit-msg" "$DEST/commit-msg"
chmod +x "$DEST/commit-msg"

# Chain with any existing hooks: preserve prior core.hooksPath if it isn't
# the standard .git/hooks default.
existing="$(git config --global core.hooksPath 2>/dev/null || true)"

mkdir -p "$HOME/.assisted-by/hooks.d"
cat > "$HOME/.assisted-by/hooks-wrapper" <<WRAPPER
#!/bin/bash
# assisted-by wrapper: runs the aiattr commit-msg hook, then any prior hooks.
if [ "\$(basename "\$0")" = "commit-msg" ]; then
  "\$HOME/.assisted-by/commit-msg" "\$@" || exit \$?
fi
${existing:+if [ -x "$existing/\$(basename \$0)" ]; then "$existing/\$(basename \$0)" "\$@"; exit \$?; fi}
exit 0
WRAPPER
chmod +x "$HOME/.assisted-by/hooks-wrapper"

git config --global core.hooksPath "$HOME/.assisted-by/hooks-wrapper"
git config --global aiattr.policy "$POLICY"
if [ -n "$AGENT" ]; then git config --global aiattr.agent "$AGENT"; fi

echo "Installed."
echo "  hook:        $DEST/commit-msg"
echo "  policy:      $POLICY"
echo "  agent:       ${AGENT:-assistant (default)}"
echo "  hooksPath:   $HOME/.assisted-by/hooks-wrapper"
echo ""
echo "Try it: commit with a vendor AI trailer in the message and watch it"
echo "become 'Assisted-by: ${AGENT:-assistant}'."
