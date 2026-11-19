"""
Bible verse fetching via bible-api.com (free, no key required).

Supported translations: web (default), kjv, bbe, asv, ylt
"""

import httpx

BASE_URL = "https://bible-api.com"
DEFAULT_TRANSLATION = "web"
REQUEST_TIMEOUT = 15.0


async def fetch_passage(reference: str, translation: str = DEFAULT_TRANSLATION) -> dict:
    url = f"{BASE_URL}/{reference}"
    params: dict = {}
    if translation and translation.lower() != DEFAULT_TRANSLATION:
        params["translation"] = translation.lower()

    async with httpx.AsyncClient(timeout=REQUEST_TIMEOUT) as client:
        response = await client.get(url, params=params)
        response.raise_for_status()
        return response.json()


def format_passage(data: dict, show_verses: bool = True) -> str:
    ref = data.get("reference", "Unknown Reference")
    translation = data.get("translation_name", "")
    verses = data.get("verses", [])

    if not verses:
        text = data.get("text", "").strip()
        return f"**{ref}** ({translation})\n\n{text}"

    if show_verses:
        lines = [f"**{ref}** ({translation})\n"]
        for v in verses:
            book = v.get("book_name", "")
            chapter = v.get("chapter", "")
            verse_num = v.get("verse", "")
            text = v.get("text", "").strip()
            lines.append(f"{book} {chapter}:{verse_num}  {text}")
        return "\n".join(lines)
    else:
        combined = " ".join(v.get("text", "").strip() for v in verses)
        return f"**{ref}** ({translation})\n\n{combined}"
