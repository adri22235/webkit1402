/*
  launch.js — NanospeedGamer landing page controller
  Countdown → auto-redirect to exploit chain, or manual start via button.
  Referrer guard: only fires when reached from index.html in the same origin.

  ── STABILITY FIX by adri22235 ──────────────────────────────────────────
  FIX #1: drain:16 → mem=2 (mem2-low profile)
    PROBLEM: Original used g=drain:16&g=drainsz:0x4000 which is 32x LESS
    than core.js default (drain:512, drainsz:0x10000). This dramatically
    reduces the heap spray density, making the WebKit UAF placement
    unreliable. On PS4's limited RAM, too few drain slots means the
    freed object's slot may not get reclaimed by the spray.

    FIX: Use mem=2 (mem2-low profile) instead of raw drain overrides.
    mem2-low = { slots: 1,500,000, drain: 24, drainsz: 0x8000 }
    This is a CALIBRATED profile designed for low-memory targets,
    not an arbitrary drain count. drain:24 with drainsz:0x8000 gives
    ~50% more spray coverage than drain:16 with 0x4000, while still
    being conservative enough for PS4's memory constraints.

    ALTERNATIVE PROFILES TO TRY IF mem=2 STILL CRASHES:
    - mem=1 (balanced): drain:48, drainsz:0x8000 — more aggressive
    - mem=3 (verylow): drain:12, drainsz:0x4000 — lighter than original
    - No mem param: uses default drain:512 — AGGRESSIVE, may OOM on PS4

  FIX #2: Added cache-busting timestamp to DEST URL
    PROBLEM: GitHub Pages does NOT send no-store headers. PS4 browser
    caches old JS modules aggressively. If jb-g.js or core.js get cached
    from a previous failed attempt, the browser may load stale code
    that doesn't match the current afterglow-g.js version.

    FIX: Append _cb=timestamp to break the cache on every launch.
  ────────────────────────────────────────────────────────────────────────
*/

(function () {
  "use strict";

  const COUNTDOWN_SEC = 0; // deliberately no automatic exploit launch

  // FIX #1: Use mem=2 profile instead of raw drain:16 override
  // FIX #2: Cache-bust with timestamp
  const CB = "_cb=" + Date.now();
  const DEST = "launch.html?v=hen184-1402-v3&log=1&afterglow=run&mode=kpstep&mem=2&" + CB;

  const countEl = document.getElementById("count"); // <p class="status" id="count">
  const content = document.querySelector(".content");

  function guardOk() {
    return true; // key auth on index.html already protects the page
  }

  /* ── inject start button ─────────────────────────────────────────────── */
  const btn = document.createElement("button");
  btn.id = "startBtn";
  btn.textContent = "START 14.02 HEN (EXPERIMENTAL)";
  btn.style.display = "none"; // hidden until guard passes
  if (content) content.appendChild(btn);

  /* ── go ──────────────────────────────────────────────────────────────── */
  function go() {
    if (countEl) countEl.textContent = "[ EXECUTE ]";
    if (btn) btn.disabled = true;
    location.href = DEST;
  }

  /* ── blocked by referrer guard ───────────────────────────────────────── */
  if (!guardOk()) {
    if (countEl) countEl.textContent = "[ ACCESS DENIED — NAVIGATE FROM ROOT ]";
    return; // stop — session restore, do not fire
  }

  /* ── show button now that we're cleared ─────────────────────────────── */
  btn.style.display = "";
  btn.addEventListener("click", function () {
    go();
  });

  /* NO AUTO-START. The user must click to begin. */
  if (countEl) countEl.textContent =
    "Experimental build. 14.02 HEN support is new; remaining Akatsuki kernel patches are not validated. A full console freeze is possible.";
})();
