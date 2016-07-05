# afpa-terraform
onstruire une infra EC2, Security_group avec Git et transfert de fichier en utilisant Terraform


# INSTALLATION :
Télécharger et décompresser le zip terraform
https://www.terraform.io/downloads.html

# CONFIGURATION :
Dans le fichier .bash_profile ajouter la ligne suivante :
export PATH=$PATH:<path-terraform>/bin

# Vérification de l'installation :
Tapper la commande suivante dans le terminal
terraform
usage: terraform [--version] [--help] <command> [<args>]

# Récupération du script terraform :
git init
git pull ...

# Inistialiser les credentiels d'AWS
export AWS_ACCESS_KEY_ID=<votre access key>
export AWS_SECRET_ACCESS_KEY=<votre secret key>

#Visualiser puis construire l'insfrastructure AWS 
terraform plan
terraform apply
