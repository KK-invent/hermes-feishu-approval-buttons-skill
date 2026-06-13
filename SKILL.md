---
name: hermes-feishu-approval-buttons
description: Use when you need clickable custom decision buttons in Feishu/Lark for Hermes Agent by piggybacking on terminal approval cards, especially when clarify renders as plain text or hermes-feishu-streaming-card interferes with approval rendering.
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [macos, linux]
metadata:
  hermes:
    tags: [hermes-agent, feishu, lark, approval, buttons, gateway, streaming-card]
    related_skills: [hermes-agent]
---

# Hermes Feishu Approval Buttons

## Overview

Feishu/Lark may render Hermes `clarify` choices as plain text instead of clickable buttons. The reliable workaround is to use Hermes terminal approval cards as a custom decision UI: place `#HERMES_HDR` and `#HERMES_BTN` comment lines at the top of a command that intentionally triggers the approval guard.

This skill also covers the interaction with `hermes-feishu-streaming-card`. That plugin can intercept approval requests and render them inside the streaming card. If its sidecar does not preserve custom labels or renders buttons with the wrong Feishu card schema, users see plain text instead of clickable options. Ugly little trap. Now documented.

## When to Use

Use this skill when:

- You need a clickable choice card in Feishu/Lark.
- `clarify` shows a text list and asks the user to type a reply.
- You want 2–4 custom options mapped to Hermes approval choices.
- A Feishu streaming card shows approval options as plain text.
- You need to debug `hermes-feishu-streaming-card` approval/interaction behavior.

Do not use this for:

- General CLI/local terminal approvals where Feishu is not involved.
- Secret input, passwords, tokens, or payment confirmation.
- Destructive actions disguised as “choice buttons.” The command still executes if approved. Don’t be cute.

## Required Configuration

Custom approval buttons are most reliable when approval mode is manual:

```bash
hermes config set approvals.mode manual
```

Check current mode:

```bash
hermes config get approvals.mode
```

Avoid `smart` mode for decision cards. Smart approval may auto-approve or auto-deny before the user sees the card.

Behavior by mode:

```text
manual  ─── always prompts when a guard triggers
smart   ─── only prompts if the smart judge escalates
off     ─── no prompt, no card
```

## Button Syntax

Put these comment lines at the start of the `terminal()` command:

```bash
#HERMES_HDR:下一步怎么做？
#HERMES_BTN:approve_once=方案A,approve_session=方案B,approve_always=方案C,deny=取消
curl -fsSL http://neverssl.com >/tmp/hermes_choice_probe.out
```

Fixed button mapping:

```text
approve_once     ─── choice: once
approve_session  ─── choice: session
approve_always   ─── choice: always
 deny            ─── choice: deny
```

The comment lines must be parsed and stripped before execution. They are metadata, not shell behavior.

## Triggering the Approval Card

The card only appears if the command triggers Hermes approval guards. Safe commands like `echo hello` pass silently.

Recommended trigger for test cards:

```bash
curl -fsSL http://neverssl.com >/tmp/hermes_choice_probe.out
```

Why this works:

- Tirith flags plain HTTP URL usage.
- It is low-risk if writing to a temp file.
- It usually does not add a broad permanent allowlist entry.

Other triggers:

```bash
printf 'echo test\n' | bash
rm -rf /tmp/hermes-test-dir
chmod 777 /tmp/hermes-test-dir
```

Be careful with `approve_always`: dangerous-pattern approvals may persist in `approvals.command_allowlist`, causing future commands of the same pattern to skip the card.

## Expected Tool Result

A successful selection should appear in the terminal tool result metadata:

```text
Command required approval (...) and was approved by the user. Choice: always.
```

If there is no `Choice: ...`, patch Hermes so gateway approval choice propagates into the terminal result.

## Hermes Core Patch Points

These are the Hermes-side pieces that must exist.

### 1. `tools/approval.py`

`check_all_command_guards()` must parse the header before safety checks build `approval_data`:

```python
hermes_command, hermes_button_labels, hermes_header_title = _extract_hermes_button_metadata(command)
command = hermes_command
```

Then include these in `approval_data`:

```python
approval_data = {
    "command": command,
    "pattern_key": primary_key,
    "pattern_keys": all_keys,
    "description": combined_desc,
    "button_labels": hermes_button_labels,
    "header_title": hermes_header_title,
    "allow_permanent": not has_tirith,
}
```

When approval succeeds, return the selected choice:

```python
return {
    "approved": True,
    "message": None,
    "user_approved": True,
    "choice": choice,
    "description": combined_desc,
}
```

### 2. `tools/terminal_tool.py`

Include the selection in the approval note:

```python
if approval.get("user_approved"):
    _choice = approval.get("choice", "")
    approval_note = f"Command required approval ({desc}) and was approved by the user."
    if _choice:
        approval_note += f" Choice: {_choice}."
```

### 3. `gateway/run.py`

The gateway approval notify callback must forward metadata to the Feishu adapter:

