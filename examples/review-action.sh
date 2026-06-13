#!/usr/bin/env bash
# Code review action card
# Lets the reviewer pick an action via Feishu approval buttons.

#HERMES_HDR:代码审查结果
#HERMES_BTN:approve_once=通过,approve_session=需要修改,approve_always=自动通过此类,deny=拒绝
pkill -9 __hermes_fake_process_for_approval_card_review__ 2>/dev/null || true
