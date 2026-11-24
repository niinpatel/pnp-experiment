# Literature survey: P vs NP as of 2026-11-24

**History of this file.** Written by the first session on the morning of 2026-11-24 from arXiv, ECCC
and the two labs' repositories. Corrected by the review session the same day. Sections 0, 5 and 6
were rewritten on 2026-11-24 (evening, UTC) after a sweep of the venues the first pass had missed:
the Hexagon preprint server, third-party GitHub repositories and issue threads, the Palomar
registry, Zenodo, the Lemmata repository, and expert commentary. Section 5 says how the sweep was
done and what it did not cover.

How claims are labelled:
- **[read]** means I opened the primary text myself and read the passage I quote or summarise.
  "Full" is said only where I read the whole document.
- **[agent]** means a reader subagent of the sweep fetched the primary text and quoted it to me.
  The saved copies are under `/mnt/data/review/sweep/`. I did not open the text myself.
- **[V-primary]**, **[V-listing]** and **[secondary]** are the first session's labels and remain in
  sections 1 to 4: read in the primary source; title and authors seen in an index; and news, blog
  or search summary only.
- **[lead]** means a search summary only. A lead is not a fact.

Nothing below was checked for mathematical correctness unless a line says so.

## 0. Headline

P vs NP is **open**. No claimed resolution since 2026-10-01 has drawn expert attention [agent]. The
Clay Mathematics Institute's news page has nothing on it [agent]. Several arXiv and Zenodo
preprints claim a resolution (for example arXiv:2512.11820, arXiv:2508.13166, and a number of
Zenodo records); none shows any sign of expert endorsement [secondary; agent for Zenodo].

The two strongest results near the problem were both found by AI models in late 2026. Both say
explicitly that they do not settle P vs NP.

1. **VP ≠ VNP over every field** (Claude, Anthropic; posted 2026-11-23; `anthropics/formal-math`,
   folder `vp-vnp`; hexagon:2611.00954).
   - **Result** [read: Theorem 1.1 in the Hexagon text]: there is an absolute constant c > 0 such
     that every arithmetic circuit for HC_m, and for PERM_m in characteristic other than 2, has
     more than m^{c (log m)^{1/3}} gates. The bound extends to border complexity.
   - **Verification:** formalized in Lean 4 with the standard axioms only; rebuilt in the first
     session (`experiments/lean-rebuild/`). The paper says: "No human mathematician has checked the
     proofs" [read].
   - **Technique** [V-primary: paper §1–2]: spectral points (Strassen's asymptotic spectrum; their
     existence comes from Zorn's lemma). The proof splits into a "flat" case and a "contracting"
     case.
   - **Why it does not reach Boolean circuits** [V-primary: paper §2.5]: two steps look at the
     formal polynomial at each gate. A Boolean circuit only has to agree on {0,1}.
   - **Barriers** [read]: "We have not analysed how it relates to relativization and algebrization."
   - **OpenAI's parallel manuscript,** "VP and VNP are different" (family 379 of `openai/math`).
     OpenAI's changelog says it "was obtained on November 6, 2026" and added on 2026-11-23 [read].
     Anthropic's paper does not mention it [agent].
   - **Reaction** [read: Fortnow's post of 2026-11-24]: "This is, for now, the most important
     computational complexity result of the year"; "VP ≠ VNP does not imply this Boolean
     separation"; "settling the P v NP question remains far out of reach for man or machine."
2. **The Exponential Time Hypothesis is false.** Two papers, a day apart.
   - **Anthropic** (Claude, "A 2^{o(n)} Time Algorithm for 3-SAT", 2026-10-26;
     `anthropics/formal-math`, folder `eth`; hexagon:2610.00577) [V-primary: paper].
     - **Main theorem:** #k-SAT in time 2^{O(min{k² n log log n/√log n, k m/√log m})}, on Mathlib's
       Turing machines. Machine-checked in Lean; rebuilt here, and re-checked here with an
       independent kernel (`REVIEW.md` §2.1).
     - **Technique:** contracting tensor networks on a complete graph, after writing each crossing
       of two edges as a signed sum of cheaper "pieces". Three versions exist and should not be
       mixed up: the README's condensed sketch (a one-bit identity, SWAP = I − 2·singlet, with
       e(9K^16) ≤ 0.9·e(K) + O(1/K)); the paper's main text (the eight-square identity, factor
       11/12); and the stated rate, which comes from Theorem A with the Appendix B pieces
       (factor ρ = 1/√2, K squared per level).
     - **Practicality:** none. For m = 5n there is no gain over 2^n unless n > 10^{10000}.
     - **Consequences stated in its §7,** all formalized upstream: SETH, NSETH and #ETH are false;
       several graph problems in 2^{δn}; E^NP has no linear-size circuits.
     - **Human checking, in the paper's own words** [read: App. E]: the Lean development "was
       written by AI models and reviewed by other instances of the same models; at the time of
       writing no person is known to have checked it".
     - **Provenance** [read: Hexagon page]: "The core algorithm was found on October 16 by an
       internal Claude research model with 14M output tokens and no human input."
   - **OpenAI** ("The Exponential Time Hypothesis is False", 2026-10-17, revised 2026-10-25;
     `openai/math`, family 378) [V-primary: paper, `lean/docs/378.md`].
     - Its Lean development covers the counting algorithm at rate 2^{O_k(n (log log n)²/√log n)}.
     - Its Corollary 1.4, on paper only: E^NP ⊄ SIZE(c·n·√log n), at infinitely many lengths.
   - **Has any human checked either proof?** Not in full, as far as the sources swept show. An
     expert group is examining OpenAI's proof and explicitly disclaims certification; no named
     expert has reported a technical error. Details in §6.1.

