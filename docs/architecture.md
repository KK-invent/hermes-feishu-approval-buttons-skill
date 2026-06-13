# Architecture

## Data Flow

When a Hermes Agent emits a command with `#HERMES_HDR` / `#HERMES_BTN` metadata, the following chain executes:

```text
┌─────────────────────────────────────────────────────────────────┐
│  Hermes Agent                                                   │
│  terminal("#HERMES_HDR:... \n #HERMES_BTN:... \n curl ...")     │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  tools/approval.py                                              │
│  _extract_hermes_button_metadata(command)                       │
│    → strips #HERMES_HDR / #HERMES_BTN                           │
│    → returns (clean_command, button_labels, header_title)        │
│  check_all_command_guards(clean_command)                         │
│    → builds approval_data with button_labels + header_title     │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  gateway/run.py                                                 │
│  Forwards approval_data (incl. button_labels, header_title)     │
│  to the platform adapter via send_exec_approval()               │
└──────────────────────────┬──────────────────────────────────────┘
                           │
               ┌───────────┴───────────┐
               ▼                       ▼
┌──────────────────────┐  ┌────────────────────────────────┐
│  gateway/platforms/  │  │  hermes-feishu-streaming-card   │
│  feishu.py           │  │  (sidecar, if installed)        │
│                      │  │                                 │
│  Renders approval    │  │  Intercepts interaction via     │
│  card with custom    │  │  interaction.requested hook     │
│  button labels       │  │  Renders buttons inside the     │
│  via Feishu Card API │  │  streaming card                 │
└──────────┬───────────┘  └──────────────┬─────────────────┘
           │                             │
           └──────────┬──────────────────┘
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│  Feishu / Lark Client                                           │
│                                                                 │
│  ┌───────────────────────────────────────────────────────┐      │
│  │  Card Header: 下一步怎么做？                            │      │
│  │                                                       │      │
│  │  [方案A]  [方案B]  [方案C]  [取消]                      │      │
│  └───────────────────────────────────────────────────────┘      │
└──────────────────────────┬──────────────────────────────────────┘
                           │ user clicks
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  tools/terminal_tool.py                                         │
│  Receives approval result with choice                           │
│  → "Command required approval (...). Choice: once."             │
└─────────────────────────────────────────────────────────────────┘
```

## Key Components

| Component | File | Responsibility |
|-----------|------|----------------|
| Metadata parser | `tools/approval.py` | Extract `#HERMES_HDR` / `#HERMES_BTN` from command |
| Approval guard | `tools/approval.py` | Build `approval_data`, trigger approval flow |
| Gateway relay | `gateway/run.py` | Forward metadata to platform adapter |
| Feishu adapter | `gateway/platforms/feishu.py` | Render Feishu card with custom buttons |
| Streaming card | `hermes_feishu_card/` | Alternative rendering path (sidecar) |
| Result reporter | `tools/terminal_tool.py` | Include user's `Choice:` in tool output |

## Two Rendering Paths

### Path A: Native Feishu Adapter (Default)

The gateway calls `feishu.py` → `send_exec_approval()` directly. This builds a Feishu card JSON with `action.actions[]` buttons and sends it via the Feishu Open API.

### Path B: Streaming Card Sidecar

When `hermes-feishu-streaming-card` is installed, it hooks into the approval flow via `interaction.requested`. The sidecar renders buttons inside its own streaming card context. This path requires the sidecar to correctly propagate `button_labels` and `header_title` from `approval_data`.

If Path B fails to render buttons correctly (plain text instead of clickable buttons), the fix is in the sidecar package — see [SKILL.md § Streaming Card Plugin Patch Points](../SKILL.md#streaming-card-plugin-patch-points).
