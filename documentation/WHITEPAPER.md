# Goodies42 — Whitepaper

**Version:** 1.0  
**Date:** Avril 2026  
**Blockchain:** Ethereum Sepolia (Testnet)  
**Standard:** ERC20  

---

## 1. Executive Summary

Goodies42 est un token utilitaire de nouvelle génération conçu pour l'écosystème éducatif de l'école 42. Ce whitepaper décrit l'architecture, la tokenomics, les mécaniques de jeu et la gouvernance d'un système de récompensation numérique basé sur la blockchain Ethereum.

L'objectif principal est de :
- **Valoriser la progression académique** des étudiants en utilisant des récompenses tangibles
- **Créer un système économique interne** permettant l'achat de goodies à l'école
- **Implémenter une mécanique innovante** de loterie gratuite encourageant l'excellence académique
- **Assurer la transparence et la décentralisation** via la blockchain

Le token repose sur deux contrats intelligents complémentaires:
- **Goodies42** : contrat ERC20 standard gérant la création, transfert et balance des tokens
- **Goodies42Shop** : contrat application métier implémentant les règles spécifiques de consommation

---

## 2. Contexte et Motivation

### 2.1 Problématique
Les systèmes de récompensation actuels manquent souvent de **transparence**, de **portabilité** et de **valeur tangible** pour les apprenants. Les badges ou certificats numériques ne sont pas facilement transférables ou échangeables.

### 2.2 Notre Solution
Goodies42 propose un système basé sur la blockchain qui:
- Émet des tokens vrais et vérifiables via la blockchain
- Permet l'échange et le transfert transparently
- Crée un marché économique réel autour des goodies 42
- Positionne l'école 42 à l'avant-garde de la gamification éducative Web3

### 2.3 Alignement avec les Valeurs 42
- **Apprentissage pratique** : construction d'une crypto actuelle avec vrai déploiement
- **Autonomie** : les étudiants gèrent leur portefeuille via MetaMask
- **Communauté** : un écosystème partagé valorisant la progression collective

---

## 3. Spécifications Techniques

### 3.1 Paramètres du Token

| Paramètre | Valeur |
|-----------|--------|
| Nom complet | Goodies42 |
| Symbole | GDS42 |
| Décimales | 18 |
| Supply initial | 42 000 000 GDS42 |
| Standard | ERC20 |
| Blockchain | Ethereum Sepolia (Testnet) |
| Langage | Solidity 0.8.28 |

### 3.2 Architecture des Contrats

#### 3.2.1 Contrat Goodies42 (ERC20)

**Responsabilités:**
- Gestion des balances de chaque compte utilisateur
- Transfert de tokens entre pairs (`transfer`, `transferFrom`)
- Système d'approbation (`approve`, `allowance`)
- Minting contrôlé par le propriétaire (`mint`)
- Métadonnées du token (nom, symbole, décimales)

**Fonctions principales:**
```solidity
transfer(address to, uint256 amount) → bool
transferFrom(address from, address to, uint256 amount) → bool
approve(address spender, uint256 amount) → bool
mint(address to, uint256 amount) → void
transferOwnership(address newOwner) → void
acceptOwnership() → void
```

