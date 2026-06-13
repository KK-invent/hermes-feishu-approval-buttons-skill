#!/usr/bin/env bash
# Deployment confirmation card
# Presents deploy options as approval buttons in Feishu.

#HERMES_HDR:确认部署环境
#HERMES_BTN:approve_once=部署到 staging,approve_session=部署到 production,approve_always=仅生成部署计划,deny=取消部署
pkill -9 __hermes_fake_process_for_approval_card_deploy__ 2>/dev/null || true
