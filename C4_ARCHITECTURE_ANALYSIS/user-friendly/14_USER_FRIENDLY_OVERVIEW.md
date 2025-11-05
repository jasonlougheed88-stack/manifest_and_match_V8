# User-Friendly Overview

**Understanding Manifest & Match V8 Architecture (Non-Technical)**

## What This App Does

Manifest & Match helps people discover career opportunities they might not have considered. Instead of just matching keywords, it learns what you actually enjoy by watching how you interact with job listings, similar to how TikTok learns what videos you like.

---

## How It Works (Simple Explanation)

### 1. Creating Your Profile

**What you see**: Fill out your name, upload your resume, add skills and experience

**What happens behind the scenes**:
- The app uses AI to read your resume (like a smart scanner)
- It extracts your job history, education, and skills automatically
- Everything is saved on your iPhone - never sent to external servers
- **Bug Alert**: Currently, manually-added work experience and education aren't saved (being fixed)

**Key Technology**: Apple's on-device AI (same tech that powers Siri)

---

### 2. Discovering Jobs

**What you see**: Swipe through job cards like a dating app

**What happens behind the scenes**:
- The app fetches jobs from 7 different job boards simultaneously
- A smart algorithm (Thompson Sampling) ranks jobs based on what you've liked before
- Every swipe teaches the algorithm more about your preferences
- All this happens in less than 10 milliseconds (357x faster than traditional methods)

**Key Technology**: Thompson Sampling algorithm + Multi-source job aggregation

---

### 3. Learning From Your Choices

**What you see**: The more you swipe, the better the suggestions get

**What happens behind the scenes**:
- Each swipe is recorded with context (what time, which job type, your mood)
- The algorithm uses Bayesian statistics to update its understanding of your preferences
- A behavioral AI watches for patterns (are you getting tired? Are your interests shifting?)
- Two "profiles" work together: one shows you safe bets, the other explores new options (70/30 split)

**Key Technology**: Beta distributions, behavioral pattern detection

---

### 4. Understanding Why Jobs Match

**What you see**: Tap "Explain Fit" to see why a job was recommended

**What happens behind the scenes**:
- AI compares your skills to the job requirements
- It analyzes your past swipes to understand your preferences
- Generates human-readable explanations in real-time (120ms)
- Everything runs on your phone - no cloud processing

**Key Technology**: Apple Foundation Models (on-device language AI)

---

### 5. Career Path Recommendations

**What you see**: Suggested career transitions with steps to get there

**What happens behind the scenes**:
- Your skills are matched to a government database of 1,016 occupations (O*NET)
- The app analyzes which job categories you're interested in (from swipe history)
- AI generates personalized transition plans with timelines and skill requirements
- Recommendations update as your interests evolve

**Key Technology**: O*NET skill taxonomy + semantic matching

---

## The Three Pillars

### Pillar 1: Privacy First

**What this means**: Everything stays on your phone
- Your resume never leaves your device
- All AI processing happens locally (no internet required)
- No tracking, no ads, no data sales
- Even job listings are cached locally for faster access

