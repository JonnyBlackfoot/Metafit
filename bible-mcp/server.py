#!/usr/bin/env python3
"""
Bible Reading MCP Server
Works with Claude, Claude Code, and any MCP-compatible AI client.

Tools:
  get_verse              — Fetch any Bible verse or passage by reference
  search_by_life_topic   — Get scriptures for a life situation
  list_life_topics       — See all supported life topics
  get_daily_plan_reading — Get a day's reading from a plan
  list_reading_plans     — Browse available reading plans
  get_verse_of_the_day   — Curated verse cycling through the year
  get_chapter            — Fetch an entire chapter
  reflect_on_life        — Describe your situation, receive tailored scriptures
"""

from __future__ import annotations

import datetime

import httpx
from mcp.server.mcpserver import MCPServer

from bible_api import fetch_passage, format_passage
from life_topics import LIFE_TOPIC_MAP, find_topic, list_topics
from reading_plans import get_day_reading, get_plan, list_plans

mcp = MCPServer(
    name="bible-reading",
    instructions=(
        "A Bible reading assistant that helps you engage with Scripture based on "
        "your life situation. Fetch verses, explore topics like anxiety or purpose, "
        "follow reading plans, and receive daily verse inspiration."
    ),
)

_VERSE_OF_THE_DAY: list[str] = [
    "John 3:16", "Psalm 23:1", "Philippians 4:13", "Romans 8:28",
    "Jeremiah 29:11", "Proverbs 3:5-6", "Isaiah 40:31", "Matthew 11:28-30",
    "Psalm 46:1", "1 Corinthians 13:4-7", "Hebrews 11:1", "Romans 12:2",
    "Joshua 1:9", "Psalm 27:1", "Galatians 5:22-23", "2 Timothy 1:7",
    "Ephesians 2:8-9", "1 Peter 5:7", "John 14:6", "Psalm 119:105",
    "Matthew 5:16", "Romans 3:23", "Isaiah 41:10", "Colossians 3:23",
    "Psalm 34:18", "Matthew 6:33", "Philippians 4:6-7", "1 John 4:8",
    "Romans 15:13", "Psalm 121:1-2", "Lamentations 3:22-23", "James 1:5",
    "Mark 16:15", "Ephesians 4:32", "Psalm 139:14", "2 Corinthians 5:17",
    "John 15:5", "Proverbs 31:25", "Romans 6:23", "Psalm 91:1-2",
    "Micah 6:8", "Matthew 28:19-20", "1 Timothy 4:12", "Psalm 37:4",
    "John 10:10", "Galatians 2:20", "Nahum 1:7", "Hebrews 12:1-2",
    "1 Samuel 16:7", "Romans 10:9", "Deuteronomy 31:6", "John 16:33",
    "Psalm 145:18", "2 Corinthians 12:9", "Ephesians 6:10-11", "Psalm 1:1-3",
    "Matthew 22:37-39", "1 Corinthians 10:13", "Psalm 16:8", "Isaiah 43:2",
    "Romans 8:1", "John 8:32", "Proverbs 16:9", "Psalm 55:22",
    "Zephaniah 3:17", "1 John 1:9", "Matthew 5:4", "Romans 12:12",
    "Psalm 40:3", "James 4:7", "John 14:27", "Isaiah 26:3",
    "Ecclesiastes 3:1", "Psalm 56:3", "1 Corinthians 6:19-20", "Romans 5:8",
    "Matthew 5:9", "Psalm 62:1-2", "Isaiah 53:5", "John 11:25",
    "Proverbs 4:23", "Philippians 1:6", "Psalm 103:2-3", "Ephesians 3:20",
    "1 Thessalonians 5:16-18", "Acts 1:8", "Psalm 18:2", "Romans 8:38-39",
    "Revelation 21:4", "Matthew 19:26", "Psalm 73:26", "Colossians 1:16-17",
    "John 1:12", "Proverbs 17:22", "Romans 12:1", "Psalm 30:5",
    "James 1:2-4", "Titus 3:5", "John 3:30", "Psalm 127:1",
    "Isaiah 55:8-9", "1 Peter 2:9", "Matthew 6:34", "Psalm 84:11",
]

