#!/usr/bin/env -S deno run --quiet

const input = JSON.parse(await new Response(Deno.stdin.readable).text())

const dim = (s: string) => `\x1b[2m${s}\x1b[0m`
const red = (s: string) => `\x1b[31m${s}\x1b[0m`
const yellow = (s: string) => `\x1b[33m${s}\x1b[0m`
const cyan = (s: string) => `\x1b[36m${s}\x1b[0m`

const compact = (n: number) =>
  n >= 1_000_000
    ? `${(n / 1_000_000).toFixed(n < 10_000_000 ? 1 : 0)}M`
    : n >= 1_000
    ? `${Math.round(n / 1_000)}k`
    : `${n}`

const bar = (pct: number) => {
  const filled = Math.round((pct / 100) * 10)
  return "░".repeat(10 - filled) + "█".repeat(filled)
}

const badge = (left: number) =>
  left <= 20
    ? { icon: "💀", color: red }
    : left <= 40
    ? { icon: "😰", color: yellow }
    : left <= 60
    ? { icon: "😐", color: yellow }
    : { icon: "", color: dim }

const model = input.model?.display_name ?? "claude"
const dir = (input.workspace?.current_dir ?? "").split("/").filter(Boolean).at(-1) ?? "~"

const ctx = input.context_window
const parts = [cyan(model), dim(dir)]

if (ctx?.context_window_size) {
  const left = Math.max(0, Math.round(ctx.remaining_percentage ?? 100))
  const used = compact(ctx.total_input_tokens ?? 0)
  const size = compact(ctx.context_window_size)
  const reading = `${bar(left)} ${left}% left ${dim(`${used}/${size}`)}`
  const { icon, color } = badge(left)
  parts.push(icon ? `${icon} ${color(reading)}` : color(reading))
}

console.log(parts.join(dim(" · ")))
