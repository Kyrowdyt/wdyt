# What do you think? — wdyt.live

Community polls for the crypto space. One question, one tap, live results.

## How voting works

- Every visitor gets a **random anonymous id** generated in their own browser.
  It contains no personal data and is the only thing this site stores — it is
  strictly necessary for the poll to work (it remembers your ballot and keeps
  voting to one vote per person), which is why there is no consent pop-up,
  just a notice. We never see who you are.
- **One vote per browser** per poll — the database has a hard uniqueness rule
  on (poll, voter), so repeated votes simply replace your previous one.
- **Votes can be changed after 15 seconds.** This cool-down is enforced by a
  trigger inside the database itself, not just by the page, so it cannot be
  bypassed from the browser. Pressing "Change vote" withdraws your ballot —
  it stops being counted until you pick a new answer (re-casting after a
  withdrawal needs no extra waiting).
- **Votes can never be deleted.** There is deliberately no delete permission
  for visitors; a withdrawn ballot stays in the database marked as withdrawn,
  it is simply not counted.
- Results update **live** for everyone with the page open.

## What we store

Exactly three things per vote: a random voter id, the poll id, and the choice
(plus timestamps). No names, no e-mails, no wallets, no IP collection by the
app. This site never asks you to connect a wallet or sign anything.

## Why you can trust what you see

This site is served by GitHub Pages **directly from this repository** — the
code you are reading here is byte-for-byte the code running on wdyt.live.
The complete database rules are public too: see [`supabase.sql`](supabase.sql).

## Honest limitations

This is an anonymous poll. A determined person can clear their browser data
and vote again. Treat results as a community vibe check, not a notarized
election.

## Stack

Static HTML/CSS/JS (no build step) · [Supabase](https://supabase.com)
(Postgres + Realtime) · GitHub Pages.


## License

MIT — see [LICENSE](LICENSE).
