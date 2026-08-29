<svg xmlns="http://www.w3.org/2000/svg" width="${CANVAS}" height="${CANVAS}" viewBox="0 0 ${CANVAS} ${CANVAS}">
  <path d="M${XLEFT} ${YBOTTOM} L${XLEFT} ${YTOP}" fill="none" stroke="${OUTLINE}"
        stroke-width="${STROKE}" stroke-linecap="round"
        stroke-dasharray="${L1}" stroke-dashoffset="${D1}"/>
  <path d="M${XLEFT} ${YTOP} L${XRIGHT} ${YBOTTOM}" fill="none" stroke="${TERTIARY}"
        stroke-width="${STROKE}" stroke-linecap="round"
        stroke-dasharray="${L2}" stroke-dashoffset="${D2}"/>
  <path d="M${XRIGHT} ${YBOTTOM} L${XRIGHT} ${YTOP}" fill="none" stroke="${OUTLINE}"
        stroke-width="${STROKE}" stroke-linecap="round"
        stroke-dasharray="${L3}" stroke-dashoffset="${D3}"/>
  <text x="${XMID}" y="${WORDY}" text-anchor="middle" font-family="Red Hat Display"
        font-size="${WORDSIZE}" font-weight="500" letter-spacing="${WORDTRACK}"
        fill="${ONSURFACE}" opacity="${WORDOPACITY}">NealOS</text>
</svg>