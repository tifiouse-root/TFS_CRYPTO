# TFS Crypto - Script de Crypto pour FIVEM

<p align="center">
  <img src="https://cdn.discordapp.com/attachments/1291112806451511369/1300131722381361152/FiveM_GTA_V_Logo.png?ex=671fb985&is=671e6805&hm=1ad9f041a278429449b639691945a5986bc0c61f6198aec86f1111ff5fd93734&" alt="Logo" width="300" height="100"/>
</p>

## 📜 Description

TFS Crypto est un script pour FiveM qui permet aux joueurs de créer et gérer des entrepôts de crypto-monnaie dans le jeu. Avec une interface utilisateur, les utilisateurs peuvent acheter, vendre et améliorer leurs équipements pour maximiser leurs profits.

## 📈 Fonctionnalités

- **Création d'entrepôts** : Créez et gérez des entrepôts de crypto-monnaie.
- **Système de profit** : Gagnez des bénéfices en fonction du niveau de votre entrepôt.
- **Améliorations** : Améliorez vos équipements pour augmenter les profits.
- **Factures d'électricité** : Gérez les coûts associés à l'exploitation de votre entrepôt.

## 💻 Installation

1. Téléchargez le script depuis le [lien de téléchargement](https://github.com/tifiouse-root/TFS_CRYPTO/archive/refs/heads/main.zip).
2. Décompressez le fichier et placez le dossier `TFS_crypto` dans votre dossier `resources` de votre serveur FiveM.
3. Ajoutez `ensure TFS_crypto` à votre fichier `server.cfg`.

## 📜 Configuration

Le fichier `config.lua` contient les paramètres de configuration. Modifiez les options selon vos besoins.

### 📜 Exemples de configuration :

```lua
Config.OldESX = false -- utilisez true si vous utilisez ESX 1.1
Config.Admin = "admin" -- nom du groupe admin qui peut créer des entrepôts 
```

## 🧪 Commandes

- **/create_cryptohouse** : Crée un nouvel entrepôt de crypto.
  - `prix` : Prix de vente de l'entrepôt.

## 🟣 Traductions

Le script prend en charge plusieurs traductions. Assurez-vous de personnaliser les messages dans le fichier `config.lua` pour répondre à vos besoins.

## License

Ce projet est sous licence [MIT](#).
```
# Licence MIT

Copyright (c) [2024] [Tifiouse]

## Conditions de la Licence

Par la présente, il est accordé, sans frais, à toute personne obtenant une copie de ce script (TFS_CRYPTO) et des fichiers de documentation associés, le droit de traiter le Script sans restriction, y compris, sans limitation, le droit de l'utiliser, de le copier, de le modifier, de le fusionner, de le publier, de le distribuer, de le sous-licencier et/ou de vendre des copies du Script, et de permettre aux personnes à qui le Script est fourni de le faire, sous réserve des conditions suivantes :

1. Attribution : L'avis de copyright ci-dessus et cet avis de permission doivent être inclus dans toutes les copies ou parties substantielles du Script.

2. Utilisation : Vous pouvez utiliser ce script dans des projets personnels ou commerciaux tant que vous respectez les conditions de cette licence.

3. Exclusion de garantie : LE SCRIPT EST FOURNI "EN L'ÉTAT", SANS GARANTIE D'AUCUNE SORTE, EXPRESSE OU IMPLICITE, Y COMPRIS MAIS SANS S'Y LIMITER AUX GARANTIES DE COMMERCIALISATION, D'ADÉQUATION À UN USAGE PARTICULIER ET DE NON-CONTREFAÇON. EN AUCUN CAS, L'AUTEUR OU LES TITULAIRES DU DROIT D'AUTEUR NE POURRONT ÊTRE TENUS RESPONSABLES DE QUELQUE RECLAMATION, DOMMAGES OU AUTRES RESPONSABILITÉS, QUE CE SOIT DANS UNE ACTION EN CONTRAT, EN DÉLIT OU AUTRE, DÉCOULANT DE OU EN LIEN AVEC LE SCRIPT OU L'UTILISATION OU D'AUTRES TRAITEMENTS DANS LE SCRIPT.
```