**Cost**: $0/month for AI (because it's on-device)

---

### Pillar 2: Lightning Fast

**What this means**: Sub-10ms job matching
- Traditional job matching: 3.5 seconds per batch
- Manifest & Match: 0.01 seconds (10 milliseconds)
- **357x faster** than competitors
- Instant swipe feedback (no lag)

**User Experience**: Feels as responsive as scrolling through photos

---

### Pillar 3: Continuous Learning

**What this means**: Gets smarter with every interaction
- Not just "set it and forget it" preferences
- Adapts as your career interests evolve
- Detects when you're exploring vs. seriously searching
- Notices patterns you might not be aware of

**Result**: Better recommendations over time (not static)

---

## Key Numbers

| Metric | Value | What It Means |
|--------|-------|---------------|
| Job Sources | 7 APIs | More opportunities from diverse sources |
| Matching Speed | 10ms | Instant results (no waiting) |
| AI Systems | 7 | Multiple specialized AIs for different tasks |
| Privacy Cost | $0 | No external AI services |
| Battery Impact | 0.3%/hour | Minimal drain (efficient processing) |
| Occupations | 1,016 | Complete O*NET database for career matching |
| Skills Taxonomy | 636 skills | Comprehensive skill matching |
| Performance Advantage | 357x | Faster than traditional methods |

---

## What Makes This Different

### vs. LinkedIn Job Search
- **LinkedIn**: Keyword matching, limited to LinkedIn network
- **Manifest & Match**: Learning algorithm across 7 job boards, discovers unexpected careers

### vs. Indeed
- **Indeed**: Static search results, pay-to-promote model
- **Manifest & Match**: Personalized ranking, no sponsored posts, learns from behavior

### vs. ZipRecruiter
- **ZipRecruiter**: AI matching (cloud-based, privacy concerns)
- **Manifest & Match**: 100% on-device AI, zero external data transmission

---

## The Journey of a Job Listing

```
1. Job Posted on Multiple Boards
   (Adzuna, Greenhouse, Lever, etc.)
         ↓
2. App Fetches Jobs (every 24 hours)
   - Deduplicated
   - Cached locally
         ↓
3. Thompson Sampling Scores Each Job
   - Based on your swipe history
   - Category-based learning
   - <10ms computation
         ↓
4. Jobs Shown in Order of Match Score
   - Top match first
   - Balanced exploration/exploitation
         ↓
5. You Swipe (Right/Left/Super)
   - Swipe recorded with context
   - Thompson arms updated
   - Behavioral patterns analyzed
         ↓
6. Algorithm Learns and Adapts
   - Next batch of jobs ranked better
   - Preferences refined
   - Career insights generated
```

---

## Common Questions

### Q: "How does the AI know what I like?"

**A**: It watches what you swipe right on and finds patterns. For example:
- You swipe right on 7 out of 10 "Data Science" jobs → The algorithm gives more weight to data science
- You swipe left on all "Sales" jobs → Sales jobs get deprioritized
- Over time, it learns nuanced preferences (remote vs. office, startup vs. corporate, etc.)

### Q: "What if my interests change?"

**A**: The algorithm notices! It has a built-in "decay" feature that gradually reduces the importance of old swipes. Recent behavior matters more than behavior from 6 months ago.

### Q: "Is my data secure?"

**A**: Yes, because your data never leaves your phone. The AI models run locally on your device, so there's no server to hack and no company storing your information.

### Q: "Why is it so fast?"

**A**: Two reasons:
1. **Caching**: Jobs are downloaded in advance and stored locally
2. **Optimized Algorithm**: Thompson Sampling is mathematically efficient (O(k) complexity instead of O(n³))

### Q: "What if I don't like any of the jobs?"

**A**: That's valuable feedback! Swiping left teaches the algorithm what you DON'T want, which is just as important as what you DO want.

---

## Current Limitations (Being Fixed)

### 1. Work Experience & Education Not Saving

**The Problem**: If you manually add work experience or education, it's not saved to the database
**Impact**: You have to re-enter this information if you restart the app
**Status**: Bug identified, fix in progress
**Workaround**: Upload a resume instead (resume parsing DOES work correctly)

### 2. Some Settings Buttons Don't Work

**The Problem**: 11 buttons in Settings (like "Clear Cache", "Export Data") don't do anything yet
**Impact**: These features aren't available
**Status**: Implementation prioritized for next release
**Workaround**: Most critical features (notifications, privacy settings) do work

### 3. Ads Package Not Removed

**The Problem**: There's code for showing ads that's never used (decision made not to monetize)
**Impact**: Takes up 1,850 lines of dead code
**Status**: Scheduled for deletion
**User Impact**: None (you'll never see ads)

---

## Success Stories (What Good Looks Like)

**Scenario 1: Career Changer**
- User was a teacher for 10 years
- Uploaded resume, started swiping on job listings
- Initially saw education jobs (expected)
- Swiped right on tech jobs out of curiosity
- Algorithm noticed the pattern shift
- After 2 weeks: Seeing 60% tech jobs, 40% education
- Result: Discovered "EdTech Product Manager" role (perfect blend)

**Scenario 2: Recent Graduate**
- Fresh CS grad with no clear specialization
- Started with broad swiping (exploring)
- Algorithm detected preference for data-heavy roles
- Career Path feature suggested: "Data Analyst" → "Data Scientist" → "ML Engineer"
- Showed timeline: 12-18 months with specific skills to learn
- Result: Focused job search with clear direction

**Scenario 3: Experienced Professional**
- Senior software engineer, feeling burned out
- Swipe patterns showed declining interest over sessions (fatigue detected)
- Behavioral AI suggested taking a break
- Returned after 3 days, started exploring management roles
- Algorithm adapted to show leadership positions
- Result: Discovered interest in engineering management

---

## Behind the Scenes: The Technology Stack

### The Brain (Algorithms)
- **Thompson Sampling**: The core matching algorithm (Beta distributions)
- **Behavioral Analysis**: Pattern detection from swipe sequences
- **Skills Matching**: Semantic similarity using embeddings

### The Senses (Data Sources)
- 7 job board APIs (Adzuna, Greenhouse, Lever, Jobicy, USAJobs, RSS, RemoteOK)
- O*NET occupation database (U.S. Department of Labor)
- Apple Foundation Models (on-device AI)

### The Memory (Storage)
- Core Data (local database on your iPhone)
- Three-tier caching system (memory, disk, network)
- Encrypted resume storage

### The Body (User Interface)
- SwiftUI (modern Apple framework)
- Card-based design (swipe interface)
- Accessibility support (VoiceOver, Dynamic Type)

---

## What's Next

### Planned Improvements

1. **Fix Critical Bugs** (Work Experience, Education persistence)
2. **Add Export Feature** (Download your data as JSON/CSV)
3. **Implement Settings Buttons** (Clear cache, reset preferences, etc.)
4. **Add Tutorial** (First-time user walkthrough)
5. **Social Features?** (Connect LinkedIn/GitHub - optional)

### Future Enhancements

- **Salary Negotiation Insights**: Compare your offer to market rates
- **Interview Prep**: AI-generated questions based on job description
- **Application Tracking**: Track where you've applied and follow up
- **Company Research**: Automated company culture analysis

---

## For Parents, Educators, Career Counselors

**How to explain this to someone unfamiliar with tech**:

"Imagine a smart career advisor who:
- Reads thousands of job listings every day
- Remembers every job you've looked at and whether you liked it
- Learns your preferences faster than a human could
- Suggests careers you might not have considered
- Never gets tired or biased
- Works 24/7 on your phone
- Keeps everything private

That's what this app does, using advanced math and AI."

---

## Visual Metaphors

### Thompson Sampling = Slot Machine Strategy

Imagine a row of slot machines:
- Some pay out frequently (known good jobs)
- Others might pay out more, but you haven't tried them enough (exploration)
- Thompson Sampling decides: "Should I pull the machine I know is good (exploitation), or try a new one that might be better (exploration)?"
- Over time, you learn which machines (job categories) are best for YOU

### Behavioral Analysis = Pattern Detective

Like a detective noticing clues:
- "You swiped quickly through these 5 jobs" → Might be fatigued
- "You're spending more time on remote jobs" → Remote preference increasing
- "You swipe right more in the evenings" → Best time to show new opportunities

### Career Paths = GPS for Your Career

Traditional job search: "Here's a map, figure it out yourself"
Manifest & Match: "You are here. Your destination is there. Here are 3 routes with estimated time and required skills"

---

## Conclusion

Manifest & Match isn't just a job board scraper - it's an adaptive learning system that helps you discover careers you might not have considered, all while keeping your data private and processing everything instantly on your device.

The technology is complex (Thompson Sampling, Beta distributions, on-device AI), but the experience is simple: swipe, learn, discover.

---

## Documentation References

- **Technical Deep Dive**: See `technical/` folder
- **Executive Summary**: See `15_EXECUTIVE_SUMMARY.md`
- **Project Context**: See `00_README.md`
