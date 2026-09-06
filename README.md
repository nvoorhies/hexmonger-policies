# hexmonger-policies

The privacy policies and support pages for Hexmonger apps, as plain static
HTML, published with GitHub Pages. One directory per app:

| App | Support | Privacy policy |
| --- | --- | --- |
| Castles in the Sand | [`castles-in-the-sand/`](castles-in-the-sand/) | [`castles-in-the-sand/privacy.html`](castles-in-the-sand/privacy.html) |
| Goblin Hunt | [`goblin-hunt/`](goblin-hunt/) | [`goblin-hunt/privacy.html`](goblin-hunt/privacy.html) |

Published at `https://nvoorhies.github.io/hexmonger-policies/…`, and
meant to be reached as `https://policies.hexmonger.com/<app>/…` — the
shape Goblin Hunt already ships pointing at. That name does not resolve
yet; see "Policy URLs the apps are built against" for what is missing.

Every page is self-contained — no build step, no shared assets, no
JavaScript — so a page is exactly the file in this repo, and the store
reviewer sees exactly what `git log` says was there on the date it says.

## Layout

One directory per app, holding exactly two pages and nothing else:

| file | what it is | served at |
| --- | --- | --- |
| `<app>/index.html` | the support page | `<app>/` |
| `<app>/privacy.html` | the privacy policy | `<app>/privacy.html` |

No policy lives outside a game directory, and no game directory holds a
second one. A policy that exists twice is a policy that will drift from the
one the store reviewed and the shipped app links to, and the copy a reviewer
opens is then a coin toss. The root `index.html` and `404.html` list both
pages of every app.

`scripts/check-pages.sh` checks that, and fails with the specific
breakage:

```sh
scripts/check-pages.sh
```

- each app directory has its support page and its privacy policy, and no
  other page;
- no stray policy at the root;
- the two pages of a pair link to each other;
- `index.html` and `404.html` list both pages of every app;
- every local link lands on a file that exists, and every page has a title.

CI runs it on every push and pull request, and a layout that fails the
check does not deploy.

To add an app: make the directory, write `index.html` and `privacy.html`,
add both to `index.html` and `404.html`, and run the check.

## Publishing

`.github/workflows/pages.yml` deploys the site to Pages on every push to
`main` — the repository root, less `scripts/` and the tooling
directories, so what is served is the pages themselves.

Pages itself has to be switched on once, by hand:
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
pointing at. Goblin Hunt compiles its policy URL in as
`PrivacyConsent.POLICY_URL` and names the same one in both store
listings, so that address and this repo have to agree.

It is now `https://policies.hexmonger.com/goblin-hunt/privacy.html`,
after two corrections: [goblin-hunt#140][gh140] added the app segment,
which the site root had no room for once there was a second app, and
[goblin-hunt#141][gh141] moved it off the apex onto a subdomain of its
own. A subdomain can be pointed at this site with a DNS record; the
apex cannot, without deciding what the rest of `hexmonger.com` is for.

**That name does not resolve yet.** Two things are missing, and they
belong together — doing either alone is worse than doing neither:

- a `CNAME` file in this repo's root holding `policies.hexmonger.com`,
  which is what tells Pages to serve the site under that name;
- a DNS `CNAME` record for `policies.hexmonger.com` onto
  `nvoorhies.github.io`.

Configuring the name without the DNS record behind it can take the site
off the `github.io` address too, because Pages redirects the default
name onto the custom one once it is set. Land the DNS record first, or
both at once, and check that the pages answer before a store review
depends on them.

Until then the `github.io` URLs are the ones that work, and the ones to
give the stores.

Because the constant ships inside a build, changing it again costs a
release — so the copy of `goblin-hunt/privacy.html` here has to keep
naming the address the shipped game names. It is a generated file:
correcting it means re-copying from goblin-hunt, never editing here.

[gh140]: https://github.com/nvoorhies/goblin-hunt/pull/140
[gh141]: https://github.com/nvoorhies/goblin-hunt/pull/141
