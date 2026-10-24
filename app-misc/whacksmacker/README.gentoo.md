# WhackSmacker 0.1.0-alpha.4 Gentoo packaging

Gentoo version: `0.1.0_alpha4`. Pinned upstream revision: `b06740a8604e9965daacf0ee5f677d06f6395f5c`, the source used by Docker alpha.4.

English (`l10n_en`) is required as the application's fallback. `l10n_zh-TW` enables the Traditional Chinese interface. Upstream's locale is `zh-Hant-TW`.

`wsm_study_*` selects built-in menu skeletons, not private curricula. All default off. Existing separately installed content is not deleted or hidden. `geo` is enabled by default and includes public geography assets and built-in geography menu entries. Disable it with `-geo` to omit both. Public linguistic terminology remains included. No private sibling repositories are needed at build time.

To display WSM_STUDY as a USE_EXPAND group, add to your existing make.conf (preserving other groups):

```sh
USE_EXPAND="${USE_EXPAND} WSM_STUDY"
WSM_STUDY="en fr ja"
```

Or select flags directly in package.use:

```text
app-misc/whacksmacker l10n_en l10n_zh-TW wsm_study_en wsm_study_fr wsm_study_ja
```

The ebuild compiles TypeScript from the pinned public source using a dependency distfile hosted as a Mushroom overlay GitHub Release asset (`distfiles-whacksmacker-0.1.0-alpha.4`). Manifest hashes pin both archives. No npm network access occurs in compile/install phases. Only production dependencies are installed.

Tests compile and stage installations with no study languages, Japanese/French, and all study languages plus both UI locales. They verify menu selection, locale availability, exclusion of private reading assets, staged CLI startup, and omission of TypeScript from installed runtime. These are targeted packaging tests, not the full upstream integration suite.
