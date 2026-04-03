# Goodies42 - Whitepaper

**Version:** 1.0  
**Date:** April 2026  
**Blockchain:** Ethereum Sepolia (Testnet)  
**Standard:** ERC20  

---

## 1. Executive Summary

Goodies42 is a next-generation utility token designed for the educational ecosystem of 42 school. This whitepaper describes the architecture, tokenomics, game mechanics, and governance model of a blockchain-based reward system built on Ethereum.

The main goals are:
- **Reward student academic progress** with tangible value
- **Create an internal economic system** to buy school goodies
- **Introduce an innovative free-lottery mechanism** that encourages excellence
- **Ensure transparency and decentralization** through blockchain technology

The system relies on two complementary smart contracts:
- **Goodies42**: a standard ERC20 contract managing token creation, transfer, and balances
- **Goodies42Shop**: an application-level contract implementing spending rules

---

## 2. Context and Motivation

### 2.1 Problem Statement
Traditional reward systems often lack **transparency**, **portability**, and **tangible value** for learners. Digital badges and certificates are not always transferable or usable in a real on-chain economy.

### 2.2 Our Solution
Goodies42 provides a blockchain-based system that:
- Issues verifiable on-chain tokens
- Enables transparent exchange and transfer
- Builds a real internal economy around 42 goodies
- Positions 42 school as a Web3 gamification pioneer

### 2.3 Alignment with 42 Values
- **Hands-on learning**: building and deploying real smart contracts
- **Autonomy**: students manage their own wallet through MetaMask
- **Community**: a shared ecosystem that rewards progress

---

## 3. Technical Specifications

### 3.1 Token Parameters

| Parameter | Value |
|-----------|-------|
| Full name | Goodies42 |
| Symbol | GDS42 |
| Decimals | 18 |
| Initial supply | 42,000,000 GDS42 |
| Standard | ERC20 |
| Blockchain | Ethereum Sepolia (Testnet) |
| Language | Solidity 0.8.28 |

### 3.2 Contract Architecture

#### 3.2.1 Goodies42 Contract (ERC20)

**Responsibilities:**
- Track each account balance
- Transfer tokens between users (`transfer`, `transferFrom`)
- Manage approvals (`approve`, `allowance`)
- Owner-controlled minting (`mint`)
- Expose token metadata (name, symbol, decimals)

**Main functions:**
```solidity
transfer(address to, uint256 amount) -> bool
transferFrom(address from, address to, uint256 amount) -> bool
approve(address spender, uint256 amount) -> bool
mint(address to, uint256 amount) -> void
transferOwnership(address newOwner) -> void
acceptOwnership() -> void
```

**Security model:**
- Manual ERC20 implementation (no OpenZeppelin inheritance)
- Strict validation for zero addresses and balances
- Two-step ownership transfer to prevent mistakes

#### 3.2.2 Goodies42Shop Contract

**Responsibilities:**
- Manage on-chain goodies catalog and prices in GDS42
- Execute purchase flow with or without LotteryAccess
- Manage special access rights for high-performing students
- Allow admin treasury withdrawals

**Main functions:**
```solidity
buy(uint256 itemId, string memory answer) -> void
setItemPrice(uint256 itemId, uint256 priceInTokens) -> void
grantAccess(address student) -> void
withdrawTokens(address to, uint256 amount) -> void
```

**Behavior:**
- Standard purchases charge `priceInTokens * 10^18`
- LotteryAccess purchases require a valid answer hash
- No token payment if answer is correct and access exists

---

## 4. Tokenomics

### 4.1 Initial Distribution

**Total Supply:** 42,000,000 GDS42 (pre-minted at deployment)

| Destination | Amount | Rationale |
|------------|--------|-----------|
| 42 school treasury | 42,000,000 | Full reserve for progressive distribution |

### 4.2 Student Rewards

Distribution follows objective academic milestones:

#### 4.2.1 Piscine (Bootcamp)
- **Reward:** 50 GDS42
- **Condition:** Successful validation of required piscine projects
- **Purpose:** Reward initial commitment
- **Frequency:** Once per student

#### 4.2.2 Core Projects (CPP grouped by circle)
- **100% validation:** 25 GDS42
- **125% validation:** 50 GDS42 + potential bonus
- **125% + Outstanding:** 50 GDS42 + **1 LotteryAccess**
- **Purpose:** Incentivize excellence and innovation
- **Frequency:** Per project

