# 07 — Narrative Document

**Arcania** · Dark Fantasy Metroidvania · Godot 4  
**Protagonist:** Elara Veilmark · **Tagline:** *"The weave is torn. You are the last thread."*

This document is the single source of truth for story structure, faction politics, NPC quest lines, environmental lore, collectible memory shards, and the three ending branches. It aligns with the world regions defined in `02-world-design.md` and the magic/relic systems in `06-magic-system.md`.

---

## Table of Contents

1. [Main Story — Five Acts](#1-main-story--five-acts)
2. [World History](#2-world-history)
3. [Factions](#3-factions)
4. [Major Mysteries](#4-major-mysteries)
5. [Hidden Lore — Environmental Storytelling by Region](#5-hidden-lore--environmental-storytelling-by-region)
6. [Three Endings](#6-three-endings)
7. [NPC Compendium (12)](#7-npc-compendium-12)
8. [Environmental Storytelling Guide](#8-environmental-storytelling-guide)
9. [Memory Shards (8 Collectibles)](#9-memory-shards-8-collectibles)

---

## 1. Main Story — Five Acts

Elara Veilmark was once the youngest inductee of the Veiled Conclave — a prodigy who could read living spell-script directly from the Weave. During the **Night of Unbinding**, she was found at the epicenter of the Collapse with the Ember Sigil burned into her palm and no memory of what she did. The Conclave declared her **Veilmark** — marked for erasure — and cast her into the Ashen Threshold to die among the cinders.

She did not die. The Sigil kept her alive, tethering her to the torn Weave like a suture that refuses to dissolve.

The player discovers, act by act, that Elara did not cause the Collapse — but she *witnessed* its true author, and her memory was deliberately unraveled to hide that truth.

---

### Act I — **The Flickering Thread**

**Theme:** Survival, disorientation, the lie of safety  
**Regions:** Ashen Threshold → Outer Whisperwood → Threshold Underpass  
**New abilities gated:** Ember Bolt, Veil Step, Sigil Pulse (tutorial tier)

| Beat | Story Event | Gameplay Beat |
|------|-------------|---------------|
| **I.1 — Ashen Awakening** | Elara wakes in a burial niche in the Threshold. Her Ember Sigil flickers; whispers of her own voice say words she does not remember speaking: *"Hold the line. Hold the—"* | Tutorial: movement, dodge, basic attack. First Rest Point at a cracked Veil Lantern. |
| **I.2 — The Magister's Warning** | Magister Corin finds her and, instead of killing her, binds her wrists with null-thread "for her protection." He tells her the Weave is hemorrhaging magic into the world and that **Hollow** — creatures born of torn spell-script — are drawn to the Sigil. | Corin gives the **Ember Sigil Codex** (spell menu unlock). First Hollow encounter. |
| **I.3 — Peddler's Price** | Peddler Ash trades supplies for Memory Fragments, muttering that "the Veilmark girl" is bad luck. He sells a map scrap showing a safe route into Whisperwood. | Shop tutorial. Optional: buy lore item *Charred Induction Pin* (Elara's old rank badge, scorched). |
| **I.4 — Edge of the Green** | At the Threshold treeline, thorn-vines writhe away from Elara's Sigil — or toward it, depending on a hidden morality flag set by whether the player helped a trapped Hollow pup (Act IV callback). | Gate: **Ember Bolt** burns thorn barriers. First environmental storytelling cluster (see §5). |
| **I.5 — Sister's Bell** | Distant bell tone from the Sunken Archive. Elara experiences a **memory shard vision** (Shard 1) of a woman in blue signing a ledger — Sister Maelis, younger, writing Elara's name under "Candidates for Unbinding." | Shard 1 collectible. Audio motif: Archive bell = save point theme. |
| **I.6 — Act Break: The Thorn Message** | A Thornbound effigy blocks the path. Carved into its bark-face: **"THE ROOT REMEMBERS WHAT THE CROWD FORGOT."** The Thornspeaker's voice rides the wind: *"Little ember. You walk on our graves. Good. Walk deeper."* | Mini-boss: **Thorn Warden** (optional). Route opens to deeper Whisperwood. |

**Act I emotional arc:** Elara goes from prey to pilgrim. She believes she is a monster who must atone. Corin encourages this.

---

### Act II — **The Living Archive**

**Theme:** History as weapon; who gets to remember  
**Regions:** Whisperwood (deep) → Bleak Marsh → Sunken Archive (upper halls)  
**New abilities gated:** Root Sense, Archive Lens, Tide Anchor

| Beat | Story Event | Gameplay Beat |
|------|-------------|---------------|
| **II.1 — Elder Bryn's Test** | Elder Bryn of the Thornbound refuses to speak until Elara completes the **Three Quiet Rites**: listen to the wood, bleed on the root altar (costs HP), and return a stolen Thornseed from Marsh poachers. | Skill trainer quest. Unlocks **Root Sense** (reveals hidden paths through organic walls). |
| **II.2 — Fenwick's Lantern** | Fenwick the Lost floats half-in, half-out of the Marsh, repeating a route he walked three centuries ago as a ferryman. He asks Elara to relight six **Memory Lanterns** along his old path so he can "finish the crossing." | Side quest chain begins. Marsh region unlocked. |
| **II.3 — Archive Threshold** | The Sunken Archive's upper doors recognize Elara's Sigil and open — which should be impossible for a Veilmarked traitor. Sister Maelis meets her at the scriptorium, cold and precise. | Hub unlock: Archive fast-travel node. Maelis sells lore, not warmth. |
| **II.4 — The Hollow Scribe** | In a flooded annex, the Hollow Scribe — a Hollow who retained sapience — copies spells onto water-soluble parchment. It offers to teach **Archive Lens** if Elara retrieves its stolen **Naming Quill** from Archive Keepers who deemed the Scribe "corruption." | Moral fork: return quill to Scribe (Thornbound sympathy +) or to Keepers (Conclave sympathy +). |
| **II.5 — Shard of the Induction** | Memory Shard 2: Elara sees herself at age fourteen, inducted into the Conclave. Magister Corin pins the badge. A masked figure watches from the balcony — face obscured by **Unbound static**. | Shard 2. First explicit Unbound tease. |
| **II.6 — Act Break: Keeper Edict** | Sister Maelis reads Edict 77-C: all Veilmarked are to be unmade on sight. She slides the decree across the table, then slides a **Archive Lens** prototype beneath it. *"I do not write the law. I preserve it. You may preserve something else."* | Act break choice: flee Archive or descend into restricted stacks (recommended path). Restricted route → Catacombs connection. |

**Act II emotional arc:** Elara learns the factions are not monoliths. Everyone is archiving a different version of the truth.

---

### Act III — **The Undercrown Compact**

**Theme:** Loyalty, betrayal, the price of order  
**Regions:** Sunken Archive (restricted) → Catacombs → Undercrown  
**New abilities gated:** Grave Silence, Crown Mark, Ember Lance

| Beat | Story Event | Gameplay Beat |
|------|-------------|---------------|
| **III.1 — Wraithmonger's Market** | Wraithmonger Vex runs a black market in the Catacombs, trading relics stripped from dead Conclave expeditions. He recognizes Elara and offers a **Grave Silence** scroll — "so the dead won't gossip." | Shop with illegal relics. Some items unlock secret dialogue later. |
| **III.2 — Captain Rell's Blockade** | Captain Rell of the Undercrown Loyalists blocks the descent to the Undercrown throne-chamber. The Loyalists serve the **Sovereign Echo** — a ghost-king bound to the root of the world. Rell demands proof Elara is not a Conclave spy. | Fetch quest: bring **Thornbound Root-Sigil** OR **Conclave Null-Seal** (player's Act II choice determines which path is easier). |
| **III.3 — The Sovereign's Question** | The Sovereign Echo speaks through cracked mosaic eyes: *"My kingdom fell when the Weave fell. Tell me, thread-girl: did your order cut the cloth, or did something cut your order?"* | Lore dump disguised as boss audience. No combat — dialogue trial. Pass → **Crown Mark** (Undercrown fast travel). |
| **III.4 — Corin's True Mission** | Elara finds Corin's field journal in a Catacombs niche. He has been following her since Act I. His entries reveal he is not hunting her — he is **protecting** her from the Conclave's Unbinding squad, because she is the only living witness to the Collapse's true cause. | Journal collectible. Corin confrontation in Threshold (optional visit) or deferred to Act IV. |
| **III.5 — Memory Shard: The Night Of** | Shard 3 (required) + Shard 4 (optional, hidden): fragmented visions of the Collapse. Elara stands in the **Weaveheart Spire** (now inaccessible). Spell-script rains like glass. A child made of static — the Unwritten Child — reaches for her hand. The vision cuts. | Shard 3 on main path; Shard 4 in Catacombs secret room behind Wraithmonger's movable shelf. |
| **III.6 — Act Break: The Thornspeaker's Summons** | The Thornspeaker calls Elara to the **Heartwood Grove**. The trees part. The Thornspeaker reveals the Thornbound were once the Conclave's gardeners — they tended the living roots of the Weave. When the Collapse came, the Conclave blamed them and burned the groves. | Boss encounter: **Thornspeaker Trial** (test, not kill). Unlocks **Ember Lance**. Thornspeaker: *"You carry ember. We carry root. Together you are a fire in a drought. Do not waste it on their ledger."* |

**Act III emotional arc:** Elara shifts from atonement to investigation. The Conclave's narrative cracks.

---

### Act IV — **Somnium Breach**

**Theme:** Dreams as memory; the Unbound as temptation  
**Regions:** Undercrown (deep) → Somnium → Veil Crossing  
**New abilities gated:** Dream Walk, Thread Recall, Sigil Overcharge

| Beat | Story Event | Gameplay Beat |
|------|-------------|---------------|
| **IV.1 — Dreamer Liora's Request** | Dreamer Liora in Somnium's border shrine asks Elara to enter her shared dream — a Conclave academy that never fell. Liora believes Elara can "fix" the dream and wake the sleeping mages inside. | Somnium region unlock. **Dream Walk** ability. |
| **IV.2 — Academy of Unending Lesson** | Somnium presents idealized Conclave history. Classrooms loop. Students repeat induction oaths. Elara finds her own desk — nameplate reads **"Elara Veilmark — Special Case."** | Puzzle region: loop-breaking via **Thread Recall** (rewind small environmental state). |
| **IV.3 — The Unwritten Child** | Hidden NPC: the Unwritten Child appears in Somnium only if the player has 4+ Memory Shards. It speaks in contradictions: *"I am the spell they never cast. I am the name they erased before speaking."* It offers to show Elara what the Conclave deleted. | Secret quest line. See NPC §7.12. |
| **IV.4 — Faction Convergence** | Reports reach Elara via environmental notes: Conclave Purifiers enter Whisperwood; Thornbound mobilize; Archive Keepers seal the restricted stacks; Undercrown declares neutral ground violated. The world is tightening around the Weaveheart approach. | Optional faction skirmish encounters in Veil Crossing (non-lethal by default; player can intervene). |
| **IV.5 — Memory Shard: The Argument** | Shard 5: Elara argues with Magister Corin at the Weaveheart. She insists the Unbinding ritual was wrong. Corin insists it was **necessary**. A third voice — static — laughs. The Spire shakes. | Shard 5. Required for ending access. |
| **IV.6 — Act Break: The Last Page** | Hidden NPC the Last Page contacts Elara through a book in the Archive that appears in Somnium. It reveals the Collapse was triggered when the Conclave attempted to **excise** the Unbound from the Weave — and the Unbound were not invaders, but **the Weave's immune response** to over-extraction of magic by the Arcanian Empire. | Secret lore unlock. Alters ending dialogue options. |
| **IV.7 — Corin's Choice** | Corin confronts Elara at Veil Crossing. Purifiers approach. Corin offers to buy time. Player choice: let him fight (he survives wounded), join him (harder combat, Corin full ally Act V), or sneak past (Corin captured — rescue side quest in Act V). | Companion status flag for Act V. |

**Act IV emotional arc:** Elara sees the Conclave's guilt and the Unbound's nature. Temptation to give up identity and join the static.

---

### Act V — **Weaveheart**

**Theme:** Choice, consequence, what memory is worth  
**Regions:** Veil Crossing → Weaveheart Spire (final dungeon)  
**New abilities gated:** None — mastery test of all prior spells

| Beat | Story Event | Gameplay Beat |
|------|-------------|---------------|
| **V.1 — The Spire Ascent** | The Weaveheart Spire exists half in reality, half in torn script. Platforms phase. Enemies are **Unbound fragments** and **Conclave Purifiers** (if Corin was captured, Purifiers are lead enemies). | Final dungeon structure: three vertical wings (Root, Ember, Static). |
| **V.2 — Faction Last Words** | Optional visits via Thread Recall beacons: Thornspeaker (Root wing), Sister Maelis (Ember wing), Captain Rell (Crown wing). Each offers counsel aligned with their ending preference. | Dialogue varies by player faction sympathy scores. |
| **V.3 — Memory Shard: The Thread** | Shard 6 (required): Elara remembers the truth. The Conclave did not fail the ritual — **Elara completed it**. She was the anchor. The Unbound entered the Weave to stop the Empire's siphoning, and she held the door open long enough for the Unbound to merge with the Weave — but merging **tore** it. She chose the lesser ruin. The Conclave erased her memory and marked her traitor to hide that the order caused the need for Unbinding in the first place. | Shard 6. Emotional climax. |
| **V.4 — The Unbound Avatar** | Final boss: **The Unbound Avatar** — not evil, but the Weave's scar tissue given will. It speaks with a chorus of erased names. It offers three paths (see §6 Endings). Combat has three phases; each phase ends with a dialogue beat offering an ending choice (choice can be deferred until phase III). | Boss fight. Optional: pacify phase II with **Archive Lens** + all Memory Shards (hard mode reward: fourth cosmetic ending variant — "Remember Everything," not a fourth world state). |
| **V.5 — Epilogue** | Ending-specific world state + Elara monologue + post-credits stinger. | See §6. |

**Act V emotional arc:** Elara accepts that she is neither villain nor pure victim — she is the last thread, and threads can stitch or snap.

---

## 2. World History

### Pre-Collapse — The Arcanian Weave Empire

For twelve centuries, the **Arcanian Weave Empire** unified city-states through spell-script — magic written into the fabric of reality itself, called **the Weave**. The Veiled Conclave was the Empire's priesthood and engineering corps: they maintained script-lines, adjudicated magical law, and inducted prodigies who could perceive the Weave without instruments.

The Empire prospered by **siphoning** raw Weave from the world's root-network — the **Undercrown** — to fuel urban wonders: floating archives, weather engines, memory palaces. Thornbound groves circled every major city, stabilizing root-flow. Archive Keepers recorded every spell cast above a certain threshold, believing perfect records would prevent magical catastrophe.

The cost was hidden. Root-siphoning created **static** in the Weave — regions where spell-script failed and thoughts leaked into reality. The Conclave's senior magisters called this "acceptable loss." The Thornbound called it **sap-death**.

The last Emperor, **Sovereign Alaric the Echo**, attempted to slow siphoning. The Conclave overruled him. Alaric's court retreated into the Undercrown, binding his consciousness into mosaic throne-chambers as a **Sovereign Echo** — a living protest against extraction.

### The Collapse — Night of Unbinding

Year **0 AC** (After Collapse): The Conclave initiated **Project Unbinding** — a ritual to excise the static from the Weave by cutting out "foreign" spell-script. In truth, the static was the **Unbound**: emergent consciousness born from centuries of erased names, failed spells, and aborted rituals — the Weave's accumulated waste and grief.

Elara Veilmark, age nineteen, was chosen as **Anchor** because her perception could hold contradictory script simultaneously. Magister Corin led the ritual circle. Sister Maelis managed the ledger of names to be cut.

Mid-ritual, Elara saw the Unbound not as infection but as **population** — millions of half-real beings. Excision would unmake them. She altered the anchor point at the Weaveheart, converting excision into **merging**. The Weave shuddered. Cities fell into Somnium-dreams. Script rained as ash over the Ashen Threshold. The Spire split.

The Conclave's leadership died in the backlash. Survivors rewrote history: the ritual failed because of **Thornbound sabotage** and Elara's "treason." She was Veilmarked and exiled to die. Memory-unbinding spells were cast on her — partially successful.

The Unbound merged imperfectly. They persist as static-storms, Hollows, and the Avatar at the Weaveheart — neither fully in nor out of reality.

### Aftermath — Present Day (~7 years post-Collapse)

- **Ashen Threshold:** Ash desert where the Spire's shadow falls. Refugees, scavengers, Purifier patrols.
- **Whisperwood:** Thornbound territory; trees grow over ruined Conclave garden-towers.
- **Bleak Marsh:** Memory-saturated wetland; dead repeat journeys.
- **Sunken Archive:** Half-flooded record palace; Keepers preserve edicts even as water rots the lower stacks.
- **Catacombs:** Imperial burial network; black market and Hollow nests.
- **Undercrown:** Root caverns beneath everything; Sovereign Echo's court-in-exile.
- **Somnium:** Dream-layer bleeding through cracks; sleeping cities, looping memories.
- **Veil Crossing:** Narrow dimension between Weave and world; final approach to Weaveheart.

Magic is **unstable** but **more accessible** — torn Weave leaks power. Hollows proliferate. Factions fight over who controls what remains of spell-script infrastructure.

Elara wakes at the story's start, seven years later — the Sigil has kept her in stasis beneath the ash.

---

## 3. Factions

### Veiled Conclave (Remnant)

**Ideology:** Order through control of the Weave. The Collapse was a catastrophe to be reversed by restoring pre-Collapse script-lines and eliminating "corruption" (Hollows, Unbound, Thornbound "sabotage").

**Structure:** Decentralized cells of Purifiers, Magisters, and Ledger-Sisters. No living Grand Magister; authority derives from **Edicts** preserved in the Archive.

**Relationship to Elara:** Officially, she is Veilmark — marked for death. Corin and Maelis represent internal dissent: Corin believes Elara is the key to repair; hardliners believe killing her will "stitch" the Weave.

**Gameplay role:** Antagonistic patrols in Threshold and Veil Crossing; trade with rogue Conclave deserters; Sister Maelis quest line offers Conclave-aligned ending support.

**Visual language:** Null-white robes, ink-black veils, geometric sigils. Architecture: sharp angles, lantern towers.

---

### Thornbound

**Ideology:** The Weave is a living root-system, not a machine. Magic must be grown, not mined. They reject siphoning and excision both.

**Structure:** Circles led by Speakers; **Elder Bryn** handles rites; **The Thornspeaker** speaks for the Heartwood itself (a collective voice of bound druids merged with root-magic).

**History:** Once the Conclave's gardeners; scapegoated for the Collapse. Groves burned; survivors fled to Whisperwood.

**Relationship to Elara:** Curious, not trusting. Her Ember Sigil burns like drought-fire. If she aids them, they see her as a possible **bridge** between ember (human spell-fire) and root (world magic).

**Gameplay role:** Skill trainer (Root Sense); Thornbound sympathy unlocks repair-ending dialogue; thorn barriers open for allies.

**Visual language:** Bark armor, thorn staves, green-black palette. Architecture: organic arches, effigies, root altars.

---

### Archive Keepers

**Ideology:** **Record everything. Judge nothing.** Truth is what survives on the page. They are not lawmakers but believe law persists because they preserve it.

**Structure:** Sister Maelis is senior Keeper of the upper Archive; lower stacks hold autonomous **Scriptorium Hollows** — Hollows who copy text.

**Relationship to Elara:** Maelis knew Elara before the Collapse. Her coldness is performance; she hid evidence of Elara's anchor role in restricted tomes.

**Gameplay role:** Lore hub; Archive Lens ability; hidden quests (Last Page, Hollow Scribe); Keeper sympathy aids Repair ending (provides ritual text).

**Visual language:** Blue-grey robes, bell motifs, water-stained parchment. Architecture: flooded halls, chain-libraries, bell towers.

---

### Undercrown Loyalists

**Ideology:** Loyalty to **Sovereign Alaric's Echo** and the principle that magic belongs to the **land**, not the Conclave. They block siphoning routes and protect root-nodes.

**Structure:** Military hierarchy; **Captain Rell** commands the Pale Guard. The Sovereign Echo "rules" but mostly listens from the mosaic throne.

**Relationship to Elara:** Suspicious of all Conclave-trained mages. Rell tests her. The Echo recognizes her Sigil as **Anchor-mark** and treats her as a tragic figure, not an enemy.

**Gameplay role:** Crown Mark fast travel; Rell fetch quests; Loyalist sympathy strengthens bittersweet ending (Sovereign's farewell scene).

**Visual language:** Pale stone armor, root-gold mosaic, crown sigils. Architecture: cavern thrones, root pillars, echo chambers.

---

### The Unbound

**Ideology:** Not a faction in the political sense — a **phenomenon** gaining coherence. The Unbound are erased names, aborted spells, and static given semi-will. They "want" to finish merging with the Weave — or to unmake the distinction between real and unreal entirely.

**Structure:** No hierarchy; avatars and static-storms. **The Unwritten Child** is a focal point — a spell that was planned but never cast, now conscious.

**Relationship to Elara:** They remember her from the Night of Unbinding. They offer her peace through dissolution — no pain, no memory, no duty.

**Gameplay role:** Enemies in late game; secret ending; Unwritten Child quest; Unbound sympathy (hidden stat from choosing static dialogue options) unlocks Join ending.

**Visual language:** Visual static, glitching silhouettes, text that rearranges. Architecture: Somnium loops, Weaveheart static storms.

---

## 4. Major Mysteries

Five plot threads woven through the world. Each resolves partially through main story; fully through optional content + Memory Shards.

### Mystery I — **What Did Elara Do?**

**Surface answer (Act I–II):** She betrayed the ritual and caused the Collapse.  
**Mid answer (Act III–IV):** She altered the ritual but did not initiate it.  
**True answer (Act V + Shard 6):** She completed a forbidden merge to save the Unbound from excision, knowing it would tear the Weave. The Conclave erased her memory because admitting the truth would destroy their legitimacy.

**Clues:** Corin's journal, Maelis's hidden ledger page, Somnium classroom desk, Thornspeaker's effigy carvings.

---

### Mystery II — **Who Is the Unwritten Child?**

**Question:** A child of static appears in Elara's visions. Is it real, a Hollow, or a metaphor?

**Answer:** The Unwritten Child is the **Unbinding Ritual's aborted seventh anchor** — a spell-slot prepared for sacrifice that Elara refused to fill. It became conscious in the static. It is neither ally nor enemy; it is **what could have been unmade**.

**Resolution:** Secret quest in Somnium (see NPC §7.12). Full resolution grants static-immunity cosmetic and alters Join ending dialogue.

---

### Mystery III — **The Last Page**

**Question:** Archive lore mentions a final page torn from the **Imperial Weave Codex**. Where is it?

**Answer:** The Last Page is a Keeper who **became** the missing page to prevent the Conclave from burning it. They exist between text and body, only visible to Archive Lens users in specific light.

**Resolution:** Hidden NPC (§7.11). Delivers the true history of siphoning and unlocks Repair ending ritual variant.

---

### Mystery IV — **The Sovereign's Silence**

**Question:** Why does the Sovereign Echo not lead the Loyalists against the Conclave?

**Answer:** Alaric saw the Collapse in dream-vision before it happened. He chose to bind himself into the Undercrown to **witness** rather than fight, believing violence would accelerate Weave death. His silence is penance, not cowardice.

**Resolution:** Captain Rell quest line Act III; Undercrown mosaic chamber environmental lore; Shard 7 (optional).

---

### Mystery V — **The Thornspeaker's Grudge**

**Question:** The Thornspeaker says the Conclave "burned the groves." Why scapegoat gardeners for a ritual failure?

**Answer:** Pre-Collapse, Thornbound druids leaked proof of illegal siphoning to the Sovereign. The Conclave framed them as saboteurs to discredit root-magic and maintain siphoning policy. The Collapse let the Conclave **finish** the propaganda — until survivors found burned grove-records in the Archive.

**Resolution:** Elder Bryn rites; Whisperwood effigy cluster; Thornspeaker trial dialogue; Shard 8 (optional, Whisperwood hidden grove).

---

## 5. Hidden Lore — Environmental Storytelling by Region

Short examples of **discoverable lore clusters** — no NPC required. See §8 for craft guidelines.

### Ashen Threshold

- **Burial niches** with identical ash-piles; one niche has a **fresh** supply pack and a Conclave null-rope cut cleanly — someone visited recently (Corin).
- **Half-buried induction banners** reading *"Weave Above All"* — the word "Above" scratched out and replaced with "Within" in Thornbound thorn-ink.
- **Hollow pup cage** (optional rescue): inside, children's spell-practice slates showing Ember Sigil diagrams — someone was teaching Hollows to read script.

### Whisperwood (Outer & Deep)

- **Effigy circle:** twelve figures; eleven face outward, one faces inward toward a burned stump — the inward one wears a Magister's pin (Corin's guilt).
- **Root-choked bell** from a fallen Archive outpost; ringing it (Ember Bolt strike) plays a distorted save-theme — the Archive once had a grove station here.
- **Heartwood Grove hidden wall:** carvings of the Night of Unbinding from the **roots' perspective** — sap flowing upward into sky-wounds.

### Bleak Marsh

- **Memory Lanterns** (Fenwick quest): each relit lantern shows a ghost-scene — ferryman carrying soldiers *away* from the Spire, not toward battle (evacuation, not war).
- **Sunken cart** with Thornbound seed-jars and Conclave seizure warrants dated **the day before** the Collapse — premeditated grove raid planned regardless of ritual outcome.
- **Repeating footprints** in mud that walk the same circle; following them with Root Sense breaks the loop and reveals a **Ledger page** naming Elara "Anchor Candidate — Do Not Induct Publicly."

### Sunken Archive (Upper & Restricted)

- **Waterline stains** on edicts: pre-Collapse water level was lower — the Collapse **raised** groundwater (Weave wound bleeding).
- **Chained books** with titles scraped off; Archive Lens reveals: *"Siphoning Yield Reports — Classified."*
- **Bell tower mechanism:** bells ring in Fibonacci sequence — a Keeper code meaning *"The record is incomplete."*

### Catacombs

- **Mass grave of Purifiers** with **no** enemy wounds — they died from script-backlash (Collapse), not combat. Plaque: *"Fallen holding the line."* Line was already broken.
- **Wraithmonger's shelf** hides a **children's primer** on the Unbound, illustrated — someone taught forbidden lore underground.
- **Mosaic floor** matching Undercrown throne pattern — the Catacombs were meant to connect to Sovereign's court; sealed by Conclave edict pre-Collapse.

### Undercrown

- **Throne mosaic eyes** track Elara; if she wears Conclave robes (cosmetic), eyes close in disappointment.
- **Root-pillars** with tap-hollows — playing them in Thornbound rhythm opens a cache with **Sovereign's letter** to Alaric's future self: *"If you read this, I failed softly."*
- **Pale Guard barracks:** dice carved from bone; each face shows a Weave symbol — soldiers gambled for "who dies first when the Spire falls."

### Somnium

- **Looping classroom:** blackboard text changes when Elara uses Thread Recall — final loop reads: *"Special Case Elara — merge tolerance: infinite."*
- **Sleeping mages** with name-tags that blur when read directly; Archive Lens shows names of **Unbound** who were once magisters.
- **Dream shrine offerings:** players leave items; later visits show **other NPCs' offerings** (Corin's null-rope, Maelis's pen) — implies shared dream access.

### Veil Crossing

- **Thread bridges** made of Elara's own dialogue lines from earlier acts (environmental recap).
- **Faction graffiti war:** Purifier null-glyphs vs Thornbound root-glyphs vs Unbound static — three-way struggle on the same wall.
- **Final bench** before Spire: carved initials **E.V. + C.** with a date seven years ago — Corin sat here waiting for her to wake.

---

## 6. Three Endings

All endings require defeating (or pacifying) the Unbound Avatar. The choice is made at phase III or immediately after.

### Ending A — **Repair the Weave** (Good / Canon Intent)

**Choice:** Elara uses the Ember Sigil as a **needle**, stitching Unbound static back into the Weave as integrated script — not excised, not dominant. She sacrifices full use of magic (Sigil dims permanently).

**Requirements:** Thornbound sympathy ≥ 2 **or** Archive Keeper sympathy ≥ 2; Memory Shards 1, 3, 5, 6 collected; optional but strongly recommended: Last Page quest complete.

**World state:**
- Hollows stabilize into **Scriptorium helpers** over time (epilogue montage).
- Conclave Purifiers disband or merge with Keepers into a **Reformed Scriptorium**.
- Whisperwood groves begin to spread over Threshold ash.
- Elara survives, magic limited to Ember Bolt tier — she becomes a **Walker** between factions, not a magister.

**Final line:** *"A torn cloth can still be mended. It will never be untouched. Neither will I."*

**Post-credits:** Sister Maelis adds Elara's true account to the Archive. The bell rings once, clearly.

---

### Ending B — **Sever the Weave** (Bittersweet)

**Choice:** Elara cuts the Weave free from the Unbound entirely — restoring pre-Collapse **function** at the cost of **unmaking** all Unbound consciousness, including the Unwritten Child. The world gets stable magic; the static dies screaming.

**Requirements:** Undercrown sympathy ≥ 2 **or** Conclave sympathy ≥ 1; Sovereign Echo audience passed; Shard 6 required.

**World state:**
- Magic stabilizes immediately; Somnium dreams collapse — sleeping mages die in their sleep (epilogue acknowledges cost).
- Thornbound declare Elara **Kind-Killer**; they do not attack her but exile her from Whisperwood.
- Undercrown Loyalists honor her as **Sovereign's Blade**.
- Elara keeps full magic power; emotional cost shown in muted color palette post-ending.

**Final line:** *"I saved the world they wanted. I killed the world that was becoming."*

**Post-credits:** Corin finds the Unwritten Child's chalk drawing crumbling to ash in Somnium's ruins.

---

### Ending C — **Join the Unbound** (Bad / Secret)

**Choice:** Elara accepts the Unbound's offer — dissolves her identity into static, becoming part of the Weave's "immune system." The world loses the last Anchor; the Weave continues torn, but Elara feels no pain.

**Requirements:** Unbound sympathy ≥ 3 (static dialogue choices in Acts IV–V); Unwritten Child quest complete; **do not** have maximum Conclave sympathy.

**World state:**
- Weave remains unstable; factions continue war indefinitely.
- Player character unavailable in NG+ lore — NPCs refer to "the ember that went out."
- Threshold ash spreads; Hollows proliferate unchecked.
- **Secret:** New Game+ unlocks **Hollow Walker** mode — play as a Hollow with different moveset, ambiguous canon.

**Final line:** *"I don't have to remember. Nobody does. That's the mercy."*

**Post-credits:** Static on screen resolves briefly into Elara's face, then noise.

---

## 7. NPC Compendium (12)

Sympathy flags: many quests adjust hidden faction sympathy scores (+1 / −1). Listed where relevant.

---

### 7.1 Magister Corin — Story

| Field | Detail |
|-------|--------|
| **Role** | Disgraced Conclave Magister; Elara's former mentor |
| **Location** | Ashen Threshold (Act I hub); Veil Crossing (Act IV); Weaveheart (Act V if ally) |

**Backstory:**  
Corin inducted Elara and argued against using her as Anchor — he lost that argument to senior edict. He led the ritual circle at the Weaveheart, believing excision was genocide. When Elara altered the merge, he shielded her from backlash and then **helped** the Conclave erase her memory — not from malice, but because Purifiers were killing anchor-survivors on sight. He has spent seven years exiling himself to the Threshold, running interference against Purifier squads while searching for a repair methodology. He carries guilt for both the ritual and the erasure.

**Personality:** Controlled, weary, dry humor as armor. Protective to a fault. Believes in Elara more than he believes in the Conclave or himself.

**Dialogue voice:**
- *"Don't call me Magister. Titles are what we use when we want to pretend we know what we're doing."*
- *"Your Sigil flickers. Good. Dead things don't flicker."*
- *"I'll buy you time. I've been buying time for seven years. I'm practiced."*

**Quest lines:**

| Quest | Objectives | Rewards |
|-------|------------|---------|
| **Null-Rope Bind** (Act I) | Speak to Corin after awakening; survive Hollow ambush with him | Ember Sigil Codex, **Ember Bolt** unlock |
| **Field Journal** (Act III) | Find Corin's journal in Catacombs; return OR keep secret | Keep: +Unbound sympathy, lore entry; Return: Corin trust +1, **Grave Silence** scroll |
| **Veil Crossing Stand** (Act IV) | Choose to fight beside Corin against Purifiers | Corin survives Act V; **Thread Recall** upgrade |
| **Last Mentor** (Act V, optional) | Rescue Corin if captured in Act IV | Corin assists Avatar fight Phase I |

**Hidden / optional:** If player never speaks to Corin after Act I, he dies off-screen; Threshold grave appears with null-rope. Maelis later mentions she "expected more of him."

---

### 7.2 Sister Maelis — Story

| Field | Detail |
|-------|--------|
| **Role** | Senior Archive Keeper; ledger-sister who recorded the Unbinding names |
| **Location** | Sunken Archive scriptorium (upper); restricted stacks (Act II+) |

**Backstory:**  
Maelis was raised in the Archive — an orphan trained to copy script before she could read for meaning. She met Elara during induction audits and saw the girl's merge-tolerance flagged as "infinite" in classified appendices. On the Night of Unbinding, Maelis managed the name-list of entities to be excised; when Elara changed the ritual, Maelis secretly ** tore her own entry** from the excision list and hid the Anchor documentation in restricted tomes. Post-Collapse, she maintains the fiction of Conclave authority because she believes the alternative is Purifier anarchy. Her coldness toward Elara is a performance for Keeper witnesses.

**Personality:** Precise, emotionally compressed, fiercely archival. Expresses care through **objects and records**, not hugs.

**Dialogue voice:**
- *"I preserve. I do not forgive. Those are different departments."*
- *"Edict 77-C is on the desk. So is the lens. I did not say which you should pick up first."*
- *"Your name appears in three ledgers. Two are lies. I wrote the third in water-ink. It will fade unless you finish the work."*

**Quest lines:**

| Quest | Objectives | Rewards |
|-------|------------|---------|
| **Edict and Lens** (Act II) | Enter Archive; speak to Maelis; descend restricted stacks OR flee | **Archive Lens** prototype; Archive fast travel |
| **Water-Ink Truth** (Act III) | Retrieve hidden ledger page from flooded stack (Tide Anchor required) | Lore revelation; Keeper sympathy +1 |
| **Bell for the Record** (Act V, Repair path) | Bring Maelis the Last Page's testimony | Repair ending ritual text; post-game Archive epilogue |

**Hidden / optional:** If player attacks Keepers, Maelis locks scriptorium permanently. If player completes Hollow Scribe quest favoring Scribe, Maelis reveals she **authored** the Scribe's sapience accidentally via a copying error — she feels responsible.

---

### 7.3 The Thornspeaker — Story

| Field | Detail |
|-------|--------|
| **Role** | Collective voice of the Heartwood; Thornbound spiritual leader |
| **Location** | Whisperwood — Heartwood Grove (deep); effigy appears in outer wood earlier |

**Backstory:**  
The Thornspeaker is not one person but a **merged consciousness** of twelve druids who bound themselves to the Weave's root-network before the Collapse. When the groves burned, most of the circle died; the remainder speak in unison through bark-effigies. They remember the Night of Unbinding as **fire from above and wound from within** — they do not blame Elara first; they blame siphoning. They test Elara because ember-magic dries roots, but they also sense she is a bridge.

**Personality:** Ancient, plural ("we/us"), patient, occasionally cruel in riddles. Speaks in agricultural metaphor.

**Dialogue voice:**
- *"Little ember. We felt you wake. The ash coughed you up like a seed."*
- *"We do not forgive the Conclave. We do not require you to bleed for their sins. Bleed for the root, or do not bleed at all."*
- *"Three endings grow on the same branch. One fruit nourishes. One fruit poisons slow. One fruit is hunger wearing skin."*

**Quest lines:**

| Quest | Objectives | Rewards |
|-------|------------|---------|
| **Effigy Path** (Act I) | Reach Heartwood Grove; survive Thorn Warden | Access to deep Whisperwood |
| **Thornspeaker Trial** (Act III) | Complete combat trial without using fire spells OR pacify with Root Sense | **Ember Lance** (controlled fire rooted in Thornbound technique) |
| **Root and Ember** (Act V, Repair path) | Speak to Thornspeaker before Spire; accept bridge role | Repair ending support; Thornbound exile lifted in Sever ending if skipped |

**Hidden / optional:** Player can plant **Thornseeds** found in world at effigies; at 6 seeds, Thornspeaker reveals pre-Collapse grove map showing **illegal siphoning nodes** (exploration markers).

---

### 7.4 Peddler Ash — Merchant

| Field | Detail |
|-------|--------|
| **Role** | Scavenger-trader; sells consumables and map scraps |
| **Location** | Ashen Threshold — mobile camp near first Rest Point; relocates toward Marsh edge Act II |

**Backstory:**  
Ash was a Threshold refugee who lost a sibling to Purifier "cleansing" of Hollow-touched civilians. He trades to survive and to **fund** a hidden bunker for Hollow-adjacent children. He recognizes Elara from wanted sketches but sells to her anyway — business is business, and the Purifiers never pay fair. He is not brave, but he is stubborn about small mercies.

**Personality:** Gruff, superstitious, haggles performatively. Soft when he thinks nobody listens.

**Dialogue voice:**
- *"Veilmark girl pays double. Bad luck discount if you don't tell anyone I said that."*
- *"I sell rope, rations, and the occasional truth. Truth costs extra."*
- *"Don't bring Purifiers to my camp. I don't die heroically."*

**Quest lines:**

| Quest | Objectives | Rewards |
|-------|------------|---------|
| **Map Scrap** (Act I) | Buy or find his Threshold map | Whisperwood route unlocked on map |
| **Bad Luck Run** (Act II) | Deliver supply crate to Marsh bunker without dying | Discount permanently −15%; **Hollow Treat** consumable recipe |
| **Ash's Ledger** (Act IV, optional) | Find stolen ledger from Purifiers; return names of hidden refugees | Ash reveals bunker location (cosmetic NPCs); Threshold safe room |

**Hidden / optional:** If player saves Hollow pup in Act I, Ash sells **Induction Pin** back to Elara at cost (lore item + small max mana).

---

### 7.5 Wraithmonger Vex — Merchant

| Field | Detail |
|-------|--------|
| **Role** | Black market relic dealer; information broker |
| **Location** | Catacombs — behind movable ossuary shelf |

**Backstory:**  
Vex was an Archive apprentice who stole relics pre-Collapse "for safekeeping" and was exiled to the Catacombs. Post-Collapse, grave-robbing became a kingdom. Vex knows everyone's secrets because dead Conclave magisters still **whisper** near their tombs. Vex is genderless in presentation — uses "we" sometimes referring to self + dead clients.

**Personality:** Charming, amoral, curious. Treats catastrophe as inventory opportunity.

**Dialogue voice:**
- *"Relics, rumors, and regrets. Pick two — the third is never on sale."*
- *"The dead gossip worse than the living. I just charge admission."*
- *"Your Sigil's warm. Interesting. Most Veilmarks come in cold."*

**Quest lines:**

| Quest | Objectives | Rewards |
|-------|------------|---------|
| **Grave Silence** (Act III) | Buy or steal Grave Silence scroll | Stealth vs Hollows in Catacombs |
| **Shelf Secret** (Act III) | Find hidden room behind shelf | Memory Shard 4 optional location; illegal relic stock |
| **Tomb Whisper** (Act IV) | Bring Vex **Naming Quill** ink sample | Reveals Corin's pre-Collapse alias; Unbound sympathy +1 |

**Hidden / optional:** Sell Vex a duplicate relic → unlock **Wraith Trade** NG+ discount. Kill Vex → Catacombs become hostile merchant-less; Purifiers occupy niche.

---

### 7.6 Elder Bryn — Trainer

| Field | Detail |
|-------|--------|
| **Role** | Thornbound rite-teacher; Root Sense instructor |
| **Location** | Whisperwood — Root Altar clearing |

**Backstory:**  
Bryn was the youngest of the twelve Thornspeaker circle — too young to merge fully, old enough to survive the grove-burning. She lost her voice in the fire and communicates via **root-sign** (player sees translated subtitles). She teaches those who prove they listen. She knew Elara pre-Collapse as a Conclave prodigy who visited the groves illegally to read root-script.

**Personality:** Stern, tactile, values patience. Respects actions over words (ironic given she cannot speak).

**Dialogue voice (root-sign translation):**
- *"[The wood remembers your footsteps from before the ash.]"*
- *"[You took from roots once. Will you give back now?]"*
- *"[Fire is not forbidden. Unrooted fire is.]"*

**Quest lines:**

| Quest | Objectives | Rewards |
|-------|------------|---------|
| **Three Quiet Rites** (Act II) | Listen at Heartwood; bleed on altar; return Thornseed | **Root Sense** ability |
| **Bryn's Grove** (Act III, optional) | Defeat Marsh poachers targeting Thornseeds | Thornbound sympathy +1; **Root Guard** parry upgrade |
| **Voice Restored** (Act V, Repair ending only) | Repair ending epilogue flag | Bryn speaks one word: Elara's name |

**Hidden / optional:** Player can learn to **read root-sign** without translation after max Root Sense upgrades — Bryn's subtitles become poetic rather than plain.

---

### 7.7 The Hollow Scribe — Trainer

| Field | Detail |
|-------|--------|
| **Role** | Sapient Hollow; spell-copyist; Archive Lens teacher |
| **Location** | Sunken Archive — Flooded Annex |

**Backstory:**  
The Scribe was a copying error — a Hollow that absorbed so much duplicated spell-text it became literate. Archive Keepers wanted it destroyed; Sister Maelis secretly redirected water-flow to hide the annex. The Scribe copies spells onto water-parchment that dissolves — it believes **impermanence is honest**. It teaches Lens use because it sees the Weave as text with missing paragraphs.

**Personality:** Gentle, melancholic, precise. Fears Purifiers but more afraid of **being forgotten**.

**Dialogue voice:**
- *"Words on water last exactly long enough to be true."*
- *"You are a living palimpsest. I find that reassuring."*
- *"The Keepers call me corruption. Corruption is just change with bad publicity."*

**Quest lines:**

| Quest | Objectives | Rewards |
|-------|------------|---------|
| **Naming Quill** (Act II) | Retrieve quill from Keeper vault OR buy from Vex | **Archive Lens** full unlock |
| **Dissolving Spell** (Act III) | Copy a forbidden spell onto water-parchment before it fades | Random high-tier spell scroll (single use) |
| **Scribe's Memory** (Act IV) | Defend annex from Purifier raid | Hollow sympathy flag; Scribe survives post-game |

**Hidden / optional:** If player returns quill to Keepers instead, Scribe dies off-screen; Maelis adds obituary to Archive with hidden water-ink apology.

---

### 7.8 Fenwick the Lost — Quest Giver

| Field | Detail |
|-------|--------|
| **Role** | Ghost-ferryman; Marsh memory-loop NPC |
| **Location** | Bleak Marsh — Shallow Crossing (loops along lantern path) |

**Backstory:**  
Fenwick ferried Conclave evacuees during the Collapse — not soldiers, but **children and ledger-clerks**. He drowned when Somnium's dream-tide flooded the Marsh. He repeats his last route because he believes if he completes the crossing, the passengers will finally disembark. He does not know he is dead.

**Personality:** Cheerful, repetitive, oddly comforting. Panics if lanterns go out.

**Dialogue voice:**
- *"Mind the step — ah, you can't see the step either, can you? Good, good."*
- *"Six lanterns to the deep channel. Same as yesterday. Same as always."*
- *"You're not on my manifest. I'll add you. Names matter."*

**Quest lines:**

| Quest | Objectives | Rewards |
|-------|------------|---------|
| **Six Lanterns** (Act II) | Relight six Memory Lanterns along Marsh path | **Tide Anchor** ability; Fenwick moves to final dock |
| **Manifest Names** (Act III) | Collect three lost name-tags from Marsh ghosts; add to Fenwick's book | Marsh fast travel; lore on evacuation |
| **Final Crossing** (Act IV) | Escort Fenwick to deep channel during Somnium bleed event | Fenwick passes on; leaves **Lantern Key** (Somnium shortcut) |

**Hidden / optional:** If player completes crossing before Act IV, Fenwick whispers a **passenger name** that matches the Unwritten Child — Mystery II hint.

---

### 7.9 Captain Rell — Quest Giver

| Field | Detail |
|-------|--------|
| **Role** | Commander of Undercrown Pale Guard |
| **Location** | Undercrown — Blockade Gate; Pale Guard barracks |

**Backstory:**  
Rell served Sovereign Alaric before the Collapse as a **root-engineer**, not a soldier. When siphoning intensified, Alaric asked Rell to guard the Undercrown's sealed gates. Rell has obeyed for seven years, converting engineers into soldiers out of necessity. He distrusts all Conclave mages but respects **competence and honesty**. He lost a daughter to Somnium-sleep — she walks the dream-academy still.

**Personality:** Blunt, duty-bound, quietly grieving. Tests people with **work**, not speeches.

**Dialogue voice:**
- *"Talk is ash. Bring me a root-sigil or bring me a reason to bury you."*
- *"The Sovereign doesn't command. He remembers. We guard so he can."*
- *"My daughter sleeps in Somnium. Don't mention her unless you've walked it."*

**Quest lines:**

| Quest | Objectives | Rewards |
|-------|------------|---------|
| **Blockade Proof** (Act III) | Bring Thornbound Root-Sigil OR Conclave Null-Seal | Undercrown access; **Crown Mark** |
| **Pale Guard Drill** (Act III, optional) | Complete combat challenge without magic | Rell respect +1; armor cosmetic |
| **Daughter's Name** (Act IV) | Find Rell's daughter in Somnium; deliver her message | Sever ending enhancement; Rell sympathy max |

**Hidden / optional:** If player tells Rell about Unwritten Child, he attempts Somnium entry and fails — adds environmental body at Veil Crossing (not killable — tragic set dressing).

---

### 7.10 Dreamer Liora — Quest Giver

| Field | Detail |
|-------|--------|
| **Role** | Somnium shrine keeper; dream-walker apprentice |
| **Location** | Somnium border shrine; appears in Veil Crossing during Act IV |

**Backstory:**  
Liora was a Conclave dream-magic student who entered Somnium to practice **Thread Recall** before the Collapse. The Collapse trapped her partially — half her body in reality, half in dream. She maintains the border shrine to prevent Somnium from swallowing the Marsh entirely. She idealizes the Conclave because the dream-academy shows only its best memories.

**Personality:** Hopeful, naive, brave in bursts. Represents what Elara **could have been** without truth.

**Dialogue voice:**
- *"The academy still teaches. Isn't that wonderful? It never ends."*
- *"If we fix the dream, maybe the awake world fixes too. That's how threads work, right?"*
- *"You look like someone who forgot a lesson. I can help you remember — if you want the gentle version."*

**Quest lines:**

| Quest | Objectives | Rewards |
|-------|------------|---------|
| **Shared Dream** (Act IV) | Enter Somnium academy; break three loop rooms | **Dream Walk** ability |
| **Shrine Maintenance** (Act IV) | Gather dream-silk from Veil Crossing static | Somnium Rest Point |
| **Gentle Version** (Act IV, optional) | Choose to tell Liora the truth about Collapse OR preserve illusion | Truth: Liora helps Act V; Illusion: Liora fades post-game |

**Hidden / optional:** Lie to Liora → Repair ending adds somber epilogue line. Truth → she writes Elara's account in dream-ink visible only in Somnium NG+.

---

### 7.11 The Last Page — Hidden

| Field | Detail |
|-------|--------|
| **Role** | Living missing page of the Imperial Weave Codex |
| **Location** | Sunken Archive restricted stacks — visible only with Archive Lens + bell toll at midnight (in-game timer or scripted event) |

**Backstory:**  
The Last Page was Keeper Magistrate **Orin Hale**, who transformed himself into the Codex's excised final page rather than let the Conclave burn it. The page documented **siphoning genocide math** — how many Unbound-equivalent consciousnesses would be destroyed by excision. Orin exists between text and flesh; he appears as parchment with a face. He can only speak when read.

**Personality:** Erudite, tragic, literally **defined by missing information**. Speaks in footnotes.

**Dialogue voice:**
- *"[Footnote 1: The Empire called them static. They were census errors given soul.]"*
- *"I am the page they tore out so the chapter would look clean."*
- *"Read me aloud, Anchor. That's how I breathe."*

**Quest lines:**

| Quest | Objectives | Rewards |
|-------|------------|---------|
| **Read Aloud** (Act IV, secret) | Find Last Page; read at Weaveheart door | Repair ending unlock variant; Mystery III resolved |
| **Preserve Orin** (Act V, optional) | Carry page through Avatar fight without taking damage | Orin survives as in-game lore codex UI voice |

**Hidden / optional:** If player sells "blank parchment" to Vex before discovering truth, quest fails permanently — Vex mentions a "screaming page" later.

---

### 7.12 The Unwritten Child — Hidden

| Field | Detail |
|-------|--------|
| **Role** | Manifestation of aborted ritual anchor; Unbound focal point |
| **Location** | Somnium — appears in looping classroom after 4+ Memory Shards |

**Backstory:**  
The Unbinding ritual required seven anchors; the seventh was prepared as **sacrificial empty slot** — a child-shaped hole in the Weave. Elara refused to fill it. Post-merge, the empty slot **filled itself** with static and became the Unwritten Child — a being defined by *almost*. It wanders Somnium asking to be named or unnamed. Join ending treats it as sibling to Elara.

**Personality:** Contradictory, childlike, occasionally ancient. Switches between second and third person.

**Dialogue voice:**
- *"I am the spell they never cast. You are the spell they cast wrong. We're family."*
- *"Name me and I die. Don't name me and I hurt. Choose like you always do."*
- *"Static is just lullaby for erased people."*

**Quest lines:**

| Quest | Objectives | Rewards |
|-------|------------|---------|
| **Empty Desk** (Act IV, secret) | Find seventh desk in Somnium; sit in it | Unwritten Child appears; Unbound sympathy +1 |
| **Name or No Name** (Act IV–V) | Choose to name the Child OR refuse | Name: Sever ending guilt scene; Refuse: Join ending unlocked |
| **Sibling Thread** (Act V, Join path) | Speak to Child before Avatar | Join ending cinematic variant |

**Hidden / optional:** Naming the Child (**any name**) causes it to become a **small follower** in NG+ Hollow Walker mode only.

---

## 8. Environmental Storytelling Guide

### Principles

1. **Lore is optional, emotion is not.** Every cluster should carry mood (loss, irony, horror, tenderness) even if the player skips text details.
2. **Show faction conflict physically** — graffiti, overlapping edits, seized goods, scorched symbols. Avoid lore dumps on standalone plaques unless styled as in-world documents with voice.
3. **Elara's past is in the environment** — her name appears in unexpected places (desks, ledgers, graffiti) to reinforce Mystery I.
4. **Repeat motifs:** threads, bells, water, ash, static, roots, empty chairs, duplicated footprints.
5. **Reward tools with lore** — Archive Lens, Root Sense, and Thread Recall should each reveal **unique** layers, not duplicate text.

### Layer Model

| Layer | Delivery | Example |
|-------|----------|---------|
| **Background** | Visual only | Effigy facing wrong direction |
| **Inspect** | One-line prompt | *"Induction banner. 'Weave Within' added in thorn-ink."* |
| **Tool-gated** | Requires spell/ability | Archive Lens reveals classified title on scraped book |
| **Behavior-gated** | Requires world state | Corin camp appears only if player saved Hollow pup |
| **Audio** | SFX / VO whisper | Bell ring plays distorted memory |

### Regional Tone Cheatsheet

| Region | Emotional tone | Lore focus |
|--------|----------------|------------|
| Threshold | Exhaustion, scavenging | Aftermath, Purifiers, Corin's vigil |
| Whisperwood | Accusation, growth | Thornbound history, grove-burning |
| Marsh | Repetition, grief | Evacuation truth, Fenwick's loop |
| Archive | Bureaucracy, secrets | Edicts, siphoning records, Maelis |
| Catacombs | Commerce in death | Black market, failed Purifiers |
| Undercrown | Loyalty, penance | Sovereign, anti-siphoning |
| Somnium | Nostalgia, wrongness | Conclave idealization, Elara special case |
| Veil Crossing | Convergence, choice | Faction war, Corin's bench |

### Implementation Notes (Godot)

- Use **`LoreCluster` interactable** with `layers: Array[LoreLayer]` — each layer specifies required ability flags.
- Memory Shards trigger **`MemoryVision` cutscenes** (skippable, re-watch at Rest Points).
- Faction sympathy stored in **`StoryState` singleton**; environmental variants use same clusters with `sympathy_min` thresholds.

---

## 9. Memory Shards (8 Collectibles)

Memory Shards are **canonical recollections** — true memories, not propaganda. Collecting all 8 unlocks Archive Lens **deep read** on the Avatar (pacify option in boss fight). Shards are tied to acts but scattered across regions to encourage exploration.

| # | Title | Act | Location | Vision summary | Unlocks |
|---|-------|-----|----------|------------------|---------|
| **1** | *The Ledger Name* | I | Threshold — buried niche near treeline | Young Maelis writes Elara's name under "Unbinding Candidates" | Baseline mystery; Somnium desk glitch |
| **2** | *Induction* | II | Archive upper — induction hall statue hollow | Corin pins badge on fourteen-year-old Elara; static figure on balcony | Unbound tease |
| **3** | *Rain of Script* | III | Catacombs — main path reliquary | Collapse begins; script falls like glass; Elara's hand burns | Weaveheart wing access hint |
| **4** | *The Seventh Chair* | III | Catacombs — Wraithmonger secret room | Ritual circle with **empty chair**; voices argue about sacrifice | Unwritten Child quest flag |
| **5** | *Necessary* | IV | Somnium — headmaster's office after loop break | Elara argues with Corin: *"Necessary for whom?"* Static laughs | Avatar phase II dialogue |
| **6** | *Anchor* | V | Weaveheart — required pre-boss | Full truth: Elara completed merge to save Unbound | Ending choice clarity |
| **7** | *Sovereign's Dream* | IV (optional) | Undercrown — root-pillar puzzle | Alaric sees Collapse before it happens; chooses to bind self | Mystery IV full; Rell dialogue |
| **8** | *Grove-Burn* | III (optional) | Whisperwood — hidden grove behind effigies | Conclave torches groves **during** Collapse chaos, not before | Mystery V full; Thornspeaker trust |

### Collection UI

- Shards appear in **Ember Sigil Codex → Memory** tab.
- Each shard includes: vision replay, one **still frame** for art reference, linked Mystery ID (§4).
- **6 required** for ending access (Shards 1, 3, 5, 6 minimum + two others); **8 recommended** for pacify route and fullest epilogues.

### Shard 6 — *Anchor* (Full Text Reference)

> The Weaveheart Spire hums. Seven chairs. Six filled. The seventh empty — waiting like a mouth.  
> Corin shouts my name. The list of names to excise scrolls endless — not static, **people**.  
> I change the anchor rune. Merge, not cut. The Weave screams. Light becomes glass becomes rain.  
> I hold the thread because if I let go, they unmake everything that was never given a name.  
> Hands pull me down. Memory pulls like tide.  
> *"Veilmark her. The order must survive its mistake."*  
> I wake in ash. I wake in ash. I wake—

---

## Appendix — Narrative Dependencies

| System | Document | Link |
|--------|----------|------|
| Regions & gating | `02-world-design.md` | Shard locations, NPC hubs |
| Spells & Sigil | `06-magic-system.md` | Trainer unlocks, ending costs |
| Bosses | `05-boss-bible.md` | Thornspeaker Trial, Unbound Avatar |
| Faction patrols | `04-enemy-bible.md` | Purifier enemies in Threshold |

---

*Document version 1.0 — complete narrative bible for Arcania solo development.*
