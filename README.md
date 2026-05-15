# bryanberger — Claude Code plugins

Marketplace personnelle pour Claude Code. Hébergée sur GitHub, listée via
`.claude-plugin/marketplace.json`.

## Install

```text
/plugin marketplace add BryanBerger98/claude-plugins
```

> Le repo GitHub vit sous `BryanBerger98/` (username réel). Le nom de marketplace `bryanberger` (alias défini dans `marketplace.json`) sert uniquement pour `/plugin install snap@bryanberger`.

Puis installe un plugin :

```text
/plugin install snap@bryanberger
```

## Plugins disponibles

| Nom    | Version | Description                                                                                                                     |
| ------ | ------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `snap` | 1.1.0   | Workflow produit autonome : 6 skills enchaînables (`define → ticket → wireframe → design → develop → qa`) + 2 utilitaires doc. |

Détails : [BryanBerger98/snapship-plugin](https://github.com/BryanBerger98/snapship-plugin).

## Test local

```bash
git clone https://github.com/BryanBerger98/claude-plugins ~/.claude/marketplaces/bryanberger
# puis dans claude :
/plugin marketplace add ~/.claude/marketplaces/bryanberger
/plugin install snap@bryanberger
```

## Mettre à jour la marketplace

À chaque release d'un plugin tracké, bump le `ref` et le `version` du plugin
dans `.claude-plugin/marketplace.json`. Helper inclus :

```bash
./scripts/bump-plugin.sh --plugin=snap --version=1.1.0
```

Le script met à jour le `ref` (tag git) et le `version` du plugin ciblé,
puis affiche le diff. Commit + push manuellement après revue.

## Validation

`.github/workflows/validate.yml` valide le `marketplace.json` à chaque push/PR
contre le schema Claude Code. Lancer en local :

```bash
jq empty .claude-plugin/marketplace.json
./scripts/validate-marketplace.sh
```

## License

MIT — voir [LICENSE](LICENSE).
