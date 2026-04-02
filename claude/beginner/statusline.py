#!/usr/bin/env python3
"""yasashii Claude Code statusline — ring meter with i18n labels
Based on: https://nyosegawa.com/posts/claude-code-statusline-rate-limits/
"""
import json, sys, os

if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')

data = json.load(sys.stdin)

R = '\033[0m'
DIM = '\033[2m'
BOLD = '\033[1m'
RINGS = ['○', '◔', '◑', '◕', '●']

lang = os.environ.get('YASASHII_LANG', 'en')

LABELS = {
    'ja': {'ctx': 'コンテキスト', '5h': '5時間', '7d': '7日間', 'cost': 'コスト'},
    'zh': {'ctx': '上下文', '5h': '5小时', '7d': '7天', 'cost': '费用'},
    'ko': {'ctx': '컨텍스트', '5h': '5시간', '7d': '7일', 'cost': '비용'},
    'en': {'ctx': 'context', '5h': '5h limit', '7d': '7d limit', 'cost': 'cost'},
}

L = LABELS.get(lang, LABELS['en'])


def gradient(pct):
    """Green → Yellow → Red gradient based on percentage"""
    if pct < 50:
        r = int(pct * 5.1)
        return f'\033[38;2;{r};200;80m'
    else:
        g = int(200 - (pct - 50) * 4)
        return f'\033[38;2;255;{max(g, 0)};60m'


def ring(pct):
    idx = min(int(pct / 25), 4)
    return RINGS[idx]


def fmt(label, pct):
    p = round(pct)
    return f'{DIM}{label}{R} {gradient(pct)}{ring(pct)} {p}%{R}'


# Model name
model = data.get('model', {}).get('display_name', 'Claude')
parts = [f'{BOLD}{model}{R}']

# Context window
ctx = data.get('context_window', {}).get('used_percentage')
if ctx is not None:
    parts.append(fmt(L['ctx'], ctx))

# 5-hour rate limit
five = data.get('rate_limits', {}).get('five_hour', {}).get('used_percentage')
if five is not None:
    parts.append(fmt(L['5h'], five))

# 7-day rate limit
week = data.get('rate_limits', {}).get('seven_day', {}).get('used_percentage')
if week is not None:
    parts.append(fmt(L['7d'], week))

# Cost
cost = data.get('cost', {}).get('total_cost_usd')
if cost is not None:
    parts.append(f'{DIM}{L["cost"]}{R} ${cost:.2f}')

print('  '.join(parts), end='')