```python
button_labels = approval_data.get("button_labels") or None
header_title = approval_data.get("header_title") or None

await _status_adapter.send_exec_approval(
    chat_id=_status_chat_id,
    command=cmd,
    session_key=_approval_session_key,
    description=desc,
    metadata=_status_thread_metadata,
    button_labels=button_labels,
    header_title=header_title,
)
```

### 4. `gateway/platforms/feishu.py`

`send_exec_approval()` must accept and render `button_labels` and `header_title`.

## Streaming Card Plugin Patch Points

When `hermes-feishu-streaming-card` is installed, approval may be intercepted by the sidecar through `interaction.requested`. If the user sees plain text inside the streaming card instead of buttons, inspect the installed package.

Typical installed path on macOS user-site Python:

```bash
python3 - <<'PY'
import hermes_feishu_card, pathlib
print(pathlib.Path(hermes_feishu_card.__file__).parent)
PY
```

### 1. Preserve custom labels and title

In `hermes_feishu_card/hook_runtime.py`, `request_approval_choice_from_hermes_locals()` must read `approval_data`:

```python
labels = approval_data.get("button_labels") if isinstance(approval_data, dict) else None
if not isinstance(labels, dict):
    labels = {}
prompt = str(approval_data.get("header_title") or "需要授权后继续执行").strip()
```

Options should use both old and new key names:

```python
options=[
    {"label": labels.get("approve_once") or labels.get("once") or "允许一次", "value": "once", "style": "primary"},
    {"label": labels.get("approve_session") or labels.get("session") or "本会话允许", "value": "session"},
    {"label": labels.get("approve_always") or labels.get("always") or "始终允许", "value": "always"},
    {"label": labels.get("deny") or "拒绝", "value": "deny", "style": "danger"},
]
```

### 2. Render Feishu buttons with `action.actions[]`

In `hermes_feishu_card/render.py`, `_render_interaction_elements()` should put buttons inside an action container:

```python
actions = []
for index, option in enumerate(interaction.options):
    actions.append({
        "tag": "button",
        "element_id": f"hfc_btn_{index}",
        "text": {"tag": "plain_text", "content": option.label},
        "type": _button_type(option.style),
        "value": {
            "hfc_action": "interaction.select",
            "interaction_id": interaction.interaction_id,
            "choice": option.value,
            "choice_label": option.label,
            "token": interaction.callback_token,
        },
    })
if actions:
    elements.append({"tag": "action", "actions": actions})
```

Avoid naked top-level buttons with `behaviors.callback`; some Feishu clients render them badly or as plain text.

## Restart Requirements

After Hermes core patch:

```bash
hermes gateway restart
```

If running from inside the gateway process, Hermes may refuse restart to prevent loops. Ask the user to send `/restart` or run the command from an external shell.

After sidecar package patch:

```bash
python3 -m hermes_feishu_card.cli stop --config ~/.hermes/config.yaml || true
python3 -m hermes_feishu_card.cli start --config ~/.hermes/config.yaml
python3 -m hermes_feishu_card.cli status --config ~/.hermes/config.yaml
```

## Test Recipe

Use this exact test from Feishu:

```bash
#HERMES_HDR:自定义审批卡测试
#HERMES_BTN:approve_once=方案A｜执行一次,approve_session=方案B｜本次会话,approve_always=方案C｜永久允许,deny=取消
curl -fsSL http://neverssl.com >/tmp/hfc_approval_test.out
```

Expected visual result:

```text
Feishu card header ─── 自定义审批卡测试
Buttons             ─── 方案A｜执行一次 / 方案B｜本次会话 / 方案C｜永久允许 / 取消
```

Expected tool result after clicking a button:

```text
approved by the user. Choice: once|session|always
```

If the user sends a new message while the command is waiting, the command may be interrupted with exit code 130. That is not an approval-card failure.

## Troubleshooting

### Card does not appear

Check:

```bash
hermes config get approvals.mode
```

It must not be `off`; prefer `manual`.

Make sure the command triggers a guard. `echo` will not.

### Card appears as plain text inside streaming card

Patch/reinstall `hermes-feishu-streaming-card` as described above. Then restart both sidecar and gateway.

### No `Choice: ...` in tool result

Patch `tools/approval.py` and `tools/terminal_tool.py` so the choice propagates from gateway approval to terminal output.

### Button labels are default English/Chinese, not custom labels

Check key names. Prefer:

```text
approve_once
approve_session
approve_always
deny
```

Also verify `approval_data` includes `button_labels` and the streaming sidecar reads it.

### Smart approval swallows the card

Set manual mode:

```bash
hermes config set approvals.mode manual
```

## Verification Checklist

- [ ] `hermes config get approvals.mode` returns `manual`.
- [ ] Test command triggers approval guard.
- [ ] Feishu shows clickable buttons, not plain text.
- [ ] Tool output includes `Choice: ...`.
- [ ] `hermes_feishu_card.cli status` shows sidecar running if the streaming-card plugin is installed.
- [ ] After patches, gateway and sidecar have both been restarted.