**What this repository added.** Lean proofs, on top of Anthropic's development, of
E^NP ⊄ SIZE(ε·n·√log n) and of three transfer theorems (`experiments/enp-superlinear/RESULT.md`).
The first is not new even as a formalization: V. Tulsyan's public Lean proof of the same statement
is dated 2026-11-04 (§6.2). The transfer theorems were not found anywhere else (§6.2).

## 1. Other 2025–2026 results near the problem

All entries below are [V-listing] in the ECCC 2026 index (eccc.weizmann.ac.il/year/2026), unless marked otherwise. Only TR26-173 to TR26-339 were in the part of the index I fetched. The one-line summaries come from search snippets; I have not read the papers.

**Boolean circuit size**
- TR26-260, Mishra & Santhanam: an explicit 3.5n − o(n) lower bound for general B_2 circuits. The previous record was 3.1n, from Li–Yang (STOC 2022). A later paper cites a revision of 2026-11-03 with 4n − O(log n) [lead; not checked].
- arXiv:2611.30887, Yianni & Allahyar (2026-11-23): a (17/7)n − o(n) lower bound over the full binary basis for one binary encoding of 3-SAT [read: abstract].

**Threshold and constant-depth circuits**
- TR26-039, Chen, Tal & Wang, "Super-quadratic Lower Bounds for Depth-2 Linear Threshold Circuits" [agent: archived index]. That it goes through circuit-analysis algorithms is [secondary].
- TR26-248, Chukhin: "Breaking the Parity Barrier for Constant-Depth Circuits".
- TR26-221, Korten: "Top-Down Lower Bounds for All Depths".
- TR26-302, Korten: "Tight Depth Lower Bounds for Stretch Amplification".
- TR26-313, Chukhin, Gajulapalli, Golovnev & Mihajlin: unconditional circuit lower bounds using low-degree PIT.
- TR26-330, Reitwießner: improved bounds for depth-2 threshold circuits computing Andreev's function.

**Exponential-time classes, range avoidance and TFNP**
- TR26-118, Ren & Williams: circuit lower bounds for exponential time with MA queries (arXiv:2607.09963) [agent: archived index for authors and title]. "Near-maximum" and "via range avoidance" are [secondary].
- TR26-233, Li & Tell: hardness of range avoidance gives "plasticity".
- TR26-270, Li: derandomizing fragments of AM with range avoidance.
- TR26-319, Ghentiyala, Korten & Pitassi: power and limitations of TFNP hierarchies.

**Collapses and witness isolation**
- TR26-328, Hirsch & Volkovich: "The Ultimate Karp–Lipton Collapse".
- TR26-250, Hirsch, Volkovich & Williams: input-oblivious classes in the second level of PH.
- TR26-246, Ben Daniel: constant-probability witness isolation implies NP ⊆ P/poly.

**Space, isolation and unambiguity**
- TR26-323, Hoza: **NL = UL**. This resolves a long-standing open problem.

**Meta-complexity**
- TR26-249, Goldberg, Nanashima & Oliveira: learning, compression and meta-complexity.
- TR26-253, Goldberg, Hu, Lu, Lyu & Oliveira: the gap between average-case and worst-case complexity.
- TR26-290, Goldberg, Hu, Lu, Lyu & Oliveira: asymmetry of nondeterministic computations.
- TR25-203, Hu, Lu & Oliveira: hardness of nondeterministic Kolmogorov complexity [secondary].
- TR26-277, Garlik, Gryaznov, Lu, Santhanam & Tzameret: meta-mathematics of algebraic complexity.

