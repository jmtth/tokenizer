# Tokenizer (42) — Goodies42

> Projet ERC20 réalisé dans le cadre de l’école 42.

![Goodies42 logo](./documentation/GDS42_logo.png)

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
│   └── WHITEPAPER_FR.md
│   └── WHITEPAPER_US.md
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

- `onlyOwner` sur fonctions sensibles.
- transfert de propriété en 2 étapes: `transferOwnership` puis `acceptOwnership`.
- possibilité de transférer la propriété vers un multisig.

> [Lien vers norme ERC20](https://ethereum.org/fr/developers/docs/standards/tokens/erc-20/)

### `code/contracts/Goodies42Shop.sol`

Permet l’achat d’un goodie via `buy`:

- vérification du prix on-chain via `itemPrice[itemId]`.
- accès bonus (`LotteryAccess`) si bonne réponse.
- sinon transfert du prix vers la trésorerie du shop.
- max `LotteryAccess` par utilisateur: `3`.
- retrait admin possible via `withdrawTokens`.

## Déroulement d'un achat (wallet étudiant)

Flux standard côté dApp:

1. L'étudiant connecte son wallet (MetaMask) à la dApp.
2. La dApp lit le prix on-chain avec `itemPrice(itemId)`.
3. La dApp vérifie l'allowance du token pour `Goodies42Shop`.
4. Si allowance insuffisante, la dApp propose une transaction `approve(shopAddress, price)`.
5. L'étudiant confirme la transaction `approve` dans son wallet.
6. La dApp envoie ensuite `buy(itemId, answer)`.
7. L'étudiant confirme la transaction `buy` dans son wallet.
8. Le contrat applique la règle:
	- bonus valide: pas de paiement en token, consommation de `LotteryAccess`.
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

- La blockchain cible est Sepolia, mais l'accès se fait via un provider RPC (Alchemy, Infura, QuickNode, etc.).
- Sans URL RPC valide, le projet ne peut pas lire l'état de la chaîne ni envoyer les transactions de déploiement.
- Un endpoint public sans compte peut exister, mais il est souvent limité ou instable.

Variables à renseigner:

- `SEPOLIA_RPC_URL` : URL HTTP du provider RPC Sepolia.
- `PRIVATE_KEYS` : clés privées du wallet de déploiement (wallet testnet dédié).
> on peut en mettre plusieurs, elles doivent être séparées par des `,` 
> C'est nécessaire pour le déploiement multisignatures

Préparer l'environnement Sepolia:

```bash
cp .env.example .env
# puis renseigner SEPOLIA_RPC_URL et PRIVATE_KEY dans .env
```

Sans Makefile:

```bash
npx hardhat compile
npx hardhat test
npx hardhat ignition deploy ./deployment/ignition/modules/Goodies42Core.ts --network localhost
npx hardhat ignition deploy ./deployment/ignition/modules/Goodies42Core.ts --network sepolia
```

## Déploiement public

- Goodies42 (Sepolia): `0xaDf4D6A3889962F5EF5658a813C75f7c922334ED`
- Etherscan link :`https://sepolia.etherscan.io/address/0xaDf4D6A3889962F5EF5658a813C75f7c922334ED#code`
- Goodies42Shop (Sepolia): `0x15a97d74EC9aE403E791B9A59F8656dE8a6Cc750`
- Etherscan link: `https://sepolia.etherscan.io/address/0x15a97d74EC9aE403E791B9A59F8656dE8a6Cc750#code`
- Goodies42Management (Sepolia): `0xa9Df6773F1aD7da8d8cFe6DD2bAb4B28B93b0E43`
- Etherscan link (Sepolia): `https://sepolia.etherscan.io/address/0xa9Df6773F1aD7da8d8cFe6DD2bAb4B28B93b0E43#code`

## Séquence de déploiement

1. Déployer `Goodies42Core` qui déploie `Goodies42` et `Goodies42Shop`.
2. Déployer `Goodies42Bonus` qui déploie `Goodies42Management`.
3. Transférer la propriété de `Goodies42Shop` à `Goodies42Management`.
4. Appeler `acceptOwnership()` depuis le flux multisig pour que `Goodies42Management` devienne le nouveau propriétaire de `Goodies42Shop`.

`Goodies42Shop` utilise `Goodies42`, mais n'est pas automatiquement son propriétaire. Le transfert de propriété se fait en deux étapes dans `Goodies42Shop.sol` afin de garantir que ce contrat ait toujours un propriétaire.

## Flux de transfert sur Etherscan

1. Sur `Goodies42Shop`, appelez `transferOwnership(<adresse du multisig>)` depuis l’owner actuel.
2. Sur la page Etherscan de `Goodies42Management`, ouvrez `Write Contract`.
3. Appelez `submitTransaction(...)` avec :
	- `_to` = l’adresse de `Goodies42Shop`
	- `_value` = `0`
	 - `_data` = le calldata de `acceptOwnership()` (sélecteur : `0x79ba5097`)
		 - Remarque : si vous ne pouvez pas installer `ethers`, calculez le sélecteur en prenant keccak256("acceptOwnership()") et en utilisant les 4 premiers octets, ou recherchez-le sur 4byte.directory.
		 [Encoder Online](https://web3tools.chainstacklabs.com/keccak-256)
		 - Remarque : C'est le code hexa à côté du nom de la fonction sur Etherscan
4. Ensuite, chaque manager appelle `signTransaction(txIndex)`.
5. Quand le seuil est atteint, un manager appelle `executeTransaction(txIndex)`.

## Whitepaper

Voir [WHITEPAPER FR](documentation/WHITEPAPER_FR.md) et [WHITEPAPER US](documentation/WHITEPAPER_US.md).
