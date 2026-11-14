#!/bin/bash
# tune-agresivo.sh — Aumentar agresividad del exploit para éxito en 1er intento
# Cambios SOLO en parámetros numéricos, no en código de exploit
set -e

REPO="$HOME/webkit1402"
AG="$REPO/PS4_1402_v3/afterglow-g.js"
JB="$REPO/PS4_1402_v3/jb-g.js"

echo "=== TUNE AGRESIVO — AFTERGLOW-G.JS ==="

# Backup
cp "$AG" "$AG.bak2"
cp "$JB" "$JB.bak2"
echo "  Backups creados (.bak2)"

# ── FIX 7: sprays 126 → 200 (60% más spray = más probabilidad de llenar el hueco UAF)
sed -i 's/sprays: 126/sprays: 200/' "$AG"
grep -q "sprays: 200" "$AG" && echo "  FIX #7 OK — sprays: 126 → 200" || echo "  FIX #7 FALLO"

# ── FIX 8: units 15 → 24 (más unidades /dev/apm = más oportunidades)
sed -i 's/units: 15/units: 24/' "$AG"
grep -q "units: 24" "$AG" && echo "  FIX #8 OK — units: 15 → 24" || echo "  FIX #8 FALLO"

# ── FIX 9: batch 60 → 100 (spray más rápido = ventana de race más pequeña)
sed -i 's/batch: 60/batch: 100/' "$AG"
grep -q "batch: 100" "$AG" && echo "  FIX #9 OK — batch: 60 → 100" || echo "  FIX #9 FALLO"

# ── FIX 10: reintentos 4 → 8 (el doble de intentos antes de rendirse)
sed -i 's/|| 4;/|| 8;/' "$AG"
grep -q "|| 8;" "$AG" && echo "  FIX #10 OK — tries: 4 → 8" || echo "  FIX #10 FALLO"

# ── FIX 11: delay entre reintentos 400ms → 1200ms (más tiempo para que el kernel se estabilice)
sed -i 's/setTimeout(ok, 400)/setTimeout(ok, 1200)/' "$AG"
grep -q "setTimeout(ok, 1200)" "$AG" && echo "  FIX #11 OK — delay: 400ms → 1200ms" || echo "  FIX #11 FALLO"

echo ""
echo "=== TUNE AGRESIVO — JB-G.JS ==="

# ── FIX 12: Cache-busting en import de afterglow-g.js dentro de jb-g.js
# El import actual: "./afterglow-g.js?v=hen184-1402"
# Cambiamos a añadir timestamp dinámico
sed -i 's|await import("./afterglow-g.js?v=hen184-1402")|await import("./afterglow-g.js?v=hen184-1402\&_cb=" + Date.now())|' "$JB"
grep -q '_cb=" + Date.now()' "$JB" && echo "  FIX #12 OK — cache-busting en afterglow-g.js import" || echo "  FIX #12 FALLO"

echo ""
echo "=== COMMIT Y PUSH ==="
cd "$REPO"
git add -A
git commit -m "tune agresivo: sprays 200, units 24, batch 100, tries 8, delay 1200ms, cache-bust afterglow import"
git push origin main

echo ""
echo "=== HECHO — 6 FIXES ADICIONALES APLICADOS ==="
echo "  FIX #7:  sprays 126 → 200 (más cobertura de spray)"
echo "  FIX #8:  units 15 → 24 (más unidades apm)"
echo "  FIX #9:  batch 60 → 100 (spray más rápido)"
echo "  FIX #10: tries 4 → 8 (más reintentos)"
echo "  FIX #11: delay 400 → 1200ms (estabilización kernel)"
echo "  FIX #12: cache-busting en afterglow-g.js import"
echo ""
echo "Espera ~2 min para que GitHub Pages actualice, luego prueba en PS4."
