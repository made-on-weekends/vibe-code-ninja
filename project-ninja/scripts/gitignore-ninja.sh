#!/usr/bin/env bash
# gitignore-ninja.sh — Project Ninja .gitignore engine.
#
# Subcommands
#   detect                 List detected stacks, one per line.
#   render  [--stacks a,b] Print the proposed .gitignore to stdout (read-only).
#   blocks  [--stacks a,b] Show managed-block status: OK / STALE / MISSING / EXTRA.
#   audit   [--stacks a,b] [--no-history] [--strict]
#                          Full read-only report. --strict exits 3 on MUST findings.
#   apply   --yes [--stacks a,b]
#                          Write the proposed .gitignore. Only run after a human
#                          approved the diff. Backs up to .git/project-ninja/.
#
# Dependencies: bash 3.2+ (macOS default works), git, grep, sed, awk, diff. No jq.
# Never untracks files, never commits, never rewrites history.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FRAG_DIR="${NINJA_FRAG_DIR:-$SKILL_DIR/assets/gitignore}"
VERSION="$(tr -d '[:space:]' < "$FRAG_DIR/VERSION" 2>/dev/null || echo unknown)"
MARK_OPEN='# >>> project-ninja:'
MARK_CLOSE='# <<< project-ninja:'
USER_SEP='# ---- Project-specific rules below (not managed by Project Ninja; these win on conflict) ----'
HEAVY=(-x node_modules -x vendor -x .venv -x venv -x target -x .next -x .gradle -x .terraform -x __pycache__ -x .git)

TMPS=()
cleanup(){ local t; for t in "${TMPS[@]:-}"; do [ -n "$t" ] && rm -rf "$t"; done; }
trap cleanup EXIT
mktmp(){ local t; t="$(mktemp)"; TMPS+=("$t"); printf '%s' "$t"; }
mktmpd(){ local t; t="$(mktemp -d)"; TMPS+=("$t"); printf '%s' "$t"; }
die(){ echo "gitignore-ninja: $*" >&2; exit 2; }

require_repo(){
  command -v git >/dev/null 2>&1 || die "git not found"
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || die "not inside a git repository (run 'git init' first)"
  cd "$ROOT" || die "cannot cd to $ROOT"
  [ -f "$FRAG_DIR/baseline.gitignore" ] || die "fragments not found in $FRAG_DIR"
}

# ---------------------------------------------------------------- detection
inventory(){ git ls-files -co --exclude-standard "${HEAVY[@]}" 2>/dev/null; }

manifest_has(){ # $1 inventory file, $2 fixed string
  local f
  while IFS= read -r f; do
    [ -f "$f" ] && grep -qF -- "$2" "$f" 2>/dev/null && return 0
  done < <(grep -E '(^|/)manifest\.json$' "$1")
  return 1
}

detect_stacks(){
  local inv; inv="$(mktmp)"; inventory > "$inv"
  has(){ grep -Eq -- "$1" "$inv"; }
  {
    has '(^|/)package\.json$' && echo node
    has '(^|/)next\.config\.(js|mjs|cjs|ts|mts)$' && echo nextjs
    if has '(^|/)(wxt\.config\.(ts|js|mjs)|plasmo\.config\.(ts|js))$' \
       || manifest_has "$inv" '"manifest_version"' \
       || { [ -f package.json ] && grep -q '"plasmo"' package.json; }; then echo chrome-extension; fi
    has '(^|/)(pyproject\.toml|setup\.py|setup\.cfg|Pipfile|requirements[^/]*\.txt)$|\.ipynb$' && echo python
    has '(^|/)go\.mod$' && echo go
    has '(^|/)Cargo\.toml$' && echo rust
    has '(^|/)(pom\.xml|build\.gradle(\.kts)?|settings\.gradle(\.kts)?)$' && echo jvm
    has '(^|/)composer\.json$' && echo php
    if has '(^|/)(wp-config(-sample)?\.php|wp-content/)' ; then echo wordpress
    else
      local f found=""
      while IFS= read -r f; do
        [ -f "$f" ] && head -n 30 "$f" 2>/dev/null | grep -qE '^[[:space:]/*#]*(Plugin|Theme) Name:' && { found=1; break; }
      done < <(grep -E '^([^/]+/)?[^/]+\.(php|css)$' "$inv")
      [ -n "$found" ] && echo wordpress
    fi
    has '(^|/)Gemfile$' && echo ruby
    has '\.(csproj|fsproj|vbproj|sln|slnx)$' && echo dotnet
    has '\.tf$' && echo terraform
    has '(^|/)wrangler\.(toml|json|jsonc)$' && echo cloudflare
    { has '(^|/)vercel\.json$' || [ -d .vercel ]; } && echo vercel
    has '(^|/)supabase/config\.toml$' && echo supabase
    has '(^|/)firebase\.json$' && echo firebase
    { manifest_has "$inv" '"api_version"' || manifest_has "$inv" '"frameworkVersion"' || [ -f .zat ]; } && echo zendesk
  } | sort -u
}

