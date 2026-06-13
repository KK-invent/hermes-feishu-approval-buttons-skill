#!/usr/bin/env bash
# Deployment confirmation card
# Presents deploy options as approval buttons in Feishu.

#HERMES_HDR:确认部署环境
#HERMES_BTN:approve_once=部署到 staging,approve_session=部署到 production,deny=取消部署
curl -fsSL http://neverssl.com >/tmp/hermes_deploy_probe.out
