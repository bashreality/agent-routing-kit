# agent-routing-kit

Zestaw do Claude Code, który przy każdym zadaniu z planu wdrożenia wybiera najtańszego subagenta (model + effort), który zrobi je dobrze za pierwszym razem. Do tego dochodzą bramki weryfikacji i review oraz automatyczna eskalacja, gdy coś się nie uda.

Zestaw jest przenośny między projektami: instalujesz go raz jako plugin (albo do `~/.claude`), a w każdym repo dopisujesz tylko krótki fragment do `CLAUDE.md`.

## Co jest w środku

```
agent-routing-kit/
├── .claude-plugin/marketplace.json     # lokalny/gitowy marketplace
├── plugins/model-routing/
│   ├── .claude-plugin/plugin.json
│   ├── agents/                         # 9 subagentów
│   └── skills/
│       ├── routing-rubric/             # rubryka punktowa + eskalacja + bramki
│       ├── write-plan/                 # /write-plan → PLAN.md z przypisanymi tierami
│       │   └── PLAN.template.md
│       └── run-plan/                   # /run-plan → orkiestracja planu
├── examples/
│   ├── CLAUDE.md.snippet               # wklejasz do CLAUDE.md projektu
│   └── settings.json.example           # opcjonalne env i deny
└── install-user.sh                     # alternatywa: kopia do ~/.claude
```

## Agenci

| Agent | Tier | Model / effort | Do czego |
|---|---|---|---|
| `scout` | S | Haiku / low | Szukanie plików, symboli i konwencji. Tylko odczyt |
| `verifier` | S | Haiku / low | Testy, lint, typecheck. Zwraca tylko błędy |
| `worker-mechanical` | T0 | Haiku / low | Rename, boilerplate, config. Bez decyzji projektowych |
| `implementer` | T1 | Sonnet / medium | Domyślny implementer według istniejących wzorców |
| `implementer-senior` | T2 | Opus / high | Zadania cross-module, auth, migracje, współbieżność, eskalacje |
| `architect` | T3 | Opus / high | Projekt i rozbicie dużych lub niejasnych zadań. Tylko odczyt |
| `reviewer` | gate | Opus / medium | Review diffu względem kryteriów akceptacji |
| `security-reviewer` | gate | Opus / high | Obowiązkowy przy R=2 (OWASP/CWE) |
| `debugger` | eskalacja | Opus / high | Root cause po dwóch nieudanych próbach |

Każdy agent zwraca **ustrukturyzowany raport** (`STATUS / VERIFY / ESCALATE`). Dzięki temu orkiestrator decyduje mechanicznie, bez zgadywania.

## Rubryka w skrócie

Każde zadanie dostaje ocenę 0–2 w pięciu osiach:

- **A**: niejasność
- **R**: ryzyko
- **S**: zakres
- **N**: nowość
- **V**: trudność weryfikacji

Suma punktów wyznacza tier:

- **0–1** → T0
- **2–4** → T1
- **5–7** → T2
- **8+** → T3 (najpierw architekt)

Nadpisania mają pierwszeństwo przed sumą:

- **R=2**: minimum T2 i obowiązkowy security review.
- **R=1**: minimum T1.
- **A=2**: zadanie trafia do architekta albo pytamy człowieka.
- **S=2**: zadanie trzeba rozbić.

Eskalacja przebiega tak: ponowienie u tego samego agenta → tier wyżej → `debugger` → stop i raport do człowieka. Szczegóły i przykłady kalibracyjne są w `skills/routing-rubric/SKILL.md`.

## Instalacja

**Opcja A: plugin (zalecana).** Łatwo go aktualizować i udostępnić zespołowi.

```bash
claude plugin validate ./agent-routing-kit
claude plugin marketplace add ./agent-routing-kit        # albo: <org>/<repo> po wypchnięciu na GitHub
claude plugin install model-routing@agent-routing-kit    # scope: user = wszystkie projekty
```

Komendy mają wtedy prefiks: `/model-routing:write-plan` i `/model-routing:run-plan`.

**Opcja B: kopia do `~/.claude`.** Komendy są bez prefiksu i działają pełne pola frontmattera (`hooks`, `permissionMode`, `mcpServers` są ignorowane dla agentów z pluginu).

```bash
./agent-routing-kit/install-user.sh
```

Nie instaluj obu naraz, bo agenci będą zdublowani.

## Użycie w projekcie

1. Wklej `examples/CLAUDE.md.snippet` do `CLAUDE.md` repo i uzupełnij komendy testów oraz ścieżki z R=2.
2. `/model-routing:write-plan dodaj rate limiting do logowania`: Claude zbada repo przez `scout`, zada pytania i zapisze `PLAN.md` z punktacją przy każdym zadaniu.
3. Przejrzyj tiery. Możesz ręcznie zmienić dowolną ocenę, bo liczby są po to, żeby dało się z nimi dyskutować.
4. `/model-routing:run-plan --dry-run` pokaże tabelę dyspozycji, a samo `/model-routing:run-plan` uruchomi wykonanie.
5. Przerwane wykonanie wznawiasz przez `/model-routing:run-plan --from T-05`. Postęp zapisuje się w sekcji *Progress log* w `PLAN.md`.

Sesję główną (orkiestratora) najlepiej uruchamiać na **Opus / medium**. Orkiestrator tylko planuje i deleguje, więc nie potrzebuje high, a słabszy model gorzej ocenia raporty subagentów.

## Wymagania i uwagi

- Claude Code z obsługą pól `effort` i `omitClaudeMd` we frontmatterze. `omitClaudeMd` wymaga v2.1.271+, a parametr `effort` przy wywołaniu v2.1.292+. Sprawdzisz to przez `claude --version`.
- Zmienna `CLAUDE_CODE_EFFORT_LEVEL` nadpisuje effort wszystkich agentów. Jeśli ją ustawiasz, routing effortu przestaje działać.
- `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` wyłącza routing modeli. Nie używaj jej razem z tym zestawem.
- Model `fable` i effort `max` są celowo zarezerwowane do zadań, które człowiek wprost zatwierdzi.
- Dostrajaj progi na podstawie danych z *Progress log*. Jeśli T1 często eskaluje do T2 w danym typie zadań, podnieś punktację odpowiedniej osi w `CLAUDE.md` projektu.
- Prompty agentów są po angielsku, bo tak są najkrótsze i najprecyzyjniejsze. Agenci i tak odpowiadają w kontekście twojego repo, a orkiestrator raportuje ci po polsku, jeśli o to poprosisz.