**Proof complexity**
- TR26-316, Alekseev et al.: hard instances for depth-4 PC and AC0[2]-Frege.
- TR26-332, Itsykson & Smirnov: resolution is automatable on Tseitin formulas.
- TR26-196, Li, Ren & Zhong: proof complexity generators inside demi-bits generators.

**Algebraic complexity: determinantal complexity and border depth**
- TR26-218, Kumar & Volk: a quadratic lower bound on determinantal complexity.
- TR26-287, Sheshadri: extends "OpenAI's cubic lower bound for the permanent" (dc(perm_m) = Ω(m³)) to odd characteristic.
- TR26-309, Sheshadri: dc(perm_4) = 15.
- TR26-297, Dey, Dutta & Guo: an exponential top fan-in hierarchy for border depth-4 circuits.

**Algorithms**
- TR26-281, Shpilka: exposition of "OpenAI's matrix multiplication in exponent 9/4".
- arXiv:2610.06783, Alman & Vassilevska Williams: 3SUM in O(n^{1.9992}) and APSP in O(n^{2.99942}). Formalized by Anthropic.

## 2. Barriers any P ≠ NP proof must pass (classical, from memory; standard)

- **Relativization** (Baker, Gill & Solovay 1975). There are oracles A and B with P^A = NP^A and P^B ≠ NP^B.
- **Natural proofs** (Razborov & Rudich 1997). If a lower-bound argument is *constructive* and *large*, and it works against P/poly, then strong PRFs do not exist.
- **Algebrization** (Aaronson & Wigderson 2009). Techniques that algebrize cannot separate P from NP.
- **Locality barrier for hardness magnification** (Chen, Hirahara, Oliveira, Pich, Rajgopal & Santhanam 2020).

Known non-relativizing, non-naturalizing successes:
- Williams' ACC lower bounds: NEXP ⊄ ACC⁰ (2011), then NQP ⊄ ACC⁰ (Murray & Williams 2018).
- The algorithms-to-lower-bounds program that the 2026 E^NP results come from.

## 3. OpenAI `openai/math` catalogue

Label for this section: **[catalogue summary read, paper not read]** unless noted otherwise.
The repository README lists 722 manuscripts in 374 families, produced by an unnamed internal model. About 42% of the top-line results are formalized in Lean.
- **Changelog** [read: `history.md`]. The entry of 2026-10-26 says of the ETH paper: "An independent working group of computer scientists led by Russell Impagliazzo, Ramamohan Paturi, and Ryan Williams will examine and explain the proof." The entry of 2026-11-23 says the VP ≠ VNP result "was obtained on November 6, 2026". See §6.1.
- **Family 378, "The Exponential Time Hypothesis is False" (2026-10-25).**
  - Claim: #k-SAT in (n+m)^{O_k(1)}·2^{n/(log n)^{1/2+o(1)}}, plus superlinear circuit lower bounds for E^NP.
  - Lean scope [V-primary: lean/docs/378.md]: formalizes only the counting algorithm, at rate 2^{O_k(n (log log n)²/√log n)}. **The E^NP circuit lower bound is not formalized there.**
- **Family 379, "VP and VNP are different" (2026-11-23).** The border-circuit bound is exp(Ω((log n)^{5/4})) over every field. Both labs' VP ≠ VNP manuscripts are dated 2026-11-23. Neither paper I read states whether the work was independent.
- **Family 103:** L = RL = BPL.
- **Family 102:** claims a proof of the Unique Games Conjecture.
- **Family 112:** a language in P that needs 2^{ω(√n)} gates in depth-3 (OR–AND–OR) circuits.
- **Family 108:** a cubic lower bound for permanent vs determinant (border determinantal complexity).
- **Family 107:** a matrix multiplication algorithm with ω ≤ 9/4.
- **Family 136:** a quasilinear PCP for PPAD.
- **Withdrawals** [V-primary: history.md, 2026-10-07]: three Hodge-related manuscripts were withdrawn after a sign error. AI-produced, unformalized claims can therefore be wrong.
- **P vs NP:** grepping CONTENTS.md for "P vs NP", "P ≠ NP" and "P = NP" turns up **no family that claims to resolve it**.

## 4. Unverified P vs NP claims with a Lean veneer (example)

- **Reservoir package `Mintpath/p_ne_np`** (v0.1.0, 2026-07-25). It claims "Machine-verified
  proof (0 sorries, **2 axioms**) that P ≠ NP via exponential circuit lower bounds for
  Hamiltonian Cycle". The registry page does not state the axioms, and the source repository
  returned HTTP 404 when I tried it.
