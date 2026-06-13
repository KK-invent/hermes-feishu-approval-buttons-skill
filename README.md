# hermes-feishu-approval-buttons-skill

A Hermes Agent skill for using Feishu/Lark approval cards as clickable custom decision buttons.

It documents the practical workaround for Feishu clients where `clarify` renders as plain text, plus the compatibility patch points for `hermes-feishu-streaming-card`.

## What it covers

- `#HERMES_HDR` / `#HERMES_BTN` syntax
- Manual approval mode requirement
- Stable approval-card test recipe
- Hermes core patch points
- `hermes-feishu-streaming-card` sidecar/rendering pitfalls
- Verification checklist

## Install locally

Copy this repository into your Hermes skills directory:

```bash
mkdir -p ~/.hermes/skills/feishu/hermes-feishu-approval-buttons
cp SKILL.md ~/.hermes/skills/feishu/hermes-feishu-approval-buttons/SKILL.md
```

Then start a new Hermes session and load:

```text
skill_view(name="hermes-feishu-approval-buttons")
```

## Publish

Create an empty GitHub repo, then from this directory:

```bash
git remote add origin git@github.com:KK-invent/hermes-feishu-approval-buttons-skill.git
git branch -M main
git push -u origin main
```

## License

MIT
