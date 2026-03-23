# Goodies42 — Whitepaper (version courte)

## Vision
Goodies42 est un token utilitaire pour valoriser la progression des étudiants 42 et servir de monnaie interne pour l’achat de goodies.

## Utilité
- Récompenser les étapes de parcours (piscine, projets, cercle, transcendance)
- Permettre des achats via `Goodies42Shop`
- Ajouter une mécanique bonus (`LotteryAccess`) limitée à 3

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