- **Assessment:** this is a Lean proof that uses extra axioms, so it proves nothing until those
  axioms are inspected. I found no sign of expert acceptance. [secondary: registry page]

## 5. How this survey was made, and what it does not cover

**Three passes.**
- **First pass** (first session, morning of 2026-11-24): arXiv, ECCC reports TR26-173 to TR26-339,
  `anthropics/formal-math`, `openai/math`, and web search. It produced sections 0 to 4.
- **Review addendum** (second session, same day): one targeted check found that most follow-up work
  is not on arXiv or ECCC.
- **Sweep** (second session, evening): five reader subagents, one per venue, each told to save full
  texts, quote verbatim with locations, and dump the reference lists of what they read. I then
  opened the passages behind every sentence below that says "proves", "first", "nobody" or the
  like.

**Coverage of the sweep.**

| Venue | What was covered | Evidence |
|---|---|---|
| Hexagon (hexagonmath.org) | All 1,530 works on the server; 20 relevant papers downloaded; one read line by line by the reader, and passages of seven read by me | `/mnt/data/review/sweep/hexagon/` |
| GitHub | All 54 issues and pull requests of `anthropics/formal-math`; `openai/math`; 27 repositories cloned and searched | `/mnt/data/review/sweep/github/` |
| One notes repository (`1337isnot1337/integer-factoring`) | Inventory of 858 notes on crossings; result sections of about 30 read by the reader | `/mnt/data/review/sweep/crossing/` |
| arXiv | 2,469 records from 2026-10-15 to 11-25 (all of cs.CC, cs.DS, cs.LO, plus keyword queries); 17 papers downloaded | `/mnt/data/review/sweep/arxiv/` |
| Zenodo | Keyword searches; four records read | same |
| Palomar registry | All 1,349 registered results | `/mnt/data/review/sweep/palomar_experts/` |
| Lemmata repository (lemmata.iol.berlin) | All 22 entries listed; one read by me | `/mnt/data/review/sweep/verify/lemmata/` |
| Expert commentary | The working group's site, the Computational Complexity blog (all posts of October and November), one news article, the labs' announcements | `/mnt/data/review/sweep/palomar_experts/`, `verify/` |

**Not covered.**
- **ECCC after TR26-265.** The site blocked automated access during the sweep, and only an archived
  index of 2026-10-20 was available. The first session's list (TR26-173 to TR26-339) therefore
  stands as it was, and reports after TR26-339 are unchecked.
- **arXiv categories math.CO and cs.AI** were covered by keyword queries only.
- **Social media** (X, Bluesky, Mathstodon), where some of the experts' remarks were made.
- **The working group's shared document repository,** and the blogs of Tao, Barak, Gowers and
  Wigderson. Several other blogs refused automated fetches.
- **News outlets** other than one TechCrunch article.
- **Most of the 858 crossing notes** in §6.3: only their result sections were read, by a reader.
- **Correctness.** No proof in any follow-up was checked. Third-party Lean code was not built,
  except the one proof named in §6.2.

## 6. Follow-up work on the ETH refutations and on VP ≠ VNP (consolidated 2026-11-24)

### 6.1 Has any human checked the proofs?

**Short answer, for the sources swept (§5).** An organised examination of OpenAI's proof is under
way and has issued no verdict. No named expert has said they checked either ETH proof, or either
VP ≠ VNP proof, in full. None has reported a technical error. Many researchers are already
building on the results.

**The examination of OpenAI's proof.**
- OpenAI's announcement of 2026-10-26 [read]: "This work will be verified and shepherded by a
  group led by Russell Impagliazzo (UC San Diego), Ramamohan Paturi (UC San Diego), and Ryan
  Williams (MIT)." OpenAI also agreed to fund a conference on the implications.
- The group's site, ethdiscussion.blog [read: home page and feed, 2026-11-24]: "Our involvement
  should not be taken as certification of the claim. A result of this significance requires
  careful, independent scrutiny and an understanding that others can reconstruct, question, and
  build upon."
  - It has five posts, from 2026-10-26 to 2026-11-12. None reports a conclusion.
  - It proposes a virtual meeting before the end of 2026 and keeps a shared repository of
    follow-up documents, which I did not read.
  - A post of 2026-10-30 by Francis Zane [read] notes that several people have compiled the Lean
    proofs locally, and adds: "someone besides the original author should probably check the
    proof".

