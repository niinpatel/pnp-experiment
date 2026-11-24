I covered the whole Hexagon catalogue, but I could not write `REPORT.md`: the environment blocks subagents from writing report files. The findings are below; please create the report from them. The evidence is under `/mnt/data/review/sweep/hexagon/`:
- `table_2a.md`: the relevant-items table.
- `table_2b.md`: titles of the 1,462 irrelevant items.
- `provenance_all.txt`: provenance statements and version histories.
- `dl/<id>/`, `extracts/`, `refs/`.
- `refs/_chase_2026_refs.tsv`: the citation chase.

**Coverage.**
- **Global listing:** the cursor crawl of all subjects returned 1,530 of 1,530 works, ids 2609.00001 to 2611.00998. 1,492 are dated 2026-10-01 or later. The cs.CC listing has 66 works.
- **Queries:** 28 keyword queries. None turned up an item missing from the global listing.
- **Fetches:** every fetch returned HTTP 200.
- **Contributors:** nothing on Hexagon was contributed by Majdoddin, Dias, Lima, Wu, Wang or Szeider.

**Relevant items, 20 papers.**
- **The two originals:**
  - 2610.00577: only v1, dated Oct 27; the PDF says October 26.
  - 2611.00954 (VP ≠ VNP).
- **Follow-ups:**
  - Expositions: O'Donnell 2610.00572, Kominers 2610.00574.
  - Factoring: Rudich–Rousseau 2610.00600 (Lean, Palomar entry PALOMAR-2026-10-28-000015) and Shunia 2610.00711.
  - Uses of the new counting algorithms: Bhattacharjee 2610.00594, Nguyen 2611.00004, Xiaoyu Li 2610.00613, 2611.00132 and 2611.00133.
  - Tulsyan: 2610.00672, 2611.00088, 00090, 00115, 00116 and 00149.
  - Naves de Brito 2610.00692.
  - Fradj 2611.00627 (limits on pieces).
- **Builds on the VP ≠ VNP papers:** Liu 2611.00994; Liu 2611.00972 cites the Anthropic one.
- **Claims to settle P vs NP:** none found.

**2611.00149 (Tulsyan), read in full.**
- **The ρ ≥ 3/8 result** is Prop 4.12, "(on paper)", lines 690–694. It applies to decompositions of a full g×g grid level into row and column networks whose terms need not be products: "ρ ≥ h(3h−2)/(2(2h−1)²) − o(1) → 3/8 and α′ ≤ log2(8/3) ≈ 1.415". Prop 4.13 (695–700) says 3/8 is the limit of that method.
- **What is in Lean:** rank bounds only (Theorems 4.1, 4.9–4.11).
  - The ρ ≥ 1/2 result for pieces is the "rank form", which the paper credits to Anthropic's Appendix H (496–500).
  - Correlated (non-product) decompositions reach N², N³ and N⁸. N⁹ is open; it is Conjecture 4.15 (705–710).
  - The step from network cost to rank is on paper (1160).
  - 45 theorems are cited, standard axioms only (1153–1155).
- **E^NP:** nothing on an E^NP circuit lower bound, in Lean or on paper. No Hexagon item mentions Tulsyan's Lean E^NP proof.
- **What it does not claim:** "No theorem in this paper is about all algorithms" (174). "No human has checked the work" (1259).

**Scope item 5.**
- **Faster than 2^{O(m/√log m)}:** NOT FOUND. Every follow-up uses the 1/√log rate.
- **Pieces with ρ < 1/√2, or a floor above 1/2:** NOT FOUND.
  - Fradj's Theorem 6.5 (680–686) proves a window cost of at least 1/√2 + η_J − C_J/√m, but only for Kleinian-code graded spaces. The paper says it does "not … bound the intrinsic row/column ranks" (118–121).
  - Fradj Q8.6 (lines in §8) and 2611.00149 Q8.4 (1048–1053) both leave the general question open.
- **Lean E^NP lower bound, at a general rate or from a general hypothesis:** NOT FOUND.
- **Claimed error in either ETH paper or either VP ≠ VNP paper:** NOT FOUND.
- **Human expert review:** NOT FOUND.
  - 2611.00954 line 579: "No human mathematician has checked the proofs."
  - O'Donnell's landing page says "Human understanding: no parts".
  - Kominers is "far from having fully grokked" the argument.
- **Other VP ≠ VNP points:**
  - Theorem 1.1 is at lines 66–73.
  - The paper has "not analysed … relativization and algebrization" (158–159).
  - It does not mention OpenAI's VP ≠ VNP paper; its only OpenAI citation is the determinantal-complexity manuscript [OAI26] (138).

**References not in SURVEY.md:**
- Hexagon papers: 2610.00594, 00600, 00613, 00672, 00711, 2611.00004, 00088, 00090, 00115, 00116.
- Curticapean arXiv:2611.03636, a (2−10⁻⁴⁰)^n permanent algorithm.
- Majdoddin arXiv:2610.17420 (3SUM/APSP).
- Sheshadri arXiv:2610.40484, Guo arXiv:2609.29568, Kumar–Volk arXiv:2609.34462, Raz arXiv:2604.22006.
- The GitHub repo bochum-crypto/subexponential-ecdl.
- Khoruzhii's notes on lemmata.iol.berlin: "Crossing decomposition…" and "square-root bound…".
- Wu–Wang arXiv:2611.02560 is not cited by any Hexagon paper.

**Leads not followed:** the Palomar entry above, the Lemmata server, bochum-crypto, and Tulsyan's factoring note (`factoring-note/` in his repository).

**What I did not check:**
- Only 2611.00149 was read line by line. The other papers were downloaded in full, but I read only their opening sections and the lines my keyword searches hit.
- I did not read 2611.00388, 2611.00972 or 2611.00055 beyond their abstracts.
- I did not check any proof, and did not open the source (src) downloads or the bibtex.