#!/usr/bin/env bash
set -euo pipefail

# Expects in the environment: all colour vars, all geometry vars, TPL (template
# dir), OUTDIR (theme dir to populate). Writes PNGs + the .plymouth file.

mkdir -p "$OUTDIR"
cd "$(mktemp -d)"

XMID=$(awk "BEGIN{print ($XLEFT+$XRIGHT)/2}")
L1=$(awk "BEGIN{print $YBOTTOM-$YTOP}")
L2=$(awk "BEGIN{print sqrt(($XRIGHT-$XLEFT)^2+($YBOTTOM-$YTOP)^2)}")
L3=$L1
export XMID L1 L2 L3

# Boot animation. Each segment draws over its own slice of the timeline:
# left vertical 0-28%, diagonal 28-72%, right vertical 72-100%, word fades 85-100%.
FRAMES=24
for i in $(seq 1 $FRAMES); do
  p=$(awk "BEGIN{print ($i-1)/($FRAMES-1)}")
  D1=$(awk "BEGIN{s=($p-0.00)/0.28; if(s<0)s=0; if(s>1)s=1; print $L1*(1-s)}")
  D2=$(awk "BEGIN{s=($p-0.28)/0.44; if(s<0)s=0; if(s>1)s=1; print $L2*(1-s)}")
  D3=$(awk "BEGIN{s=($p-0.72)/0.28; if(s<0)s=0; if(s>1)s=1; print $L3*(1-s)}")
  WORDOPACITY=$(awk "BEGIN{s=($p-0.85)/0.15; if(s<0)s=0; if(s>1)s=1; print s}")
  export D1 D2 D3 WORDOPACITY
  envsubst < "$TPL/frame.svg.tpl" > f.svg
  resvg f.svg "$OUTDIR/$(printf 'animation-%04d.png' "$i")"
done

# Throbber: finished mark, diagonal breathing. Loops while boot continues.
for i in $(seq 1 30); do
  PULSE=$(awk "BEGIN{pi=atan2(0,-1); print 0.775+0.225*cos(2*pi*($i-1)/30)}")
  export PULSE
  envsubst < "$TPL/throbber.svg.tpl" > t.svg
  resvg t.svg "$OUTDIR/$(printf 'throbber-%04d.png' "$i")"
done

# LUKS passphrase prompt assets.
for name in entry bullet lock capslock keyboard; do
  envsubst < "$TPL/prompt/$name.svg.tpl" > p.svg
  resvg p.svg "$OUTDIR/$name.png"
done

oxipng -o 4 --strip safe "$OUTDIR"/*.png

IMAGEDIR="$OUTDIR" envsubst < "$TPL/nealos.plymouth.tpl" > "$OUTDIR/nealos.plymouth"