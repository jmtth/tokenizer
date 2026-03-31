# Deployment

Ce dossier regroupe les éléments de déploiement.

- `ignition/modules/Goodies42Core.ts`: déploie `Goodies42` + `Goodies42Shop`
- `ignition/modules/Goodies42Bonus.ts`: déploie `Goodies42Management` (multisig)

## Commandes

Local:

```bash
make deploy-core-local
make deploy-bonus-local
```

Sepolia:

```bash
make deploy-core-sepolia
make deploy-bonus-sepolia
```
