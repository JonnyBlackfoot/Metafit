# Bible Reading MCP Server

An MCP (Model Context Protocol) server that helps you engage with Scripture based on your life — anxieties, relationships, purpose, grief, work, and more. Works with **Claude**, **Claude Code**, and any other MCP-compatible AI client.

## Tools

| Tool | What it does |
|------|--------------|
| `get_verse` | Fetch any verse or passage by reference (e.g. `John 3:16`, `Psalm 23`, `Matthew 5:1-12`) |
| `search_by_life_topic` | Get scriptures for a life topic: anxiety, grief, purpose, marriage, finances, etc. |
| `list_life_topics` | See all 24 supported life topics |
| `get_verse_of_the_day` | A curated verse that cycles daily through the year |
| `get_chapter` | Fetch an entire chapter |
| `list_reading_plans` | Browse multi-day reading plans |
| `get_daily_plan_reading` | Get today's (or any day's) reading from a plan |
| `reflect_on_life` | Describe your situation in natural language → receive tailored scriptures + a reflection prompt |

## Supported Life Topics

anxiety · depression · grief · fear · purpose · forgiveness · relationships · marriage · finances · work · health · faith · temptation · loneliness · anger · identity · hope · wisdom · prayer · salvation · strength · family · loss · peace

Natural-language aliases also work: "stressed", "scared", "alone", "who am I?", "job", "sick", "money", etc.

## Bible Translations

| Code | Translation |
|------|------------|
| `web` | World English Bible (default, public domain) |
| `kjv` | King James Version |
| `bbe` | Bible in Basic English |
| `asv` | American Standard Version |
| `ylt` | Young's Literal Translation |

Verse text is fetched live from [bible-api.com](https://bible-api.com) — free, no API key required.

## Reading Plans

| Plan ID | Name | Length |
|---------|------|--------|
| `bible_in_a_year` | Bible in a Year | 365 days |
| `new_testament_90` | New Testament in 90 Days | 90 days |
| `psalms_30` | Psalms in 30 Days | 30 days |
| `proverbs_31` | Proverbs in a Month | 31 days |
| `gospels_28` | Life of Jesus (Four Gospels) | 28 days |
| `sermon_on_the_mount` | Sermon on the Mount | 7 days |

## Setup

### 1. Install dependencies

```bash
cd bible-mcp
pip install -r requirements.txt
```

### 2. Test the server

```bash
python server.py
```

### 3. Connect to Claude Code

The `.mcp.json` at the repo root registers this server automatically for Claude Code sessions in this project.

To add it globally to your `~/.claude/claude.json`:

```json
{
  "mcpServers": {
    "bible-reading": {
      "command": "python3",
      "args": ["/absolute/path/to/Metafit/bible-mcp/server.py"]
    }
  }
}
```

### 4. Use with ChatGPT / OpenAI

Any MCP-compatible bridge (e.g. [openai-mcp-bridge](https://github.com/wong2/chatgpt-mcp)) can expose these tools to ChatGPT. Point it at `server.py`.

## Example Usage

```
# In Claude Code or any MCP client:

get_verse("John 3:16", "kjv")

search_by_life_topic("anxiety")

reflect_on_life("I just lost my job and feel hopeless about the future")

get_verse_of_the_day()

get_daily_plan_reading("bible_in_a_year")

get_chapter("Psalm", 23)
```

## Architecture

```
bible-mcp/
├── server.py        # MCP server — tool definitions and entry point
├── bible_api.py     # Live verse fetching from bible-api.com
├── life_topics.py   # Life situation → scripture mapping (24 topics, ~120 passages)
├── reading_plans.py # Built-in multi-day reading plans
└── requirements.txt # mcp, httpx
```
