I could not create REPORT.md: the harness blocks subagents from writing report `.md` files, and I did not work around that. The full report is in the appendix below for you to save. The raw material is on disk under `/mnt/data/review/sweep/palomar_experts/`: downloads in `dl/`, scripts in `scripts/`, plus `palomar_entries.txt`, `ccposts.txt` and `gemini1.txt`.

## Summary

**Palomar.** I paged the whole registry: 1,349 results, revision 1192.
- **Not registered:** nothing from anthropics/formal-math (neither `eth` nor `vp-vnp`), nothing from openai/math, and nothing from xennygrimmato/eth-hamiltonicity. Each repository lookup returns 404.
- **No circuit lower bound** for E^NP or any explicit class is registered, and no theorem about ETH, SETH or 3-SAT running time.
- **PALOMAR-2026-11-16-000011** (Arth-Singh) proves only linear bounds: P(n) ≥ 4n/3, 15n/11, 67n/49 and n+3, P(4) = 7, P(5) ≥ 8, P(6) ≥ 9.
- **Missing from SURVEY.md:** PALOMAR-2026-10-28-000015, Rudich and Rousseau, "Deterministic factoring in time N^{o(1)}". It re-proves Anthropic's counting engine in Lean. The authors "audited the statement, not the proof."
- **Submission rules** are recorded verbatim in the appendix. The minimum toolchain is v4.35.0-rc2.

**Human verification.** The survey's sentence needs correcting.
- No named expert says they have checked either ETH proof.
- **Formal verification effort:** OpenAI's announcement of 2026-10-26 set up an examination group led by Impagliazzo, Paturi and Ryan Williams, with a site (ethdiscussion.blog), a shared repository, and a conference that OpenAI will fund. The three say: "Our involvement should not be taken as certification of the claim."
- **Fortnow (2026-10-28):** "I have not verified the proof myself, but it is safe to assume now that the exponential-time hypothesis is toast."
- **Statement faithfulness:** Stefan Szeider (Zenodo, 2026-10-27) says OpenAI's Lean statement "is a correct statement of the intended result, for a weaker but still subexponential bound."
- **Errors:** no named expert has reported an error in either proof. The only reported gap is in a non-specialist blog comment.
- **What the authors say now:** the current `eth` README no longer says no human has checked it. The `vp-vnp` README does: "no human mathematician has checked the proof." anthropic.com has no announcement of either result.

**VP ≠ VNP.** Fortnow (2026-11-24) calls Anthropic's paper "for now, the most important computational complexity result of the year". Kalai (2026-11-24) reports that Claude and ChatGPT proved it. Neither says they checked it.

**P vs NP.** I found no claimed resolution since 2026-10-01 that drew expert attention. Clay's most recent news item is a Navier–Stokes announcement of 2026-09-11.

**Not checked:**
- Tao, Barak, Gowers and Wigderson.
- Nature, Science, MIT Technology Review, Quanta, the NYT and Wired.
- Posts on Bluesky and X, including Williams's and Nelson's.
- The ETH Google Drive repository.
- The Lean Zulip: its public archive stops at February 2026.

Some quotes came through the fetch tool, which caps excerpts at 125 characters; they are labelled. My second Gemini call was rate-limited (HTTP 429).

---

## Appendix: full report

### 1. Coverage log

**Palomar (Part A)**
- `palomar-registry.org/llms.txt` (200).
- `/api/v1/results?order=registered` with cursors: 54 pages, 1,349 entries, `totals` {results 1349, projects 1025}, revision 1192, no 409 errors, nothing abbreviated.
- I filtered titles, abstracts, theorem names, repositories and classifications (cs.CC, cs.DS, MSC 68Q/68W/03D15) locally: 258 candidates, which I triaged by hand.
- I fetched 34 full entry records.
- 23 `q=` searches. Zero results for: "exponential time hypothesis", xennygrimmato, Tulsyan, VNP, "permanent circuit", "P versus NP", BPL.
- Repository lookups: anthropics/formal-math 404, openai/math 404, xennygrimmato/eth-hamiltonicity 404, arth-singh/crossing-lower-bounds 200 (1 registration).
- Submission protocol (`submit.palomar-registry.org/llms.txt`), the policy file `CONTRIBUTING.md` and `toolchains.json` (minimum v4.35.0-rc2), all fetched raw.

