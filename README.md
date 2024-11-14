# Lighthouse CI Server <img src="https://raw.githubusercontent.com/GoogleChrome/lighthouse/refs/heads/main/assets/lighthouse-logo_512px.png" alt="Google Lighthouse Logo" align="right" height="auto" width="256"/>

[![License](https://img.shields.io/github/license/fmjstudios/lhci?label=License)](https://opensource.org/license/gpl-3-0)
[![Language](https://img.shields.io/github/languages/top/fmjstudios/lchi?label=JavaScript&logo=javascript)](https://ecma-international.org/publications-and-standards/standards/ecma-262/)
[![GitHub Release](https://img.shields.io/github/v/release/fmjstudios/lchi?label=Release)][github_releases]
[![GitHub Activity](https://img.shields.io/github/commit-activity/m/fmjstudios/lchi?label=Commits)][github_commits]
[![Renovate](https://img.shields.io/badge/Renovate-enabled-brightgreen?logo=renovate&logoColor=1A1F6C)][renovate]
[![PreCommit](https://img.shields.io/badge/PreCommit-enabled-brightgreen?logo=precommit&logoColor=FAB040)][precommit]

**L**ight**h**ouse **CI** (or `LHCI`) is a [Node.js][node.js]-based server for the storage and review of [Google Lighthouse][lighthouse]
report data. The server saves historical Lighthouse data displays it in various dashboards and offers and in-depth build comparison UI to
uncover differences between CI builds. During CI we export the results to the `LHCI` server using a component capable of exporting it to
`LHCI` like the [`lighthouse-ci-action`][lighthouse_ci_action] or different tools like [Unlighthouse][unlighthouse].

## ✨ TL;DR

```shell
# run the latest LHCI image
docker run -p 9000:9001 fmjstudios/lhci:latest
```

### 🔃 Contributing

Refer to our [documentation for contributors][contributing] for contributing guidelines, commit message
formats and versioning tips.

### 📥 Maintainers

This project is owned and maintained by [FMJ Studios][org] refer to the [`AUTHORS`][authors] or [`CODEOWNERS`][owners]
for more information.

### ©️ Copyright

- _Assets provided by:_ **[Google Lighthouse][lighthouse]**
- _Sources provided by:_ **[FMJ Studios][org]** under the **[GPL-3.0 License][license]**

<!-- INTERNAL REFERENCES -->

<!-- Project references -->

<!-- File references -->

[license]: LICENSE
[contributing]: docs/CONTRIBUTING.md
[authors]: .github/AUTHORS
[owners]: .github/CODEOWNERS

<!-- General links -->

[org]: https://github.com/fmjstudios
[node.js]: https://nodejs.org/
[lighthouse]: https://github.com/GoogleChrome/lighthouse
[lighthouse_ci_action]: https://github.com/treosh/lighthouse-ci-action
[unlighthouse]: https://unlighthouse.dev/
[github_releases]: https://github.com/fmjstudios/gopskit/releases
[github_commits]: https://github.com/fmjstudios/gopskit/commits/main/

<!-- Third-party -->

[renovate]: https://renovatebot.com/
[precommit]: https://pre-commit.com/
