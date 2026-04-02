# Goodies42 — Whitepaper (version courte)

## Vision
Goodies42 est un token utilitaire pour valoriser la progression des étudiants 42 et servir de monnaie interne pour l’achat de goodies.
Afin d'assurer un compatibilité totale avec les smarts contracts de la norme ERC20 et de pouvoir interagir avec tout l'univers ERC20, les transaction, les interactions avec les wallets, j'ai fait deux contrats:
 - Goodies42 norme strict ERC20
 - Goodies42Shop règle spécifique de l'utilisation du token

## Utilité
- Récompenser les étapes de parcours (piscine, projets, cercle, transcendance)
- Permettre des achats via `Goodies42Shop`
- Ajouter une mécanique bonus (`LotteryAccess`) limitée à 3

## Modalité d'attribution des token Goodies42
 - validation piscine 100 Goodies42
 - validation de projet 
    - à 100% = 50 Goodies42
    - à 125% = 100 Goodies42
    - à 125% + toutes les corrections avec "outstanding project"= 100 Goodies42 + 1 LotteryAccess
 - validation cercle 100 Goodies42
 - transcender 500 Goodies42

## Token
- Nom: `Goodies42`
- Symbole: `GDS42`
- Décimales: `18`
- Standard: ERC20 (réécriture des fonctions clés)

## Mécanique de consommation
- Achat standard: transfert de token vers la trésorerie du shop (`transferFrom`)
- Achat bonus: si `LotteryAccess` + bonne réponse, pas de paiement en token

## Gouvernance et sécurité
- Fonctions sensibles protégées par `onlyOwner`
- Transfert de propriété en 2 étapes (`transferOwnership` + `acceptOwnership`)
- Compatibilité prévue pour transfert de propriété vers un multisig
