![AFPA](https://www.afpa.fr/afpa-theme/images/afpa/logo-afpa.png "Logo AFPA")
![TERRAFORM](https://chocolatey.org/content/packageimages/terraform.0.6.16.png "Logo AFPA")



# Afpa Terraform
construire une infra EC2, Security_group, R53 avec Git et transfert de fichier en utilisant Terraform


# INSTALLATION :
Télécharger et décompresser le zip terraform
https://www.terraform.io/downloads.html

# CONFIGURATION :
Dans le fichier .bash_profile ajouter la ligne suivante :
```sell
export PATH=$PATH:<path-terraform>/bin
```

# Vérification de l'installation :
Tapper la commande suivante dans le terminal
```tf
terraform
```
usage: terraform [--version] [--help] <command> [<args>]

# Récupération du script terraform :
 git clone https://github.com/solidismail/afpa-terraform.git

# Inistialiser les credentiels d'AWS
Mettre lec credentiels AWS dans les variables d'environnement de la machine au lieu de les insérer dans le fichier terraform.
export AWS_ACCESS_KEY_ID=<votre access key>
export AWS_SECRET_ACCESS_KEY=<votre secret key>

# Visualiser puis construire l'insfrastructure AWS
```tf
terraform plan
```
```tf
terraform apply
```

# Détruire l'infrastructure
```tf
terraform destroy
```

# Récupérer l'ensemble les informations réseau de l'infrastructure
les informations sont : DNS privé, hostname, ip_local et ip_public
```tf
terraform output output-csv
```

ou
```tf
terraform output output-csv > output.csv
```

Extraire que les DNS privés ($1=1er champs) :
```tf
terraform output output-csv | awk -F','  '{print $1}'
```

sortie :
```tf
terraform output output-csv | awk -F','  '{print $1}'
```
$private_dns
 moodle1.afpa.aws.com
 moodle2.afpa.aws.com
 sgbd1.afpa.aws.com
 sgbd2.afpa.aws.com
 mediation.afpa.aws.com
 fichier1.afpa.aws.com
 fichier2.afpa.aws.com
 webdav.afpa.aws.com
 memcached1.afpa.aws.com
 memcached2.afpa.aws.com
 logs.afpa.aws.com
 outils.afpa.aws.com
