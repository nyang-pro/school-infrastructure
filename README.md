# school-infrastructure (WIP)

## Description
Dépôt qui permet de partager les scripts pour la mise en place d'une infrastructure virtualisée
C'est un projet de formation qui permet de mettre en pratique des compétences réseaux et de virtualisation.

## Table des matières

## Fonctionnalités
- **Hyper-V** : contient les VM OPNsense et Proxmox VE.
  - **OPNsense** :  VM qui permet à la LAN Kiformatou d'accéder à Internet. Il segmente le LAN avec des VLAN et sert de serveur DHCP.
  - **Proxmox VE** : hyperviseur de type 1 qui contient les machines de l'infrastructure (serveurs et postes de travail).
    - **Serveur Active Directory + Domain Service + DNS** : WIP.
    - **Serveur Nextcloud** : serveur de partage de fichiers.
    - **Serveur Proxmox Backup server** : serveur de sauvegarde.
    - **Poste de travail étudiant** : contient le service Veyon Client.
    - **Ordinateur portable enseignant** : contient le service Veyon Master pour superviser un poste étudiant.

## Technologies
- Hyper-V
- OPNSense
- NAT
- VLAN
- DHC
- Pare-feu
- Proxmox VE
- Active Directory + Domain Service
- DNS
- Serveur Ubuntu
- Nextcloud
- Proxmox Backup Server
- Windows 10 Desktop
