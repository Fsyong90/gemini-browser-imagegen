---
name: gemini-browser-imagegen
description: Generate images via Gemini in Chrome browser using Computer Use (virtual desktop). Use when user asks to generate images with Gemini browser, draw pictures via Gemini web UI, or create AI art through the Gemini website. Requires virtual desktop (computer-use skill) to be running. Does NOT use Gemini API — operates through the actual browser UI with the user's Gemini Pro subscription.
---

# Gemini Browser Image Generation (Computer Use)

Generate images through the Gemini web UI in Chrome on the virtual desktop.
Uses the user's Gemini Pro subscription — no API key needed.

## Prerequisites

- Virtual desktop running (Xvfb + XFCE + x11vnc + noVNC via `computer-use` skill)
- Chrome installed and Google account logged in
- `computer-use` skill scripts available at `~/clawd/skills/computer-use/scripts/`

## Workflow

### 1. Navigate to Gemini

```bash
SKILL_DIR="$(dirname "$0")/.."
CU_SCRIPTS=~/clawd/skills/computer-use/scripts

# Focus Chrome or open it
$CU_SCRIPTS/action.sh '{"actions":[
  {"type":"key","key":"ctrl+l"},
  {"type":"type","text":"https://gemini.google.com/app"},
  {"type":"key","key":"Return"}
]}'
sleep 3
```

Or use the helper script:

```bash
./scripts/navigate.sh
```

### 2. Enter image prompt

Click the prompt input field (bottom center of page), type the image generation prompt, and submit.

```bash
# Click the input field area (bottom center)
$CU_SCRIPTS/action.sh '{"type":"click","x":512,"y":720}'
sleep 0.5

# Type the prompt
$CU_SCRIPTS/action.sh '{"type":"type","text":"Draw a cute cat sitting on a windowsill watching the rain"}'
sleep 0.5

# Press Enter to submit
$CU_SCRIPTS/action.sh '{"type":"key","key":"Return"}'
```

Or use the helper script:

```bash
./scripts/prompt.sh "Draw a cute cat sitting on a windowsill watching the rain"
```

### 3. Wait for image generation

Gemini image generation takes 10-30 seconds. Poll with screenshots until the image appears.

```bash
# Wait and check
sleep 15
$CU_SCRIPTS/action.sh '{"type":"screenshot"}'
# Analyze the screenshot — look for generated image or loading spinner
# If still loading, wait another 10s and screenshot again
```

Or use the helper script:

```bash
./scripts/wait-for-image.sh    # Polls every 10s, up to 60s
```

### 4. Download the generated image

Click the download button on the generated image.

```bash
# The download icon is typically on hover over the image
# Move mouse over the image first, then click the download button
$CU_SCRIPTS/action.sh '{"type":"move","x":512,"y":400}'
sleep 1
$CU_SCRIPTS/action.sh '{"type":"screenshot"}'
# Find and click the download button (usually appears as ⬇ icon on the image)
```

Or use the helper script:

```bash
./scripts/download.sh
```

Downloaded files go to `~/Downloads/` — look for the most recent `.png` file.

### 5. Send to user

Copy the downloaded image to the OpenClaw media directory and send via Telegram.

```bash
./scripts/send.sh "<chat_id>" "Here's your cat image!"
```

## CRITICAL: Do NOT blindly run scripts

**The helper scripts (`navigate.sh`, `prompt.sh`, `download.sh`, etc.) are reference templates, NOT reliable automation.**

The correct approach is to use the scripts as **guidance** but **execute each step manually with the AI agent in the loop**:
1. Run the action (click, type, navigate)
2. Take a screenshot and **analyze it** (save to file, read with image tool)
3. Decide the next action based on what you actually see
4. Repeat

**Never chain scripts together blindly** — the UI changes between sessions (different chat state, popups, layout shifts).

## Step-by-step Procedure (What Actually Works)

### Step 1: Navigate to Gemini
```bash
export DISPLAY=:99
CU=~/clawd/skills/computer-use/scripts

# Go to address bar
xdotool key ctrl+l && sleep 0.3 && xdotool key ctrl+a && sleep 0.1
xdotool type --delay 8 "gemini.google.com/app" && sleep 0.2
xdotool key Return && sleep 4

# Screenshot → analyze → handle any popups/dialogs
$CU/action.sh '{"type":"screenshot"}' | base64 -d > /tmp/openclaw/gemini_nav.png
```
Then **read the screenshot** to check:
- Is there a "Restore pages?" dialog? → Dismiss it
- Is there a "Stay in the know" popup? → Close it
- Is the page loaded? → Click "New chat" if needed

### Step 2: Enter prompt
```bash
# Click the input field (bottom center) — BUT verify coordinates first!
$CU/action.sh '{"type":"click","x":512,"y":720}' && sleep 0.5
xdotool type --delay 12 -- "Draw a cute dog playing in a park"
sleep 0.5
xdotool key Return
```
Then **screenshot to verify the prompt was submitted** — sometimes typing fails silently.

### Step 3: Wait for image generation
**Do NOT rely on `wait-for-image.sh`** — its polling screenshots don't auto-detect completion.

Instead, manually poll:
```bash
sleep 20  # Initial wait
$CU/action.sh '{"type":"screenshot"}' | base64 -d > /tmp/openclaw/gemini_check.png
# READ the screenshot — is the image visible? Or still loading?
# If still loading, wait 10 more seconds and check again
```

**Key signs of completion:**
- A large image appears in the chat area
- The loading spinner/animation stops
- The response text appears around the image

**Key signs still generating:**
- Spinner/pulsing dots visible
- "Generating..." text
- The chat area looks the same as right after submission