_REFLECTION_PROMPTS: dict[str, str] = {
    "anxiety": "Notice where God invites you to release control. What specific worry can you hand to Him right now?",
    "depression": "Let the truth of God's nearness sink into the painful places. What does it feel like to be seen by God?",
    "grief": "You don't have to rush through grief. Where do you sense God's presence in your loss?",
    "fear": "What would it look like today to trust God's protection over your circumstances?",
    "purpose": "God's purposes unfold over a lifetime. What small step of faithfulness feels possible today?",
    "forgiveness": "Forgiveness is a process, not a moment. What relationship can you take one step toward today?",
    "relationships": "How might these passages shape the way you show up in your most important relationship today?",
    "marriage": "What does your spouse need from you today that reflects Christ's love for the church?",
    "finances": "How is God calling you to hold your financial situation with open hands?",
    "work": "What would it look like to bring the quality of worship to your work today?",
    "health": "In what ways is God asking you to honor your body as His temple?",
    "faith": "What area of your life most needs the anchor of faith right now?",
    "temptation": "What is the 'way out' God is providing for you in your current struggle?",
    "loneliness": "Even in loneliness, God is present. Where have you experienced a hint of His nearness recently?",
    "anger": "What is the wound underneath your anger? How might God want to heal it?",
    "identity": "You are God's beloved. How would living from that identity change your day?",
    "hope": "What does it look like to hold tight to hope in your current season?",
    "wisdom": "What decision most needs God's wisdom in your life right now?",
    "prayer": "Set aside five minutes to bring your exact situation to God in prayer using His Word.",
    "salvation": "How does knowing you are loved and forgiven shape how you face today?",
    "strength": "Where are you most aware of your own weakness? That is where God's strength can shine.",
    "family": "What is one thing you can do today to bless your family?",
    "loss": "What are you grieving that you haven't fully brought to God yet?",
    "peace": "What noise in your life is most drowning out God's peace?",
}


def _votd_ref() -> str:
    day = datetime.date.today().timetuple().tm_yday
    return _VERSE_OF_THE_DAY[(day - 1) % len(_VERSE_OF_THE_DAY)]


# ---------------------------------------------------------------------------
# Tools
# ---------------------------------------------------------------------------

@mcp.tool()
async def get_verse(
    reference: str,
    translation: str = "web",
    show_individual_verses: bool = True,
) -> str:
    """
    Fetch any Bible verse or passage by reference.

    Args:
        reference: e.g. 'John 3:16', 'Psalm 23', 'Matthew 5:1-12', 'Romans 8'.
        translation: 'web' (default), 'kjv', 'bbe', 'asv', 'ylt'.
        show_individual_verses: If True, prefix each verse with its number.
    """
    try:
        data = await fetch_passage(reference, translation)
        return format_passage(data, show_verses=show_individual_verses)
    except httpx.HTTPStatusError as e:
        if e.response.status_code == 404:
            return (
                f"Reference '{reference}' was not found. "
                "Try formats like 'John 3:16', 'Psalm 23', or 'Matthew 5:1-12'."
            )
        return f"Error fetching verse: HTTP {e.response.status_code}"
    except Exception as e:
        return f"Error fetching verse: {e}"


