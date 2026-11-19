"""
Built-in Bible reading plans.
"""

READING_PLANS: dict[str, dict] = {
    "bible_in_a_year": {
        "name": "Bible in a Year",
        "description": "Read the entire Bible in 365 days",
        "days": 365,
        "schedule": {
            1:  ["Genesis 1-3", "Psalm 1"],
            2:  ["Genesis 4-7", "Psalm 2"],
            3:  ["Genesis 8-11", "Psalm 3"],
            4:  ["Genesis 12-15", "Psalm 4"],
            5:  ["Genesis 16-18", "Psalm 5"],
            6:  ["Genesis 19-21", "Psalm 6"],
            7:  ["Genesis 22-24", "Psalm 7"],
            8:  ["Genesis 25-27", "Psalm 8"],
            9:  ["Genesis 28-30", "Psalm 9"],
            10: ["Genesis 31-33", "Psalm 10"],
            11: ["Genesis 34-36", "Psalm 11"],
            12: ["Genesis 37-39", "Psalm 12"],
            13: ["Genesis 40-42", "Psalm 13"],
            14: ["Genesis 43-45", "Psalm 14"],
            15: ["Genesis 46-50", "Psalm 15"],
            16: ["Exodus 1-4", "Psalm 16"],
            17: ["Exodus 5-8", "Psalm 17"],
            18: ["Exodus 9-12", "Psalm 18:1-29"],
            19: ["Exodus 13-15", "Psalm 18:30-50"],
            20: ["Exodus 16-18", "Psalm 19"],
            21: ["Exodus 19-21", "Psalm 20"],
            22: ["Exodus 22-24", "Psalm 21"],
            23: ["Exodus 25-27", "Psalm 22"],
            24: ["Exodus 28-30", "Psalm 23"],
            25: ["Exodus 31-33", "Psalm 24"],
            26: ["Exodus 34-36", "Psalm 25"],
            27: ["Exodus 37-40", "Psalm 26"],
            28: ["Leviticus 1-4", "Psalm 27"],
            29: ["Leviticus 5-7", "Psalm 28"],
            30: ["Leviticus 8-10", "Psalm 29"],
        },
    },
    "new_testament_90": {
        "name": "New Testament in 90 Days",
        "description": "Read the entire New Testament in 90 days",
        "days": 90,
        "schedule": {
            1:  ["Matthew 1-4"],   2:  ["Matthew 5-7"],
            3:  ["Matthew 8-11"],  4:  ["Matthew 12-14"],
            5:  ["Matthew 15-18"], 6:  ["Matthew 19-22"],
            7:  ["Matthew 23-25"], 8:  ["Matthew 26-28"],
            9:  ["Mark 1-3"],      10: ["Mark 4-6"],
            11: ["Mark 7-10"],     12: ["Mark 11-13"],
            13: ["Mark 14-16"],    14: ["Luke 1-3"],
            15: ["Luke 4-6"],      16: ["Luke 7-9"],
            17: ["Luke 10-13"],    18: ["Luke 14-17"],
            19: ["Luke 18-21"],    20: ["Luke 22-24"],
            21: ["John 1-3"],      22: ["John 4-6"],
            23: ["John 7-10"],     24: ["John 11-13"],
            25: ["John 14-17"],    26: ["John 18-21"],
            27: ["Acts 1-3"],      28: ["Acts 4-7"],
            29: ["Acts 8-11"],     30: ["Acts 12-15"],
        },
    },
    "psalms_30": {
        "name": "Psalms in 30 Days",
        "description": "Journey through all 150 Psalms in 30 days (5 psalms per day)",
        "days": 30,
        "schedule": {day: [f"Psalm {(day-1)*5+1}-{day*5}"] for day in range(1, 31)},
    },
    "proverbs_31": {
        "name": "Proverbs in a Month",
        "description": "One chapter of Proverbs per day for 31 days",
        "days": 31,
        "schedule": {day: [f"Proverbs {day}"] for day in range(1, 32)},
    },
    "gospels_28": {
        "name": "Life of Jesus (Four Gospels) in 28 Days",
        "description": "Encounter Jesus through Matthew, Mark, Luke, and John",
        "days": 28,
        "schedule": {
            1:  ["Matthew 1-4"],   2:  ["Matthew 5-7"],
            3:  ["Matthew 8-11"],  4:  ["Matthew 12-15"],
            5:  ["Matthew 16-19"], 6:  ["Matthew 20-22"],
            7:  ["Matthew 23-25"], 8:  ["Matthew 26-28"],
            9:  ["Mark 1-4"],      10: ["Mark 5-8"],
            11: ["Mark 9-12"],     12: ["Mark 13-16"],
            13: ["Luke 1-4"],      14: ["Luke 5-8"],
            15: ["Luke 9-12"],     16: ["Luke 13-16"],
            17: ["Luke 17-19"],    18: ["Luke 20-24"],
            19: ["John 1-4"],      20: ["John 5-8"],
            21: ["John 9-12"],     22: ["John 13-15"],
            23: ["John 16-18"],    24: ["John 19-21"],
            25: ["Acts 1-4"],      26: ["Acts 5-8"],
            27: ["Acts 9-12"],     28: ["Acts 13-16"],
        },
    },
    "sermon_on_the_mount": {
        "name": "Sermon on the Mount — 7 Days",
        "description": "Deep dive into Jesus' core teaching in Matthew 5-7",
        "days": 7,
        "schedule": {
            1: ["Matthew 5:1-12"], 2: ["Matthew 5:13-48"],
            3: ["Matthew 6:1-18"], 4: ["Matthew 6:19-34"],
            5: ["Matthew 7:1-14"], 6: ["Matthew 7:15-29"],
            7: ["Matthew 5-7"],
        },
    },
}


def get_plan(plan_id: str) -> dict | None:
    return READING_PLANS.get(plan_id)


def list_plans() -> list[dict]:
    return [
        {"id": k, "name": v["name"], "description": v["description"], "days": v["days"]}
        for k, v in READING_PLANS.items()
    ]


def get_day_reading(plan_id: str, day: int) -> list[str] | None:
    plan = READING_PLANS.get(plan_id)
    if plan is None:
        return None
    return plan["schedule"].get(day)
