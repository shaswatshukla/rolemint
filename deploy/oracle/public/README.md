# Public RoleMint

Anonymous, stateless resume tailoring with visitor-supplied Groq or Gemini API keys. No private backend database, shared settings, or server API keys are mounted. Uploaded resumes, job descriptions, and drafts are not persisted. Provider policies still apply.

The public service reuses the upstream Resume Matcher image and bounded document parser. Each request carries its own model and key. The client retains drafts only in its current tab; downloads belong to the visitor. PDF rendering blocks all network requests and escapes resume text.

The service serializes expensive operations and caps API operations at 30/minute for the whole small Oracle instance. Files are limited to 5 MB and request bodies to 6 MB.

Tests cover anonymous routes, blocked shared-data routes, distinct request keys and drafts, invalid files, and export HTML escaping. Live PDF and DOCX exports were also verified using fictional data. Actual model generation still requires a working visitor provider key.

## Key setup and comparison report

Both Groq and Gemini key-creation links are shown in the public form. Generated drafts include an AI edit summary and their actual extracted source for comparison. The browser computes before/after exact-match coverage over up to 40 selected JD terms, with matched, missing and newly introduced terms; it refreshes after manual edits and makes no extra AI calls. This heuristic does not estimate ATS pass probability, rankings or interview chances.

## Prompt-only workflow

/api/analyze accepts a resume and JD without an API key and extracts source text without any AI provider call. The browser finds exact-text keyword gaps and builds a downloadable/copyable prompt. The prompt requires the user to attach the original resume, asks the chosen AI to edit in place while preserving layout, and requests exact replacements when file editing is unavailable. Original DOCX is preferred; no formatting guarantee is made for external tools. The prompt also appears after in-site tailoring.
