# Containerize It — Docker Lab

**Topic: Docker · individual submission**

The SecureNotes API is finished and tested. Your job is to **package it into a
Docker image**, then **run the whole stack** (API + a Postgres database) with
one command. You write three files: `Dockerfile`, `.dockerignore`, and
`docker-compose.yml`. You don't touch the app or the tests.

> You need **Docker Desktop** installed and running, and an internet connection
> (Docker downloads the base images the first time).

---

## Setup

```bash
# 1. the app runs the same as before — confirm it's healthy
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
pytest -q              # 12 app tests pass; the 15 Docker checks are red (your job)

# 2. make sure Docker is ready
docker --version
docker run --rm hello-world     # should print a success message
```

Two structural test files guide you — run the one for the part you're on:

```bash
pytest tests/test_dockerfile.py    # Parts A & B
pytest tests/test_compose.py       # Part C
```

These check your files are built right. They can't build the image for you —
that happens with real Docker commands, and the screenshots are your proof.

---

## Part A — Write the Dockerfile  (~40 min)

File: `Dockerfile`  ·  check: `pytest tests/test_dockerfile.py`

- [x] **A1** — `FROM` a small, pinned Python base (e.g. `python:3.12-slim`)
- [x] **A2** — set a `WORKDIR` (e.g. `/app`)
- [x] **A3** — `COPY requirements.txt .` then `RUN pip install -r requirements.txt`
      **before** copying the code (so the install layer caches)
- [x] **A4** — `COPY . .` to bring in the rest of the source
- [x] **A5** — `EXPOSE 8000` and a `CMD` that starts uvicorn on `--host 0.0.0.0`

Then build and run it for real:

```bash
docker build -t securenotes .
docker run -p 8000:8000 securenotes      # open http://localhost:8000/docs
```

## Part B — Make it a good image  (~25 min)

- [x] **B1** — add a non-root `USER` (create one, then switch to it)
- [x] **B2** — fill in `.dockerignore` so `venv/`, `.git/`, `__pycache__/` and
      other junk never get copied into the image

Rebuild — the image should still work, and the build context shrinks.

## Part C — Run the whole stack with Compose  (~35 min)

File: `docker-compose.yml`  ·  check: `pytest tests/test_compose.py`

- [x] **C1** — an `api` service that `build:`s from your Dockerfile, maps port
      `8000`, `depends_on` the db, and gets `DATABASE_URL`
- [x] **C2** — a `db` service using `postgres:16`, with a volume and the
      `POSTGRES_USER` / `POSTGRES_PASSWORD` / `POSTGRES_DB` env vars

Bring it up and prove the two containers can talk:

```bash
docker compose up -d
curl http://localhost:8000/health/db     # -> {"database":"ok"}
docker compose ps                         # api + db both up
docker compose down
```

The `/health/db` endpoint is already in the app — with no database it says
`"not configured"`, but once compose connects Postgres it returns `"ok"`. That
`ok` is your proof the containers are networked together.

## Part D — Ship it & submit  (~20 min)

```bash
git init && git add . && git commit -m "Dockerized SecureNotes"
git branch -M main
git remote add origin https://github.com/<you>/securenotes-docker.git
git push -u origin main
```

Capture **three screenshots**: (1) `docker build` finishing, (2) `/docs` open in
the browser from the running container, (3) `docker compose ps` with both
containers up (or the `{"database":"ok"}` response).

---

## Reflection (3–4 sentences each)

1. **Your teammate clones the repo on a different OS and runs `docker run`. Why
   does it behave the same as on your machine, when running the app directly
   might not?**

   Docker packages the SecureNotes application together with its Python runtime
   and installed dependencies inside an image. The container uses that same
   image configuration on supported machines instead of relying on each
   computer's locally installed Python version and libraries. This reduces
   differences between Windows, macOS, and Linux development environments.
   Running the application directly could behave differently if those local
   versions or environment settings do not match.

2. **Why copy `requirements.txt` and install *before* copying the rest of the
   code? What does it save on a rebuild?**

   Docker builds an image in layers and can reuse layers that have not changed.
   By copying `requirements.txt` and installing dependencies first, the
   dependency-installation layer stays cached when only application code
   changes. Docker can then copy the revised code without reinstalling all
   Python packages. This makes subsequent builds faster and avoids unnecessary
   downloads.

## Final verification and submission (perform on your computer)

The three configuration files and the reflection are completed in this package.
The Python structural tests can be run independently of Docker, but the real
container builds, GitHub upload, and required proof screenshots **must be
performed on a computer with Docker Desktop**; do not mark them as complete
until you have seen them succeed.

- [ ] Run `pytest -q` and confirm all app and Docker structural tests pass.
- [ ] Run `docker build -t securenotes .` and capture screenshot 1 (build success).
- [ ] Run `docker run --rm -p 8000:8000 securenotes`, open
      `http://localhost:8000/docs`, and capture screenshot 2. Stop the
      stand-alone container with Ctrl+C before using Compose.
- [ ] Run `docker compose up -d --build` and confirm
      `http://localhost:8000/health/db` returns `{"database":"ok"}`.
- [ ] Run `docker compose ps` and capture screenshot 3 (both services running;
      optionally also capture the successful health response).
- [ ] Create your own GitHub repo, push the project, and submit the link,
      three screenshots, and this completed `TASKS.md` in the LMS.