#### 4.2.3 Circle Certification
- **Reward:** 50 GDS42
- **Condition:** Validation of one circle
- **Purpose:** Recognize acquired expertise
- **Frequency:** Once per completed circle

#### 4.2.4 Transcendence
- **Reward:** 200 GDS42
- **Condition:** Transcender status reached
- **Purpose:** Celebrate full curriculum completion
- **Frequency:** Once per student

#### 4.2.5 Common Core Estimate (Baseline)

Baseline assumptions for one student in the common core:
- 7 circles x 50 GDS42 = 350 GDS42
- 17 projects x 25 GDS42 = 425 GDS42
- Transcendence = 200 GDS42

Estimated common-core total: **975 GDS42**.

Common-core duration ranges from 8 to 24 months, with a 16-month average.
Annualized at that average pace:
- 975 / 16 = 60.9 GDS42/month
- 60.9 x 12 = **~731 GDS42/year**

After common core, emissions are mostly project-driven (no circles), which typically reduces milestone-based bonuses and ties rewards more closely to project pace.

### 4.3 Supply Cap and Inflation

Goodies42 follows a **stable utility** model, not a speculative one.
Goodies prices are governance-controlled (periodic updates), not market-priced in real time.

- **Initial reserve:** 42,000,000 GDS42 in treasury at deployment
- **Minting:** allowed but strictly governed (owner first, multisig target)
- **Emission policy:** predefined yearly budget, publicly published and traceable on-chain
- **Transparency:** every mint is auditable through blockchain events

**Economic choices:**
- Goodies are priced in GDS42 with stable prices by period (for example, quarterly)
- Prices can be adjusted by governance based on real costs (inventory, logistics)
- A fraction of spent tokens can be burned, and another fraction recycled to treasury

**Operational scale assumptions:**
- Average yearly reward per student: 500 to 800 GDS42
- Common-core reference (average): ~731 GDS42/year
- 42 Angouleme (~400 students): estimated emissions ~200,000 to 320,000 GDS42/year
- 42 Network (~50 campuses x 400 = ~20,000 students): estimated emissions ~10,000,000 to 16,000,000 GDS42/year

**Strategic implication:**
- At single-campus scale, 42M can cover many decades
- At full network scale, 42M alone may become insufficient depending on emission pace
- Long-term sustainability therefore relies on yearly budgeting, reward adjustments, and burn/recycling mechanics

**Internal tracking formula:**
- Yearly emission: E = N x R
- Theoretical reserve duration: T = 42,000,000 / E
  - N = number of active students
  - R = average yearly reward per student

---

## 5. Consumption Mechanics

### 5.1 Standard Purchase

A student buys an item without LotteryAccess:

```
1. Read on-chain price: itemPrice[itemId] = 50 * 10^18
2. Approve shop spending: approve(shopAddress, 50 * 10^18)
3. Call buy(itemId, "wrong-answer-or-empty")
4. Tokens are transferred: shop receives 50 * 10^18
5. Student receives item
```

**Cost:** 50 GDS42 + Ethereum gas fees

### 5.2 LotteryAccess Purchase (Free)

A student uses bonus access for a free purchase:

```
1. userLotteryAccessCount[student] = 1 (earned through "outstanding")
2. Call buy(itemId, "42")  // correct answer
3. Validation: keccak256("42") == HASH_ANSWER
4. Result: no token deduction, LotteryAccess consumed
5. Student receives item for free
```

**Cost:** 0 GDS42 (except gas)

### 5.3 LotteryAccess with Wrong Answer

Student has access but gives a wrong answer:

```
1. userLotteryAccessCount[student] = 1
2. Call buy(itemId, "wrong-answer")
3. Validation: keccak256("wrong-answer") != HASH_ANSWER
4. Result: full token payment and LotteryAccess consumed
5. Student pays full price
```

**Cost:** item price in GDS42

### 5.4 LotteryAccess Rules

| Aspect | Detail |
|--------|--------|
| **How to earn** | One project validated at "125% + Outstanding" |
| **Maximum per student** | 3 (soft cap) |
| **Lifetime** | Unlimited until used |
| **Territorial validity** | Intended to be valid across 42 shops (future multi-campus) |
| **Transferability** | No (bound to recipient address) |
| **Reset** | No (consumed once used) |

---

## 6. Governance and Security

### 6.1 Ownership Model

#### Two-Step Ownership Transfer

To reduce transfer mistakes:

