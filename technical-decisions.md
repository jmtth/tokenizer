# Projet 
- création de son propre token
- réécriture des fonctions

# Consignes du projet Ecole 42 "tokenizer"
- création token
- nom du token doit contenir 42
- token doit avoir une utilité
- READNE.md doit expliquer les choix que l'on a pris et les raisons
- choisir une blockchain
- on ne nous demande pas d'utiliser de la vraie monnaie
- on doit penser à tous les aspects de sécurité et de propriété et privilèges
- on doit déployer sur un blockchain public de test
- on doit donner l'adresse du smart contract du déploiement public dans le README.md
- faire de la documentation sur tous les aspects du projet, afin de faire comprendre comment cela marche, et ce dont on a besoin pour utiliser le token
- on doit bien expliquer comment le token va être utiliser et ce qu'il représente
- on doit faire un "whitepaper" sur les features et les fonctionnqlités du token
- structure du projet demandées
    - code/ création de token
    - documentation/
    - deployment/
- partie bonus multisig
    - création d'un smart contract qui demande de multuple signature pour exécuter des transactions
    - on est libre du choix du nombre de signatures

# Evaluation du projet
- être capable de faire des operatins minimalistes

# Choix techniques
- standard ERC20
- solidity
- framework hardhat
- blockchain de test Sepolia
- wallet metamask
- test en local puis en testnet
- scripts js pour test en cli avec hardhat hre
- etherscan pour fair des opérations sur le token

# Mon choix de token
- nom : Goodies42
- symbol : GDS42
- decimal : 18
- fichier : Goodies42.sol = réécriture des fonctions ERC20
- fichier : Goodies42Shop.sol = interaction avec le token

**Principe du token**
> token de récompense et d'achat de goodies par les étudiants de 42
> 42 000 sont miner à l'origine (si j'ai le temps, je voudrais valoriser le token avec uniswap sur Base, pour donner la possibilité au étudiant d'acheter des Goodies42)
> puis on mine les récompenses aux étudiants selon les critère ci-dessous

- Obtention de Goodies 42:
 - validation piscine 50 Goodies42
 - validation de projet 
    - à 100% = 25 Goodies42
    - à 125% = 50 Goodies42
    - à 125% + toutes les corrections avec "outstanding project"= 50 Goodies42 + 1 LotteryAccess
 - validation cercle 50 Goodies42
 - transcender 200 Goodies42

- Dépense de Goodies 42 pour l’achat de goodies (exemple mug sur l’intra)
 - si pas LotteryAccess burn normal
 - si LotteryAccess une question est posé et si bonne réponse pas de burn on garde nos token , LotteryAcces n'est valable qu'une fois, il est remis à zéro

- LotteryAcces
 - tous les evals d'un projet avec la mention "outstanding projet" pour en avoir 1
 - on ne peut en avoir maximum 3
 - quand il est utilisé on ne peux plus le réutiliser