# ------------------------------------------------------------ managed blocks
check_markers(){ # $1 file; die if blocks are unbalanced or nested (prevents silent content loss)
  [ -f "$1" ] || return 0
  local msg
  msg="$(awk -v o="$MARK_OPEN" -v c="$MARK_CLOSE" '
    index($0,o)==1 { if (open) { print "nested block at line " NR; bad=1; exit } open=1; ol=NR; next }
    index($0,c)==1 { if (!open) { print "close marker without open at line " NR; bad=1; exit } open=0; next }
    END { if (open && !bad) { print "block opened at line " ol " is never closed"; bad=1 } exit bad }' "$1")" \
    || die "managed markers in $1 are broken: $msg. Fix by hand before render/apply."
}

existing_blocks(){ # names of managed blocks in .gitignore
  [ -f .gitignore ] || return 0
  grep -E "^# >>> project-ninja:[a-z0-9-]+ " .gitignore | sed -E 's/^# >>> project-ninja:([a-z0-9-]+) .*/\1/'
}

block_body(){ # $1 name -> body of that block in .gitignore
  awk -v o="$MARK_OPEN$1 " -v c="$MARK_CLOSE$1 " '
    index($0,o)==1 {on=1; next} on && index($0,c)==1 {on=0; next} on {print}' .gitignore
}

frag_file(){ case "$1" in baseline|agents) echo "$FRAG_DIR/$1.gitignore" ;; *) echo "$FRAG_DIR/stack-$1.gitignore" ;; esac; }

STACKS_OVERRIDE=""
resolve_stacks(){ # explicit override wins; else detected ∪ stacks already managed in the file
  if [ -n "$STACKS_OVERRIDE" ]; then tr ',' '\n' <<< "$STACKS_OVERRIDE" | sed '/^$/d' | sort -u; return; fi
  { detect_stacks; existing_blocks | grep -vxE 'baseline|agents'; } | sort -u
}

strip_managed(){ # stdin -> user content only
  awk -v o="$MARK_OPEN" -v c="$MARK_CLOSE" -v sep="$USER_SEP" '
    index($0,o)==1 {skip=1; next}
    skip && index($0,c)==1 {skip=0; next}
    skip {next}
    $0==sep {next}
    {print}'
}

trim_blank_edges(){ # drop leading/trailing blank lines (portable, no tac)
  awk '{ a[NR]=$0; if (NF) { if (!first) first=NR; last=NR } }
       END { if (first) for (i=first; i<=last; i++) print a[i] }'
}

render(){
  check_markers .gitignore
  local s f
  printf '# .gitignore — sections between project-ninja markers are managed by the\n'
  printf '# Project Ninja skill. Do not edit inside markers; add project-specific\n'
  printf '# rules at the bottom, where they take precedence.\n\n'
  local open_line
  for s in baseline agents $(resolve_stacks); do
    f="$(frag_file "$s")"
    [ -f "$f" ] || { echo "gitignore-ninja: no fragment for stack '$s' (skipped)" >&2; continue; }
    open_line="$MARK_OPEN$s v$VERSION >>>"
    # unchanged block keeps its original stamp so review diffs show only real changes
    if [ -f .gitignore ] && grep -q "^# >>> project-ninja:$s " .gitignore && cmp -s <(block_body "$s") "$f"; then
      open_line="$(grep -m1 "^# >>> project-ninja:$s " .gitignore)"
    fi
    printf '%s\n' "$open_line"
    cat "$f"
    printf '%s%s <<<\n\n' "$MARK_CLOSE" "$s"
  done
  printf '%s\n' "$USER_SEP"
  if [ -f .gitignore ]; then
    # drop our own header lines so re-rendering is idempotent
    strip_managed < .gitignore | grep -vE '^# (\.gitignore — sections between project-ninja markers|Project Ninja skill(\.| \(fragment set)|add project-specific rules at the bottom\.|rules at the bottom, where they take precedence\.)' | trim_blank_edges
  fi
}