**What named people have said.**
- Lance Fortnow, 2026-10-28 [read]: "I have not verified the proof myself, but it is safe to
  assume now that the exponential-time hypothesis is toast."
- Bill Gasarch, 2026-11-01 [read]: "All of these results are being looked at by experts."
- Ryan Williams, quoted by TechCrunch on 2026-10-27 [read]: "there are two or three alien-looking
  parts, and it's exactly these parts that I saw that made me think, wow, this is something that
  the whole community needs to work on together".
- Stefan Szeider, Zenodo note of 2026-10-27 [read]: "This note does not judge the correctness of
  the proof." It does check OpenAI's Lean statement: "a correct statement of the intended result,
  for a weaker but still subexponential bound". His note of 2026-11-16 [read] says of the two
  proofs: "They are widely accepted, but not yet published in refereed form."
- Sebastian Ben Daniel, arXiv:2611.01884v2, 2026-11-23 [read], on Anthropic's paper: "The preprint
  is not refereed, and as far as we know no person has checked its proofs."
  - He reports having checked the printed argument of its Appendix B for the one bound he uses,
    and the identity of its Theorem B by computation for h ≤ 7.
  - He notes that in Anthropic's Lean development "the time clause of Definition 7 is formalized
    only in a weak form". That bears on the hypothesis of `piecesTransfer` in this repository.
- Scott Kominers, hexagon:2610.00574, 2026-10-27, a reading of OpenAI's proof [read: provenance
  statement]: "I have read and understood each component individually, but I am still far from
  having fully 'grokked' the argument as a whole."
- Ryan O'Donnell posted an exposition of OpenAI's proof (hexagon:2610.00572). Its page says it is
  primarily AI-generated, with "Human understanding: no parts" [read: provenance statement].
- Others have posted expositions or comments without claiming to have checked the proofs:
  Kintali, Sellke, Nederlof, Lindzey, Lovett [agent].
- **A partial check of one step.** Vassilevska Williams and Zamir, arXiv:2611.09764 (2026-11-06),
  re-prove one lemma "distilled … out of the recent ETH refutation of OpenAI" with a
  self-contained proof [agent].
- **An unconfirmed report** [lead]: a search summary says Jelani Nelson read Claude's proof before
  its release. I could not confirm it.
- **One reported gap, not assessed.** A commenter on the working group's site (A. Arefiev,
  2026-10-30) writes that "the Lean 4 formalization didn't even check the actual Word RAM
  complexity claimed in the paper" [agent]. This concerns what the formalization covers, not a
  step of the proof.

**Formal re-checks by third parties.** These confirm that Lean accepts the proofs and, in two
cases, what the Lean statements say. They are not human checks of the mathematics.
- Several independent rebuilds, including this repository's, with an independent kernel
  (`REVIEW.md` §2.1). Carlos Toledo reports replaying both labs' proofs with Comparator and
  nanoda, and bridging both statements to a textbook form of ETH in Lean [agent].
