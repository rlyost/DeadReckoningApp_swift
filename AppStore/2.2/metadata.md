# Dead Reckoning 2.2 (5) — App Store product page

Everything posted to App Store Connect for version 2.2 (posted 2026-10-07). Screenshots, creative assets and the icon are in this folder.

## Header and search results

App Store Connect's **Header and Search Results** tab takes two creative assets (PNG only in the uploader, no transparency):

- **Header:** `creative/header-3840x1646.png` (21:9). The needle and headline sit inside the 2946 × 661 centered safe area.
- **Search results:** `creative/search-results-3840x2560.png` (3:2). Shows screenshots 01–03 as phones; without it, the store falls back to the first screenshots.
- **App icon:** `app-icon-1024.png` (1024 × 1024, opaque). The store takes the icon from the app binary; it is installed as the single-size AppIcon in the 2.2 build.

## Name

24 / 30 characters · shown in the header and search results

```text
Dead Reckoning: Land Nav
```

## Subtitle

28 / 30 characters · shown under the name in the header and search results

```text
Pace Count & Azimuth Compass
```

## Keywords

98 / 100 characters · comma-separated, no spaces; words already in the name and subtitle are left out because Apple indexes them automatically

```text
navigation,orienteering,bearing,ranger,army,military,infantry,hiking,topo,map,steps,pedometer,ruck
```

## Promotional text

140 / 170 characters · can be changed any time without a new build

```text
New in 2.2: a red-and-white compass needle and a topographic-map look on every screen, in Light and Dark Mode. Set your azimuth and walk it.
```

## Description

1528 / 4000 characters

```text
Dead Reckoning helps you practice the land navigation technique taught in basic Army training: move a set distance along a set azimuth, counting your paces as you go.

SET UP YOUR LEG IN SECONDS
• Enter your pace count, the distance in meters and a true azimuth.
• Or tap your destination on the map, and the app works out the distance and azimuth for you.

FOLLOW THE NEEDLE
• Turn until the needle points straight ahead, then walk.
• Steps taken, steps left and estimated distance remaining update as you move, using your iPhone's motion sensors.
• An alert tells you when you've reached your goal.

KNOW YOUR PACE COUNT
• Walk a measured stretch and the built-in calculator counts your steps and works out your pace count per 100 meters.
• Your pace count is saved for next time.

MADE FOR THE FIELD
• Topographic-map styling on every screen, in Light and Dark Mode.
• A slim red-and-white compass needle that stays sharp on any screen.
• VoiceOver describes the needle and how to follow it.

A NOTE ON TRUE NORTH
Dead Reckoning navigates by true north, the same reference Apple Maps uses. If you enter an azimuth by hand, use the true (map) angle, not a magnetic one. The About screen explains declination and how to convert.

GROUNDED IN ARMY DOCTRINE
Based on dead reckoning as described in U.S. Army FM 3-25.26, Section 12-5. Written by a Ranger-qualified Army officer.

Use Dead Reckoning as a training aid alongside a map and compass. It is not affiliated with or endorsed by the U.S. Army or the Department of Defense.
```

## What's New in Version 2.2

268 / 4000 characters

```text
Dead Reckoning has a new look.

• New compass needle: a slim red-and-white needle replaces the hand-drawn arrow. It stays sharp on every screen size.
• New topographic-map background on every screen, with matching Light and Dark Mode versions.
• New app icon to match.
```

## Screenshots

| Folder | Size (px) | Covers |
|---|---|---|
| `screenshots/iphone-6.3/` | 1206 × 2622 | iPhone with Dynamic Island, medium display (6.1"/6.3"). Required. |
| `screenshots/iphone-6.9/` | 1320 × 2868 | iPhone with Dynamic Island, large display (6.5"–6.9"). Optional. |
| `screenshots/ipad-13/` | 2064 × 2752 | iPad 13" display. Required; used for every iPad size, Apple silicon Mac and Apple Vision Pro. |

Older iPhone and iPad slots were cleared, so those devices scale down from the sets above.

Upload order, the same in every folder:

1. `01-follow-the-needle.png` — compass needle, Light Mode
2. `02-tap-your-destination.png` — map destination picker
3. `03-know-your-pace-count.png` — pace count calculator
4. `04-plan-every-leg.png` — main entry screen
5. `05-day-or-night.png` — compass needle, Dark Mode
6. `06-learn-the-army-method.png` — About screen

The screenshots were captured from the 2.2 build in the iOS Simulator (iPhone 17 Pro Max, iPad Pro 13-inch) with sample values and a 9:41 status bar.