blocks_status(){
  check_markers .gitignore
  local s f want have
  want="$(printf '%s\n' baseline agents; resolve_stacks)"
  have="$(existing_blocks)"
  for s in $want; do
    f="$(frag_file "$s")"
    if ! grep -qx "$s" <<< "$have"; then echo "MISSING  $s"
    elif [ ! -f "$f" ]; then echo "UNKNOWN  $s (no fragment in skill)"
    elif cmp -s <(block_body "$s") "$f"; then echo "OK       $s"
    else echo "STALE    $s (differs from skill fragment v$VERSION)"; fi
  done
  for s in $have; do grep -qx "$s" <<< "$want" || echo "EXTRA    $s (managed block present, stack not requested)"; done
}

# -------------------------------------------------------------- classifiers
SECRET_RE='(^|/)(\.env(\.[^/]+)?|\.dev\.vars(\.[^/]+)?|\.netrc|\.pypirc|\.runtimeconfig\.json|\.zat|wp-config\.php|master\.key|id_(rsa|dsa|ecdsa|ed25519)|[^/]*\.(pem|key|p12|pfx|jks|keystore|ppk)|[^/]*\.tfstate(\.[^/]+)?|[^/]*\.tfvars(\.json)?|client_secret[^/]*\.json|service-account[^/]*\.json|gha-creds-[^/]*\.json)$|(^|/)\.gemini/\.env$'
AGENT_LOCAL_RE='(^|/)\.claude/settings\.local\.json$|(^|/)CLAUDE\.local\.md$|(^|/)\.claude/(agent-memory-local|worktrees)/|(^|/)\.aider\.(chat\.history\.md|input\.history|llm\.history)$|(^|/)\.aider\.tags\.cache|(^|/)\.specstory/(history|ai_rules_backups)/|(^|/)\.crush/|(^|/)\.opencode/plans/'
EXAMPLE_RE='\.(example|sample|template|dist)$|\.(example|sample|template)\.[^/]+$|(^|/)examples?/'
LOCKFILES=(package-lock.json npm-shrinkwrap.json yarn.lock pnpm-lock.yaml bun.lock bun.lockb poetry.lock uv.lock Pipfile.lock pdm.lock Cargo.lock go.sum Gemfile.lock composer.lock packages.lock.json gradle.lockfile mix.lock pubspec.lock Podfile.lock flake.lock .terraform.lock.hcl)
MUST_KEEP=(.gitignore .gitattributes .gitmodules .editorconfig .env.example .env.sample .env.template
  CLAUDE.md .claude/CLAUDE.md AGENTS.md GEMINI.md WARP.md .claude/settings.json .claude/skills .claude/agents
  .claude/commands .claude/rules .claude/output-styles .claude/workflows .mcp.json .worktreeinclude
  .cursor/rules .cursorrules .cursorignore .cursorindexingignore .windsurfrules .windsurf/rules .windsurf/workflows
  .clinerules .clineignore .roomodes .roo/rules .rooignore .aiderignore .geminiignore .gemini/settings.json
  .gemini/commands .gemini/skills .codex/config.toml .github/copilot-instructions.md .github/instructions
  .github/prompts .github/agents .goosehints .kiro/steering .kiro/specs .kiro/hooks .amazonq/rules .junie/guidelines.md
  .opencode/agent .opencode/agents .opencode/command .opencode/commands opencode.json opencode.jsonc
  .crushignore crush.json .crush.json .continue/rules .continue/prompts .agents)
