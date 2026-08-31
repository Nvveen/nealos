<svg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080" viewBox="0 0 1920 1080">
  <rect width="1920" height="1080" fill="${SURFACE}"/>
  <g transform="translate(${SPLASHX} ${SPLASHY}) scale(${SPLASHSCALE})">
    <path d="M${XLEFT} ${YBOTTOM} L${XLEFT} ${YTOP}" fill="none" stroke="${OUTLINE}"
          stroke-width="${STROKE}" stroke-linecap="round"/>
    <path d="M${XLEFT} ${YTOP} L${XRIGHT} ${YBOTTOM}" fill="none" stroke="${TERTIARY}"
          stroke-width="${STROKE}" stroke-linecap="round"/>
    <path d="M${XRIGHT} ${YBOTTOM} L${XRIGHT} ${YTOP}" fill="none" stroke="${OUTLINE}"
          stroke-width="${STROKE}" stroke-linecap="round"/>
    <text x="${XMID}" y="${WORDY}" text-anchor="middle" font-family="Red Hat Display"
          font-size="${WORDSIZE}" font-weight="500" letter-spacing="${WORDTRACK}"
          fill="${ONSURFACE}">NealOS</text>
  </g>
</svg>