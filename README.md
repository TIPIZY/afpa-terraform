# Afpa Terraform
construire une infra EC2, Security_group, R53 avec Git et transfert de fichier en utilisant Terraform


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
 git clone https://github.com/solidismail/afpa-terraform.git

# Inistialiser les credentiels d'AWS
Mettre lec credentiels AWS dans les variables d'environnement de la machine au lieu de les insérer dans le fichier terraform.
export AWS_ACCESS_KEY_ID=<votre access key>
export AWS_SECRET_ACCESS_KEY=<votre secret key>

# Visualiser puis construire l'insfrastructure AWS
terraform plan
terraform apply

# Détruire l'infrastructure
terraform destroy

# Récupérer l'ensemble les informations réseau de l'infrastructure
les informations sont : DNS privé, hostname, ip_local et ip_public
terraform output output-csv
ou
terraform output output-csv > output.csv