**Experts (Part B)**
- **RSS feeds by urllib:** the CC blog worked and I read every October–November post in full. Aaronson, Lipton, Kalai, Windows on Theory, Tao and Xena all returned 403. Quanta's feed had no hits.
- **Through the fetch tool:**
  - ethdiscussion.blog: home page, feed, and the 2026-10-26 post with its comments.
  - scottaaronson.blog: home page and post ?p=10283.
  - xenaproject (first 100k characters), gilkalai (first 100k characters), and rjlipton.com, whose newest post is dated 2026-05-03.
- **By urllib:**
  - openai.com/index/building-scientific-understanding-with-academic-communities/
  - TechCrunch, 2026-10-27.
  - Wikipedia's ETH article.
  - anthropic.com/news and /research (no post on ETH or VP ≠ VNP).
  - carlostoledo.co/eth/
  - Woit's blog post p=15896.
  - PDFs by O'Donnell, Kintali and Sellke.
  - Zenodo API: Szeider's records worked; free-text queries returned HTTP 400.
  - arxiv.org abs page and PDF for 2611.09764.
  - claymath.org news page and P vs NP page.
  - Lean Zulip archive: stale, last updated 2026-02-28.
  - Raw READMEs: anthropics/formal-math `eth` and `vp-vnp`, openai/math.
- **Searches:** 6 web searches. Gemini: 2 runs of the same query (the first output was cut off when printed, so I re-ran it saving to a file). A third, different query failed with HTTP 429.

### 2. Palomar

**Registered entries in scope.** All have trust level `high` and the three standard axioms. All received the AI review outcome `neutral` from `codex:gpt-6-sol`. Every authorization relationship is `maintainer`. Palomar has no submitter field.

1. **PALOMAR-2026-10-28-000015** (2026-10-28), "Deterministic factoring in time N^{o(1)}"
   - IsaacRudich/SubexponentialDeterministicFactoring @5f5ff8f382; Isaac Rudich and Louis-Martin Rousseau; v4.35.0.
   - Verbatim: "...one deterministic Turing machine computes the smallest prime factor Nat.minFac N of every natural number N in time N^{o(1)}: for every k >= 1 there is a constant C_k such that the same machine halts with the correct output within C_k * 2^(n/k) steps on every n-bit input... evaluates it with a re-proved form of the counting engine of the 2026 3-SAT preprint by Claude (Anthropic)... The ideas and the Lean code were generated by AI; the authors audited the statement, not the proof."
   - It lists both labs' ETH preprints as sources, marked "not-contacted".
2. **PALOMAR-2026-11-16-000011** (2026-11-16), "Lower bounds for Naslund's crossing problem"
   - Arth-Singh/crossing-lower-bounds @3d302668a9; Arth Singh; v4.35.0-rc2; math.CO and cs.CC; Challenge file 88 lines.
   - Verbatim: "Over every field the project proves P(n) ≥ 4n/3 for n ≥ 3, P(n) ≥ 15n/11 for n ≥ 5, P(n) ≥ 67n/49 for n ≥ 7, P(n) ≥ n + 3 for n ≥ 4, P(5) ≥ 8, P(6) ≥ 9, and P(4) = 7 (with a split that attains 7). The results are original."
3. **PALOMAR-2026-11-23-000005**, "A verified finite oracle reduction for Hamiltonicity"
   - wstrinz; Will Strinz; v4.35.0-rc3.
   - Verbatim: "...No machine-runtime, space, recovery or ETH conclusion."
   - This is the only hit for `q=ETH`. It is not Tulsyan's repository.