- A third-party audit of `eth` (formal-math issue #50) reports only the standard axioms [agent].
- Of the 54 issues and pull requests on `anthropics/formal-math`, none makes a technical claim of
  an error in `eth` or `vp-vnp`. One (#52) asserts, without a mathematical argument, that `vp-vnp`
  cannot work. No maintainer has replied to any of them [agent].
- `openai/math` has no issue about the ETH or VP ≠ VNP families, and its changelog records no
  withdrawal since 2026-10-07 [agent].

### 6.2 What has been machine-checked, and by whom

| Who | What | Where and when | Evidence |
|---|---|---|---|
| V. Tulsyan | E^NP ⊄ SIZE(ε·n·√log n) at infinitely many lengths, on Anthropic's development | `xennygrimmato/eth-hamiltonicity`, `lean-bridge-anthropic/bridge/EthFollowup/Circuits/`, one commit of 2026-11-04 | [read], and built here: `experiments/enp-superlinear/prior-check/` |
| This repository | The same statement, proved independently on 2026-11-24 | `experiments/enp-superlinear/` | `REVIEW.md` §2.1 |
| This repository | Three transfer theorems: from any 3-SAT machine with a clause rate, from any counting machine with a clause rate, and from any family of pieces | same | `REVIEW.md` §6.1 |
| V. Tulsyan | Rank bounds for barriers, including the rank form of ρ ≥ 1/2 for pieces; 45 theorems cited | hexagon:2611.00149, 2026-11-06 | [read: abstract, Theorem 4.1 remark, limitations] |
| S. Szeider | Arithmetic circuits of size 2^{o(n)} for weighted model counts of 3-CNFs; IPS refutations of size 2^{o(n)}; on Anthropic's development | Zenodo 10.5281/zenodo.24243987, v2 of 2026-11-16 | [read: abstract and introduction] |
| I. Rudich, L.-M. Rousseau | Deterministic factoring in time N^{o(1)}, re-proving Anthropic's counting engine | hexagon:2610.00600; PALOMAR-2026-10-28-000015 | [agent]; "the authors audited the statement, not the proof" |
| `1337isnot1337` | Factoring with "saving exponent 1/2" | `1337isnot1337/integer-factoring`, README | [read: README status table] |
| K. Khoruzhii | A crossing decomposition from a fermionic model; circuits of size O(n^{5/3}) for symmetric noncommutative quartics; (Σa_i²)(Σb_j²) as n^{√2+o(1)} squares of complex bilinear forms | Lemmata 2611.00001, first version 2026-11-02, last revised 11-04; six results kernel-checked in Lean v4.35.0 | [read: the entry] |
| A. Singh | Linear lower bounds for Naslund's crossing number, such as P(n) ≥ 4n/3 | PALOMAR-2026-11-16-000011 | [agent] |
| TSavo; C. Toledo | Bridges between the two labs' statements of ETH and a textbook form; a port of `eth` to Lean v4.36.0-rc2 (48 of 812 files changed) | formal-math issue #36 | [agent] |

**Is anyone else's transfer theorem already out there?** I found none.
- Tulsyan's own note says of his module: it "is **not** parametric in the SAT time" [read:
  `research/circuit-lower-bounds.md`]. His five Lean files fix the rate at 1/√log [read].
- A reader searched the Lean sources of 27 cloned repositories for an E^NP circuit bound with a
  general rate, a general machine hypothesis, or a pieces hypothesis. Outside upstream's own files
  the only hits were Tulsyan's five files [agent]. The search keys on upstream's names (`InENP`,
  `DecidedAt`, `HasCircuits`); a formalization built on different definitions would be missed.
- Nothing of the kind is registered on Palomar (1,349 results), posted on Hexagon (1,530 works) or
  on Lemmata (22 entries) [agent; Lemmata list read by me].
- `anthropics/formal-math` has 130 forks. 29 have commits of their own, and none of those adds a
  Lean file on circuit lower bounds, judging by file paths [read: fork list and file trees].
- **Limits of this search.** GitHub's code search needs an account and was not used. Five
  repositories that turned up were not cloned. Fork contents were compared by path, not read.
- Rate-parametric transfers exist **on paper**: a "fixed-point law" in `MJIFmc/eth-2026-notes`
  (H. Chen, 2026-11-08), a note in `jhune-yim/ETH`, and a remark in Tulsyan's circuit note [agent].

**Palomar.** Nothing from `anthropics/formal-math`, `openai/math` or Tulsyan's repository is
registered, and no circuit lower bound for E^NP or statement about ETH is [agent]. A submission
needs Lean v4.35.0-rc2 or later, Lean's module system in every file, and files of at most 10,000
lines [agent]. Its policy also says: "No other project-specific source may occur in the
Challenge's transitive import closure" beyond Lean core, Mathlib, Tau Ceti and CSLib [read]. That
rule matters here: this repository's statements import upstream's statement files, so a submission
would need a Challenge file with every definition written out in it.

### 6.3 Can the rate be improved? The question of the pieces

**The question.** Anthropic's algorithm runs in time 2^{O(k·m/(log m)^{α'})} with α' = log₂(1/ρ),
where ρ measures the cost of the "pieces" that decompose a crossing. Its Appendix B has ρ = 1/√2,
so α' = 1/2. A simple pigeonhole argument gives ρ ≥ 1/2. Anything in between would speed up the
algorithm.

**State on 2026-11-24.** In the sources swept, nobody has posted pieces with ρ < 1/√2, an
improved rate by any other route, or an unconditional lower bound on ρ above 1/2. All five readers
looked for these and found none.

**Lower bounds and barriers.**
- **ρ ≥ 1/2.** Anthropic's Appendix H; Majdoddin's Propositions 4.6 and 4.8. Tulsyan's Theorem 4.1
  checks the rank form in Lean [read].
- **Grid algorithms.** Majdoddin, arXiv:2610.41622 (still v1): α' ≤ 1 for all grid recursions in
  his model, and no gain below about 2^{6000} variables for them. See `lit/RHO_SPEC.md` §4.