@mcp.tool()
async def search_by_life_topic(
    topic: str,
    translation: str = "web",
    fetch_text: bool = True,
) -> str:
    """
    Find Bible passages relevant to a life situation or emotional state.

    Args:
        topic: e.g. 'anxiety', 'grief', 'purpose', 'marriage', 'finances',
               or natural language like 'I feel scared' or 'struggling with money'.
        translation: 'web' (default), 'kjv', 'bbe', 'asv', 'ylt'.
        fetch_text: If True, fetches verse text for top 3 passages (default True).
    """
    canonical = find_topic(topic)
    if canonical is None:
        available = ", ".join(list_topics())
        return (
            f"No matching topic found for '{topic}'.\n\n"
            f"Available topics: {available}\n\n"
            "Try natural language like 'I feel anxious' or one of the topic names above."
        )

    passages = LIFE_TOPIC_MAP[canonical]
    lines = [f"## Scripture for '{canonical.title()}'\n"]

    if fetch_text:
        for i, p in enumerate(passages):
            ref, note = p["ref"], p["note"]
            lines.append(f"\n### {ref}\n*{note}*\n")
            try:
                data = await fetch_passage(ref, translation)
                lines.append(format_passage(data, show_verses=True))
            except Exception:
                lines.append(f"*(Could not fetch text for {ref})*")
            if i >= 2:
                remaining = passages[3:]
                if remaining:
                    lines.append("\n**Additional passages:**")
                    for rp in remaining:
                        lines.append(f"- {rp['ref']} — {rp['note']}")
                break
    else:
        for p in passages:
            lines.append(f"- **{p['ref']}** — {p['note']}")

    return "\n".join(lines)


@mcp.tool()
def list_life_topics() -> str:
    """
    List all life topics and emotional states supported by search_by_life_topic.
    """
    topics = list_topics()
    lines = ["## Supported Life Topics\n"]
    for t in topics:
        sample = LIFE_TOPIC_MAP[t][0]["ref"] if LIFE_TOPIC_MAP[t] else ""
        lines.append(f"- **{t}** *(e.g. {sample})*")
    lines.append(
        "\nAlso accepts natural language: 'stressed', 'worried', 'alone', "
        "'mad', 'calling', 'sick', 'money', 'who am I?', etc."
    )
    return "\n".join(lines)


@mcp.tool()
async def get_verse_of_the_day(translation: str = "web") -> str:
    """
    Get today's Bible verse — a curated verse that cycles daily through the year.

    Args:
        translation: 'web' (default), 'kjv', 'bbe', 'asv', 'ylt'.
    """
    ref = _votd_ref()
    today = datetime.date.today().strftime("%B %d, %Y")
    try:
        data = await fetch_passage(ref, translation)
        text = format_passage(data, show_verses=True)
        return f"## Verse of the Day — {today}\n\n{text}"
    except Exception as e:
        return f"## Verse of the Day — {today}\n\nReference: {ref}\n\n*(Could not fetch text: {e})*"


@mcp.tool()
async def get_chapter(book: str, chapter: int, translation: str = "web") -> str:
    """
    Fetch an entire Bible chapter.

    Args:
        book: Book name, e.g. 'John', 'Psalm', 'Genesis', 'Romans'.
        chapter: Chapter number.
        translation: 'web' (default), 'kjv', 'bbe', 'asv', 'ylt'.
    """
    reference = f"{book} {chapter}"
    try:
        data = await fetch_passage(reference, translation)
        return format_passage(data, show_verses=True)
    except httpx.HTTPStatusError as e:
        if e.response.status_code == 404:
            return f"'{reference}' not found. Check the book name and chapter number."
        return f"Error fetching chapter: HTTP {e.response.status_code}"
    except Exception as e:
        return f"Error fetching chapter: {e}"


@mcp.tool()
def list_reading_plans() -> str:
    """
    List all available Bible reading plans.
    Use the plan ID with get_daily_plan_reading to get a day's reading.
    """
    plans = list_plans()
    lines = ["## Available Bible Reading Plans\n"]
    for p in plans:
        lines.append(f"### {p['name']} (`{p['id']}`)")
        lines.append(f"{p['description']} — **{p['days']} days**\n")
    lines.append("Use `get_daily_plan_reading` with a plan ID and day number.")
    return "\n".join(lines)