**IMPORTANT: Image may require scrolling down** — if you submitted a long prompt, the response may be below the visible area. Try:
```bash
$CU/action.sh '{"type":"scroll","x":512,"y":400,"direction":"down","amount":3}'
sleep 1
# Screenshot again
```

### Step 4: Download the image
This is the trickiest part. Multiple approaches ranked by reliability:

**Approach A: Hover to reveal download button (most reliable)**
```bash
# Move mouse over the generated image
$CU/action.sh '{"type":"move","x":512,"y":400}' && sleep 1.5
# Screenshot to find the download button
$CU/action.sh '{"type":"screenshot"}' | base64 -d > /tmp/openclaw/gemini_hover.png
# READ screenshot → find the download icon (⬇) position → click it
```

**Approach B: Click image → look for "Download full size" in toolbar**
- After hovering, a toolbar may appear with share/download options
- Look for "Download full size" text or a download arrow icon

**Approach C: Right-click → "Save image as"**
- If download button doesn't appear, right-click the image
- Navigate the context menu to "Save image as..."
- ⚠️ This is fragile — the "Save as" dialog requires more interaction

After clicking download:
```bash
sleep 3  # Wait for download
ls -lt ~/Downloads/*.png | head -1  # Find the downloaded file
```

### Step 5: Send to user
```bash
# Copy to OpenClaw media directory (REQUIRED for Telegram)
cp ~/Downloads/Gemini_Generated_Image_*.png /tmp/openclaw/result.png
# Send
openclaw message send --media /tmp/openclaw/result.png --channel telegram --to "<chat_id>" "Your generated image!"
```

## Pitfalls & Lessons Learned

### Screenshot output is base64
- `screenshot.sh` outputs base64 to stdout and deletes the temp file
- To save as a file: `$CU/screenshot.sh | base64 -d > /tmp/screenshot.png`
- Or use `action.sh '{"type":"screenshot"}'` which also returns base64
- **Always save to a file and use the image analysis tool to read it** — don't try to parse base64 in your head

### Sending media to Telegram
- **Must** copy files to `/tmp/openclaw/` first (NOT `/tmp/` directly — regular `/tmp/` paths are blocked by `mediaLocalRoots` restriction)
- Regular `/tmp/` paths are blocked by `mediaLocalRoots` restriction
- Use: `openclaw message send --media /tmp/openclaw/image.png --channel telegram --to <chat_id> "caption"`
- `file://` URLs do NOT work for Telegram
- The `MEDIA:<path>` tag in agent replies does NOT reliably work — **always use CLI**

### Chrome quirks on virtual desktop
- "Restore pages?" dialog may appear on Chrome launch — dismiss with Escape or click Cancel
- Bookmarks bar may pop out — click empty area to dismiss
- "Stay in the know" / notification popups — dismiss first before any interaction
- Gemini "Superpower for Gemini" extension may add extra UI elements
- `type_text.sh` may fail silently — prefer `xdotool type --delay 12 -- "text"` directly

### xdotool type vs action.sh type
- `xdotool type --delay 12 -- "text"` works directly and is simpler
- `action.sh` wraps xdotool with chunking (50 chars at a time)
- For long prompts, `action.sh` is more reliable
- **Always verify typing worked** by taking a screenshot after

### Image download location
- Chrome downloads go to `~/Downloads/` by default
- Gemini images are named `Gemini_Generated_Image_*.png` (~5-10MB)
- Use `ls -lt ~/Downloads/Gemini_Generated_Image_*.png | head -1` to find the latest
- Check file age with `stat -c %Y` to confirm it's the new download, not a stale one

### Google login
- Chrome saves Google login — usually stays logged in across sessions
- Google accounts stay logged in much longer than Taobao
- If expired, user needs to re-authenticate manually

### Coordinate hints for Gemini UI (approximate — ALWAYS verify with screenshot!)
- **Prompt input field**: bottom center, approximately (512, 720)
- **Send button**: right of input field, approximately (950, 720)
- **Generated image**: center of page, varies (512, 350-500)
- **Download button on image**: appears on hover, position varies
- **"New chat" button**: left sidebar, approximately (96, 299)
- ⚠️ **Coordinates are UNRELIABLE** — they shift based on chat history, screen state, and popups. Always screenshot first!

### Timing
- Page load: wait 3-5 seconds after navigation
- Image generation: **15-45 seconds** (can be longer for complex prompts — today's dog took ~35s)
- After clicking download: wait 2-3 seconds for file to appear in ~/Downloads/
- Always verify with screenshot before proceeding to next step

### Common failure modes
1. **Typing fails silently** → Always screenshot after typing to confirm text appeared
2. **Image not visible without scrolling** → Scroll down if prompt area pushed content out of view
3. **Download button not appearing** → Try hovering at different Y coordinates (the image may be higher/lower)
4. **Stale screenshots in wait loop** → Screenshots may look identical because the loading spinner is between frames — increase wait time
5. **Multiple images generated** → Gemini sometimes generates 2-4 variants. Download button may download all or just one
6. **"Restore pages" on Chrome restart** → The virtual desktop persists, but Chrome may crash/restart between sessions

## Complete Example

```bash
CU=~/clawd/skills/computer-use/scripts
SKILL=~/clawd/skills/gemini-browser-imagegen/scripts

# 1. Navigate to Gemini
$SKILL/navigate.sh

# 2. Enter prompt and submit
$SKILL/prompt.sh "A watercolor painting of a fluffy orange cat"

# 3. Wait for generation
$SKILL/wait-for-image.sh

# 4. Download the image
$SKILL/download.sh

# 5. Send to user
$SKILL/send.sh "-5239395083" "Here's your cat!"
```
