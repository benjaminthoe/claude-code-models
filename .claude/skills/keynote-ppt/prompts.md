# PPT Studio — Master Prompt Library

## Design Philosophy
Every presentation deck must look like an Apple keynote or Xiaomi product launch, regardless of topic. Every slide has a full-bleed visual. No plain backgrounds. No text-on-black without imagery.

## Audience
Primary: Hong Kong, Korean, Japanese professionals.
All humans in visuals MUST be:
- East Asian (Korean, Japanese, or Chinese appearance)
- Celebrity-level beautiful / handsome
- Well-groomed, stylish, confident
- Age 25-40 unless topic requires otherwise
- Professional but approachable

## Image Generation API
- **Model**: `higgsfield-ai/soul/standard` (text-to-image) or `higgsfield-ai/soul/reference` (face-preserving)
- **Base URL**: `https://platform.higgsfield.ai`
- **Auth**: `Authorization: Key {KEY_ID}:{KEY_SECRET}`
- **Resolution**: Always `1080p`
- **Aspect ratio**: Always `16:9` for slides

---

## MASTER PROMPT FORMULA

Every prompt follows this structure in strict order:

```
[SUBJECT] + [SETTING/ENVIRONMENT] + [CAMERA] + [LIGHTING] + [STYLE] + [QUALITY]
```

### 1. SUBJECT (what's in the image)

**For PEOPLE:**
```
Beautiful [Korean/Japanese/Chinese] [man/woman] in [their 20s/30s],
[specific appearance: hair, skin, expression],
wearing [specific outfit with brand-level detail],
[specific pose or action]
```

**For PRODUCTS:**
```
[Product type] [specific details: color, material, shape],
[position: floating, angled, front view, side profile],
[state: screen glowing, lid open, in use]
```

**For ABSTRACT/TECH:**
```
[Concept visualization], [specific visual metaphor],
[materials: glass, metal, light, particles]
```

### 2. SETTING/ENVIRONMENT

| Category | Prompt Fragment |
|----------|----------------|
| Studio (clean) | `pure black background, nothing else in frame` |
| Studio (warm) | `warm neutral background, subtle gradient` |
| Office | `modern minimalist office with floor-to-ceiling windows, warm wood` |
| Urban HK | `neon-lit Hong Kong street, wet pavement reflections, signage` |
| Urban Seoul | `modern Seoul Gangnam district, glass towers, clean sidewalks` |
| Urban Tokyo | `quiet Tokyo backstreet, lanterns, autumn leaves, minimal` |
| Nature | `lush green forest, dappled sunlight, serene atmosphere` |
| Cafe | `modern specialty coffee shop, warm pendant lights, marble counter` |
| Rooftop | `rooftop terrace overlooking city skyline at blue hour dusk` |
| Abstract | `deep dark space with subtle nebula wisps and light rays` |

### 3. CAMERA MODIFIERS

| Shot Type | Prompt Fragment |
|-----------|----------------|
| Hero wide | `wide shot, 24mm lens, full environment visible` |
| Medium | `medium shot from waist up, 50mm lens` |
| Close-up | `close-up portrait, 85mm lens, shallow depth of field` |
| Extreme CU | `extreme macro close-up, incredible detail` |
| Product | `product photography, centered composition` |
| Overhead | `overhead bird's eye view, flat lay composition` |
| Low angle | `low angle looking up, dramatic perspective` |
| 3/4 angle | `three-quarter view, slight angle` |

### 4. LIGHTING MODIFIERS

| Mood | Prompt Fragment |
|------|----------------|
| Apple keynote | `dramatic single key light from above, deep shadows, rim light` |
| Warm lifestyle | `warm natural window light, soft diffused, golden hour quality` |
| Neon/WKW | `neon sign lighting, warm orange and cool teal, atmospheric` |
| Studio portrait | `butterfly lighting, soft key light, subtle fill, catch lights in eyes` |
| Product | `dramatic side light catching edges, gradient background glow` |
| Moody | `low-key lighting, deep shadows, single light source` |
| Golden hour | `golden hour sunset light, warm amber, lens flare` |
| Blue hour | `blue hour dusk, city lights beginning to glow, purple sky` |

### 5. STYLE MODIFIERS

| Style | Prompt Fragment |
|-------|----------------|
| Cinematic | `cinematic photography, anamorphic lens, film grain` |
| Editorial | `editorial fashion photography, magazine quality` |
| Commercial | `commercial product photography, clean, professional` |
| Lifestyle | `candid authentic lifestyle photography, natural moment` |
| Tech keynote | `Apple keynote style, clean dark background, floating product` |
| Dramatic | `dramatic cinematic, high contrast, bold composition` |
| Minimal | `minimalist composition, generous negative space, clean` |
| Wong Kar-wai | `Wong Kar-wai cinematography, saturated colors, motion blur, step printing` |

### 6. QUALITY MODIFIERS (always append)

```
ultra realistic, 8K, professional photography, high resolution
```

### 7. NEGATIVE PROMPTS (when supported)

```
blurry, distorted, low quality, bad anatomy, deformed, artificial, cartoon,
illustration, painting, sketch, CGI look, uncanny valley, bad lighting
```

---

## SLIDE-TYPE PROMPT TEMPLATES

### Title Slide Background
```
Abstract deep space gradient, dark navy to black with subtle [ACCENT_COLOR]
nebula wisps, a single dramatic beam of white light, Apple WWDC style,
ultra high resolution, 8K
```