4. **PALOMAR-2026-11-11-000006** (v2, 2026-11-14), "A beeping busy beaver machine for the Σ₂ form of P vs NP" (Gregory Morse). It encodes P = NP as a quasihalting question and proves the equivalence in Lean. It does not resolve anything.
5. **PALOMAR-2026-11-04-000006**, "The natural proofs barrier (Razborov and Rudich)" (zzyzek). This is the only registered barrier theorem.
6. **R. D. Barish:** PALOMAR-2026-10-02-000013 (Cook–Levin and NP-completeness of SAT variants; "GPT-6 Astra ... produced the proof, and Claude Opus 5.5 ... ran its full verification"), and PALOMAR-2026-10-09-000010 (the PCP theorem and APX-completeness of MAX-3-SAT). The second reuses pieces of "the Lean formalization of the Unique Games theorem in the OpenAI mathematics repository".
7. **Other complexity-related entries:**
   - PALOMAR-2026-10-28-000017: Merhavi, "Group constructions cannot refute the Set Cover Conjecture".
   - PALOMAR-2026-11-09-000020 and PALOMAR-2026-09-21-000005: exact AND-gate counts for small multipliers.
   - PALOMAR-2026-10-30-000013: TSP and 3-SAT reductions.
8. **Matrix multiplication:**
   - PALOMAR-2026-10-08-000005 and -10-11-000007: Sela Navot, extensions of OpenAI's ω ≤ 9/4 to every field and every ring.
   - PALOMAR-2026-10-07-000007: ω < 2.3710449.
   - PALOMAR-2026-10-13-000009: bilinear rank of 3×3 matrix multiplication ≥ 21.
   - PALOMAR-2026-11-14-000005 and -000006: rank-640 and rank-708 schemes.
   - PALOMAR-2026-11-21-000018: Strassen's algorithm.
   - PALOMAR-2026-09-30-000014: pebbling I/O bounds.
9. **PALOMAR-2026-10-08-000003** (Jihoon Hyun): 3SUM in O(n^1.99896) and APSP in O(n^2.99791), built on Anthropic's `3sum-apsp` formalization.
10. **VP, VNP and the permanent:** nothing registered.

**Specific answers:**
- Anthropic `eth`: no. Anthropic `vp-vnp`: no. Anything from openai/math: no.
- Tulsyan's repository: no.
- E^NP or any explicit-class circuit lower bound: none.
- ETH, SETH or 3-SAT running-time theorems: none.

**Submission requirements (verbatim excerpts):**
- **Files:** "lean-toolchain / lakefile.toml / lake-manifest.json / formalization.yaml / Challenge.lean / Solution.lean / comparator.json / LICENSE". A full 40-character commit SHA is required. The repository must be ≤ 500 MiB. One entry per Comparator configuration.
- **Toolchain:** "no older than the minimum recorded in `toolchains.json`" (now v4.35.0-rc2). It must exactly match the Mathlib toolchain.
- **Size limits:** "Every regular `.lean` source file ... must use Lean's module system and contain at most 10,000 physical lines." The Challenge file is capped at 1,000 lines and 100 KiB, with a warning above 300 lines or 32 KiB. The Challenge's import closure may contain only Lean core, Mathlib, Tau Ceti or CSLib.
- **Axioms:** "`permitted_axioms` may contain only `propext`, `Quot.sound`, and `Classical.choice`."
- **Checks:** Comparator, then Lean's kernel, then "the independent NanoDa kernel checker". Preflight must use the reusable workflow `PalomarSubmission/.github/workflows/submission.yml` with `mode: full`.
- **Scope:** Palomar does not index "purported solutions of famous open problems without a careful comparison with the standard conjecture...", nor "duplicated or lightly repackaged work without useful provenance".
- **Review:** "No person reads an ordinary submission before the outcome ... it is not evidence that a mathematician has checked the result."
- **Steps:** `POST /api/submit` → create tag `palomar-verify-CHALLENGE` → secret gist → `POST /api/verify` → delete the tag and gist. The intake expires after 15 minutes, with 10 attempts. `POST /register` requires `review_sha256` and only after the user's explicit instruction.

### 3. Expert statements

**(a)/(b) The ETH refutations**
- **OpenAI** (2026-10-26), openai.com/index/building-scientific-understanding-with-academic-communities/, PRIMARY:
  - "This work will be verified and shepherded by a group led by Russell Impagliazzo (UC San Diego), Ramamohan Paturi (UC San Diego), and Ryan Williams (MIT)."
  - "...that OpenAI commit to funding a conference to understand the implications of this work."
  - The result "was subsequently verified in Lean."
