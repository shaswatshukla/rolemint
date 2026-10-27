# Public RoleMint

Anonymous, stateless resume tailoring with visitor-supplied Groq or Gemini API keys. No private backend database, shared settings, or server API keys are mounted. Uploaded resumes, job descriptions, and drafts are not persisted. Provider policies still apply.

The public service reuses the upstream Resume Matcher image and bounded document parser. Each request carries its own model and key. The client retains drafts only in its current tab; downloads belong to the visitor. PDF rendering blocks all network requests and escapes resume text.

The service serializes expensive operations and caps API operations at 30/minute for the whole small Oracle instance. Files are limited to 5 MB and request bodies to 6 MB.

Tests cover anonymous routes, blocked shared-data routes, distinct request keys and drafts, invalid files, and export HTML escaping. Live PDF and DOCX exports were also verified using fictional data. Actual model generation still requires a working visitor provider key.