- **Graded families shaped like Appendix B.**
  - C. S. Naves de Brito, hexagon:2610.00692, 2026-10-31 [read: full]. The weight count is at
    least max(2^{α−1}, 2^{−α}) ≥ 1/√2 for regularly varying growth. It names two escapes and says
    that pieces of rank far below the counted dimensions are "not covered".
  - M. Fradj, hexagon:2611.00627, 2026-11-19 [read: abstract and scope remarks]. For graded
    spaces of "Kleinian codes", a prescribed-window cost of at least 1/√2 + η. The paper says
    this concerns "window dimensions, not intrinsic matrix ranks".
  - This repository's `lit/RHO_SPEC.md` and `lit/STAGE2_GRADED.md` overlap both.
- **Decompositions whose terms are not products.** Tulsyan's Proposition 4.12, on paper [read]:
  ρ ≥ 3/8 for decompositions of a full grid level into row and column networks. His
  Conjecture 4.15 would give ρ ≥ 1/2 for all of them.
- **A link to OpenAI's VP ≠ VNP proof, which is not a barrier.** Y. Liu, hexagon:2611.00994,
  2026-11-24 [read: its §2 and the passage "Two crossing cuts"].
  - A "strict shortening" of the crossing is a way to write it as a sum of tensor networks in a
    disk that are cheaper, in a geometric cost model, than the two straight cables.
  - The paper states: if no planar crossing admits a strict shortening, then writing the crossing
    as two tensors, one of low rank across each cut, needs rank at least q^{√2−o(1)}.
  - By the paper's own argument, a two-cut decomposition of lower rank would itself be a strict
    shortening. So the hypothesis already assumes that nothing of that kind exists. The statement
    is not evidence that 1/√2 is optimal.
  - What it gives is a connection: beating √2 in the two-cut sense would put the crossing in the
    "a shortening exists" case of the case distinction on which OpenAI's VP ≠ VNP manuscript
    turns.
  - Reading a two-cut rank bound as a bound on ρ for Definition-7 families is my inference, not
    the paper's.
  - The page says the text is primarily AI-generated, with "Human understanding: no parts".
    Nobody has reviewed it.

**Work in progress by others, by their own account.** Neither body of notes has been refereed, and
I did not check either.
- **V. Tulsyan's repository** [read: `research/engine3-STATUS.md`, in full]. It reports that every
  level with two merges has ρ ≥ 1/2 whatever the pieces; that three or more merges are "the only
  door left" for α' > 1; exact negative searches at small block sizes; and that the attack was
  paused on 2026-11-06. A file of 2026-11-24 lists "eight routes" to a faster 3-SAT as ideas only
  [read: headings].
- **`1337isnot1337/integer-factoring`** [agent digest; README and one note read by me]. About 860
  notes, nearly all from 2026-10-29 to 11-03; only housekeeping after 11-14.
  - Its README at the last commit (2026-11-22) lists "Saving exponent above 1/2" as "Not
    established" [read].
  - It works with pieces over a fixed finite field, for factoring. Nowhere does it map them back to
    Anthropic's integer Definition 7 or to 3-SAT [agent].
  - It reports lower floors for particular certificates, not for actual ranks. One note says its
    basic criterion "cannot give a half-rate improvement" on any alphabet of at most 12 letters,
    and that 13 letters "remains open" [read].
  - It reports no construction below 1/√2. The best it certifies is ρ < 18/25 [agent].
  - A "formal profile" below 0.707 that its checkpoint of 2026-11-01 mentions is excluded by its
    own later notes; the checkpoint was not updated [agent].
  - It contains the reformulation for pieces built from Pauli strings (the two costs are the
    support sizes of a function and of its Walsh transform), dated 2026-10-30 [read].

**The upper-bound side.**
- Khoruzhii's entry [read] gives a second derivation of the sum-of-squares exponent √2, from a
  finite fermionic model with two colours, and has it kernel-checked. It does not state a value
  of ρ. Majdoddin's paper had argued that a fermionic Fock space gives no such pieces; the two are
  not the same construction.

**The sum-of-squares connection.** Anthropic's Appendix G relates pieces to the least number P(N)
of row- or column-rank-one terms summing to the crossing, and quotes Hrubeš's bound of about
N^{1.62}.
- Appendix B implies P(N) ≤ N^{√2+o(1)}. Khoruzhii's entry states the corresponding
  sum-of-squares bound and had it kernel-checked by 2026-11-04 [read].
- J. Siemaszko posted the same observation on 2026-11-07 (formal-math issue #45; Zenodo
  10.5281/zenodo.24024689), saying he "has not verified the mathematical argument"; an independent
  re-derivation was posted on 2026-11-23 [read: issue; agent: note].
- On the lower side only linear bounds are known (A. Singh, above). A bound of N^{1+ε} would give
  ρ ≥ (1+ε)/2.

