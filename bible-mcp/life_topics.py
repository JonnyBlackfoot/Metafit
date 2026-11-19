"""
Maps life situations and emotional states to relevant Bible passages.
"""

LIFE_TOPIC_MAP: dict[str, list[dict]] = {
    "anxiety": [
        {"ref": "Philippians 4:6-7", "note": "Peace that surpasses understanding"},
        {"ref": "Matthew 6:25-34", "note": "Do not worry — God provides"},
        {"ref": "Isaiah 41:10", "note": "Fear not, I am with you"},
        {"ref": "1 Peter 5:7", "note": "Cast all your anxiety on Him"},
        {"ref": "Psalm 46:1-3", "note": "God is our refuge and strength"},
    ],
    "depression": [
        {"ref": "Psalm 34:18", "note": "God is close to the brokenhearted"},
        {"ref": "Isaiah 40:31", "note": "Renewing strength like eagles"},
        {"ref": "Romans 8:28", "note": "All things work for good"},
        {"ref": "Psalm 42:11", "note": "Hope in God"},
        {"ref": "Matthew 5:4", "note": "Blessed are those who mourn"},
    ],
    "grief": [
        {"ref": "Psalm 23", "note": "The Lord is my shepherd"},
        {"ref": "Revelation 21:4", "note": "No more tears or pain"},
        {"ref": "John 11:25-26", "note": "I am the resurrection and the life"},
        {"ref": "2 Corinthians 1:3-4", "note": "God of all comfort"},
        {"ref": "Psalm 147:3", "note": "He heals the brokenhearted"},
    ],
    "fear": [
        {"ref": "Psalm 27:1", "note": "The Lord is my light and salvation"},
        {"ref": "2 Timothy 1:7", "note": "Spirit of power, love, and self-discipline"},
        {"ref": "Isaiah 41:13", "note": "God holds your right hand"},
        {"ref": "Joshua 1:9", "note": "Be strong and courageous"},
        {"ref": "Psalm 56:3-4", "note": "When I am afraid I will trust in You"},
    ],
    "purpose": [
        {"ref": "Jeremiah 29:11", "note": "Plans to prosper and give hope"},
        {"ref": "Proverbs 3:5-6", "note": "Trust in the Lord with all your heart"},
        {"ref": "Romans 8:28", "note": "Called according to His purpose"},
        {"ref": "Ephesians 2:10", "note": "Created for good works"},
        {"ref": "Psalm 138:8", "note": "The Lord will fulfil His purpose for me"},
    ],
    "forgiveness": [
        {"ref": "1 John 1:9", "note": "He is faithful and just to forgive"},
        {"ref": "Ephesians 4:31-32", "note": "Forgive as God forgave you"},
        {"ref": "Matthew 6:14-15", "note": "Forgive others to be forgiven"},
        {"ref": "Colossians 3:13", "note": "Bearing with one another in love"},
        {"ref": "Psalm 103:12", "note": "As far as east is from west"},
    ],
    "relationships": [
        {"ref": "1 Corinthians 13:4-8", "note": "Love is patient and kind"},
        {"ref": "Proverbs 17:17", "note": "A friend loves at all times"},
        {"ref": "Ephesians 4:2-3", "note": "Bearing with one another in love"},
        {"ref": "John 15:12-13", "note": "Love one another as I have loved you"},
        {"ref": "Romans 12:10", "note": "Be devoted to one another"},
    ],
    "marriage": [
        {"ref": "Genesis 2:24", "note": "Two shall become one flesh"},
        {"ref": "Ephesians 5:25-33", "note": "Love your wife as Christ loves the church"},
        {"ref": "Proverbs 31:10-31", "note": "A wife of noble character"},
        {"ref": "1 Corinthians 13:4-8", "note": "Love is patient and kind"},
        {"ref": "Ecclesiastes 4:9-12", "note": "Two are better than one"},
    ],
    "finances": [
        {"ref": "Matthew 6:19-21", "note": "Store treasure in heaven"},
        {"ref": "Proverbs 3:9-10", "note": "Honor the Lord with your wealth"},
        {"ref": "Philippians 4:19", "note": "God will supply all your needs"},
        {"ref": "Luke 16:13", "note": "You cannot serve both God and money"},
        {"ref": "Malachi 3:10", "note": "Test God with your tithes"},
    ],
    "work": [
        {"ref": "Colossians 3:23-24", "note": "Work as if working for the Lord"},
        {"ref": "Proverbs 14:23", "note": "All hard work brings profit"},
        {"ref": "Ecclesiastes 9:10", "note": "Whatever your hand finds to do"},
        {"ref": "2 Thessalonians 3:10-12", "note": "If a man won't work, he shall not eat"},
        {"ref": "Proverbs 16:3", "note": "Commit your work to the Lord"},
    ],
    "health": [
        {"ref": "1 Corinthians 6:19-20", "note": "Your body is a temple"},
        {"ref": "3 John 1:2", "note": "I pray you may be in good health"},
        {"ref": "Proverbs 17:22", "note": "A cheerful heart is good medicine"},
        {"ref": "Psalm 103:2-3", "note": "He heals all your diseases"},
        {"ref": "Isaiah 40:29", "note": "He gives strength to the weary"},
    ],
    "faith": [
        {"ref": "Hebrews 11:1", "note": "Faith is confidence in what we hope for"},
        {"ref": "Romans 10:17", "note": "Faith comes from hearing the Word"},
        {"ref": "Mark 11:24", "note": "Whatever you ask in prayer, believe"},
        {"ref": "James 2:17", "note": "Faith without works is dead"},
        {"ref": "Matthew 17:20", "note": "Faith as small as a mustard seed"},
    ],
    "temptation": [
        {"ref": "1 Corinthians 10:13", "note": "God provides a way out"},
        {"ref": "James 4:7", "note": "Resist the devil and he will flee"},
        {"ref": "Matthew 26:41", "note": "Watch and pray not to fall into temptation"},
        {"ref": "Hebrews 4:15-16", "note": "Jesus was tempted yet did not sin"},
        {"ref": "Galatians 5:16", "note": "Walk in the Spirit"},
    ],
    "loneliness": [
        {"ref": "Deuteronomy 31:6", "note": "He will never leave nor forsake you"},
        {"ref": "Psalm 68:6", "note": "God sets the lonely in families"},
        {"ref": "Matthew 28:20", "note": "I am with you always"},
        {"ref": "John 14:16-18", "note": "He will give you the Spirit of truth"},
        {"ref": "Psalm 139:7-10", "note": "Where can I go from Your presence?"},
    ],
    "anger": [
        {"ref": "Ephesians 4:26-27", "note": "In your anger do not sin"},
        {"ref": "James 1:19-20", "note": "Be slow to become angry"},
        {"ref": "Proverbs 15:1", "note": "A gentle answer turns away wrath"},
        {"ref": "Colossians 3:8", "note": "Rid yourself of anger"},
        {"ref": "Psalm 37:8", "note": "Refrain from anger and turn from wrath"},
    ],
    "identity": [
        {"ref": "Genesis 1:27", "note": "Made in the image of God"},
        {"ref": "Psalm 139:13-14", "note": "Fearfully and wonderfully made"},
        {"ref": "John 1:12", "note": "Given the right to be children of God"},
        {"ref": "Galatians 3:26-28", "note": "All one in Christ Jesus"},
        {"ref": "1 Peter 2:9", "note": "A chosen people, royal priesthood"},
    ],
    "hope": [
        {"ref": "Romans 15:13", "note": "God of hope fill you with joy"},
        {"ref": "Jeremiah 29:11", "note": "Plans to give you hope and a future"},
        {"ref": "Lamentations 3:22-23", "note": "His mercies are new every morning"},
        {"ref": "Romans 8:24-25", "note": "Hope for what we do not yet have"},
        {"ref": "Hebrews 6:19", "note": "Hope as an anchor for the soul"},
    ],
    "wisdom": [
        {"ref": "James 1:5", "note": "Ask God for wisdom and He will give it"},
        {"ref": "Proverbs 2:6", "note": "The Lord gives wisdom"},
        {"ref": "Proverbs 1:7", "note": "Fear of the Lord is the beginning of wisdom"},
        {"ref": "Colossians 2:2-3", "note": "In Christ are all treasures of wisdom"},
        {"ref": "Ecclesiastes 7:12", "note": "Wisdom preserves those who have it"},
    ],
    "prayer": [
        {"ref": "Matthew 6:9-13", "note": "The Lord's Prayer"},
        {"ref": "1 Thessalonians 5:17", "note": "Pray without ceasing"},
        {"ref": "Philippians 4:6", "note": "Present your requests to God"},
        {"ref": "James 5:16", "note": "The prayer of a righteous person is powerful"},
        {"ref": "Luke 18:1-8", "note": "Always pray and not give up"},
    ],
    "salvation": [
        {"ref": "John 3:16", "note": "God so loved the world"},
        {"ref": "Romans 10:9-10", "note": "Confess Jesus is Lord and be saved"},
        {"ref": "Ephesians 2:8-9", "note": "Saved by grace through faith"},
        {"ref": "Acts 4:12", "note": "Salvation is found in no one else"},
        {"ref": "John 14:6", "note": "I am the way, the truth, and the life"},
    ],
    "strength": [
        {"ref": "Philippians 4:13", "note": "I can do all things through Christ"},
        {"ref": "Isaiah 40:31", "note": "They will soar on wings like eagles"},
        {"ref": "Psalm 28:7", "note": "The Lord is my strength and my shield"},
        {"ref": "2 Corinthians 12:9-10", "note": "My power is made perfect in weakness"},
        {"ref": "Nehemiah 8:10", "note": "The joy of the Lord is your strength"},
    ],
    "family": [
        {"ref": "Proverbs 22:6", "note": "Train up a child in the way he should go"},
        {"ref": "Ephesians 6:1-4", "note": "Children obey your parents in the Lord"},
        {"ref": "Joshua 24:15", "note": "As for me and my house, we will serve the Lord"},
        {"ref": "Psalm 127:3", "note": "Children are a heritage from the Lord"},
        {"ref": "Colossians 3:18-21", "note": "Family relationships in Christ"},
    ],
    "loss": [
        {"ref": "Psalm 34:18", "note": "Close to the brokenhearted"},
        {"ref": "John 16:22", "note": "Your grief will turn to joy"},
        {"ref": "Romans 8:38-39", "note": "Nothing can separate us from God's love"},
        {"ref": "2 Corinthians 4:17", "note": "Momentary troubles achieving eternal glory"},
        {"ref": "Psalm 30:5", "note": "Weeping may stay for the night but joy comes in the morning"},
    ],
    "peace": [
        {"ref": "John 14:27", "note": "My peace I give to you"},
        {"ref": "Philippians 4:7", "note": "Peace that transcends understanding"},
        {"ref": "Isaiah 26:3", "note": "Perfect peace for those who trust in Him"},
        {"ref": "Romans 5:1", "note": "Peace with God through our Lord Jesus Christ"},
        {"ref": "Psalm 4:8", "note": "In peace I will lie down and sleep"},
    ],
}