- **Impagliazzo, Paturi and Williams** (ethdiscussion.blog, 2026-10-26), PRIMARY through the fetch tool: "Our involvement should not be taken as certification of the claim." / "A result of this significance requires careful, independent scrutiny". They propose a virtual meeting before the end of 2026.
- **Francis Zane** ("Lean Replications", 2026-10-30), PRIMARY through the fetch tool: unnamed people "run the Lean proofs locally and confirmed that they compiled"; "someone besides the original author should probably check the proof".
- **Ryan Williams** (TechCrunch, Tim Fernholz, 2026-10-27; quoted speech), PRIMARY:
  - "there are two or three alien-looking parts, and it's exactly these parts that I saw that made me think, wow, this is something that the whole community needs to work on together"
  - "Every computer scientist should probably put a little more weight on the plausibility of P = NP"
  - "I don't think that OpenAI's algorithm could possibly be the best algorithm you can get."
  - Journalist's paraphrase, not Williams's words: Anthropic mathematician Levent Alpöge "suggested that OpenAI was basing its solutions on pre-existing work."
- **Lance Fortnow** (blog.computationalcomplexity.org/2026/10/the-exponential-time-refutation.html, 2026-10-28), PRIMARY: "I have not verified the proof myself, but it is safe to assume now that the exponential-time hypothesis is toast." He recommends O'Donnell's exposition.
- **Fortnow** (2026-11-04), PRIMARY: "Spoiler alert: It will never beat CDCL."
- **Fortnow** (2026-11-23), PRIMARY: "They are mostly Lean-verified. And if they aren't, I'm not the one to thoroughly check all the details."
- **Bill Gasarch** (2026-11-01), PRIMARY: "(Throughout this post I will assume that the recent results by OpenAI and Anthropic contain correct proofs of what they claim.)" / "All of these results are being looked at by experts."
- **Stefan Szeider** (Zenodo 23688832, 2026-10-27), PRIMARY:
  - "This note does not judge the correctness of the proof."
  - The algorithm is exhaustive search below 2^131071.
  - OpenAI's Lean statement "is a correct statement of the intended result, for a weaker but still subexponential bound."
- **Szeider** (Zenodo 24299623 v2, 2026-11-16), PRIMARY: proves in Lean, on top of Anthropic's development, that "the weighted model count of every 3-CNF ... has an arithmetic circuit of size 2^(o(n))", and that IPS refutations of size 2^(o(n)) follow.
- **Jesper Nederlof** (comment, 2026-11-05), PRIMARY through the fetch tool: "the anthropic approach now looks quite intuitive to me"; "I think I got quite far already towards a short and self-contained exposition".
- **Nathan Lindzey** (comment, 2026-11-05), PRIMARY through the fetch tool: "I'm still trying to understand the proof (haven't finished it yet)".
- **Shachar Lovett** (comment, 2026-11-04), PRIMARY through the fetch tool: asks for "a poly-math like blog".
- **Expositions:**
  - Ryan O'Donnell, dated 2026-10-30: "Produced ... through interaction with LLMs".
  - Shiva Kintali, "A simplified proof of ETH is false", 2026-10-26.
  - Sellke slides (msellke.com), titled "Theorem (OpenAI/Anthropic, 2026)".
  - None of these states that the author checked the proof.
- **Vassilevska Williams and Zamir**, arXiv:2611.09764 (2026-11-06), PRIMARY: they re-prove one lemma "distilled ... out of the recent ETH refutation of OpenAI" with a self-contained proof, and cite "[Ope26a, Cla26]".
- **Carlos Toledo** (carlostoledo.co/eth/; comment of 2026-10-28), PRIMARY:
  - He replayed both Lean proofs with Comparator, Lean's kernel and nanoda: "CERTIFIED", "It does not mean that a Lean statement is its paper's theorem".
  - He bridged both statements to a textbook ETH in Lean.
  - His tools were written with Claude.
