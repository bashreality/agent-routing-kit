# agent-routing-kit

Mój stack do Claude Code. Daje jakość superpowers przy mniejszym zużyciu tokenów i szybszej pracy.

- **superpowers** odpowiada za proces: brainstorming, plan, debugging, worktrees, weryfikację.
- **model-routing** (ten plugin) wykonuje plan tanimi, dobranymi subagentami (Haiku, Sonnet lub Opus z odpowiednim effortem).
- **ponytail** pilnuje, żeby kodu było jak najmniej.

## Instalacja (raz na komputer)

```bash
claude plugin marketplace add bashreality/agent-routing-kit
claude plugin install model-routing@agent-routing-kit     # dociąga superpowers + ponytail
```

Jeśli masz superpowers albo ponytail z innego marketplace, odinstaluj tamte kopie (`claude plugin list`). Ponytail wymaga Node.js.

## Użycie: automatycznie, komendy są opcjonalne

Piszesz tak jak dotąd. Wszystko odpala się samo, tak jak w superpowers:

| Sytuacja | Co się dzieje |
|---|---|
| Mała zmiana, pytanie, fix | Claude robi to od razu, bez planu i bez agentów |
| Niejasny pomysł na funkcję | Uruchamia się brainstorming superpowers |
| Potrzebny plan | Uruchamia się `plan`: plan w formacie superpowers z linią `Route:` przy każdym zadaniu |
| Akceptujesz plan ("ok, rób") | Uruchamia się `build`: tańsze wykonanie zamiast `subagent-driven-development` |

Komendy przydają się tylko wtedy, gdy chcesz coś wymusić: `/model-routing:plan <co zbudować>` oraz `/model-routing:build` (z `--dry-run`, żeby zobaczyć samą tabelę, albo `--from 5`, żeby wznowić od Task 5).

Najlepiej uruchamiać sesję główną na **Opus / medium**. Ona tylko planuje i deleguje, a ciężką pracę robią subagenci.

## Skąd oszczędność względem czystego superpowers

| Superpowers sam | Ten stack |
|---|---|
| Brainstorming przy każdej "kreatywnej" zmianie | Tylko gdy pomysł jest niejasny. Małe zmiany robione są od razu |
| `subagent-driven-development` (~8k tokenów instrukcji w sesji głównej) i świeży reviewer po każdym zadaniu | `/build` (~1,5k tokenów). Review zbiorczy po fazie dla T1, osobny tylko dla T2 i security |
| Model dobierany heurystycznie przy wykonaniu | Model i effort zapisane w planie (rubryka A/R/S/N/V) |
| Każde drobne zadanie to osobny subagent | Drobne zadania T0 łączone w jeden wywołany raz worker na Haiku |
| Orkiestrator przepisuje zadania do briefu | Brief to sekcja zadania 1:1 z planu, bez przepisywania |
| Niezależne zadania jedno po drugim | Do 3 równolegle (worktree przy ryzyku konfliktu plików) |

Jakość zostaje ta sama, bo plan dalej pisze `superpowers:writing-plans`: interfejsy między zadaniami, testy najpierw i self-review. `/plan` dopisuje tylko linię routingu do każdego zadania:

```
### Task 3: Rate limit on /login
**Route:** T2 · implementer-senior · A1 R2 S1 N1 V1 = 6 · gate: review+security
```

## Agenci

| Agent | Model / effort | Kiedy |
|---|---|---|
| `scout` | Haiku / low | Szukanie w repo. Tylko odczyt |
| `verifier` | Haiku / low | Testy, lint, build. Zwraca tylko błędy |
| `worker-mechanical` | Haiku / low | T0: rename, config, boilerplate, także paczki zadań |
| `implementer` | Sonnet / medium | T1: typowa praca według wzorców w repo |
| `implementer-senior` | Opus / high | T2: auth, migracje, współbieżność, eskalacje |
| `architect` | Opus / high | T3: projekt dużych lub niejasnych zadań |
| `reviewer` | Opus / medium | Review. Wyłapuje też przeinżynierowanie |
| `security-reviewer` | Opus / high | Obowiązkowy przy ryzyku R=2 |
| `debugger` | Opus / high | Po dwóch nieudanych próbach. Używa `superpowers:systematic-debugging` |

Eskalacja wygląda tak: ponowienie u tego samego agenta → tier wyżej → `debugger` → stop i pytanie do ciebie. Rubryka i przykłady są w `plugins/model-routing/skills/routing-rubric/SKILL.md`.

## Opcjonalnie

- **`~/.claude/settings.json`** (z `examples/settings.json.example`): `PONYTAIL_SUBAGENT_MATCHER` ogranicza ponytail do implementerów, żeby nie marnował tokenów w `scout`, `verifier` i review.
- **`CLAUDE.md` projektu** (z `examples/CLAUDE.md.snippet`): komendy testów i ścieżki wysokiego ryzyka.
- `CLAUDE_CODE_EFFORT_LEVEL` nadpisuje effort wszystkich agentów, a `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` wyłącza routing. Nie ustawiaj żadnej z nich.

## Wersje i aktualizacje

superpowers v7.0.0 i ponytail v5.3.2 są przypięte do taga i SHA w `.claude-plugin/marketplace.json`. Żeby podbić wersję, zmień `ref`/`sha`, przejrzyj zmiany w hookach upstream, zrób commit, a potem uruchom `claude plugin marketplace update agent-routing-kit`.
