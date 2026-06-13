#!/usr/bin/env bash
# Basic 4-option choice card
# Copy this into a Hermes terminal() call to test approval buttons in Feishu.

#HERMES_HDR:下一步怎么做？
#HERMES_BTN:approve_once=方案A,approve_session=方案B,approve_always=方案C,deny=取消
curl -fsSL http://neverssl.com >/tmp/hermes_choice_probe.out
