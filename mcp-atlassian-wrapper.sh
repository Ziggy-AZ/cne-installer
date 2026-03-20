#!/bin/bash
export ATLASSIAN_API_TOKEN=$(op read "op://Private/Atlassian MCP/Section_zqtsil445nmuisel464mlbuez4/api_key")
export ATLASSIAN_BASE_URL=https://liferay.atlassian.net
export ATLASSIAN_EMAIL=allen.ziegenfus@liferay.com
npx -y mcp-atlassian