TOPIC_ALIASES: dict[str, str] = {
    "stress": "anxiety", "worry": "anxiety", "worried": "anxiety",
    "sad": "depression", "sadness": "depression",
    "hurt": "grief", "mourn": "grief", "mourning": "grief",
    "scared": "fear",
    "calling": "purpose", "direction": "purpose", "meaning": "purpose",
    "pardon": "forgiveness",
    "friendship": "relationships", "love": "relationships",
    "money": "finances", "debt": "finances",
    "job": "work", "career": "work",
    "sick": "health", "illness": "health", "healing": "health",
    "trust": "faith", "believe": "faith",
    "sin": "temptation", "addiction": "temptation",
    "alone": "loneliness", "isolated": "loneliness",
    "mad": "anger", "frustrated": "anger",
    "who am i": "identity",
    "future": "hope",
    "knowledge": "wisdom", "guidance": "wisdom",
    "talk to god": "prayer",
    "saved": "salvation", "eternal life": "salvation",
    "power": "strength", "courage": "strength",
    "children": "family", "parenting": "family",
    "death": "loss",
    "calm": "peace", "rest": "peace",
}


def find_topic(query: str) -> str | None:
    q = query.lower().strip()
    if q in LIFE_TOPIC_MAP:
        return q
    if q in TOPIC_ALIASES:
        return TOPIC_ALIASES[q]
    for alias, canonical in TOPIC_ALIASES.items():
        if alias in q:
            return canonical
    for topic in LIFE_TOPIC_MAP:
        if topic in q:
            return topic
    return None


def list_topics() -> list[str]:
    return sorted(LIFE_TOPIC_MAP.keys())
