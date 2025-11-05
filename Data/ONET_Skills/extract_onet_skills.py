#!/usr/bin/env python3
"""
O*NET Skills Extractor for ManifestAndMatch V8
Extracts skills from O*NET 30.0 database and maps to 14 ManifestAndMatch sectors
"""

import csv
import json
from collections import defaultdict
from typing import Dict, List, Set

# Map O*NET occupation codes to ManifestAndMatch's 14 sectors
SECTOR_MAPPING = {
    # Office/Administrative (11-xxxx management, 43-xxxx office/admin support)
    "Office/Administrative": ["11-", "13-1", "43-"],

    # Healthcare (29-xxxx healthcare practitioners, 31-xxxx healthcare support)
    "Healthcare": ["29-", "31-"],

    # Technology (15-xxxx computer/math)
    "Technology": ["15-"],

    # Retail (41-xxxx sales)
    "Retail": ["41-"],

    # Skilled Trades (47-xxxx construction, 49-xxxx installation/maintenance/repair)
    "Skilled Trades": ["47-", "49-"],

    # Finance (13-2xxx financial specialists)
    "Finance": ["13-2"],

    # Food Service (35-xxxx food prep/serving)
    "Food Service": ["35-"],

    # Warehouse/Logistics (53-xxxx transportation/material moving)
    "Warehouse/Logistics": ["53-"],

    # Education (25-xxxx education/training/library)
    "Education": ["25-"],

    # Construction (47-xxxx)
    "Construction": ["47-"],

    # Legal (23-xxxx legal)
    "Legal": ["23-"],

    # Real Estate (41-9021, 41-9022 real estate brokers/sales agents)
    "Real Estate": ["41-9021", "41-9022"],

    # Marketing (11-2021, 11-2031, 13-1161 marketing managers/specialists)
    "Marketing": ["11-2021", "11-2031", "13-1161"],

    # Human Resources (13-1071, 13-1075, 13-1151, 13-1199 HR specialists)
    "HR": ["13-1071", "13-1075", "13-1151", "13-1199"],
}


def map_occupation_to_sector(onet_code: str) -> str:
    """Map an O*NET occupation code to a ManifestAndMatch sector."""
    for sector, prefixes in SECTOR_MAPPING.items():
        for prefix in prefixes:
            if onet_code.startswith(prefix):
                return sector

    # Default to Office/Administrative for unmapped occupations
    return "Office/Administrative"


def extract_skills_from_file(filename: str) -> Dict[str, Set[str]]:
    """Extract unique skills from Skills.txt and map to sectors."""
    skills_by_sector = defaultdict(set)

    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f, delimiter='\t')

        for row in reader:
            onet_code = row['O*NET-SOC Code']
            skill_name = row['Element Name']

            # Map to sector
            sector = map_occupation_to_sector(onet_code)
            skills_by_sector[sector].add(skill_name)

    return skills_by_sector


def extract_technology_skills(filename: str) -> Dict[str, Set[str]]:
    """Extract technology skills/tools from Technology Skills or Tools Used file."""
    tech_by_sector = defaultdict(set)

    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f, delimiter='\t')

        for row in reader:
            onet_code = row['O*NET-SOC Code']

            # Get technology/tool name (column name differs by file)
            tech_name = row.get('Example') or row.get('Commodity Title', '')

            if tech_name and tech_name.strip():
                sector = map_occupation_to_sector(onet_code)
                tech_by_sector[sector].add(tech_name.strip())

    return tech_by_sector


def load_occupations(filename: str) -> Dict[str, str]:
    """Load occupation titles for reference."""
    occupations = {}

    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f, delimiter='\t')

        for row in reader:
            occupations[row['O*NET-SOC Code']] = row['Title']

    return occupations


def merge_skills(*skill_dicts) -> Dict[str, Set[str]]:
    """Merge multiple skill dictionaries."""
    merged = defaultdict(set)

    for skill_dict in skill_dicts:
        for sector, skills in skill_dict.items():
            merged[sector].update(skills)

    return merged


def main():
    print("=" * 80)
    print("O*NET Skills Extractor for ManifestAndMatch V8")
    print("=" * 80)
    print()

    # Step 1: Load occupations
    print("Step 1: Loading occupation data...")
    occupations = load_occupations('Occupation_Data.txt')
    print(f"✅ Loaded {len(occupations)} occupations")
    print()

    # Step 2: Extract skills
    print("Step 2: Extracting skills from Skills.txt...")
    skills_by_sector = extract_skills_from_file('Skills.txt')
    total_skills = sum(len(skills) for skills in skills_by_sector.values())
    print(f"✅ Extracted {total_skills} unique skills")
    print()

    # Step 3: Extract technology skills
    print("Step 3: Extracting technology skills...")
    tech_skills = extract_technology_skills('Technology_Skills.txt')
    total_tech = sum(len(skills) for skills in tech_skills.values())
    print(f"✅ Extracted {total_tech} unique technology skills")
    print()

    # Step 4: Extract tools
    print("Step 4: Extracting tools...")
    tools = extract_technology_skills('Tools_Used.txt')
    total_tools = sum(len(skills) for skills in tools.values())
    print(f"✅ Extracted {total_tools} unique tools")
    print()

    # Step 5: Merge all skills
    print("Step 5: Merging all skills by sector...")
    all_skills = merge_skills(skills_by_sector, tech_skills, tools)

    # Step 6: Display distribution
    print()
    print("=" * 80)
    print("SECTOR DISTRIBUTION")
    print("=" * 80)
    print()

    sorted_sectors = sorted(all_skills.items(), key=lambda x: x[0])
    grand_total = 0

    for sector, skills in sorted_sectors:
        count = len(skills)
        grand_total += count
        status = "✅" if count >= 200 else "⚠️"
        print(f"{status} {sector:30s}: {count:4d} skills")

    print()
    print(f"{'TOTAL':30s}: {grand_total:4d} skills")
    print()

    # Step 7: Export to JSON
    print("Step 7: Exporting to JSON...")

    output_data = {
        "version": "1.0",
        "source": "O*NET 30.0 Database",
        "date_extracted": "2025-10-27",
        "total_skills": grand_total,
        "sectors": {}
    }

    for sector, skills in sorted_sectors:
        output_data["sectors"][sector] = sorted(list(skills))

    with open('onet_extracted_skills.json', 'w', encoding='utf-8') as f:
        json.dump(output_data, f, indent=2, ensure_ascii=False)

    print(f"✅ Exported to onet_extracted_skills.json")
    print()
    print("=" * 80)
    print("Extraction Complete!")
    print("=" * 80)


if __name__ == "__main__":
    main()
