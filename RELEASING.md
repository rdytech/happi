# Releasing happi

Publishing is only ever done by GitHub Actions (`.github/workflows/release.yml`), triggered by
a `vX.Y.Z` tag whose commit is reachable from `develop`. Tags on any other branch are rejected by
the workflow before anything is built. No one needs local publishing credentials — the workflow
authenticates to RubyGems.org via OIDC trusted publishing and to GitHub Packages via the
Actions-provided `GITHUB_TOKEN`.

## Cutting a release

1. Bump `Happi::VERSION` in `lib/happi/version.rb`.
2. Move the entries under `## [Unreleased]` in `CHANGELOG.md` to a new `## [X.Y.Z] - YYYY-MM-DD`
   heading.
3. Commit both changes and get them onto `develop` (PR + merge, as normal).
4. From an up-to-date `develop`, tag the commit and push the tag:

   ```bash
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```

5. Watch the "Release" workflow run in the Actions tab.
6. Confirm the new version shows up on [rubygems.org](https://rubygems.org/gems/happi) and on
   [GitHub Packages](https://github.com/rdytech/happi/pkgs/rubygems/happi).

## One-time setup

- **RubyGems.org**: an existing owner of the `happi` gem must add a Trusted Publisher for
  `rdytech/happi`, workflow `release.yml` (no environment). See
  [Trusted Publishing: adding a publisher](https://guides.rubygems.org/trusted-publishing/adding-a-publisher/).
  Until this is done, the "Publish to RubyGems.org" step will fail.
- **GitHub Packages**: nothing to configure — the workflow's `packages: write` permission is
  sufficient.
