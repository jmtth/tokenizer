# Tokenizer (42) — Goodies42

> Projet ERC20 réalisé dans le cadre de l’école 42.

## Résumé

`Goodies42 (GDS42)` est un token utilitaire pour récompenser les étudiants et acheter des goodies via un contrat boutique.

- Nom: `Goodies42`
- Symbole: `GDS42`
- Décimales: `18` (fixes)
- Standard: ERC20 (`IERC20Metadata`)
- Blockchain cible: Sepolia

## Structure du projet (conforme consignes)

``` bash
Goodies42
├── 📁 code/   #code source du token et tests
│   ├── 📁 contracts/
│   │   └── Goodies42.sol
│   └── 📁 test/
│       └── Goodies42.test.ts
├── 📁 deployment/   #déploiement
│   └── 📁 Modules/
│       └── Goodies42.ts
├── 📁 documentation/   #docs projet
│   └── WHITEPAPER.md
├── MakeFile
├── README.md
└── config-Files(json, ts, env, gitignore)
```
Les fichiers de configuration restent à la racine (`hardhat.config.ts`, `package.json`, `tsconfig.json`) pour conserver la convention Hardhat.

## Contrats 📁

### `code/contracts/Goodies42.sol`

Implémente les fonctions ERC20 principales:

- `transfer`
- `approve`
- `transferFrom`
- `mint` (owner only)

Sécurité/propriété:

- `onlyOwner` sur fonctions sensibles
- transfert de propriété en 2 étapes: `transferOwnership` puis `acceptOwnership`
- possibilité de transférer la propriété vers un multisig

### `code/contracts/GoodiesShop.sol`

Permet l’achat d’un goodie via `buy`:

- vérification du prix on-chain via `itemPrice[itemId]`
- accès bonus (`LotteryAccess`) si bonne réponse
- sinon transfert du prix vers la trésorerie du shop
- max `LotteryAccess` par utilisateur: `3`
- retrait admin possible via `withdrawTokens`

## Déroulement d'un achat (wallet étudiant)

Flux standard côté dApp:

1. L'étudiant connecte son wallet (MetaMask) à la dApp.
2. La dApp lit le prix on-chain avec `itemPrice(itemId)`.
3. La dApp vérifie l'allowance du token pour `GoodiesShop`.
4. Si allowance insuffisante, la dApp propose une transaction `approve(shopAddress, price)`.
5. L'étudiant confirme la transaction `approve` dans son wallet.
6. La dApp envoie ensuite `buy(itemId, answer)`.
7. L'étudiant confirme la transaction `buy` dans son wallet.
8. Le contrat applique la règle:
	- bonus valide: pas de paiement en token, consommation de `LotteryAccess`
	- sinon: `transferFrom(student, shop, price)`
9. Le backend peut confirmer l'achat en lisant l'event `ItemPurchased` on-chain.

## Commandes

Via Makefile:

```bash
make install
make compile
make test
make node
make deploy-local
make deploy-sepolia
```

## Pourquoi un RPC provider est nécessaire

Pour déployer sur Sepolia, Hardhat doit se connecter à un noeud Ethereum via une URL RPC.

- La blockchain cible est Sepolia, mais l'accès se fait via un provider RPC (Alchemy, Infura, QuickNode, etc.)
- Sans URL RPC valide, le projet ne peut pas lire l'état de la chaîne ni envoyer les transactions de déploiement
- Un endpoint public sans compte peut exister, mais il est souvent limité ou instable

Variables à renseigner:

- `SEPOLIA_RPC_URL` : URL HTTP du provider RPC Sepolia
- `PRIVATE_KEY` : clé privée du wallet de déploiement (wallet testnet dédié)

Préparer l'environnement Sepolia:

```bash
cp .env.example .env
# puis renseigner SEPOLIA_RPC_URL et PRIVATE_KEY dans .env
```

Sans Makefile:

```bash
npx hardhat compile
npx hardhat test
npx hardhat ignition deploy ./deployment/modules/Goodies42.ts --network localhost
npx hardhat ignition deploy ./deployment/modules/Goodies42.ts --network sepolia
```

## Déploiement public (à compléter)

- Goodies42 (Sepolia): `TODO`
- GoodiesShop (Sepolia): `TODO`
- Lien Etherscan: `TODO`

## Whitepaper

Voir `documentation/WHITEPAPER.md`.
