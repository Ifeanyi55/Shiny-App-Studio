---
name: r-shiny-builder
description: Build, structure, and debug R Shiny applications — especially apps where an LLM generates dynamic plots or UI from structured specs, and apps deployed to GCP Cloud Run via Docker/Terraform. Use whenever the request involves creating a Shiny app, wiring reactive plots, resolving renderUI()/renderPlot() boundary issues, structuring server/UI logic, or deploying a Shiny app as a container. Do not use for general R data-analysis scripts that don't involve Shiny.
---

# R Shiny Builder

## When to use this skill
- Scaffolding a new Shiny app (single-file `app.R` or `ui.R`/`server.R` split)
- Adding reactive plots or tables driven by user input or an LLM-generated spec
- Debugging why a plot won't update, or why `renderUI()` and `renderPlot()` are stepping on each other
- Containerizing and deploying a Shiny app to Cloud Run
- Wiring an LLM (via reticulate/Antigravity bridge) to produce structured output that drives the UI

## Core architecture rules

1. **UI declares structure, server declares behavior.** Anything that changes at runtime belongs in `server`, wrapped in a reactive (`reactive()`, `renderPlot()`, `renderUI()`, `observeEvent()`) — never mutate UI elements directly outside a render function.
2. **`renderPlot()` vs `renderUI()` — pick one job per output.**
   - `renderPlot()` owns pixels: axes, geoms, themes. It should receive a fully-resolved plot object or spec — no conditional UI logic inside it.
   - `renderUI()` owns layout: which inputs/outputs exist, conditional panels, dynamic control generation. It should never contain plotting code.
   - If a plot's *shape* (not just its data) needs to change based on user choice, resolve that choice in a `reactive()` upstream, then have `renderPlot()` consume the resolved object. Don't try to make `renderUI()` regenerate the plot — this is the boundary bug that shows up most often.
3. **Reactivity flows one direction.** Inputs → reactive expressions → outputs. If you find yourself reading an output's value back into an input's reactive chain, restructure around a shared `reactiveVal()`/`reactiveValues()` instead.

## Pattern: LLM-driven dynamic plots

For apps where an LLM (via the Antigravity/reticulate bridge) decides what to plot:

1. LLM call returns a **structured JSON spec**, not code — e.g. `{"chart_type": "bar", "x": "region", "y": "value", "filters": {...}}`. Never have the LLM emit raw R code to `eval()`.
2. Validate the spec against an allowed schema (allowed chart types, allowed columns) before it touches `renderPlot()`. Reject/re-prompt on invalid specs rather than passing them through.
3. A single `renderPlot()` block interprets the validated spec and dispatches to the right ggplot2 builder function. Keep one builder function per chart type — don't branch deeply inside `renderPlot()` itself.
4. If the LLM also needs to add/remove *input controls* (not just plot content), that's a `renderUI()` job downstream of the same spec — keep the spec as the single source of truth both renders read from.

```r
# server.R sketch
spec <- reactive({
  req(input$llm_prompt)
  raw <- call_llm_for_spec(input$llm_prompt)   # via reticulate bridge
  validate_plot_spec(raw)                       # schema check, throws on failure
})

output$dynamic_plot <- renderPlot({
  build_plot(spec())                            # dispatches on spec()$chart_type
})

output$dynamic_controls <- renderUI({
  build_controls(spec())                        # layout only, no plotting
})
```

## Deployment: Cloud Run

- Base image: use `rocker/shiny` or a slimmed custom image — avoid `rocker/tidyverse` in production (large, slow cold starts).
- Cloud Run expects the container to listen on `$PORT` (usually 8080), not Shiny's default 3838. Set this explicitly:
  ```r
  shiny::runApp(host = "0.0.0.0", port = as.numeric(Sys.getenv("PORT", 8080)))
  ```
- Common failure: port-mismatch timeout on deploy — the container starts fine but Cloud Run health-checks the wrong port. Check this first before touching Terraform.
- Terraform: manage `google_cloud_run_v2_service` with explicit `min_instance_count = 0` unless you need warm instances; Shiny cold starts are usually acceptable for internal tools.
- Keep the Dockerfile's `COPY` layer for `renv.lock`/package installs separate from and above the `COPY . .` app-code layer, so code changes don't invalidate the package-install cache.

## Common pitfalls checklist
- [ ] Plot not updating → check the reactive dependency is actually read inside `renderPlot()`, not just computed nearby
- [ ] "argument is of length zero" on load → an input hasn't rendered yet; guard with `req()`
- [ ] `renderUI()` flashing/rebuilding whole panel on unrelated input change → its reactive is too coarse; split into smaller `reactive()`s
- [ ] Works locally, fails on Cloud Run → check port binding first, then check for local file paths that don't exist in the container
- [ ] LLM spec occasionally breaks the plot → you're likely `eval()`-ing generated code somewhere instead of dispatching on a validated schema

## Reference files (optional — add if this SKILL.md grows past ~300 lines)
- `references/reactivity.md` — deeper reactive-graph debugging patterns
- `references/deployment.md` — full Dockerfile + Terraform templates
- `scripts/validate_plot_spec.R` — the schema-validation function referenced above
