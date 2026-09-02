# hexmonger-policies

The privacy policies and support pages for Hexmonger apps, as plain static
HTML, published with GitHub Pages. One directory per app:

| App | Pages |
| --- | --- |
| Castles in the Sand | [`castles-in-the-sand/`](castles-in-the-sand/) (support), [`castles-in-the-sand/privacy.html`](castles-in-the-sand/privacy.html) |

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
every push to `main`, and turns Pages on for the repository the first
time it runs (`actions/configure-pages` with `enablement: true`), so
nothing needs clicking in the repository settings.

## Where the source lives

This tree is authored in the app repositories — for Castles in the Sand,
`store/site/` in that repo — and published here with a subtree push, so
the policy text is versioned next to the code it describes:

```sh
# from the Castles-in-the-Sand checkout, once the public repo exists
git subtree split --prefix=store/site -b policies-site
git push git@github.com:nvoorhies/hexmonger-policies.git policies-site:main
git branch -D policies-site
```

Edit the pages in the app repo, not here.