### Product Hero
```
[PRODUCT] floating in pure darkness, [ACCENT] edge lighting catching
[MATERIAL] frame, subtle floor reflection below, Apple product photography,
absolutely clean composition, nothing else in frame, 8K ultra realistic
```

### Person / Lifestyle
```
Beautiful [East Asian ethnicity] [gender] in their [age]s, [appearance details],
wearing [outfit], [action], [setting], [camera: 85mm shallow DOF],
[lighting: warm natural/studio], editorial quality lifestyle photography,
8K ultra realistic
```

### Macro / Detail
```
Extreme macro close-up of [subject detail], [specific textures and materials
visible], dramatic studio lighting revealing micro details, dark background,
scientific/product photography, 8K ultra realistic
```

### Tech / Abstract
```
[Concept] visualization, [visual metaphor: circuits, light streams, neural
networks, data flow], [color palette: cool blue and warm gold], futuristic
render, dark background, 8K
```

### Environment / Establishing
```
Cinematic wide shot of [location], [time of day], [atmospheric conditions],
dramatic sky, establishing shot quality, ultra high resolution panoramic
photography, 8K
```

### Comparison / Before-After
```
Split composition, left side [before state] in cool desaturated tones,
right side [after state] in warm vibrant tones, dramatic lighting transition,
commercial photography, 8K
```

---

## COLOR PALETTES BY THEME

### Dark Cinematic (default)
- Background: #08080f
- Accent gradient: indigo → violet → pink (#6366f1 → #8b5cf6 → #ec4899)
- Text: white with 70% secondary, 35% muted

### Apple
- Background: pure #000000
- Accent: #2997ff (Apple blue)
- Text: white with 65% secondary

### Xiaomi / Lei Jun
- Background: #050508
- Accent: #ff6a00 (Xiaomi orange)
- Secondary: #2196f3 (tech blue)
- Text: white with 50% secondary

### Warm Professional
- Background: #0a0908
- Accent: #d4a574 (warm gold)
- Text: warm white #f5f0eb

### Medical / Healthcare
- Background: #060d12
- Accent: #00b4d8 (medical teal)
- Text: clean white

### Finance / Corporate
- Background: #080a0e
- Accent: #3b82f6 (corporate blue)
- Secondary: #10b981 (growth green)

---

## AUDIENCE-SPECIFIC RULES

### Hong Kong (繁體中文)
- Use traditional Chinese characters
- Urban scenes: Victoria Harbour, Central district, neon streets
- Fashion: smart casual, international style
- Aesthetic: cosmopolitan, sophisticated

### Korean (한국어)
- Use Hangul
- Urban scenes: Gangnam, Myeongdong, Han River
- Fashion: K-beauty influenced, trendy, polished
- Aesthetic: clean, bright, youthful sophistication

### Japanese (日本語)
- Use Kanji/Hiragana/Katakana
- Urban scenes: Shibuya, quiet backstreets, temples
- Fashion: minimal, understated luxury
- Aesthetic: wabi-sabi meets modern, restrained elegance

---

## PROMPT EXAMPLES BY SLIDE POSITION

### Slide 1 (Title)
```
Abstract deep space gradient background, dark navy blue to black with subtle
purple and blue nebula wisps, a single dramatic beam of white light cutting
diagonally, Apple WWDC keynote style, ultra high resolution 8K
```

### Slide 2 (Product Hero)
```
Modern smartphone floating in pure black void, front view showing
edge-to-edge OLED display with colorful wallpaper glowing, titanium frame
catching dramatic side light, subtle floor reflection, Apple product
photography style, 8K ultra realistic render
```

### Slide 3 (Statement + Human)
```
Beautiful Korean woman in her late 20s, flawless skin, natural makeup,
wearing elegant white blazer, confident smile looking at camera, modern
glass office background with city view, 85mm portrait lens, butterfly
lighting with warm fill, editorial fashion photography, 8K ultra realistic
```

### Slide 4 (Tech Detail)
```
Extreme macro close-up of microprocessor chip die, silicon wafer surface
with intricate circuit patterns, cool blue and warm gold details, dramatic
studio lighting, dark background, 8K scientific photography
```

### Slide 5 (Lifestyle)
```
Handsome Japanese man in his 30s, stylish dark hair, wearing premium
navy coat, using smartphone while walking through quiet Tokyo backstreet
at golden hour, warm amber light, 50mm lens shallow depth of field,
cinematic lifestyle photography, 8K
```

### Slide 6 (Data/Stats Background)
```
Abstract data visualization, streams of glowing blue light particles
flowing through dark space, neural network nodes connected by light
threads, futuristic and clean, dark background, 8K render
```

### Slide 7 (Team/Group)
```
Group of four attractive East Asian professionals in their 30s (2 men,
2 women), collaborating around modern glass table with laptops, warm
pendant lighting, modern creative office, candid authentic interaction,
medium wide shot, warm natural light, editorial photography, 8K
```

### Slide 8 (Full-Bleed Environment)
```
Cinematic aerial view of Hong Kong Victoria Harbour at blue hour dusk,
skyscrapers reflecting in water, dramatic purple and orange sky, city
lights glowing, ultra wide panoramic shot, 8K cinematic photography
```

### Slide 9 (Closing)
```
Single spotlight on dark stage, soft warm glow expanding outward,
abstract bokeh light particles floating, Apple keynote closing slide
atmosphere, minimal and dramatic, 8K
```
