#!/usr/bin/env python3
import json
import os
import sys
from textwrap import indent

ROOT = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(ROOT, ".."))
JSON_PATH = os.path.join(PROJECT_ROOT, "user_stories_database.json")
OUTPUT_DIR = os.path.join(PROJECT_ROOT, "GHFollowersTests")
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "GeneratedUserStoryTests.swift")

AI_PROMPT = """
You are an AI coding assistant for the GHFollowers iOS app (Swift, Swift Testing).
Goal: Generate Swift tests from user stories JSON at project root: user_stories_database.json.
Rules:
- Use Swift Testing (import Testing), not XCTest.
- Use @MainActor on test structs that touch UIKit.
- Place acceptance criteria under a block comment (/* ... */) with bullets prefixed by "- ".
- File header should mark it AUTO-GENERATED and import GHFollowers with @testable.
- Prefer one struct per generated file; name it GeneratedUserStoryTests (or Generated_<Category>_Tests if split).
Command the tool to run:
python3 Tools/generate_tests_from_userstories.py [N]
where [N] is optional. If omitted, all stories are generated. If provided, generate the first N stories.
Output path:
GHFollowersTests/GeneratedUserStoryTests.swift
"""

HEADER = """//
//  GeneratedUserStoryTests.swift
//  GHFollowersTests
//
//  AUTO-GENERATED FILE. DO NOT EDIT MANUALLY.
//

import Testing
import UIKit
@testable import GHFollowers

@MainActor
struct GeneratedUserStoryTests {
"""

FOOTER = """
}
"""

# Escape literal braces for Python .format by doubling them
TEMPLATE = """
    // {id}: {title}
    // Screen: {screen}
    // Priority: {priority}
    // TestType: {test_type}
    // Acceptance Criteria:
    /*
{criteria_block}
    */
    @Test("{id}: {title}")
    func test_{safe_id}_{safe_title}() throws {{
        // NOTE: This is a scaffold generated from user story data.
        // Replace with concrete assertions against the app UI / logic.
        // For example, you may instantiate the relevant VC and assert key elements.
        // Example to keep test compiling:
        #expect(true)
    }}
"""

def safe_name(s: str) -> str:
    allowed = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
    s2 = "".join(ch if ch in allowed else "_" for ch in s)
    if s2 and s2[0].isdigit():
        s2 = "_" + s2
    return s2


def main(limit: int | None = None):
    if not os.path.exists(JSON_PATH):
        print(f"JSON not found at {JSON_PATH}", file=sys.stderr)
        sys.exit(1)

    with open(JSON_PATH, "r") as f:
        data = json.load(f)

    # Flatten stories in category order
    stories = []
    cats = data.get("categories", {})
    for cat_key in cats:
        for story in cats[cat_key].get("stories", []):
            stories.append(story)
    if isinstance(limit, int):
        stories = stories[:limit]

    os.makedirs(OUTPUT_DIR, exist_ok=True)

    parts = [HEADER]
    for st in stories:
        crit_list = st.get("acceptance_criteria", [])
        # Each bullet should be prefixed with ' - ' and properly indented inside the block comment
        crit_lines = [f"        - {c}" for c in crit_list]
        criteria_block = "\n".join(crit_lines) if crit_lines else "        - (none)"
        test = TEMPLATE.format(
            id=st.get("id", "US-XXX"),
            title=st.get("title", "Untitled"),
            screen=st.get("screen", "Unknown"),
            priority=st.get("priority", "Unknown"),
            test_type=st.get("test_type", "Unknown"),
            criteria_block=criteria_block,
            safe_id=safe_name(st.get("id", "US_XXX")),
            safe_title=safe_name(st.get("title", "Untitled"))
        )
        parts.append(test)

    parts.append(FOOTER)
    content = "\n".join(parts)

    with open(OUTPUT_FILE, "w") as f:
        f.write(content)

    print(f"Generated {OUTPUT_FILE} with {len(stories)} tests.")

if __name__ == "__main__":
    if "--print-prompt" in sys.argv:
        print(AI_PROMPT.strip())
        sys.exit(0)

    lim: int | None = None
    for arg in sys.argv[1:]:
        if arg.startswith("--"):
            continue
        try:
            lim = int(arg)
        except ValueError:
            pass
    main(lim)
