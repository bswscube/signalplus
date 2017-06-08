import React from 'react';

function getIcon(type) {
  const iconTypes = {
    offers:      window.__IMAGE_ASSETS__.iconsOffersPng,
    contest:     window.__IMAGE_ASSETS__.iconsContestPng,
    today:       window.__IMAGE_ASSETS__.iconsTodayPng,
    support:       window.__IMAGE_ASSETS__.iconsSupportPng,
    bell:        window.__IMAGE_ASSETS__.iconsBellSvg,
    close:       window.__IMAGE_ASSETS__.iconsCloseSvg,
    reminder:    window.__IMAGE_ASSETS__.iconsReminderPng,
    clock:        window.__IMAGE_ASSETS__.iconsClockPng,
    welcome:     window.__IMAGE_ASSETS__.iconsSplusPurplePng,
    create:      window.__IMAGE_ASSETS__.iconsSignalplusSmallSvg,
    custom:      window.__IMAGE_ASSETS__.iconsSignalplusSmallPinkSvg,
    tip:         window.__IMAGE_ASSETS__.iconsTipIconSvg,
    public:      window.__IMAGE_ASSETS__.iconsPublicIconSvg,
    explanation: window.__IMAGE_ASSETS__.iconsExplanationPng,
    twitter:     window.__IMAGE_ASSETS__.socialTwitterBlueSvg,
    twitterGrey: window.__IMAGE_ASSETS__.socialTwitterGreySvg,
    arrow:       window.__IMAGE_ASSETS__.iconsBlueArrowPng,
    comingSoon:  window.__IMAGE_ASSETS__.logoSignalplusIconPng,
  };

  return iconTypes[type];
}

export default function SignalIcon({ className, src, type }) {
  const actualSrc = src || getIcon(type);

  return (
    <img src={actualSrc} className={className} />
  );
}