- **Alexander Arefiev** (comment, 2026-10-30), PRIMARY through the fetch tool: "the Lean 4 formalization didn't even check the actual Word RAM complexity claimed in the paper". This is a non-expert claim.
- **Scott Aaronson** (2026-10-26, ?p=10239), PRIMARY through the fetch tool: "an OpenAI model has now refuted the Exponential Time Hypothesis". He makes no statement about checking it.
- **Leads I could not confirm (SNIPPET):** Jelani Nelson read Claude's proof before release; an NYT quote of Impagliazzo dated 2026-11-07; Williams on Bluesky; Peter Jonsson in WIRED; Aaronson raising his odds of P = NP to 5%.

**(c) VP ≠ VNP**
- **Fortnow** (2026-11-24), PRIMARY:
  - "This is, for now, the most important computational complexity result of the year"
  - "Anthropic's proof uses essentially no algebraic geometry"
  - "VP ≠ VNP does not imply this Boolean separation"
  - "settling the P v NP question remains far out of reach for man or machine."
- **Gil Kalai** (2026-11-24), PRIMARY through the fetch tool: "The big news of today is that Claude, and a few hours later ChatGPT, proved that VP ≠ VNP."
- No other named reaction found, including none to OpenAI's family 379.

### 4. Plain answers to item 5
- **Has a named expert said they checked either ETH proof?** No. Fortnow explicitly has not, and the examination group disclaims certification.
- **Has anyone checked the statements' faithfulness?** Szeider did so for OpenAI's Lean statement. Toledo, who is not a complexity theorist, did so for both.
- **Has anyone reported an error or gap?** No named expert has. Arefiev's comment above is the only reported gap.
- **Is there an organised effort?** Yes, for OpenAI's result: the Impagliazzo–Paturi–Williams group, ethdiscussion.blog, a Google Drive "ETH_Repository", a feedback form, a planned virtual meeting, and a conference funded by OpenAI. Anthropic's paper is discussed on the same site. I found no journal or conference submission.
- **What do the labs say now?**
  - OpenAI: verification is being done by the external group.
  - Anthropic, `eth` README at main: "Lean 4 formalization, which was written by AI models". It contains no "no human" sentence.
  - Anthropic, `vp-vnp` README: "no human mathematician has checked the proof."
  - A search snippet says the paper itself states "no person is known to have checked it". I did not verify that.
  - anthropic.com has no post on either result.

### 5. P versus NP
- I found no claimed resolution since 2026-10-01 that received expert attention.
- Fortnow (2026-10-07): "none of these results get us any closer to settling P v NP."
- Clay's news page: the newest item is "11 September 2026 Navier-Stokes Announcement". Nothing from October or November.

### 6. Works not in SURVEY.md
- The Palomar entries listed in section 2: items 1, 3, 4, 5, 6, 7 and 9, and Navot's two extensions (item 8).
- ethdiscussion.blog and its Drive repository.
- Expositions: O'Donnell, Kintali, Sellke; Nederlof's Drive folder.
- Szeider's Zenodo notes: 23688832, 23981772, 24088151, 24299623.
- arXiv:2611.09764 (Vassilevska Williams and Zamir).
- arXiv:2611.05082 (Alman, Li, Pant, Pratt, Williams on hyperclique), title only.
- arXiv:2610.08144 (Bastounis, Circelli and Hansen on Lean and the natural-language proof), not read.
- arXiv:2611.02650 "ETH is Dead, Long Live SH", title only.
- carlostoledo.co/eth/
- Subercaseaux's result NTIME(T) ⊆ DTIME(2^{O(T(log log T)^3/√log T)}), from an X post cited by Fortnow and O'Donnell.
- Fortnow's page lance.fortnow.com/openai-math-tcs.htm.
- Arefiev's Zenodo records 23840074 and 24136643 (low credibility).

### 7. Not done
- Blogs and people: Tao (blog and Mathstodon), Windows on Theory, Barak, Gowers, Wigderson.
- News: Nature, Science, MIT Technology Review, a direct check of Quanta, the NYT and Wired.
- Social media: Bluesky and X.
- Contents of the Google Drive repository.
- Toledo's page beyond §2.
- The full text of Kalai's VP ≠ VNP post, and the Xena and Kalai pages beyond 100k characters.
- The Challenge.lean of the factoring entry.
- Further Gemini queries (rate-limited).
- The Lean Zulip (its public archive is stale).