```solidity
// Step 1: current owner initiates
transferOwnership(newOwnerAddress)
// -> pendingOwner = newOwnerAddress

// Step 2: new owner confirms
acceptOwnership()
// -> owner = pendingOwner, pendingOwner = 0x0
```

**Benefit:** protects against wrong-address mistakes.

### 6.2 Access Control

**Protected functions:**
- `mint()` : onlyOwner
- `setItemPrice()` : onlyOwner
- `grantAccess()` : onlyOwner
- `transferOwnership()` : onlyOwner
- `withdrawTokens()` : onlyOwner

**Rationale:**
- Only 42 staff can validate and issue rewards
- Full on-chain traceability of distributions

### 6.3 Answer Security

**Stored as hash:**
```solidity
bytes32 public constant HASH_ANSWER =
  0xccb1f717aa77602faf03a594761a36956b1c4cf44c6b336d1db57da799b331b8;
// keccak256("42")
```

**Benefits:**
- Answer is never stored in plain text
- One-way hash prevents direct leakage
- Can be changed by deploying a new shop contract

### 6.4 Attack Mitigations

| Threat | Mitigation |
|--------|-----------|
| Reentrancy | No dangerous external call path; checks-effects pattern |
| Integer Overflow | Solidity 0.8.28 checked arithmetic |
| Front-running | Purchase flow is executed atomically in `buy` |
| User phishing impact | Only staff can mint (centralized control) |
| Double-spend | Ethereum state consistency guarantees uniqueness |

### 6.5 Audit and Verification

- **Tested contracts:** 43 passing unit tests
- **Coverage:** ~95% on critical paths
- **Timelock:** not enabled for test setup, planned for production
- **Upgrade model:** no proxy (immutability favored for trust)

---

## 7. Path to Multisig (Bonus)

For stronger production-grade security:

### 7.1 Goodies42Management Contract

Multisignature for sensitive actions:

```solidity
contract Goodies42Management {
    address[] public managers;
    uint256 public signaturesRequired;

    // Used to:
    // - approve high-impact mints
    // - change critical pricing settings
    // - transfer ownership
}
```

### 7.2 Process

1. A transaction is proposed (mint, setPrice, etc.)
2. Managers sign (minimum 2/3)
3. Once threshold is reached, execution is allowed
4. All actions remain permanently traceable

---

## 8. Deployment and Verification

### 8.1 Network and Addresses

| Item | Value |
|------|-------|
| Blockchain | Ethereum Sepolia |
| Token address | To be filled after deployment |
| Shop address | To be filled after deployment |
| Chain ID | 11155111 |

### 8.2 Etherscan Verification

All contracts should be publicly verified on Etherscan:
- Readable source code
- Verifiable constructor arguments
- Public ABI and contract methods

---

## 9. Roadmap for Real Deployment

### Phase 1: Testing (March - April 2026)
- Deploy on Sepolia
- Pilot tests with 10-20 students
- MetaMask integration

### Phase 2: Educational Validation (May - June 2026)
- Rollout to current cohort
- Collect student and staff feedback
- Tune reward settings

### Phase 3: Expansion (Q3 2026)
- Integrate 42 intra API for automated minting
- Deliver dedicated shop web interface
- Support multi-campus setup

### Phase 4: Productionization (Future)
- Migrate to Ethereum mainnet or an L2
- Full multisig governance
- Integrate with external purchase partners

---

## 10. Risks and Limitations

### 10.1 Technical Risks
- **Network congestion:** unpredictable gas fees
- **Contract bugs:** mitigated through tests and recommended audits
- **Private key loss:** students remain responsible for wallet custody

### 10.2 Economic Risks
- **Inflation risk from abuse:** requires strict mint governance
- **Off-chain abuse/scams:** social layer cannot be fully prevented by smart contracts

### 10.3 Design Limitations
- **LotteryAccess is non-transferable:** by design
- **Public chain visibility:** purchases are traceable, not private
- **School-bound utility:** value is mainly inside the 42 ecosystem

---

## 11. Conclusion

Goodies42 combines **education**, **gamification**, and **blockchain** into a practical learning economy. By rewarding academic outcomes with transparent digital assets, the project turns Web3 concepts into real student-facing workflows.

Goodies42 is not designed as a speculative asset. It is a **practical educational token**.

---

**Validated by:** 42 School (Tokenizer Project)  
**Last update:** April 2, 2026  
**Next review:** After Sepolia deployment
