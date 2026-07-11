# todoer_devstack

Local-only Docker Compose orchestration for todoer: `db` (Postgres) +
`todoer_be`, plus an on-demand `migrate` runner. **Not used in production.**
For repo-wide guidance see [../CLAUDE.md](../CLAUDE.md).

## Commands

- `docker compose up -d --build` — build + start `db` and `todoer_be`.
- `docker compose run --rm migrate up` — apply DB migrations (`down N` to roll
  back one/N).
- `./reset.sh` — drop + recreate the database, apply all migrations, rebuild and
  start `todoer_be` (data is wiped; re-run seeding after — see
  `../todoer_be/seed.sh`).
- `./redeploy.sh` — rebuild `todoer_be` from latest source and (re)start it; db
  and data untouched.
- `./db-shell.sh` — open a psql shell in the `db` container.

## Notes

- `db` listens on host port **5433** (5432 is often taken); other containers
  reach it as host `db`. DB name and user are both `todoer` (password
  `password`).
- `todoer_be` bakes its binary **and `config.yaml`** into the image, so after
  any backend code/config change rebuild it (`./redeploy.sh` or
  `docker compose up -d --build todoer_be`) — a plain restart runs the stale
  image.
- The backend needs `GOOGLE_CLIENT_SECRET` in the environment, injected from a
  gitignored `.env` here (see `../todoer_be/README.md` for the OAuth setup).
