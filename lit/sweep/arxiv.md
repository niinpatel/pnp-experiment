I could not write `/mnt/data/review/sweep/arxiv/REPORT.md`: the harness refused it ("Subagents should return findings as text"), and I did not get around that through Bash. So the report is below, longer than the 400 words you asked for. The supporting data my scripts saved is under `/mnt/data/review/sweep/arxiv/`: `ECCC_2026.tsv`, `abstracts_tier1.md` and `abstracts_tier2.md` (verbatim abstracts), `all_api.json`, `ext/` (theorem extracts with line numbers), `refs/` (reference lists), `dl/` (downloads) and `scripts/`.

**1. Coverage**
- **arXiv API:** worked with no rate limits. 16 queries over 2026-10-15 to 11-25 (cs.CC 365 results, cs.DS 796, cs.LO 326, plus keyword queries), 2,469 unique records in all.
  - The cs.CC listings for 2026-10 and 2026-11 match the API results exactly.
  - Not cross-checked against listings: cs.DS and cs.LO. Not swept by category: math.CO and cs.AI, which are covered only by the keyword queries.
- **ECCC:** the live site, its RSS feed and WebFetch all hit a JavaScript bot challenge or "Request Rejected"; I did not run the challenge. The only copy available was the Wayback snapshot of 2026-10-20, which lists TR26-001 to TR26-265 (264 reports, TR26-093 absent) and is in `ECCC_2026.tsv`. dblp blocks bots too.
  - So reports from TR26-266 onward are not listed. In particular, everything after TR26-339 is not checked.
  - Gemini's ECCC leads (TR26-275, 300 and others) are unconfirmed.
- **Zenodo:** worked with `size=25`.

**2. arXiv follow-ups the survey lacks** (all checked in full text unless noted):
- 2611.11832, Strassle and Subercaseaux: "NTIME[t] ⊆ DTIME[2^{O(t/√log t)}]" (Thm 1, lines 47-50). It rests on OpenAI's Theorem D.1.
- 2611.02650 v2, MIT Hardness Group, "ETH is Dead, Long Live SH": "SH is equivalent to Weak ETH" (Thm 2.4, lines 413-414).
- 2611.01884 v2, Ben Daniel, a space bound of t/√log t. Lines 252-256 say that in Anthropic's Lean development "The time clause of Definition 7 is formalized only in a weak form". That is a limit of the formalization, not an error.
- 2611.02548, Wu and Wang: assumes OpenAI's Theorem D.1 as "Hypothesis 1" (line 195).
- 2611.26080, Molter: results "Conditional on OpenAI's Theorem D.1" (line 119).
- Further applications, abstracts or citations only: 2610.41048 (Kozma), 2611.27956 (Firbas and Sorge, Cluster Editing), 2611.00994, 2611.12321, 2611.24611, 2611.24750.
- Hypothesis refutations: 2611.03880 (which says it is "almost entirely due to AI"), 2611.05082, 2611.06813, 2611.09764 (k-Clique).

**3. Answers to the four checks**
- **Better rate than 2^{O(m/√log m)}:** none found anywhere.
- **Claimed errors in the ETH or VP ≠ VNP papers:** none found. No arXiv paper addresses the VP ≠ VNP manuscripts.
- **E^NP circuit lower bounds:** only Wu and Wang, 2611.02560 (read in full), and both results hold only infinitely often.
  - Thm 1 (lines 42-48): Ω(m√log m/log log m) gates over unbounded AND/OR with binary XOR.
  - Thm 2 (lines 71-77): Ω(m√log m) gates over a bounded binary base with a budget b(C) ≤ δm of XOR and symmetric gates.
- **Majdoddin (2610.41622):** still v1.

**4. Zenodo**
- **Szeider, 23688832** (v1 only; read in full, 81 lines). OpenAI's main-text algorithm is exhaustive search below about 2^(10^10) variables, and the Appendix D algorithm below n+m = 2^131071.
  - Line 20: "An independent group led by Russell Impagliazzo, Ramamohan Paturi and Ryan Williams will examine the proof".
  - The record's addendum on Anthropic gives 2^275616 clauses and 2^(1.7·10^10) variables, "rather than" the paper's 10^10000 and 10^(10^8).
- **Siemaszko, 24024689:** a concept DOI with versions v0.2 and v0.4, both 2026-11-07; listed creators "Claude, JacobSiemaszko". Read in full.
  - Claim: "B_Q(N) ≤ N^{√2+o(1)} and σ_C(N) ≤ N^{√2+o(1)}", against Hrubeš's ≈1.615.
  - The author "has not verified the mathematical argument" (§9).
- **New Szeider notes:**
  - k×k Clique Hypothesis, now v3 of 11-09.
  - 24299623, a Lean-proved 2^{o(n)} IPS refutation of every unsatisfiable 3-CNF. It says of the two ETH proofs: "widely accepted, but not yet published in refereed form" (line 33).
  - 23981772, the klam value.
- **Other new records:** Toledo's Lean kernel exports of OpenAI's family 378 (23991348); Çıracıoğlu (23895435); Lin (23724560); Geiger (24024062); Vinaik (24042872); Bhattacharjee, an E^NP wire lower bound (24163297, description only); Yianni and Allahyar (23925452); many records claiming to resolve P vs NP (Islam, Storm and others), none assessed.

**5. Corrections to SURVEY.md**
- **Line 36:** 2611.01774 (Gaspers) is not a follow-up. It mentions the ETH preprints only in §2.5 (lines 749-755).
- **Line 37:** Chukhin's result covers constant-depth circuits only; the paper says the k-OV Conjecture "remains open" (lines 281-283).
- **Lines 49 and 57:** TR26-039 (Chen, Tal, Wang, "Super-quadratic Lower Bounds for Depth-2 Linear Threshold Circuits") and TR26-118 (Ren, Williams, E^{prMA}/₁) are confirmed from the archived index. "Range avoidance" and "circuit-analysis algorithms" are not visible in the index snippets.
- **Line 46:** TR26-260 v0 does say 3.5n−o(n). But arXiv:2611.30887 (line 63 and its reference [8]) cites a "Revision 1, 3 November 2026" with 4n − O(log n). That is unverified.

**6. References not in SURVEY.md:** Cruz (GitHub draft), Kintali's note, Schlesinger (complexitylib), Tulsyan hexagon:2611.00090, Li hexagon:2610.00613, Nguyen hexagon:2611.00004, the UC San Diego ETH Group note, Lampis and Aaronson comments, Manurangsi 1611.05991 v3, and an Impagliazzo–Paturi–Williams "Message to the TCS Community on ETH". The full lists are in `refs/`.

**7. Not done**
- No ECCC data after TR26-265, and no ECCC abstract pages beyond the index snippets.
- Not every line was read: only Wu and Wang (2611.02560), Szeider's 23688832 note and Siemaszko's note were read line by line. The other papers I checked through structured extracts plus targeted passages; Gaspers' 182-page paper only that way.
- The k×k note and the "Consequences" note were read only in part.
- No Lean or companion files were inspected.
- No version check for the arXiv:2607.09963 that the survey cites for TR26-118.

Sources: [ECCC TR26-138](https://eccc.weizmann.ac.il/report/2026/138/), [ECCC TR26-128](https://eccc.weizmann.ac.il/report/2026/128/), [ECCC TR26-186](https://eccc.weizmann.ac.il/report/2026/186/), [ECCC TR26-104](https://eccc.weizmann.ac.il/report/2026/104/), [CASRAI](https://casrai.org/news/anthropic-claude-authored-vp-vnp-proof-unverified-lean-2026) (web search leads only).