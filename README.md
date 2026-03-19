# Tokenizer (42) — Liberty Token (ERC20)

Projet d'apprentissage pour créer un token ERC20 simple avec Hardhat 3.

## Objectif du projet

Créer une monnaie personnalisée (`Liberty`, symbole `LIB`) avec les opérations ERC20 principales:

- `transfer`
- `approve`
- `transferFrom`
- `mint` (owner only)
- `burn` (owner only)

## Contrat principal

Le contrat est dans `contracts/Liberty.sol`.

### Ce qu'il fait

- Définit les métadonnées du token (`name`, `symbol`, `decimals`).
- Stocke les soldes via `balanceOf[address]`.
- Stocke les autorisations via `allowance[owner][spender]`.
- Définit un propriétaire (`Libertyowner`) qui peut `mint` et `burn`.

### Remarques importantes

- Le contrat ne mint pas automatiquement au déploiement.
- Dans ce projet, le mint initial est fait dans le module Ignition.
- `mint(to, amount)` et `burn(from, amount)` multiplient `amount` par `10**decimals`.

## Déploiement Ignition

Module: `ignition/modules/Liberty.ts`

- Déploie `Liberty("Liberty Token", "LIB", 18)`
- Exécute ensuite `mint(owner, 1000000)`

Donc le owner reçoit `1 000 000 LIB` (affichés), soit `1000000 * 10^18` unités internes.

## Lancer le projet

### Compiler

`npx hardhat compile`

### Lancer tous les tests

`npx hardhat test`

### Déployer en local persistant (pour MetaMask)

1. Démarrer une node locale:

`npx hardhat node`

2. Déployer sur localhost:

`npx hardhat ignition deploy ./ignition/modules/Liberty.ts --network localhost`

## Tests implémentés

### Solidity

Fichier: `contracts/Liberty.t.sol`

- Initialisation correcte (name/symbol/decimals/owner/supply)
- Seul le owner peut mint
- Transfert limité au solde disponible

### TypeScript

Fichier: `test/Liberty.test.ts`

- Initialisation correcte
- Seul le owner peut mint
- Transfert max possible, dépassement refusé
- Scénario `approve -> transferFrom`

## Explications des notions clés

### Smart contract

Un smart contract est un programme stocké sur la blockchain.
Il a une adresse et son état (balances, allowances, owner) est public/vérifiable.

### Token ERC20

Un token ERC20 n'est pas un objet unique par token.
Le contrat garde seulement des montants par adresse (`balanceOf`).

- Le token (contrat) a **une adresse de contrat**.
- Les utilisateurs ont un **solde** de ce token.

### Pourquoi `approve` existe si `transfer` existe déjà ?

- `transfer`: tu envoies **tes propres** tokens.
- `approve + transferFrom`: tu autorises un tiers (ou un autre contrat) à dépenser à ta place.

Cas typique: DEX, marketplace, abonnement.

### Ligne importante de `transferFrom`

`allowance[sender][msg.sender] -= amount;`

Elle réduit l'autorisation restante après la dépense.
Sans cette ligne, le spender pourrait réutiliser la même autorisation indéfiniment.

### `payable(msg.sender)`

`payable` sert pour les transferts d'ETH.
Dans ce contrat ERC20, les fonctions déplacent des tokens, pas de l'ETH.

Donc:

- `address payable Libertyowner` fonctionne,
- mais `address Libertyowner` serait suffisant ici si tu ne transfères jamais d'ETH.

## MetaMask: voir ton token custom

Pour voir `LIB` dans MetaMask:

1. Être sur le bon réseau (localhost 8545, chainId 31337).
2. Importer le token custom avec l'adresse du contrat déployé.
3. Vérifier que c'est bien le wallet du owner (ou un wallet ayant reçu des tokens).

Si tu déploies sans `--network localhost` sur une instance in-process Hardhat, l'état est temporaire.