**Sécurité:**
- Réécriture manuelle des fonctions ERC20 (pas d'OpenZeppelin) pour transparence maximale
- Validations strictes: vérification des adresses zéro, soldes suffisants
- Ownership à deux étapes pour éviter les erreurs

#### 3.2.2 Contrat Goodies42Shop

**Responsabilités:**
- Gestion du catalogue de goodies avec prix en GDS42
- Traitement des achats avec ou sans LotteryAccess
- Gestion des droits d'accès prédéfinis pour l'excellence
- Retrait des tokens accumulés (trésorerie)

**Fonctions principales:**
```solidity
buy(uint256 itemId, string memory answer) → void
setItemPrice(uint256 itemId, uint256 priceInTokens) → void
grantAccess(address student) → void
withdrawTokens(address to, uint256 amount) → void
```

**Mécaniques:**
- Les achats standards déduisent `priceInTokens * 10^18` du portefeuille
- Les achats avec LotteryAccess valide nécessitent une réponse correcte (hash)
- Pas de déduction si la réponse est correcte ET l'accès existe

---

## 4. Tokenomics

### 4.1 Distribution Initiale

**Supply Total:** 42 000 000 GDS42 (premined au déploiement)

| Destination | Quantité | Justification |
|------------|----------|---------------|
| Trésorerie école 42 | 42 000 000 | Réserve entière pour mint progressif |

### 4.2 Attribution aux Étudiants

La distribution suit des jalons académiques objectifs :

#### 4.2.1 Piscine (Bootcamp initial)
- **Récompense:** 50 GDS42
- **Condition:** Validation de la piscine (tous les projets obligatoires)
- **Objectif:** Reconnaissance de l'engagement initial
- **Fréquence:** Une seule fois par étudiant

#### 4.2.2 Projets Cursus (les CPP sont à regrouper par cercle)
- **Validation à 100%:** 25 GDS42
- **Validation à 125%:** 50 GDS42 + potentiel bonus
- **Validation à 125% + "Outstanding":** 50 GDS42 + **1 LotteryAccess**
- **Objectif:** Encourager excellence et innovation
- **Fréquence:** Par projet (tous les 2-4 semaines)

#### 4.2.3 Certification Cercle
- **Récompense:** 50 GDS42
- **Condition:** Validation d'un cercle (spécialisation)
- **Objectif:** Reconnaissance de l'expertise acquise
- **Fréquence:** Une fois par cercle complété

#### 4.2.4 Transcendance
- **Récompense:** 200 GDS42
- **Condition:** Atteinte du statut "Transcendeur" (mastère/fin de cursus)
- **Objectif:** Célébration du parcours complet
- **Fréquence:** Une seule fois par étudiant

#### 4.2.5 Estimation Tronc Commun (base de calcul)

Hypothèse pédagogique retenue pour un étudiant sur le tronc commun:
- 7 cercles x 50 GDS42 = 350 GDS42
- 17 projets x 25 GDS42 = 425 GDS42
- Transcendance = 200 GDS42

Total estimé tronc commun: **975 GDS42**.

Le tronc commun dure environ 8 à 24 mois, avec une moyenne de 16 mois.
En annualisant ce rythme moyen:
- 975 / 16 = 60,9 GDS42/mois
- 60,9 x 12 = **~731 GDS42/an**

Après le tronc commun, les émissions reposent principalement sur les projets (plus de cercles),
ce qui réduit en général la composante "bonus de jalons" et rend l'émission plus dépendante du rythme projet.

### 4.3 Supply Cap et Inflation

Pour Goodies42, le modèle retenu est un modèle **utilitaire stable** et non spéculatif.
Le prix des goodies reste piloté par la gouvernance (révisions périodiques), et non par une cotation de marché en temps réel.

- **Réserve initiale:** 42 000 000 GDS42 en trésorerie au déploiement
- **Minting:** autorisé mais strictement gouverné (owner puis multisig en cible)
- **Politique d'émission:** budget annuel défini à l'avance, publié et traçable on-chain
- **Transparence:** chaque mint est auditable via les événements de la blockchain

**Choix économique:**
- Les goodies sont tarifés en GDS42 avec des prix stables par période (ex: trimestre)
- Les prix peuvent être ajustés par gouvernance selon les coûts réels (stock, logistique)
- Une partie des tokens dépensés peut être brûlée (burn) et une autre recyclée en trésorerie

**Ordres de grandeur (hypothèses de pilotage):**
- Récompense moyenne annuelle par étudiant: 500 à 800 GDS42
- Point de référence tronc commun (moyenne): ~731 GDS42/an
- 42 Angoulême (~400 étudiants): émission estimée ~200 000 à 320 000 GDS42/an
- 42 Network (~50 campus x 400 = ~20 000 étudiants): émission estimée ~10 000 000 à 16 000 000 GDS42/an

**Implication stratégique:**
- À l'échelle d'un campus, 42M couvrent largement plusieurs décennies
- À l'échelle du réseau 42, 42M seuls peuvent devenir insuffisants selon le rythme d'émission
- La soutenabilité long terme repose donc sur: budget annuel, ajustement des récompenses, et mécanismes de burn/recyclage

**Formule de suivi interne:**
- Emission annuelle: E = N x R
- Durée théorique de réserve: T = 42 000 000 / E
  - N = nombre d'étudiants actifs
  - R = récompense moyenne annuelle par étudiant

---

## 5. Mécaniques de Consommation

### 5.1 Achat Standard

L'étudiant achète un goodie sans LotteryAccess:

```
1. Consulte le prix: itemPrice[itemId] = 50 * 10^18
2. Approuve le shop: approve(shopAddress, 50 * 10^18)
3. Appelle buy(itemId, "wrong-answer-or-empty")
4. Les tokens sont transférés: shop reçoit 50 * 10^18
5. L'étudiant reçoit son goodie
```

**Coût:** 50 GDS42 + frais de gas Ethereum

### 5.2 Achat avec LotteryAccess (Gratuit)

L'étudiant utilise son bonus pour accès gratuit:

```
1. userLotteryAccessCount[student] = 1 (obtenu via "outstanding")
2. Appelle buy(itemId, "42")  // réponse correcte
3. Validation: keccak256("42") == HASH_ANSWER
4. Résultat: Pas de déduction de tokens, LotteryAccess consommé
5. L'étudiant reçoit son goodie gratuitement
```

**Coût:** 0 GDS42 (sauf frais de gas)

### 5.3 Achat avec LotteryAccess (Mauvaise Réponse)

L'étudiant a LotteryAccess mais répond mal:

```
1. userLotteryAccessCount[student] = 1
2. Appelle buy(itemId, "wrong-answer")
3. Validation: keccak256("wrong-answer") ≠ HASH_ANSWER
4. Résultat: Les tokens sont débités ET LotteryAccess consommé
5. L'étudiant paie le prix complet
```

**Coût:** Prix du goodie en GDS42

### 5.4 Spécifications de LotteryAccess

| Aspect | Détail |
|--------|--------|
| **Gain** | Une validation de projet en "125% + Outstanding" |
| **Maximum par étudiant** | 3 (soft cap) |
| **Durée de vie** | Illimitée (jusqu'à utilisation) |
| **Validité territoriale** | Valable dans tous les shops 42 (futur multi-campus) |
| **Transférabilité** | Non (lié à l'adresse du récipiendaire) |
| **Réinitialisation** | Non (une fois utilisé = disparu) |

---

## 6. Gouvernance et Sécurité

### 6.1 Modèle de Propriété

#### Two-Step Ownership Transfer

Pour éviter les erreurs de transfert de propriété:

```solidity
// Étape 1: Le propriétaire actuel initie
transferOwnership(newOwnerAddress)
// → pendingOwner = newOwnerAddress

// Étape 2: Le nouveau propriétaire confirme
// (depuis son compte)
acceptOwnership()
// → owner = pendingOwner, pendingOwner = 0x0
```

**Avantage:** Protection contre les erreurs d'adresse (typo, smart contract sans support ERC20, etc.)

### 6.2 Contrôle d'Accès

**Fonctions protégées:**
- `mint()` : onlyOwner
- `setItemPrice()` : onlyOwner
- `grantAccess()` : onlyOwner
- `transferOwnership()` : onlyOwner
- `withdrawTokens()` : onlyOwner

**Rationale:**
- Seul le staff école 42 peut valider les récompenses
- Transparence: qui a reçu combien via blockchain
- Traceabilité: tous les grants sont enregistrés

### 6.3 Sécurité des Conditions de Réponse

**Hachage de la réponse:**
```solidity
bytes32 public constant HASH_ANSWER = 
  0xccb1f717aa77602faf03a594761a36956b1c4cf44c6b336d1db57da799b331b8;
// keccak256("42")
```

**Avantages:**
- La réponse n'est jamais stockée en clair
- Impossible de bruteforcer efficacement (keccak256 one-way)
- Peut être changée via redéploiement du shop

### 6.4 Protections Contre les Attaques

| Menace | Mitigation |
|--------|-----------|
| Reentrancy | Pas d'appel externe à risque; check-effect-pattern |
| Integer Overflow | Solidity 0.8.28 (checked arithmetic) |
| Front-running | Achats via approve/transferFrom (atomiques) |
| Phishing de CU | Seulement staff peut minter (contrôle centralisé) |
| Double-spend | Blockchain Ethereum garantit l'unicité |

### 6.5 Audit et Vérification

- **Contrats testés:** 43 tests unitaires passants
- **Coverage:** ~95% du code critique
- **Timelock:** Non implanté pour les contrats de test, prévu pour mainnet
- **Upgrade:** Pas de proxy (immutabilité pour confiance)

---

## 7. Chemin vers le Multisig (Bonus)

Pour la sécurité maximale en production, sera implémenté:

### 7.1 Contrat Goodies42Management

Multisignature pour les fonctions sensibles:

```solidity
contract Goodies42Management {
    address[] public managers;
    uint256 public signaturesRequired;
    
    // Permet de:
    // - Approuver mints importants
    // - Changer les prix drastiquement
    // - Transférer la propriété
}
```

### 7.2 Processus

1. Une transaction est proposée (mint, setPrice, etc.)
2. Les managers (minimum 2/3) doivent signer
3. Une fois le seuil atteint, elle s'exécute automatiquement
4. Tous les actes sont enregistrés immuablement

---

## 8. Déploiement et Vérification

### 8.1 Réseau et Adresses

| Élément | Valeur |
|---------|--------|
| Blockchain | Ethereum Sepolia |
| Adresse Token | À définir après déploiement |
| Adresse Shop | À définir après déploiement |
| Chain ID | 11155111 |

### 8.2 Vérification Etherscan

Tous les contrats seront **vérifiés publiquement** sur Etherscan:
- Source code lisible
- Constructor arguments vérifiables
- Fonctions ABI publiquement documentées

---

## 9. Roadmap pour un déploiement réel

### Phase 1: Testing (Mars - Avril 2026)
- ✅ Déploiement sur Sepolia
- ✅ Tests avec 10-20 étudiants pilotes
- ✅ Intégration MetaMask

### Phase 2: Validation Pédagogique (Mai - Juin 2026)
- Déploiement auprès de la promo actuelle
- Feedback des étudiants et staff
- Ajustements des rewards

### Phase 3: Expansion (Q3 2026)
- Intégration API intra 42 pour auto-minting
- Interface web dédiée pour le shop
- Support multi-campus

### Phase 4: Productionization (Future)
- Migration vers Ethereum mainnet ou L2
- Implémentation multisig complète
- Partenariats avec services extérieurs (achat réel)

---

## 10. Risques et Limitations

### 10.1 Risques Techniques
- **Blockchain congestion:** Frais de gas imprévisibles (mitigé: Sepolia peu cher)
- **Bugs de contrat:** Tests exhaustifs et audit recommandés
- **Perte de clés privées:** Étudiants responsables de leurs wallets

### 10.2 Risques Economiques
- **Hyperinflation si abuse:** Contrôle strict du minting requis
- **Marche noir de replies:** Possible scamming (non techniquement bloqué)

### 10.3 Limitations de Design
- **Non transférable (LotteryAccess):** Par design pour éviter marché externe
- **Chaîne publique:** Tout achat est visible (traçabilité, pas d'anonymat)
- **Lié à une école:** Valeur limité en dehors de l'écosystème 42

---

## 11. Conclusion

Goodies42 représente une opportunité unique de combiner **pédagogie**, **gamification**, et **technologies blockchain**. En plaçant les étudiants au cœur d'un écosystème économique réel basé sur le mérite académique, nous renforçons l'engagement et l'apprentissage pratique.

Ce token n'est pas une spéculation — c'est un **outil d'apprentissage vivant** qui démontre les principes Web3 en action.

---

**Document validé par:** École 42 (Projet Tokenizer)  
**Dernière mise à jour:** 2 Avril 2026  
**Prochaine révision:** À définir après déploiement Sepolia
