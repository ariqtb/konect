---
name: Konect Village
colors:
  surface: '#faf8ff'
  surface-dim: '#cfdaf2'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eeff'
  surface-container-high: '#dee8ff'
  surface-container-highest: '#d8e3fb'
  on-surface: '#111c2d'
  on-surface-variant: '#584239'
  inverse-surface: '#263143'
  inverse-on-surface: '#ecf1ff'
  outline: '#8c7167'
  outline-variant: '#dfc0b4'
  surface-tint: '#a53c00'
  primary: '#a53c00'
  on-primary: '#ffffff'
  primary-container: '#ff7a3d'
  on-primary-container: '#652200'
  inverse-primary: '#ffb598'
  secondary: '#ba0035'
  on-secondary: '#ffffff'
  secondary-container: '#e21e49'
  on-secondary-container: '#fffbff'
  tertiary: '#494bd6'
  on-tertiary: '#ffffff'
  tertiary-container: '#9497ff'
  on-tertiary-container: '#1b14b1'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdbcd'
  primary-fixed-dim: '#ffb598'
  on-primary-fixed: '#360f00'
  on-primary-fixed-variant: '#7e2c00'
  secondary-fixed: '#ffdada'
  secondary-fixed-dim: '#ffb3b6'
  on-secondary-fixed: '#40000c'
  on-secondary-fixed-variant: '#920028'
  tertiary-fixed: '#e1e0ff'
  tertiary-fixed-dim: '#c0c1ff'
  on-tertiary-fixed: '#07006c'
  on-tertiary-fixed-variant: '#2f2ebe'
  background: '#f9f9ff'
  on-background: '#111c2d'
  surface-variant: '#d8e3fb'
  container: '#f2f3ff'
  success: '#10b981'
  accent-indigo: '#818cf8'
  accent-rose: '#fb7185'
typography:
  display-lg:
    fontFamily: Outfit
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.025em
  headline-md:
    fontFamily: Outfit
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  title-lg:
    fontFamily: Outfit
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 24px
  body-md:
    fontFamily: Outfit
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Outfit
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  label-caps:
    fontFamily: Outfit
    fontSize: 10px
    fontWeight: '700'
    lineHeight: 12px
    letterSpacing: 0.05em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  margin-page: 1.5rem
  gutter-card: 1rem
  stack-sm: 0.5rem
  stack-md: 1.5rem
  stack-lg: 2.5rem
---

## Brand & Style

**Konect Village** is a "Playful-Tech" design system tailored for community governance and local cooperatives. It balances the reliability required for institutional services with a warm, approachable aesthetic suitable for rural and community contexts. 

The visual style is **Modern-Tactile**, characterized by soft, organic shapes, oversized interactive elements, and a vibrant color palette that avoids clinical "corporate" blues in favor of high-energy warm tones and deep slate neutrals. The UI should evoke feelings of inclusivity, optimism, and ease of use, making technology feel like a helpful neighbor rather than a complex tool. High whitespace and "bubble" card structures are central to the identity.

## Colors

The palette is anchored by **Primary Orange (#FF7A3D)** for branding and **Secondary Rose (#E11D48)** for high-priority actions. 

- **Primary & Secondary:** Used for "hot" interaction points like primary buttons and active indicators.
- **Backgrounds:** The system uses a tinted off-white `surface` (#FAF8FF) rather than pure white to reduce eye strain and feel more "organic." 
- **Containers:** A cool-toned `container` (#F2F3FF) provides subtle contrast for card groupings and input fields.
- **Semantic Accents:** Indigo and Emerald are used for status badges (e.g., "Active" or "Open") to provide clear visual feedback without over-relying on the brand colors.
- **Typography:** Uses Slate-900 for headings to maintain high legibility against the tinted backgrounds.

## Typography

The system utilizes **Outfit** exclusively to ensure a geometric, friendly, and consistent appearance across all hierarchy levels.

- **Headlines:** Use Bold weights with tight tracking (`-0.025em`) to create a strong visual anchor.
- **Body Text:** Primarily uses Medium weights (500) for better legibility on mobile screens against colored backgrounds.
- **Navigation/Labels:** Micro-copy (like bottom navigation) uses All-Caps with increased letter spacing to maintain clarity at very small sizes (10px).
- **Hierarchy:** High contrast in size between Display (30px) and Body (14-16px) is essential to guide the user's eye in data-dense list views.

## Layout & Spacing

Konect Village uses a **Contextual Fluid Grid** optimized for mobile-first consumption.

- **Margins:** Standard page horizontal margin is **24px (1.5rem)**.
- **Horizontal Scrollers:** Used for secondary content (like the "Nearest Coop" list) to maintain vertical density. These should "peek" the next card to indicate scrollability.
- **Section Spacing:** Major sections are separated by large gaps (**40px+**) to avoid visual clutter.
- **Vertical Stack:** Elements within a card or form use an 8px base grid, typically spacing items at 4px, 8px, or 16px intervals.

## Elevation & Depth

Hierarchy is established through **Ambient Shadows** and **Tonal Layering** rather than traditional 3D depth.

- **Primary Surfaces:** Use `card-shadow` (a soft, multi-layered shadow with low opacity: `rgba(0,0,0,0.05)`) to float above the `surface` color.
- **Interactive Containers:** Active states or focus areas use a "sunken" feel or high-contrast borders (Slate-100) to define boundaries.
- **Translucency:** The Bottom Navigation utilizes a `backdrop-blur` (80% opacity) to provide a sense of place and depth as the user scrolls content behind it.
- **Active State:** Buttons and interactive cards should have a subtle scale-down or opacity change on tap to reinforce the tactile nature.

## Shapes

The shape language is **Ultra-Rounded**, bordering on pill-shaped, to maximize the "Playful-Tech" feel.

- **Large Components:** Cards and main sections use `rounded-4xl` (32px).
- **Standard Components:** Buttons and input fields use `rounded-3xl` (24px).
- **Utility:** Badges and status indicators are always fully rounded (pill-shaped).
- **Icons:** Should use a 1.5pt or 2pt stroke weight with rounded caps and joins to match the surrounding container geometry.

## Components

- **Buttons:** 
  - *Primary:* Rose-colored, full-width, 24px corner radius, bold text.
  - *Secondary:* Indigo or Brand Container background with high-contrast text.
- **Input Fields:** 24px rounded corners, white background, 1px Slate-300 border. Use large vertical padding (16px) for high touch-targets.
- **Cards:** 
  - *Hero Card:* Uses a brand-container background with a subtle geometric SVG overlay (opacity 10%) to add visual interest without distracting from content.
  - *Standard Card:* White background, card-shadow, 32px corners, with image header (if applicable).
- **Badges:** Small, pill-shaped, using high-contrast/low-saturation colors (e.g., Indigo-100 background with Indigo-700 text).
- **Bottom Navigation:** Fixed, blurred background, with a "floating" center action button that breaks the top plane of the nav bar for emphasis.
- **Lists:** Rounded list items with trailing chevron icons to indicate drill-down capability.