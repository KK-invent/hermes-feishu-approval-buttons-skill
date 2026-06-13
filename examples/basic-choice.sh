#!/usr/bin/env bash
# Basic 4-option choice card
# Copy this into a Hermes terminal() call to test approval buttons in Feishu.

#HERMES_HDR:下一步怎么做？
#HERMES_BTN:approve_once=方案A,approve_session=方案B,approve_always=方案C,deny=取消
pkill -9 __hermes_fake_process_for_approval_card_basic__ 2>/dev/null || true
