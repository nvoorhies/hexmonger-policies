#!/usr/bin/env bash
# Checks the layout this site is built on: one game directory per app, and in
# each of them exactly one support page (index.html) and one privacy policy
# (privacy.html), cross-linked, and both listed on the root page and the 404.
#
# Run it from anywhere; it checks the repository it lives in.
#
#   scripts/check-pages.sh
#
set -uo pipefail

cd "$(dirname "$0")/.."

fail=0
problem() { printf '  %s\n' "$*" >&2; fail=1; }

# A game directory is any top-level directory that is not tooling.
games=()
for d in */; do
  d=${d%/}
  case $d in .*|scripts) continue ;; esac
  games+=("$d")
done

if [ ${#games[@]} -eq 0 ]; then
  problem "no game directories found"
  exit 1
fi

echo "Game directories: ${games[*]}"

# --- one support page and one privacy page per game directory ---------------
for g in "${games[@]}"; do
  [ -f "$g/index.html" ]   || problem "$g: no support page ($g/index.html)"
  [ -f "$g/privacy.html" ] || problem "$g: no privacy policy ($g/privacy.html)"

  # Nothing else: a second policy in a directory is a policy that will drift.
  while IFS= read -r extra; do
    problem "$g: unexpected page $extra (a game directory holds index.html and privacy.html only)"
  done < <(find "$g" -name '*.html' ! -path "$g/index.html" ! -path "$g/privacy.html")
done

# A privacy policy outside a game directory has no app it belongs to, and would
# be a second copy of one that is already published under its own app.
for stray in *.html; do
  case $stray in index.html|404.html) continue ;; esac
  problem "root: unexpected page $stray (policies belong in a game directory)"
done

# --- the two pages of a pair point at each other ----------------------------
for g in "${games[@]}"; do
  [ -f "$g/index.html" ] && [ -f "$g/privacy.html" ] || continue

  grep -q 'href="privacy.html"' "$g/index.html" ||
    problem "$g: the support page does not link to its privacy policy"

  # Either relatively, or by the published URL (the generated Goblin Hunt page
  # names its absolute address rather than a relative one).
  grep -qE 'href="(\./|index\.html|https://[^"]*/'"$g"'/)"' "$g/privacy.html" ||
    problem "$g: the privacy policy does not link back to its support page"
done

# --- the hub pages list every page ------------------------------------------
for g in "${games[@]}"; do
  grep -q "href=\"$g/\"" index.html ||
    problem "index.html: does not link to $g/ (support)"
  grep -q "href=\"$g/privacy.html\"" index.html ||
    problem "index.html: does not link to $g/privacy.html"

  grep -q "href=\"/$g/\"" 404.html ||
    problem "404.html: does not list $g/ (support)"
  grep -q "href=\"/$g/privacy.html\"" 404.html ||
    problem "404.html: does not list $g/privacy.html"
done

# --- every page is a page, and every local link lands on a file -------------
while IFS= read -r page; do
  grep -q '<title>' "$page" || problem "$page: no <title>"

  while IFS= read -r href; do
    case $href in
      http*|mailto:*|'#'*|'') continue ;;
      /*) target=".${href}" ;;
      *)  target="$(dirname "$page")/$href" ;;
    esac
    case $target in */) target="${target}index.html" ;; esac
    [ -e "$target" ] || problem "$page: link to $href goes nowhere"
  done < <(grep -oE 'href="[^"]*"' "$page" | sed 's/^href="//; s/"$//' | sort -u)
done < <(find . -name '*.html' -not -path './.git/*' | sort)

if [ "$fail" -ne 0 ]; then
  echo "FAIL: the pages are not laid out as described above." >&2
  exit 1
fi

echo "OK: ${#games[@]} game directories, each with one support page and one privacy policy."