@mcp.tool()
async def get_daily_plan_reading(
    plan_id: str,
    day: int | None = None,
    translation: str = "web",
    fetch_text: bool = False,
) -> str:
    """
    Get the Bible reading for a specific day in a reading plan.

    Args:
        plan_id: Plan identifier. Use list_reading_plans to see options.
                 e.g. 'bible_in_a_year', 'new_testament_90', 'psalms_30',
                      'proverbs_31', 'gospels_28', 'sermon_on_the_mount'.
        day: Day number (1-based). Defaults to today's day cycling through the plan.
        translation: 'web' (default), 'kjv', 'bbe', 'asv', 'ylt'.
        fetch_text: If True, fetches the full text of each passage (may be slow).
    """
    plan = get_plan(plan_id)
    if plan is None:
        available = ", ".join(p["id"] for p in list_plans())
        return f"Plan '{plan_id}' not found.\n\nAvailable plans: {available}"

    if day is None:
        day_of_year = datetime.date.today().timetuple().tm_yday
        day = ((day_of_year - 1) % plan["days"]) + 1

    readings = get_day_reading(plan_id, day)
    if readings is None:
        max_day = max(plan["schedule"].keys())
        return (
            f"Day {day} is not in the built-in schedule for '{plan['name']}' "
            f"(covers days 1–{max_day}). Try a day in that range."
        )

    today = datetime.date.today().strftime("%B %d, %Y")
    lines = [f"## {plan['name']} — Day {day}", f"*{today}*\n", "**Today's reading:**"]
    for r in readings:
        lines.append(f"- {r}")

    if fetch_text:
        lines.append("\n---\n")
        for r in readings:
            try:
                data = await fetch_passage(r, translation)
                lines.append(format_passage(data, show_verses=True))
                lines.append("")
            except Exception as e:
                lines.append(f"*(Could not fetch '{r}': {e})*\n")

    return "\n".join(lines)


@mcp.tool()
async def reflect_on_life(situation: str, translation: str = "web") -> str:
    """
    Describe what you're going through and receive relevant Bible passages and a reflection prompt.

    This is the most natural-language-friendly tool. Describe your current
    situation, struggles, emotions, or questions in your own words.

    Args:
        situation: e.g. 'I just lost my job and feel hopeless',
                   'My marriage is struggling', 'I feel alone and disconnected from God',
                   'I need strength to get through this week'.
        translation: 'web' (default), 'kjv', 'bbe', 'asv', 'ylt'.
    """
    canonical = find_topic(situation)
    fallback_note = ""
    if canonical is None:
        canonical = "hope"
        fallback_note = (
            "I couldn't identify a specific topic, so here are passages of hope "
            "that speak broadly to life's challenges.\n\n"
        )

    passages = LIFE_TOPIC_MAP[canonical]
    prompt = _REFLECTION_PROMPTS.get(canonical, "How does this passage speak to your situation?")

    lines = [
        f"## Scripture for Your Situation\n",
        fallback_note,
        f"**You shared:** *{situation}*\n",
        f"**Relevant theme:** {canonical.title()}\n",
        "---\n",
    ]

    for i, p in enumerate(passages[:3]):
        ref, note = p["ref"], p["note"]
        lines.append(f"### {ref}\n*{note}*\n")
        try:
            data = await fetch_passage(ref, translation)
            lines.append(format_passage(data, show_verses=True))
        except Exception:
            lines.append(f"*(Could not fetch text — reference: {ref})*")
        lines.append("")

    remaining = passages[3:]
    if remaining:
        lines.append("**More passages on this theme:**")
        for rp in remaining:
            lines.append(f"- {rp['ref']} — {rp['note']}")
        lines.append("")

    lines += ["---", f"**Reflection question:** {prompt}"]
    return "\n".join(lines)


if __name__ == "__main__":
    mcp.run()
