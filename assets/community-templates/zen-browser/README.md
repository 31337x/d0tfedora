# Zen Browser

Applies Noctalia colors to Zen's browser interface and internal pages through `userChrome.css` and `userContent.css`. Both generated stylesheets contain dark and light palettes selected by `prefers-color-scheme`; this is not a general website theme.

## Setup

1. Install and launch Zen at least once to create a profile.
2. Back up each profile's `chrome/userChrome.css`, `chrome/userContent.css` and `user.js` if they exist.
3. Enable **Zen Browser** in **Noctalia Settings -> Templates**.

The hook only discovers profiles with a `prefs.js` file exactly one profile-directory level below either `$XDG_CONFIG_HOME/zen` (normally `~/.config/zen`) or `~/.zen`. It does nothing when those roots are absent. Other layouts, including sandbox-specific profile locations, are not searched; they need manual imports and preference setup or an adapted hook.

## Generated files

- `$XDG_CACHE_HOME/noctalia/zen-browser/zen-userChrome.css`
- `$XDG_CACHE_HOME/noctalia/zen-browser/zen-userContent.css`

The hook uses `~/.cache` when `XDG_CACHE_HOME` is unset. Profile CSS imports these files by absolute path, so keep the generated cache files available.

## Profile changes

For every discovered profile, the Bash hook creates the `chrome` directory and these files as necessary:

- `chrome/userChrome.css`: prepends an `@import` of the generated chrome stylesheet.
- `chrome/userContent.css`: prepends an `@import` of the generated content stylesheet.
- `user.js`: sets `devtools.chrome.enabled` and `toolkit.legacyUserProfileCustomizations.stylesheets` to `true`.

Existing lines referencing the corresponding generated stylesheet are removed before its import is prepended. Existing lines mentioning either preference are removed from `user.js` before the enabled values are appended. Other content is retained. The hook writes through existing symlinks and creates no backups; review these changes if you already maintain custom CSS or preferences.

Both template entries run this hook synchronously to prevent concurrent profile edits. It requires Bash and standard utilities including `find`, `sed`, `mktemp` and `cmp`. It does not restart Zen or send a live-reload command.

The shipped content stylesheet marks its `about:logins` and `about:protections` sections as no longer working; coverage of those pages is not guaranteed.
