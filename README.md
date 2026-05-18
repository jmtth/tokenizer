# Tokenizer (42) - Goodies42

> ERC20 project developed as part of the 42 school curriculum.

![Goodies42 logo](./documentation/GDS42_logo.png)

## Summary

`Goodies42 (GDS42)` is a utility token used to reward students and purchase goodies through a shop contract.

- Name: `Goodies42`
- Symbol: `GDS42`
- Decimals: `18` (fixed)
- Standard: ERC20 (`IERC20Metadata`)
- Target blockchain: Sepolia

## Project Structure (assignment-compliant)

```bash
Goodies42
├── code/   # token source code and tests
│   ├── contracts/
│   │   └── Goodies42.sol
│   └── test/
│       └── Goodies42.test.ts
├── deployment/   # deployment files
│   └── Modules/
│       └── Goodies42.ts
├── documentation/   # project docs
│   ├── WHITEPAPER_FR.md
│   └── WHITEPAPER_US.md
├── Makefile
├── README.md
├── README_FR.md
└── config files (json, ts, env, gitignore)
```

Configuration files remain at the repository root (`hardhat.config.ts`, `package.json`, `tsconfig.json`) to keep standard Hardhat conventions.

## Contracts

### `code/contracts/Goodies42.sol`

Implements the core ERC20 functions:

- `transfer`
- `approve`
- `transferFrom`
- `mint` (owner only)

Security/ownership:

- `onlyOwner` on sensitive functions
- 2-step ownership transfer: `transferOwnership` then `acceptOwnership`
- ownership can be transferred to a multisig

> [link to ERC20 standard](https://ethereum.org/fr/developers/docs/standards/tokens/erc-20/)

### `code/contracts/Goodies42Shop.sol`

Handles item purchases through `buy`:

- on-chain price check via `itemPrice[itemId]`
- bonus access (`LotteryAccess`) if the answer is correct
- otherwise transfers token payment to the shop treasury
- max `LotteryAccess` per user: `3`
- admin withdrawal available via `withdrawTokens`

## Purchase Flow (student wallet)

Standard dApp flow:

1. Student connects wallet (MetaMask) to the dApp.
2. dApp reads on-chain price with `itemPrice(itemId)`.
3. dApp checks token allowance for `Goodies42Shop`.
4. If allowance is too low, dApp requests `approve(shopAddress, price)`.
5. Student confirms the `approve` transaction in wallet.
6. dApp then sends `buy(itemId, answer)`.
7. Student confirms the `buy` transaction in wallet.
8. Contract applies the rule:
   - valid bonus: no token payment, `LotteryAccess` is consumed
   - otherwise: `transferFrom(student, shop, price)`
9. Backend can confirm purchase by reading the on-chain `ItemPurchased` event.

## Commands

Via Makefile:

```bash
make install
make compile
make test
make node
make deploy-local
make deploy-sepolia
```

## Why an RPC Provider Is Required

To deploy on Sepolia, Hardhat must connect to an Ethereum node through an RPC URL.

- Target blockchain is Sepolia, but access is through an RPC provider (Alchemy, Infura, QuickNode, etc.)
- Without a valid RPC URL, the project cannot read chain state or broadcast deployment transactions.
- Public endpoints may exist, but they are often rate-limited or unstable.

Required variables:

- `SEPOLIA_RPC_URL`: HTTP URL of the Sepolia RPC provider.
- `PRIVATE_KEY`: private key of the deployment wallet (dedicated testnet wallet).

Prepare Sepolia environment:

```bash
cp .env.example .env
# then fill SEPOLIA_RPC_URL and PRIVATE_KEY in .env
```

Without Makefile:

```bash
npx hardhat compile
npx hardhat test
npx hardhat ignition deploy ./deployment/ignition/modules/Goodies42Core.ts --network localhost
npx hardhat ignition deploy ./deployment/ignition/modules/Goodies42Core.ts --network sepolia
```

## Public Deployment (to complete)

- Goodies42 (Sepolia): `0xaDf4D6A3889962F5EF5658a813C75f7c922334ED`
- Etherscan link :`https://sepolia.etherscan.io/address/0x44cb13253644ab230b52726235d378aa5e33e16b#code`
- Goodies42Shop (Sepolia): `0x15a97d74EC9aE403E791B9A59F8656dE8a6Cc750`
- Etherscan link: `https://sepolia.etherscan.io/address/0x15a97d74EC9aE403E791B9A59F8656dE8a6Cc750#code`

## Whitepapers

See [WHITEPAPER FR](documentation/WHITEPAPER_FR.md) and [WHITEPAPER US](documentation/WHITEPAPER_US.md).
