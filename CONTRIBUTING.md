# Contributing

Thanks for your interest in improving the Hermes Feishu Approval Buttons skill!

## How to Contribute

1. **Fork** the repository
2. **Create a branch** from `main` (`git checkout -b feat/my-change`)
3. **Make your changes**
4. **Test** using the [test recipe](SKILL.md#test-recipe) in a real Feishu environment
5. **Update** `CHANGELOG.md` under `## Unreleased`
6. **Submit** a pull request

## What We're Looking For

- Bug fixes for specific Feishu client versions (Desktop/Mobile/Web)
- Additional troubleshooting entries from real-world usage
- Patch point updates for new Hermes or `hermes-feishu-streaming-card` versions
- Translations or localization improvements
- Edge cases and known limitations

## Guidelines

- Keep SKILL.md as the single source of truth for the skill content
- Test changes against a live Feishu environment before submitting
- Use [Keep a Changelog](https://keepachangelog.com/) format for CHANGELOG.md
- One logical change per PR

## Reporting Issues

If you hit a problem, open an issue with:

- Your Hermes version
- Whether `hermes-feishu-streaming-card` is installed (and its version)
- Which Feishu client you're using (Desktop / Mobile / Web)
- The output of `hermes config get approvals.mode`
- Screenshots of the card rendering (if applicable)
