# Recent Work - Out of Pocket

## November 30, 2025

### AdMob Integration Fixes
- Fixed race condition in AdManager where ads were being wiped after dismiss
- Root cause: loadInterstitialAd() was called in showInterstitialAd() before ad dismissed
- Fix: Removed premature preload, now only preloads in game start methods
- Production ads showing "No ad to show" - normal for new ad units (24-48hr wait)

### Landing Page Updates (oop-door-b59dd403)
- Added CNAME file for getoutofpocket.com custom domain
- Connected waitlist email form to Google Sheets via Apps Script
- Web App URL: https://script.google.com/macros/s/AKfycbzxe7mRldcBgrZ4G44zZlp7MN1D8K8nrdAamNobL6Y5FS67slgAhPMS0WvVf1GvCSfIhw/exec

### Patterns Learned
- Google Apps Script is free/simple way to connect static sites to Google Sheets
- AdMob production ads need time to start serving after ad unit creation
- Race conditions can occur when async operations overlap with state clearing
