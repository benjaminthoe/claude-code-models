# AI Image Prompt Engineering Guide
## Cinematic Keynote-Quality Visuals -- 2026 Edition

> A complete prompt formula system for generating professional, photorealistic, cinematic images
> across any AI model (FLUX Pro, Midjourney V7, Stable Diffusion, ChatGPT/DALL-E, Ideogram).

---

## TABLE OF CONTENTS

1. [The Universal Prompt Formula](#1-the-universal-prompt-formula)
2. [Subject Description Structure](#2-subject-description-structure)
3. [Camera and Lens Modifiers](#3-camera-and-lens-modifiers)
4. [Lighting Modifiers](#4-lighting-modifiers)
5. [Style Modifiers](#5-style-modifiers)
6. [Quality Modifiers](#6-quality-modifiers)
7. [Color Grading Modifiers](#7-color-grading-modifiers)
8. [Composition Modifiers](#8-composition-modifiers)
9. [Negative Prompt Best Practices](#9-negative-prompt-best-practices)
10. [7 Ready-Made Prompt Formulas](#10-seven-ready-made-prompt-formulas)
11. [Regional Aesthetic Profiles](#11-regional-aesthetic-profiles)
12. [Model-Specific Tips](#12-model-specific-tips)
13. [Prompt Length Guidelines](#13-prompt-length-guidelines)
14. [Quick-Reference Cheat Sheet](#14-quick-reference-cheat-sheet)

---

## 1. THE UNIVERSAL PROMPT FORMULA

Every professional AI image prompt follows this five-layer architecture. Word order matters --
models pay the most attention to what comes first.

```
[SUBJECT + Specific Details] + [ENVIRONMENT + Context] + [CAMERA + Lens] + [LIGHTING] + [STYLE + QUALITY + COLOR]
```

### Priority Order (First = Highest Weight)

| Priority | Layer              | What to Write                                    |
|----------|--------------------|--------------------------------------------------|
| 1        | Subject            | Who/what, age, clothing, expression, pose, action |
| 2        | Environment        | Where, time of day, weather, atmosphere           |
| 3        | Camera + Lens      | Focal length, aperture, camera body, angle        |
| 4        | Lighting           | Source, direction, quality, color temperature      |
| 5        | Style + Quality    | Genre, resolution, color grade, film stock         |

### The One-Line Template

```
[Detailed subject description], [environment/setting], [camera/lens specs], [lighting setup], [style], [quality keywords], [color grading]
```

---

## 2. SUBJECT DESCRIPTION STRUCTURE

The subject is the most important element. Be specific -- replace vague nouns with concrete details.

### Bad vs. Good

| Bad                      | Good                                                                                               |
|--------------------------|----------------------------------------------------------------------------------------------------|
| A woman                  | A confident woman in her late 20s with shoulder-length black hair, wearing a tailored navy blazer   |
| A product on a table     | A matte black perfume bottle on polished dark slate, water droplets on the glass surface            |
| A city at night          | Rain-slicked Kowloon street corner with vertical neon signs reflecting off wet asphalt              |

### Subject Description Checklist

For **people**:
- Age range and gender
- Hair (length, color, style)
- Skin detail (for realism: natural skin texture, visible pores, subtle imperfections)
- Clothing (material, color, fit, brand level)
- Expression and gaze direction (looking at camera, looking away, contemplative)
- Pose and body language (confident posture, leaning forward, hands in pockets)
- Accessories and props

For **products**:
- Material and finish (matte, glossy, brushed aluminum, frosted glass)
- Color and texture detail
- Size context and scale cues
- Surface interactions (reflections, water drops, condensation, fingerprints)

For **scenes**:
- Foreground, midground, background elements
- Atmospheric effects (fog, rain, dust motes, steam)
- Time of day and season
- Human presence or absence

---

## 3. CAMERA AND LENS MODIFIERS

Camera and lens specifications signal to the AI that you want photography, not illustration.
These are among the highest-leverage modifiers available.

### Camera Bodies (Style Signals)

| Camera Body            | What It Signals                                          |
|------------------------|----------------------------------------------------------|
| Canon EOS R5           | Modern digital, clean, high dynamic range                |
| Sony A7IV              | Sharp, clinical, excellent low-light                     |
| Hasselblad X2D         | Medium format, creamy rendering, fashion/editorial       |
| Phase One IQ4          | Ultra-high resolution, commercial, luxury                |
| Canon 5D Mark IV       | Reliable workhorse, balanced, versatile                  |
| Fujifilm X-T5          | Film-like color science, organic tones                   |
| Leica M11              | Rangefinder character, street photography, classic        |
| Nikon Z9               | Sports/action, fast, precise autofocus                   |

### Focal Length Guide

| Focal Length   | Best For                            | Visual Character                          |
|----------------|-------------------------------------|-------------------------------------------|
| 14-24mm        | Architecture, landscapes, interiors | Dramatic perspective, wide establishing    |
| 24-35mm        | Environmental portraits, street     | Context + subject, slight wide feel        |
| 35mm           | Street, documentary, editorial      | Natural perspective, honest framing        |
| 50mm           | Standard portraits, lifestyle       | Closest to human eye, versatile            |
| 85mm           | Portraits, beauty, headshots        | Flattering compression, beautiful bokeh    |
| 100-135mm      | Beauty, tight portraits, fashion    | Strong compression, subject isolation      |
| 200mm+         | Sports, wildlife, compressed scenes | Extreme compression, flat perspective      |
| Macro 100mm    | Product detail, jewelry, textures   | Extreme close-up, shallow depth            |

### Aperture and Depth of Field

| Aperture    | Effect                                     | Use Case                              |
|-------------|---------------------------------------------|---------------------------------------|
| f/1.2-f/1.8 | Extreme bokeh, razor-thin focus             | Dreamy portraits, subject isolation   |
| f/2.0-f/2.8 | Beautiful bokeh, subject clearly separated  | Professional portraits, product hero  |
| f/4.0-f/5.6 | Moderate depth, good balance                | Editorial, environmental portraits    |
| f/8.0-f/11  | Deep focus, sharp front to back             | Product flat lays, architecture       |
| f/16-f/22   | Maximum depth of field                      | Landscapes, architectural detail      |

### Camera Angle Keywords

```
eye-level shot         -- neutral, conversational
low angle shot         -- powerful, heroic, imposing
high angle shot        -- vulnerable, overview, contextual
bird's eye view        -- overhead, graphic, pattern
worm's eye view        -- extreme low, dramatic, towering
Dutch angle            -- tension, unease, dynamic energy
over-the-shoulder      -- intimate, relational, POV
three-quarter view     -- slightly above and to the side, dimensional
close-up               -- detail, emotion, intensity
extreme close-up       -- texture, abstraction, eyes
medium shot            -- waist up, conversational
wide establishing shot -- context, scale, environment
```

### Example Camera Strings

```
shot on Canon EOS R5, 85mm f/1.8 lens, shallow depth of field
shot on Hasselblad X2D, 80mm lens at f/2.8, medium format
shot on Fujifilm X-T5, 35mm f/1.4, natural color science
shot on Sony A7IV, 24-70mm at 50mm, clean sharp, high dynamic range
macro shot, Canon 100mm f/2.8L, extreme close-up, f/4.0
```

---

## 4. LIGHTING MODIFIERS

Lighting has the single greatest impact on image quality and mood. Describe it as you would
when briefing a professional photographer.

### Natural Lighting

```
golden hour sunlight               -- warm, directional, long shadows, magic hour
blue hour light                    -- cool, twilight, ambient, moody
soft overcast daylight             -- even, diffused, no harsh shadows
dappled forest light               -- filtered through leaves, organic patterns
harsh midday sun                   -- high contrast, strong shadows, bright
backlit / contre-jour              -- rim of light behind subject, halo effect
window light from the left         -- soft, directional, painterly
reflected light off water          -- shimmering, dynamic, dancing highlights
```

### Studio Lighting

```
three-point lighting setup         -- standard professional: key + fill + back
softbox lighting                   -- soft, even, commercial
Rembrandt lighting                 -- triangle of light under eye, dramatic portrait
butterfly lighting                 -- shadow under nose, beauty/fashion standard
rim lighting / edge lighting       -- glowing outline, separation from background
split lighting                     -- half face lit, half in shadow, dramatic
clamshell lighting                 -- beauty dish above + reflector below
ring light                         -- even, flat, catchlights in eyes
high-key lighting                  -- bright, minimal shadows, clean
low-key lighting                   -- dark, dramatic, single source
```

### Cinematic and Atmospheric Lighting

```
volumetric lighting                -- visible light rays, god rays, atmosphere
neon lighting                      -- colorful, urban, cyberpunk
practical lighting                 -- visible light sources in frame (lamps, screens)
chiaroscuro                        -- extreme light/dark contrast, Renaissance drama
film noir lighting                 -- hard shadows, venetian blinds, mystery
anamorphic lens flare              -- horizontal streaks, cinematic warmth
spotlight / pool of light          -- isolated illumination, theatrical
candlelight                        -- warm, flickering, intimate
LED panel / mixed color temp       -- modern, editorial, color contrast
```

### Lighting Direction Modifiers

```
front lighting                     -- flat, even, safe
side lighting (from left/right)    -- texture, dimension, drama
top lighting / overhead            -- fashion, mysterious, downward shadows
under lighting                     -- eerie, horror, unnatural
backlighting                       -- silhouette, rim, ethereal
45-degree key light                -- standard portrait, flattering
```

---

## 5. STYLE MODIFIERS

Style modifiers define the genre and artistic intention of the image.

### Photography Genres

```
editorial photography              -- magazine quality, styled, storytelling
commercial photography             -- product-forward, polished, advertising
fashion photography                -- high-end, styled, runway/campaign
street photography                 -- candid, urban, documentary
portrait photography               -- face-focused, character, connection
lifestyle photography              -- natural, relatable, aspirational
fine art photography               -- conceptual, gallery, artistic intent
documentary photography            -- authentic, raw, journalistic
beauty photography                 -- close-up, skin detail, cosmetic
architectural photography          -- lines, geometry, structure
food photography                   -- appetizing, styled, overhead or 45-degree
product photography                -- clean, isolated, commercial
```

### Cinematic Styles

```
cinematic film still               -- like a paused movie frame, widescreen
anamorphic cinematography          -- horizontal flares, oval bokeh, 2.39:1
indie film aesthetic                -- natural, imperfect, authentic
blockbuster visual style           -- epic scale, VFX quality, dramatic
film noir                          -- high contrast B&W, shadows, mystery
neo-noir                           -- modern noir, neon, color shadows
Wes Anderson style                 -- symmetrical, pastel, whimsical
Wong Kar-wai style                 -- neon-drenched, motion blur, saturated
David Fincher aesthetic             -- desaturated, yellow-green cast, clinical
Blade Runner 2049 aesthetic        -- vast, orange/teal, atmospheric
```

### Era Styles

```
modern digital                     -- clean, sharp, high dynamic range
2000s digicam style                -- slight noise, flash, candid, lo-fi
90s film aesthetic                  -- grain, warm cast, slightly faded
80s vintage photo                  -- heavy grain, warm tones, soft focus
70s analog                         -- expired film look, brown/orange tones
Polaroid instant film              -- white border, washed, nostalgic
black and white film               -- timeless, high contrast, classic
```

### Film Stock References (for Color Character)

```
shot on Kodak Portra 400           -- warm, natural skin tones, organic
shot on Fujifilm Pro 400H          -- cooler tones, greens, editorial
shot on Kodak Ektar 100            -- saturated, vivid, punchy colors
shot on Ilford HP5 Plus            -- classic B&W, beautiful grain
shot on CineStill 800T             -- tungsten balanced, halation, cinema
shot on Kodachrome                 -- rich, saturated, nostalgic warmth
shot on expired Kodak Gold 200     -- unpredictable, warm shifts, vintage
```

---

## 6. QUALITY MODIFIERS

Quality keywords act as a resolution and detail slider. Stack 2-4 from different categories.

### Resolution and Detail

```
8K resolution                      -- maximum detail signal
ultra high definition              -- crisp, clean rendering
hyper-detailed                     -- extreme fine detail
DSLR quality                       -- photographic realism
RAW photo                          -- unprocessed, full dynamic range
ultra realistic                    -- pushes toward photorealism
photorealistic                     -- indistinguishable from a photo
high dynamic range (HDR)           -- full tonal range, no crushed shadows
sharp focus                        -- tack sharp, no softness
```

### Texture and Realism

```
natural skin texture               -- pores, imperfections, subsurface
visible pores                      -- extreme skin detail
detailed fabric weave              -- clothing texture realism
subtle subsurface scattering       -- light passing through skin/materials
natural film grain                 -- organic, analog feel
micro-detail                       -- fine texture in all surfaces
wet surface detail                 -- reflections, droplets, sheen
```

### Professional Quality Signals

```
professional photography           -- high-end studio output
commercial quality                 -- advertising-ready polish
editorial quality                  -- magazine-worthy
award-winning photograph           -- exceptional quality signal
medium format quality              -- the look of large sensor cameras
retouched                          -- polished, commercial-ready
color graded                       -- post-production color treatment
delivery ready                     -- final, polished output
```

### Render Engine Keywords (for 3D/product work)

```
octane render                      -- photorealistic 3D rendering
corona render                      -- architectural visualization
Unreal Engine 5                    -- game-engine realism
ray tracing                        -- accurate light simulation
physically based rendering (PBR)   -- material-accurate rendering
```

---

## 7. COLOR GRADING MODIFIERS

Color grading controls mood and emotional tone. Describe color the way a colorist would.

### Warm Palettes

```
warm golden tones                  -- cozy, nostalgic, inviting
amber and honey highlights         -- rich warmth, sunset feel
warm peachy highlights             -- romantic, soft, dreamy
golden hour color grade            -- warm directional, long shadows
warm desaturated                   -- muted warmth, analog feel
earth tones                        -- brown, olive, terracotta, natural
```

### Cool Palettes

```
cool blue undertones               -- clinical, modern, serious
teal and blue shadows              -- cinematic, moody
icy blue highlights                -- cold, winter, stark
moonlit blue                       -- nighttime, ethereal, quiet
steel blue desaturated             -- Nordic, industrial, clean
```

### Cinematic Color Grades

```
teal and orange color grade        -- the Hollywood standard, high contrast
orange and teal split toning       -- warm highlights + cool shadows
Blade Runner 2049 orange/teal     -- atmospheric, vast, dystopian
David Fincher yellow-green cast    -- clinical, thriller, unsettling
desaturated with green tint        -- psychological tension
Nordic noir cold blue              -- bleak, minimal saturation
```

### Mood-Specific Grades

```
moody shadows, lifted blacks       -- film-like, never pure black
high contrast, deep blacks         -- punchy, dramatic, bold
faded blacks and warm whites       -- vintage, nostalgic
pastel soft tones                  -- dreamy, gentle, editorial
vibrant saturated colors           -- punchy, energetic, commercial
muted earth tones                  -- understated, organic, calm
rich jewel tones                   -- deep emerald, sapphire, ruby, luxury
monochromatic palette              -- single hue variations, cohesive
split complementary                -- sophisticated color tension
```

### Color Temperature Keywords

```
warm color temperature (3200K)     -- tungsten, indoor, golden
neutral color temperature (5600K)  -- daylight balanced, natural
cool color temperature (7500K)     -- overcast, shade, blue tint
mixed color temperature            -- multiple sources, visual tension
```

---

## 8. COMPOSITION MODIFIERS

Composition must be explicitly written into AI prompts -- it will not happen automatically.

### Framing and Placement

```
rule of thirds composition         -- subject on grid intersection, dynamic
centered composition               -- subject dead center, powerful, symmetrical
symmetrical composition            -- mirror balance, formal, architectural
asymmetric composition             -- intentional imbalance, dynamic tension
negative space on the right        -- breathing room, editorial feel
subject in the left third          -- creates visual movement to the right
tight crop                         -- fills frame, intensity, detail
loose framing                      -- breathing room, context, environmental
full bleed                         -- edge to edge, no border, immersive
```

### Depth and Layers

```
foreground interest                -- elements in front of subject, depth
layered composition                -- distinct foreground/mid/background
leading lines                      -- lines drawing eye to subject
depth through atmospheric haze     -- sense of distance and scale
shallow depth separating layers    -- bokeh creating depth planes
frame within a frame               -- doorway, window, arch framing subject
```

### Dynamic Composition

```
dynamic diagonal movement          -- energy, action, visual flow
S-curve composition                -- elegant, flowing, draws the eye
triangular composition             -- stable, classic, three focal points
golden ratio / spiral              -- natural proportion, harmonious
radial composition                 -- lines radiating from center
vanishing point perspective        -- depth, architectural, dramatic
```

### Aspect Ratio Keywords

```
16:9 widescreen                    -- cinematic, presentation, film
2.39:1 anamorphic widescreen       -- ultra-cinematic, letterbox
4:3 classic                        -- traditional, intimate
1:1 square                         -- Instagram, balanced, graphic
9:16 vertical                      -- stories, mobile, portrait
3:2 standard photo                 -- DSLR native, versatile
```

---

## 9. NEGATIVE PROMPT BEST PRACTICES

> **Important**: FLUX Pro and some newer models do NOT support negative prompts.
> For those models, focus entirely on describing what you want. Use negative prompts
> only with Stable Diffusion, Midjourney (--no flag), and models that support them.

### Universal Negative Prompt (Stable Diffusion)

```
low quality, worst quality, normal quality, lowres, jpeg artifacts, blurry,
noisy, ugly, deformed, disfigured, mutated, bad anatomy, bad hands,
extra fingers, fewer fingers, extra limbs, poorly drawn hands,
poorly drawn face, long neck, cross-eyed, malformed limbs,
missing arms, missing legs, extra arms, extra legs, fused fingers,
too many fingers, poorly drawn, watermark, text, signature,
out of frame, cropped, duplicate
```

### Category-Specific Negatives

**For portraits:**
```
deformed eyes, asymmetric eyes, deformed iris, extra fingers, mutated hands,
bad teeth, unnatural skin, plastic skin, airbrushed, mannequin-like,
uncanny valley, wax figure, distorted proportions
```

**For product photography:**
```
blurry, out of focus, distorted perspective, warped edges,
inconsistent shadows, floating objects, unrealistic reflections,
low resolution texture, smudged details
```

**For cinematic scenes:**
```
flat lighting, overexposed, underexposed, color banding,
visible noise, lens distortion, chromatic aberration,
unrealistic physics, impossible geometry
```

### Midjourney Negative Syntax

```
--no text, watermark, logo, blurry, low quality, deformed hands
```

### Weighted Negatives (Stable Diffusion)

```
(blurry:1.3), (bad hands:1.5), (extra fingers:1.4), (deformed:1.3)
```

Higher weights more aggressively avoid those specific artifacts.

### Pro Tip: Positive Prompting Over Negative

In most modern models (2026), positive prompting is more effective than negative prompting.
Instead of saying "no blurry," say "tack sharp focus, crisp detail."
Instead of "no bad hands," describe "detailed hands with natural finger positions."

---

## 10. SEVEN READY-MADE PROMPT FORMULAS

### Formula 1: Cinematic Portrait

```
Cinematic portrait of [SUBJECT: age, ethnicity, hair, clothing, expression],
[ENVIRONMENT: location, time, weather, atmosphere],
shot on [CAMERA] [FOCAL LENGTH] at [APERTURE],
[LIGHTING: type, direction, quality],
cinematic film still, [COLOR GRADE], 8K, photorealistic,
natural skin texture, shallow depth of field
```

**Example:**
```
Cinematic portrait of a confident East Asian woman in her late 20s with sleek
jaw-length black hair, wearing a structured charcoal wool coat, looking directly
at camera with a subtle knowing expression, standing on a rain-slicked Tokyo
street at blue hour with neon reflections on wet asphalt, shot on Canon EOS R5
85mm f/1.8, soft rim lighting from neon signs with cool blue fill light,
cinematic film still, teal and orange color grade, 8K, photorealistic,
natural skin texture, shallow depth of field, moody atmosphere
```

### Formula 2: Product Hero Shot

```
Commercial product photography of [PRODUCT: material, color, finish, details],
[SURFACE/ENVIRONMENT: texture, color, context],
[CAMERA: macro or standard, lens, aperture],
[LIGHTING: softbox/studio setup, direction],
[STYLE: commercial, editorial, luxury], [QUALITY: 8K, sharp focus],
clean background, professional color grading
```

**Example:**
```
Commercial product photography of a matte black titanium smartwatch with
sapphire crystal face showing a minimal white dial, resting on polished dark
slate with subtle water droplets, shot with macro lens at f/2.8, three-point
softbox lighting with dramatic rim light from behind, luxury commercial style,
8K, tack sharp focus, clean dark gradient background, warm neutral color grading
```

### Formula 3: Editorial / Fashion

```
Editorial fashion photography of [SUBJECT: model description, outfit, pose],
[SETTING: studio or location, props, context],
shot on [CAMERA: Hasselblad/Phase One for fashion] [LENS] at [APERTURE],
[LIGHTING: butterfly/beauty dish/dramatic],
high fashion editorial, [FILM STOCK or color style], magazine quality,
retouched, [COMPOSITION: centered/rule of thirds]
```

**Example:**
```
Editorial fashion photography of a tall elegant East Asian model in her early
20s wearing an avant-garde white sculptural dress, standing in a vast minimalist
white studio with dramatic shadow play on the floor, shot on Hasselblad X2D
100mm at f/4.0, butterfly lighting from a large octabox with subtle rim light,
high fashion editorial, shot on Fujifilm Pro 400H color science, magazine
quality, retouched, centered symmetrical composition, 8K
```

### Formula 4: Cinematic Scene / Film Still

```
Cinematic film still from a [GENRE] film,
[SUBJECT performing ACTION] in [DETAILED ENVIRONMENT],
[CAMERA ANGLE], shot on [CAMERA] [LENS: anamorphic for cinema],
[LIGHTING: motivated, practical, volumetric],
[COLOR PALETTE/GRADE], [ASPECT RATIO],
[ATMOSPHERIC EFFECTS: fog, rain, dust],
cinematic, photorealistic, 8K
```

**Example:**
```
Cinematic film still from a neo-noir thriller, a lone figure in a dark overcoat
walking through a narrow Hong Kong alley filled with vertical neon signs and
steam rising from street vents, low angle shot, shot on Arri Alexa with
anamorphic Cooke lens, neon practical lighting with volumetric fog and wet
surface reflections, teal and orange color grade with deep crushed blacks,
2.39:1 anamorphic widescreen, rain and atmospheric haze, cinematic,
photorealistic, 8K
```

### Formula 5: Lifestyle / Brand Campaign

```
Lifestyle photography of [SUBJECT: real, relatable description],
[ACTIVITY/MOMENT: natural, candid action],
[ENVIRONMENT: aspirational but authentic setting],
shot on [CAMERA] [LENS: 35-50mm for natural feel] at [APERTURE: f/2.8-f/4],
[LIGHTING: natural, golden hour, window light],
lifestyle brand campaign style, warm color grading,
natural and authentic, editorial quality, 8K
```

**Example:**
```
Lifestyle photography of a young creative professional in his early 30s wearing
a simple white linen shirt, laughing genuinely while pouring coffee in a
sun-filled modern apartment kitchen with plants and natural wood accents,
shot on Fujifilm X-T5 35mm f/2.0, warm morning window light streaming from
the left with soft natural fill, lifestyle brand campaign style, warm golden
tones with lifted shadows, natural and authentic, editorial quality, 8K
```

### Formula 6: Architecture / Interior

```
Architectural photography of [BUILDING/SPACE: style, materials, era],
[DETAILS: key design features, materials, geometry],
[TIME OF DAY: golden hour, blue hour, twilight],
shot on [CAMERA] [LENS: 14-24mm ultra-wide] at [APERTURE: f/8-f/11],
[LIGHTING: natural + architectural lighting],
architectural digest style, [COLOR GRADE],
sharp focus throughout, symmetrical composition, 8K
```

**Example:**
```
Architectural photography of a mid-century modern glass pavilion with
floor-to-ceiling windows, exposed concrete columns, and warm walnut interior
panels, surrounded by a reflecting pool at golden hour with warm light
streaming through the glass creating long shadows on polished concrete floors,
shot on Sony A7IV 16-35mm at f/8.0, natural golden hour light supplemented
by warm interior lighting, architectural digest style, warm amber tones with
cool blue sky contrast, sharp focus throughout, symmetrical composition, 8K
```

### Formula 7: Tech / Keynote Product Visual

```
[PRODUCT] floating/displayed in [ABSTRACT or MINIMAL ENVIRONMENT],
[ANGLE: three-quarter, hero angle, overhead],
shot with [CAMERA SPECS for product],
[LIGHTING: dramatic studio, gradient background],
Apple keynote presentation style, clean minimal aesthetic,
[MATERIAL DETAILS: glass, aluminum, ceramic],
professional product visualization, 8K, sharp focus,
[BACKGROUND: dark gradient, pure black, soft gradient]
```

**Example:**
```
Next-generation wireless earbuds in matte white ceramic finish with rose gold
accents, floating at a slight three-quarter angle against a deep dark gradient
background transitioning from charcoal to pure black, dramatic studio lighting
with a soft key light from above-left and subtle rim light creating material
definition, Apple keynote presentation style, clean minimal aesthetic, visible
ceramic texture and metallic sheen, professional product visualization, 8K,
tack sharp focus, subtle reflection below
```

---

## 11. REGIONAL AESTHETIC PROFILES

### Korean Beauty / K-Beauty Aesthetic

The Korean aesthetic emphasizes luminous, translucent skin and soft elegance.

```
KEY MODIFIERS:
glass skin, dewy complexion          -- luminous, poreless, translucent
soft diffused lighting                -- no harsh shadows, gentle glow
V-line face, aegyo sal highlights     -- beauty standard features
pastel color palette                  -- soft pink, lavender, mint
subtle blush, gradient lips           -- understated makeup style
bright, airy background              -- clean, high-key, minimal
soft glow, ethereal atmosphere        -- dreamy, romantic quality
K-beauty editorial style              -- magazine-quality, polished
shot on Canon EOS R5 85mm f/2.0      -- flattering portrait lens
warm soft fill light                  -- even, youthful illumination
```

**Example prompt:**
```
K-beauty editorial portrait of a young Korean woman in her early 20s with
glass skin and dewy complexion, soft wavy dark brown hair framing her face,
wearing a cream cashmere turtleneck, subtle gradient pink lips and natural
makeup with aegyo sal highlight, looking softly at camera, bright airy studio
with pastel pink background, shot on Canon EOS R5 85mm f/2.0, soft diffused
beauty lighting with warm fill, ethereal soft glow atmosphere, K-beauty
editorial style, pastel color palette, 8K, natural skin texture with luminous
finish
```

### Japanese Aesthetic

Japanese visual culture spans from wabi-sabi imperfection to ultra-precise minimalism.

```
WABI-SABI / MOODY:
wabi-sabi aesthetic                   -- beauty in imperfection, weathered
muted earth tones                     -- moss green, warm gray, aged brown
natural patina and texture            -- worn wood, rust, aged surfaces
soft overcast light                   -- gentle, diffused, contemplative
intentional negative space            -- ma (space between), breathing room
film grain, slightly soft focus       -- analog, imperfect, human
shot on Fujifilm X-T5                 -- Japanese color science
subtle, understated elegance          -- restraint over spectacle

CLEAN / MODERN:
Japanese minimalist aesthetic         -- clean lines, precision, harmony
muji-inspired clean palette           -- white, natural wood, light gray
geometric precision                   -- orderly, balanced, intentional
natural light, shadow play            -- light as design element
ultra-clean composition               -- every element purposeful
zen garden tranquility                -- calm, contemplative, sparse
```

**Example prompt:**
```
Japanese wabi-sabi photography of an elegant woman in her 30s with a simple
black linen dress, standing in a weathered wooden temple corridor with aged
wood grain and moss-covered stone, late afternoon overcast light filtering
through paper shoji screens creating soft diffused illumination, shot on
Fujifilm X-T5 50mm f/2.0, muted earth tones with subtle warm undertones,
intentional negative space, natural film grain, quiet contemplative mood,
wabi-sabi aesthetic, 8K
```

### Hong Kong Urban Cinematography

Hong Kong's visual identity fuses dense urban energy, neon saturation, and cinematic legacy.

```
KEY MODIFIERS:
neon-drenched Hong Kong streets       -- vertical signs, color saturation
dense urban layering                  -- tight alleys, stacked buildings
wet asphalt reflections               -- rain-slicked surfaces, neon mirrors
Wong Kar-wai inspired                 -- motion blur, saturated color
step-printing / smeared motion        -- fractured, dreamlike movement
Chungking Express aesthetic           -- neon, intimate, melancholic
vertical neon signage                 -- Chinese characters, warm glow
teal and neon pink color palette      -- cyberpunk meets old Hong Kong
steam and atmospheric haze            -- food stalls, vents, humidity
shot on CineStill 800T               -- tungsten film, halation glow
crowded, chaotic, alive               -- human density, energy
narrow depth of field                 -- isolating subject in chaos
```

**Example prompt:**
```
Cinematic Hong Kong street photography at night, a young woman in a red
qipao-inspired jacket standing beneath layers of vertical neon signs in a
narrow Kowloon alley, rain-slicked asphalt reflecting pink and teal neon,
steam rising from a street food stall, shot on Leica M11 35mm f/1.4 with
CineStill 800T film aesthetic, Wong Kar-wai inspired neon-drenched color
with motion blur on passing pedestrians, teal and magenta color grade with
deep warm shadows, cinematic 2.39:1 framing, atmospheric haze, 8K
```

---

## 12. MODEL-SPECIFIC TIPS

### FLUX Pro / FLUX 2

- Uses natural language processing (Mistral-3 vision-language model) -- write like you are talking to a person, not keyword stuffing
- Optimal prompt length: 12-25 words for realism, 30-80 words for complex scenes
- Does NOT support negative prompts -- describe only what you want
- Word order matters heavily -- put the most important element first
- Camera/lens specifications have very strong influence on output
- Film stock references work exceptionally well (Kodak Portra 400, CineStill 800T)
- Framework: Subject + Action + Style + Context

### Midjourney V7

- Understands natural language better than V6 -- less keyword stuffing needed
- Use --ar for aspect ratio (--ar 16:9, --ar 2.39:1)
- Use --no for excluding elements (--no text --no watermark)
- Use --style raw for less Midjourney default stylization
- Use --s (stylize) parameter: low (0-100) = literal, high (500-1000) = artistic
- V7 handles photorealism very well with camera specifications
- Concise prompts often outperform long ones

### Stable Diffusion (SDXL / SD3)

- Supports full negative prompts -- use them for artifact control
- Weighted terms: (important keyword:1.3) for emphasis
- Negative prompt is critical for quality: always include quality negatives
- Benefits from explicit quality keywords more than other models
- CFG scale affects prompt adherence (7-12 is typical range)
- Step count matters: 30-50 steps for quality output

### ChatGPT / DALL-E / GPT-4o Image Gen

- Excels with natural language descriptions
- Good at following complex scene descriptions
- Handles text rendering better than most models
- Describe scenes in full sentences, not keyword lists
- Responds well to genre and style references
- Use specific and detailed prompts for best results

### Ideogram

- Excellent at typography and text in images
- Good photorealism with explicit camera specifications
- Use "photo of" prefix for photorealistic output
- Handles complex compositions well
- Magic Prompt feature can enhance basic prompts

### Higgsfield Soul (Video)

- Lead with Soul ID first, then add style cues
- Be specific about lighting (softbox, rim light, golden hour, overcast)
- Use cinematic language: tracking, zooming, pan, low angle
- Keep descriptions concise -- avoid redundancy
- Use presets when available (tuned for Soul 2.0)
- Balance detail and clarity -- overly complex prompts produce generic results
- Use Optimize Prompt feature for consistency

---

## 13. PROMPT LENGTH GUIDELINES

| Length           | Word Count | Best For                                  | Models That Prefer |
|------------------|-----------|-------------------------------------------|--------------------|
| Short            | 10-30     | Quick concepts, style exploration         | FLUX (realism)     |
| Medium (Ideal)   | 30-75     | Most professional work, portraits         | All models         |
| Long             | 75-120    | Complex scenes, multiple subjects         | SD, ChatGPT        |
| Very Long        | 120+      | Ultra-specific scenes (diminishing returns) | ChatGPT only      |

### The 80/20 Rule

The five core elements (Subject, Environment, Camera, Lighting, Quality) produce 80% of the
result. Everything beyond that produces diminishing returns. Nail those five first, then refine.

---

## 14. QUICK-REFERENCE CHEAT SHEET

### Copy-Paste Starter Blocks

**Portrait Starter:**
```
[subject description], shot on Canon EOS R5 85mm f/1.8, soft natural light from the left with gentle fill, shallow depth of field, photorealistic, 8K, natural skin texture, cinematic color grading
```

**Product Starter:**
```
[product description] on [surface], shot with macro lens at f/2.8, three-point studio lighting with softbox key light, commercial product photography, 8K, sharp focus, clean background, professional color grading
```

**Cinematic Starter:**
```
Cinematic film still, [scene description], shot on Arri Alexa with anamorphic lens, [lighting], teal and orange color grade, 2.39:1 widescreen, atmospheric, photorealistic, 8K
```

**Editorial Starter:**
```
Editorial photography, [subject in setting], shot on Hasselblad X2D [focal length] at [aperture], [lighting], editorial magazine quality, [film stock], retouched, 8K
```

**Keynote Visual Starter:**
```
[product/concept] against [dark/clean gradient background], dramatic studio lighting, Apple keynote presentation style, clean minimal aesthetic, professional product visualization, 8K, sharp focus
```

### Top 10 Modifiers for Instant Quality Boost

1. `shot on [specific camera + lens + aperture]`
2. `8K, photorealistic`
3. `natural skin texture` (for people)
4. `shallow depth of field` (for subject separation)
5. `cinematic color grading`
6. `[specific lighting direction] with [quality descriptor]`
7. `tack sharp focus`
8. `natural film grain` (for analog feel)
9. `volumetric lighting` (for atmosphere)
10. `rule of thirds composition` (for dynamic framing)

### Lighting Quick Picks by Mood

| Mood          | Lighting Combo                                         |
|---------------|--------------------------------------------------------|
| Professional  | Three-point softbox + rim light, neutral color temp    |
| Romantic      | Golden hour backlight + warm fill, f/1.8 bokeh         |
| Dramatic      | Single hard side light + deep shadows, low-key         |
| Mysterious    | Volumetric fog + rim light from behind, cool blue      |
| Energetic     | Bright neon practical lights + mixed color temp         |
| Elegant       | Butterfly beauty light + subtle fill, high-key         |
| Moody         | Overcast + window light, muted tones, lifted blacks    |
| Cyberpunk     | Neon pink/teal practicals + wet reflections + haze     |

---

## APPENDIX: COMMON PITFALLS

1. **Keyword stuffing** -- Modern models (2026) understand natural language. Write clear descriptions, not walls of synonyms.
2. **Forgetting lighting** -- Lighting is the single highest-leverage element. Never skip it.
3. **Vague subjects** -- "A person" fails. Describe age, clothing, expression, pose, context.
4. **Ignoring word order** -- What comes first gets the most attention. Lead with your subject.
5. **Wrong length** -- 30-75 words hits the sweet spot for most models. Going over 120 words shows diminishing returns.
6. **No camera specs** -- Adding a camera body + lens + aperture transforms the output from illustration to photography.
7. **Generic quality words** -- "Beautiful, stunning, amazing" add nothing. Use specific technical terms (8K, f/1.8, Rembrandt lighting).
8. **Fighting the model** -- Each model has strengths. Use FLUX for natural language realism, Midjourney for artistic style, SD for control via negative prompts.

---

*Guide compiled April 2026. Models and techniques evolve rapidly -- test and iterate.*
