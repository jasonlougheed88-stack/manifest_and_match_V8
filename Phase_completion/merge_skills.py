#!/usr/bin/env python3
"""
Merge expansion JSON files into V8 app's skills.json
"""
import json
from pathlib import Path
from datetime import date

# Paths
EXPANSION_DIR = Path("/Users/jasonl/Desktop/ios26_manifest_and_match")
APP_SKILLS_JSON = Path("/Users/jasonl/Desktop/ios26_manifest_and_match/manifest and match V8/Packages/V7Core/Sources/V7Core/Resources/skills.json")

# Load existing skills
print(f"Loading existing skills from: {APP_SKILLS_JSON}")
with open(APP_SKILLS_JSON, 'r') as f:
    existing_data = json.load(f)

existing_skills = existing_data['skills']
print(f"Found {len(existing_skills)} existing skills")

# Expansion files to merge
expansion_files = [
    "real_estate_skills_expansion.json",
    "marketing_skills_expansion.json",
    "legal_skills_expansion.json",
    "hr_skills_expansion.json",
    "construction_skills_expansion.json",
    "education_skills_expansion.json",
    "warehouse_logistics_skills_expansion.json",
    "food_service_skills_expansion.json",
    "finance_skills_expansion.json"
]

# Collect all new skills
all_new_skills = []
for filename in expansion_files:
    filepath = EXPANSION_DIR / filename
    if filepath.exists():
        print(f"\nProcessing: {filename}")
        with open(filepath, 'r') as f:
            data = json.load(f)
            new_skills = data['new_skills']
            print(f"  Adding {len(new_skills)} {data['expansion_metadata']['sector']} skills")
            all_new_skills.extend(new_skills)
    else:
        print(f"  WARNING: {filename} not found")

print(f"\nTotal new skills to add: {len(all_new_skills)}")

# Merge skills
merged_skills = existing_skills + all_new_skills
print(f"Total skills after merge: {len(merged_skills)}")

# Update metadata
merged_data = {
    "skills": merged_skills,
    "version": "3.0.0",
    "lastUpdated": str(date.today())
}

# Write merged data
print(f"\nWriting merged skills to: {APP_SKILLS_JSON}")
with open(APP_SKILLS_JSON, 'w') as f:
    json.dump(merged_data, f, indent=2)

print(f"\n✅ SUCCESS: Merged {len(all_new_skills)} new skills into skills.json")
print(f"   Total skills: {len(merged_skills)}")
print(f"   Version: 3.0.0")
print(f"   Updated: {date.today()}")