CFG_FILES=(.mcp.json .cursor/mcp.json .vscode/mcp.json .gemini/settings.json .codex/config.toml opencode.json
  opencode.jsonc crush.json .crush.json .roo/mcp.json .kilocode/mcp.json .kiro/settings/mcp.json .amazonq/mcp.json
  .continue/config.yaml .continue/config.json .aider.conf.yml .npmrc .yarnrc.yml .claude/settings.json
  .agents/mcp_config.json)
SCAN_RULES=(
  "private-key|-----BEGIN ([A-Z]+ )?PRIV""ATE KEY-----"
  "aws-access-key|(AKIA|ASIA)[0-9A-Z]{16}"
  "github-token|(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,}"
  "anthropic-key|sk-ant-[A-Za-z0-9_-]{20,}"
  "openai-key|sk-(proj|svcacct|admin)-[A-Za-z0-9_-]{20,}"
  "slack-token|xox[abprs]-[A-Za-z0-9-]{10,}"
  "stripe-live-key|(sk|rk)_live_[A-Za-z0-9]{20,}"
  "google-api-key|AIza[0-9A-Za-z_-]{35}"
  "npm-token|npm_[A-Za-z0-9]{36}"
)
label(){ # path -> secret | agent-local | other
  if grep -Eq -- "$SECRET_RE" <<< "$1" && ! grep -Eq -- "$EXAMPLE_RE" <<< "$1"; then echo secret
  elif grep -Eq -- "$AGENT_LOCAL_RE" <<< "$1"; then echo agent-local
  else echo other; fi
}

IGN_LISTS=""
ignored_entry(){ # $1 path -> prints the ignored-list entry covering it (self or ancestor dir)
  local p="$1" e
  while IFS= read -r e; do
    [ -z "$e" ] && continue
    if [ "$e" = "$p" ] || [ "$e" = "$p/" ]; then echo "$e"; return 0; fi
    case "$e" in */) case "$p" in "$e"*) echo "$e"; return 0 ;; esac ;; esac
  done < "$IGN_LISTS"
  return 1
}

explain_rule(){ # $1 proposed file, $2 path -> which proposed line ignores it
  local t; t="$(mktmpd)"
  git -C "$t" init -q 2>/dev/null; cp "$1" "$t/.gitignore"
  if [ -d "$2" ]; then mkdir -p "$t/$2"; else mkdir -p "$t/$(dirname "$2")"; : > "$t/$2"; fi
  git -C "$t" check-ignore -v --no-index -- "$2" 2>/dev/null | awk -F'\t' '{ split($1,a,":"); if (substr(a[3],1,1)!="!") print "        rule: proposed " $1 }'
}