**This repository's own contributions to the question** are a rank computation for the Appendix B
pieces (`lit/SQRTLOG_BARRIER.md`) and a small search over the simplest Pauli-type identities
(`REVIEW.md` §8). Both are negative.

### 6.4 Limits, constants and practicality

- **Dias and Lima, arXiv:2611.00517** [V-primary: abstract]. OpenAI's interpolation scheme costs
  2^{Ω(√tw)}; the tensor route "escapes these limits". If the hidden constant is C = 2, the
  algorithm beats 2^n only for n of about 10^{32} or more.
- **Szeider, Zenodo 10.5281/zenodo.23688832** [read]. OpenAI's algorithms are exhaustive search
  on every input with fewer than 2^{131071} variables and clauses. Its addendum on Anthropic's
  algorithm says that evaluating the paper's recurrence numerically "raises these necessary sizes
  to 2^275616 clauses and 2^(1.7·10^10) variables".
- **Majdoddin, arXiv:2610.41622** [V-primary]. Lowers Anthropic's crossover to about 2^{420}
  clauses at density 1.
- **Fortnow, 2026-11-04** [read], on practical SAT solving: "Spoiler alert: It will never beat
  CDCL."

### 6.5 Consequences others have drawn, assuming the refutations hold

- **Circuit lower bounds for E^NP.**
  - OpenAI's Corollary 1.4 (paper only), then the two Lean proofs of §6.2.
  - Wu and Wang, arXiv:2611.02560 [read: Theorems 1 and 2]. More than c·m·√log m / log log m gates
    over unbounded AND/OR with binary XOR; and c·m·√log m gates over a binary basis with a linear
    budget of XOR and symmetric gates. Both at infinitely many lengths, on paper.
- **Simulations.**
  - Strassle and Subercaseaux, arXiv:2611.11832 [read: Theorem 1]:
    NTIME[t] ⊆ DTIME[2^{O(t/√log t)}]. It rests on OpenAI's Theorem D.1 [agent].
  - Ben Daniel, arXiv:2611.01884 [read: title and status paragraph]: time t in deterministic space
    t/√log t, using Anthropic's pieces.
- **What replaces ETH.** MIT Hardness Group, arXiv:2611.02650, "ETH is Dead, Long Live SH" [read:
  Theorem 2.4]: the Satisfiability Hypothesis is equivalent to a weak form of ETH.
- **Other hypotheses refuted since** [read: abstracts, which do not say whether the ETH
  algorithms' ideas are used]: the Hyperclique Hypothesis (Fischer, arXiv:2611.03880; Alman, Li,
  Pant, Pratt and Williams, arXiv:2611.05082; Chan, Itakura, Ma and Yu, arXiv:2611.06813) and the
  k-Clique conjecture (Vassilevska Williams and Zamir, arXiv:2611.09764).
- **Applications** [agent; abstracts only]: counting problems (Tulsyan's five Hexagon notes; Kozma,
  arXiv:2610.41048; Wu and Wang, arXiv:2611.02548), factoring (Rudich and Rousseau; Shunia,
  hexagon:2610.00711), fixed-parameter results, and learning theory (X. Li, three Hexagon notes).
- **Two items the first pass listed as follow-ups are not.** Gaspers, arXiv:2611.01774, only
  mentions the ETH preprints in passing. Chukhin, arXiv:2611.06231, concerns constant-depth
  circuits, and says the Orthogonal Vectors conjecture "remains open" [agent].

### 6.6 VP ≠ VNP: reactions and follow-ups

- Fortnow's post of 2026-11-24 is quoted in §0. Gil Kalai wrote the same day that Claude "and a
  few hours later ChatGPT" proved it [agent]. Neither says they checked it.
- Y. Liu, hexagon:2611.00994 [read: abstract and Theorem 1.1], uses OpenAI's VP ≠ VNP manuscript
  for lower bounds on the noncommutative permanent and determinant. It is the paper with the
  conditional claim of §6.3.
- No arXiv paper addresses either VP ≠ VNP manuscript yet [agent].

### 6.7 State of the repositories on 2026-11-24

- `anthropics/formal-math`: no commit after 11b6c7e; `eth` was last changed on 2026-10-27 [agent].
- `openai/math`: the Lean scope of family 378 is unchanged [agent].
- `xennygrimmato/eth-hamiltonicity`: 280 commits, the latest on 2026-11-24; the circuit files are
  unchanged since 2026-11-04 [agent].
- `1337isnot1337/integer-factoring`: last commit 2026-11-22 [read].
