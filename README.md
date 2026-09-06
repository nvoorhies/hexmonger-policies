# hexmonger-policies

The privacy policies and support pages for Hexmonger apps, as plain static
HTML, published with GitHub Pages. One directory per app:

| App | Pages |
| --- | --- |
| Castles in the Sand | [`castles-in-the-sand/`](castles-in-the-sand/) (support), [`castles-in-the-sand/privacy.html`](castles-in-the-sand/privacy.html) |
| Goblin Hunt | [`goblin-hunt/`](goblin-hunt/) (support), [`goblin-hunt/privacy.html`](goblin-hunt/privacy.html) |

Published at `https://nvoorhies.github.io/hexmonger-policies/…`. The
plan is for `https://hexmonger.com/<app>/privacy.html` and
`https://hexmonger.com/<app>/` to redirect here; until then the
`github.io` URLs are the ones the stores get, and a redirect later does
not break them.

Every page is self-contained — no build step, no shared assets, no
JavaScript — so a page is exactly the file in this repo, and the store
reviewer sees exactly what `git log` says was there on the date it says.

## Publishing

`.github/workflows/pages.yml` deploys the repository root to Pages on
every push to `main`. Pages itself has to be switched on once, by hand:
**Settings → Pages → Build and deployment → Source: GitHub Actions**.
(The workflow asks `actions/configure-pages` to do it, but the
workflow's own token is not allowed to create a Pages site — the first
run fails with "Resource not accessible by integration" until the
switch is set; re-run it afterwards.)

## Where the source lives

Policy text is versioned next to the code it describes, so most of what
is here is copied in rather than written here. Where a page has a source,
**edit the source, not the copy.**

### Castles in the Sand

The whole tree was authored as `store/site/` in that repo and published
with a subtree push:

```sh
# from the Castles-in-the-Sand checkout
git subtree split --prefix=store/site -b policies-site
git push git@github.com:nvoorhies/hexmonger-policies.git policies-site:main
git branch -D policies-site
```

That worked while there was one app. With a second, the subtree can no
longer own the root — one app's push would erase the other's directory —
so pages arrive per app instead.

### Goblin Hunt

`goblin-hunt/privacy.html` is **generated**, not written. Its source is
`legal/privacy-policy.md` in [nvoorhies/goblin-hunt][gh], rendered by
`scripts/build-legal-html.sh` in that repo, where CI's `--check` run
keeps the page and the markdown from drifting apart. Publish a change by
copying the built file across byte for byte:

```sh
# from a goblin-hunt checkout, after scripts/build-legal-html.sh
cp legal/privacy-policy.html ../hexmonger-policies/goblin-hunt/privacy.html
```

Editing it here instead would fork a legal document away from the one the
game links to and the store questionnaires were filled in from.

`goblin-hunt/index.html` (support) has no source elsewhere and is
authored in this repo. It describes shipped behaviour — save-slot
messages, where the ads appear, what the Settings rows say — so it needs
a read when any of that changes.

[gh]: https://github.com/nvoorhies/goblin-hunt

## Policy URLs the apps are built against

A published page is only useful at the address the app was shipped
pointing at. Goblin Hunt has
`https://hexmonger.com/privacy.html` compiled into it
(`PrivacyConsent.POLICY_URL`) and named in both store listings — note
that it carries **no app segment**, unlike the
`hexmonger.com/<app>/privacy.html` shape above. Whatever serves
`hexmonger.com` has to land that URL on `goblin-hunt/privacy.html` here,
or the constant in the game has to change and ship. Neither is done
yet.