SUBMODULES=""
is_keep(){ # $1 path -> 0 if it is (or sits under) a must-keep path, a lockfile, or a submodule
  local k b="${1##*/}"
  grep -qxF -- "$1" <<< "$SUBMODULES" && return 0
  for k in "${LOCKFILES[@]}"; do [ "$b" = "$k" ] && return 0; done
  for k in "${MUST_KEEP[@]}"; do [ "$1" = "$k" ] && return 0; case "$1" in "$k"/*) return 0 ;; esac; done
  return 1
}

# -------------------------------------------------------------------- audit
MUST=0; SHOULD=0; INFO=0
sec(){ printf '\n=== [%s] %s ===\n' "$1" "$2"; }

audit(){
  local P; P="$(mktmp)"; render > "$P"
  local TRK_IGN UNT_IGN TRACKED
  TRK_IGN="$(mktmp)"; UNT_IGN="$(mktmp)"; TRACKED="$(mktmp)"
  git ls-files -c -i --exclude-from="$P" > "$TRK_IGN" 2>/dev/null
  git ls-files -o -i --directory --exclude-from="$P" > "$UNT_IGN" 2>/dev/null
  git ls-files > "$TRACKED" 2>/dev/null
  IGN_LISTS="$(mktmp)"; cat "$TRK_IGN" "$UNT_IGN" > "$IGN_LISTS"
  SUBMODULES="$(git ls-files -s 2>/dev/null | awk '$1==160000 { sub(/^[^\t]*\t/, ""); print }')"

  sec 1 "Context"
  echo "repo:        $ROOT"
  echo "branch:      $(git branch --show-current 2>/dev/null || echo '?')"
  echo "HEAD:        $(git rev-parse --short HEAD 2>/dev/null || echo '(no commits yet)')"
  echo "git:         $(git --version | awk '{print $3}')"
  echo "fragments:   v$VERSION ($FRAG_DIR)"
  if [ -f .gitignore ]; then echo ".gitignore:  present, $(wc -l < .gitignore | tr -d ' ') lines"; else echo ".gitignore:  absent"; fi
  echo "nested .gitignore files (evaluated separately by git, unchanged by this run):"
  local ng; ng="$(git ls-files -co --exclude-standard "${HEAVY[@]}" | grep -E '/\.gitignore$')"
  if [ -n "$ng" ]; then echo "$ng" | sed 's/^/  /'; else echo "  (none)"; fi
  echo "global excludes (personal, collaborators may not have them): $(git config --global core.excludesFile || echo '(core.excludesFile unset)')"
  [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/git/ignore" ] && echo "  also present: ${XDG_CONFIG_HOME:-$HOME/.config}/git/ignore"
  local ie; ie="$(grep -cvE '^[[:space:]]*(#|$)' "$(git rev-parse --git-path info/exclude)" 2>/dev/null || true)"
  echo ".git/info/exclude active lines (personal, not shared): ${ie:-0}"

  sec 2 "Detected stacks (render uses: $(resolve_stacks | paste -sd, - ))"
  detect_stacks | sed 's/^/  /'

  sec 3 "Managed block status"
  local bs; bs="$(blocks_status)"; echo "$bs" | sed 's/^/  /'
  SHOULD=$((SHOULD + $(grep -cE '^(MISSING|STALE)' <<< "$bs")))
  if [ -f .gitignore ]; then
    local dups; dups="$(awk 'NR==FNR { if ($0 !~ /^#/ && NF) { k=$0; sub(/\/$/,"",k); m[k]=1 } next }
       $0 !~ /^#/ && NF { k=$0; sub(/\/$/,"",k); if (k in m) print "  INFO   project-specific line duplicates a managed rule: " $0 }' \
       <(sed -n "/^# >>> project-ninja:/,/^# <<< project-ninja:/p" "$P") <(strip_managed < .gitignore))"
    [ -n "$dups" ] && { echo "$dups"; INFO=$((INFO + $(grep -c . <<< "$dups"))); }
  fi

  sec 4 "Proposed diff (current -> proposed)"
  if [ -f .gitignore ]; then diff -u --label current/.gitignore --label proposed/.gitignore .gitignore "$P" || true
  else diff -u --label '/dev/null' --label proposed/.gitignore /dev/null "$P" || true; fi

  sec 5 "Tracked files the proposed rules ignore (still tracked until 'git rm --cached')"
  local f l n=0
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    l="$(label "$f")"; n=$((n+1))
    if [ "$l" = other ] && is_keep "$f"; then
      [ "$n" -le 200 ] && printf '  %-11s %s\n            do NOT untrack: shared file, lockfile, or submodule; fix the rule instead (see [6]/[7])\n' KEEP "$f"
      continue
    fi
    if [ "$l" = other ]; then case "$f" in .vscode/*|.idea/*|*/.vscode/*|*/.idea/*)
      [ "$n" -le 200 ] && printf '  %-11s %s\n            decide: team-shared and secret-free -> add %s to the project section;\n            personal -> git rm --cached -- %q\n' REVIEW "$f" "'!$f'" "$f"
      SHOULD=$((SHOULD+1)); continue ;; esac
    fi
    [ "$n" -le 200 ] && printf '  %-11s %s\n            git rm --cached -- %q\n' "$l" "$f" "$f"
    case "$l" in secret) MUST=$((MUST+1));; *) SHOULD=$((SHOULD+1));; esac
  done < "$TRK_IGN"
  [ "$n" -gt 200 ] && echo "  ... $((n-200)) more (collapse with 'git rm -r --cached -- <dir>/')"
  [ "$n" -eq 0 ] && echo "  (none)"

  sec 6 "Shared files the proposed rules would ignore (must stay committable)"
  local p why m=0 under
  local IFS_OLD="$IFS"; IFS=$'\n'
  for p in "${MUST_KEEP[@]}" $SUBMODULES; do
    IFS="$IFS_OLD"
    [ -e "$p" ] || continue
    why="$(explain_rule "$P" "$p")"
    if [ -n "$why" ]; then
      echo "  ERROR  $p"; echo "$why"; MUST=$((MUST+1)); m=$((m+1))
    elif [ -d "$p" ]; then
      under="$(grep -F -- "$p/" "$IGN_LISTS" | grep -vE -- "$SECRET_RE|$AGENT_LOCAL_RE" | head -n 5)"
      if [ -n "$under" ]; then
        echo "  WARN   files under $p are ignored (confirm intended):"; echo "$under" | sed 's/^/           /'
        SHOULD=$((SHOULD+1)); m=$((m+1))
      fi
    fi
    IFS=$'\n'
  done
  IFS="$IFS_OLD"
  [ "$m" -eq 0 ] && echo "  (none)"

  sec 7 "Lockfiles (must be committed)"
  local lf found=0
  for lf in "${LOCKFILES[@]}"; do
    while IFS= read -r f; do
      [ -z "$f" ] && continue; found=1
      if ignored_entry "$f" >/dev/null; then
        echo "  ERROR  $f is ignored by proposed rules"; explain_rule "$P" "$f"; MUST=$((MUST+1))
      elif grep -qxF -- "$f" "$TRACKED"; then echo "  ok     $f (tracked)"
      else echo "  WARN   $f exists but is untracked; commit it"; SHOULD=$((SHOULD+1)); fi
    done < <({ git ls-files; git ls-files -o "${HEAVY[@]}"; } 2>/dev/null | grep -E "(^|/)${lf//./\\.}$" | sort -u)
  done
  [ "$found" -eq 0 ] && echo "  (no lockfiles found)"

  sec 8 "Sensitive-looking untracked files NOT ignored by proposed rules (would be committed by 'git add -A')"
  n=0
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    l="$(label "$f")"; [ "$l" = other ] && continue
    echo "  $l  $f"; MUST=$((MUST+1)); n=$((n+1))
  done < <(git ls-files -o --exclude-from="$P" --exclude-per-directory=.gitignore "${HEAVY[@]}" 2>/dev/null | grep -E -- "$SECRET_RE|$AGENT_LOCAL_RE")
  [ "$n" -eq 0 ] && echo "  (none)"

  sec 9 "Credential patterns in tracked content (values not printed)"
  local r name re hits
  n=0
  for r in "${SCAN_RULES[@]}"; do
    name="${r%%|*}"; re="${r#*|}"
    hits="$(git grep -nIE -e "$re" -- . 2>/dev/null | cut -d: -f1,2 || true)"
    [ -z "$hits" ] && continue
    while IFS= read -r h; do echo "  $h  [$name]"; MUST=$((MUST+1)); n=$((n+1)); done <<< "$hits"
  done
  [ "$n" -eq 0 ] && echo "  (none)"

  sec 10 "Agent/MCP/package config with literal credential values (review; values redacted)"
  n=0
  for f in "${CFG_FILES[@]}"; do
    [ -f "$f" ] || continue
    local st; st="untracked"; grep -qxF -- "$f" "$TRACKED" && st="tracked"
    while IFS= read -r h; do
      [ -z "$h" ] && continue
      echo "  $f:$h  ($st)"; SHOULD=$((SHOULD+1)); n=$((n+1))
    done < <(grep -nEi '(token|api[_-]?key|secret|passw(or)?d|authorization|bearer|_auth)' "$f" 2>/dev/null \
             | grep -Ev '\$\{?[A-Za-z_]|\{env:|process\.env|<[^>]+>|your[_-]|placeholder|xxxx' \
             | grep -E '[:=][[:space:]]*("[^"$<{]{8,}"|[^[:space:]"{}\[,$<]{8,})' \
             | awk '{ i=index($0,":"); n=substr($0,1,i); r=substr($0,i+1);
                      gsub(/:[ \t]*"[^"]*"/, ": \"<redacted>\"", r); gsub(/=[ \t]*[^ \t]+/, "= <redacted>", r); print n r }')
  done
  [ "$n" -eq 0 ] && echo "  (none)"

  sec 11 "Sensitive or agent-local files present anywhere in git history"
  if [ "${NO_HISTORY:-0}" = 1 ]; then echo "  (skipped: --no-history)"
  elif ! git rev-parse -q --verify HEAD >/dev/null; then echo "  (no commits yet)"
  else
    n=0
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      l="$(label "$f")"; [ "$l" = other ] && continue
      local now="no longer tracked"; grep -qxF -- "$f" "$TRACKED" && now="still tracked, see [5]"
      [ "$l" = agent-local ] && [ "$now" != "no longer tracked" ] && continue
      echo "  $l  $f  ($now)"; n=$((n+1))
      if [ "$l" = secret ]; then MUST=$((MUST+1)); else INFO=$((INFO+1)); fi
    done < <(git log --all --diff-filter=A --name-only --format= 2>/dev/null | sort -u | grep -E -- "$SECRET_RE|$AGENT_LOCAL_RE")
    [ "$n" -eq 0 ] && echo "  (none)"
    [ "$n" -gt 0 ] && echo "  NOTE: rotate any secret that was ever pushed; untracking or rewriting history does not un-leak it."
    [ "$n" -gt 0 ] && echo "        agent-local entries are INFO: history rewrite is a separate, explicit decision."
  fi

  sec 12 "Safeguards"
  for t in gitleaks trufflehog; do
    if command -v "$t" >/dev/null 2>&1; then echo "  $t: installed"; else echo "  $t: not installed"; fi
  done
  if [ -f .pre-commit-config.yaml ]; then
    grep -qiE 'gitleaks|trufflehog|detect-secrets' .pre-commit-config.yaml && echo "  pre-commit: secret scanning hook configured" \
      || { echo "  pre-commit: present, no secret-scanning hook"; INFO=$((INFO+1)); }
  else echo "  pre-commit: no .pre-commit-config.yaml"; INFO=$((INFO+1)); fi
  if git ls-files -co --exclude-standard "${HEAVY[@]}" | grep -qE '(^|/)(Dockerfile|Containerfile)[^/]*$'; then
    if [ -f .dockerignore ]; then echo "  docker: .dockerignore present"; else echo "  docker: Dockerfile without .dockerignore (build context can ship .env and agent files)"; INFO=$((INFO+1)); fi
  fi

  printf '\nCOUNTS must=%d should=%d info=%d\n' "$MUST" "$SHOULD" "$INFO"
  [ "${STRICT:-0}" = 1 ] && [ "$MUST" -gt 0 ] && return 3
  return 0
}

apply_changes(){
  [ "${YES:-0}" = 1 ] || die "apply requires --yes (only after the human approved the diff from 'audit' or 'render')"
  local P bdir; P="$(mktmp)"; render > "$P" || die "render failed"
  [ -s "$P" ] || die "rendered file is empty; refusing to write"
  if [ -f .gitignore ] && cmp -s .gitignore "$P"; then echo "gitignore-ninja: .gitignore already up to date"; return 0; fi
  bdir="$(git rev-parse --git-path project-ninja)"; mkdir -p "$bdir"
  [ -f .gitignore ] && cp .gitignore "$bdir/gitignore.$(date +%Y%m%d-%H%M%S).bak" && echo "backup: $bdir/"
  cp "$P" .gitignore && echo "wrote: $ROOT/.gitignore"
}

# --------------------------------------------------------------------- main
cmd="${1:-}"; shift || true
while [ $# -gt 0 ]; do
  case "$1" in
    --stacks) STACKS_OVERRIDE="${2:-}"; shift 2 ;;
    --stacks=*) STACKS_OVERRIDE="${1#*=}"; shift ;;
    --no-history) NO_HISTORY=1; shift ;;
    --strict) STRICT=1; shift ;;
    --yes) YES=1; shift ;;
    *) die "unknown option: $1" ;;
  esac
done

case "$cmd" in
  detect) require_repo; detect_stacks ;;
  render) require_repo; render ;;
  blocks) require_repo; blocks_status ;;
  audit)  require_repo; audit ;;
  apply)  require_repo; apply_changes ;;
  ""|-h|--help|help) sed -n '2,15p' "$0" ;;
  *) die "unknown subcommand: $cmd (try --help)" ;;
esac
