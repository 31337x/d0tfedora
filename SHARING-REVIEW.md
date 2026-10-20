# Sharing review

Reviewed the project before its initial GitHub publication as d0tFedora.

- Reviewed all 248 original files, including hidden files, for credentials and personal paths. No nonempty API keys, private keys, recognized access tokens, email addresses, or private network addresses were found. This is a manual and pattern-based review, not a guarantee against every possible secret format.
- The saved Wallhaven API key is blank. Home paths use `__HOME__`; removed the local username example from the README. `/home/test` in plugin tests is synthetic fixture data.
- No existing Git history was present. The local repository is configured with a GitHub noreply author address. Publication through the connected GitHub service uses the account's default commit identity.
- Added ignore rules for environment files, common credential files, logs, editor state and backups. These rules do not prevent someone from adding secrets to tracked configuration later.
- Checked metadata containers for all 27 images. No EXIF GPS location pointers were found. The downloaded wallpaper `assets/Wallpapers/007.jpg` contains camera/lens serial-number metadata. Existing image metadata is retained; the downloaded images are not represented as photographs taken by this project's author.
- Wallpapers and community components are third-party assets. The owner explicitly confirmed permission to republish all assets and requested that none be excluded. Existing attribution and plugin license declarations are retained. No project-wide license has been imposed on third-party work.

Validation performed for this publication: Bash and POSIX-shell syntax, all JSON and TOML parsing, Python source and all seven embedded Python blocks, Niri configuration, Noctalia configuration, and installer dry run. Noctalia reports two expected warnings for disabled Notes and Wallhaven plugins. Installation, package transactions, reboot and greeter login have not been tested end to end.
