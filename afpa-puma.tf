
provider "aws" {
    #access_key = ""
    #secret_key = ""
    region     = "eu-west-1"
}

variable "afpa-vars" {  #${var.afpa-vars.}
    default = {
        centos7_ami = "ami-7abd0209"  #centos 7
        centos6_ami = "ami-42718735"  #centos 6.5
        instance_type_centos7 = "t2.micro"
        instance_type_centos6 = "t1.micro"
        vpc_id = "vpc-de52aabb"
        subnet_id = "subnet-78ea751d"
        authorized_ip    = "46.255.176.210/32"
        domain = "afpa.aws.com"
        public-domain-id = "Z3P1E0U6CTTKSW"
        public-domain = "afpa.neoxia-labs.com"
        private_key_name    = "neoxia-ismail" # neoxia-ismail.pem
        private_key_path = "/Users/isebbane/.ssh/neoxia-ismail.pem"
        source_pkg    = "/Users/isebbane/GIT/metis-middleware-install"
        destination_pkg = "/home/centos/"
        git_url = "http://10.0.1.249:10080/metis/atom-mediation.git"
        git_path = "/home/centos/git-sources"
        public-ssh-key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrskP/f3RuX9ls2Ep8vYDRpk35N8C3Wq95qHiMBybAWTBCnijP3r9j2BEAZafCr31ishO+hTaoZBbBamdIYMTweC4tv/qt9rY6BH4Xy8tOwt0Knecagy2g+q1bLc4GUcfoHdrDLwyatJr4Y0EbNokg8iVh4VOUHM+t6sBWx/7LczVP1O9IG/szs5g4pev2sXJMNfR2rpHbTGOX1Gcyz6ULP8/4+dDO1LF9sBUZo8QWudyuvGDPrs/dZQAdAg+mqNTmvXsNFImRcvtPIpEWVbJzin+hSbkbkTS+hgT0UFFKnBl5BMTrBmu/0EChH5ij+L7eQSqhKCrWRL0uFYH0hTCb iWael@localhost"
    }
}


variable "afpa-hostname" {   #${var.afpa-hostname.}
    default = {
        moodle1 = "AFLIPUAP93"
        moodle2 = "AFLIPUAP94"
        sgbd1 = "AFLIPUBD93"
        sgbd2 = "AFLIPUBD94"
        mediation = "AFLIPUMD93"
        fichier1 = "AFLIPUES93"
        fichier2 = "AFLIPUES94"
        webdav = "AFLIPUWD93"
        memcached1 = "AFLIPUMC93"
        memcached2 = "AFLIPUMC94"
        logs = "AFLIPULG93"
        outils = "AFLIPUOT93"
    }
}


resource "aws_security_group" "afpa_sg_allow_all" {
    name = "afpa_sg_allow_all"
    description = "Autoriser TCP pour ip NEOXIA"
    vpc_id = "${var.afpa-vars.vpc_id}"
    ingress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = ["${var.afpa-vars.authorized_ip}"]
    }
    # autoriser les machines a se communiquer entre eux
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        self=true
    }
    #autoriser internet
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "[afpa] [terraform] allow_all"
        Client = "AFPA"
        Owner = "ismail"
        Produit = "PUMA"
    }
}



##### moodle 1 centos7
resource "aws_instance" "afpa_terraform_moodle1" {
    ami           = "${var.afpa-vars.centos7_ami}"
    instance_type = "${var.afpa-vars.instance_type_centos7}"
    key_name = "${var.afpa-vars.private_key_name}"
    subnet_id = "${var.afpa-vars.subnet_id}"
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.afpa_sg_allow_all.id}"]
    tags {
        Name = "[afpa] [terraform] Serveur MOODLE 1"
        Hostname = "${var.afpa-hostname.moodle1}"
    }

    connection {
        user = "centos"
        key_file = "${var.afpa-vars.private_key_path}"
        agent = false
    }

    # Renommer le hostname et installation de git
    provisioner "remote-exec" {
        inline = [
        "sudo yum install -y  git",
        "mkdir -p ${var.afpa-vars.git_path}",
        "cd ${var.afpa-vars.git_path}",
        "git init",
        "git pull ${var.afpa-vars.git_url}",
        "sudo sh -c \"echo preserve_hostname: true  >> /etc/cloud/cloud.cfg\"",
        "sudo  hostnamectl set-hostname ${aws_instance.afpa_terraform_moodle1.tags.Hostname}",
        "echo '${var.afpa-vars.public-ssh-key}' >> /home/centos/.ssh/authorized_keys "
        ]
    }

    # copier les packages RPM
    provisioner "file" {
        source = "${var.afpa-vars.source_pkg}"
        destination = "${var.afpa-vars.destination_pkg}"
    }

    # Redemarrer l'instance
    provisioner "remote-exec" {
        inline = [
        "sudo -s reboot"
        ]
    }

}



##### moodle2 centos 7
resource "aws_instance" "afpa_terraform_moodle2" {
    ami           = "${var.afpa-vars.centos7_ami}"
    instance_type = "${var.afpa-vars.instance_type_centos7}"
    key_name = "${var.afpa-vars.private_key_name}"
    subnet_id = "${var.afpa-vars.subnet_id}"
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.afpa_sg_allow_all.id}"]
    tags {
        Name = "[afpa] [terraform] Serveur MOODLE 2"
        Hostname = "${var.afpa-hostname.moodle2}"
    }

    connection {
        user = "centos"
        key_file = "${var.afpa-vars.private_key_path}"
        agent = false
    }

    # Renommer le hostname et installation de git
    provisioner "remote-exec" {
        inline = [
        "sudo yum install -y  git",
        "mkdir -p ${var.afpa-vars.git_path}",
        "cd ${var.afpa-vars.git_path}",
        "git init",
        "git pull ${var.afpa-vars.git_url}",
        "sudo sh -c \"echo preserve_hostname: true  >> /etc/cloud/cloud.cfg\"",
        "sudo  hostnamectl set-hostname ${aws_instance.afpa_terraform_moodle2.tags.Hostname}",
        "echo '${var.afpa-vars.public-ssh-key}' >> /home/centos/.ssh/authorized_keys "
         ]
    }

    # copier les packages RPM
    provisioner "file" {
        source = "${var.afpa-vars.source_pkg}"
        destination = "${var.afpa-vars.destination_pkg}"
    }

    # Redemarrer l'instance
    provisioner "remote-exec" {
        inline = [
        "sudo -s reboot"
        ]
    }

}



##### SGBD1 centos 6
resource "aws_instance" "afpa_terraform_sgbd1" {
    ami           = "${var.afpa-vars.centos6_ami}"
    instance_type = "${var.afpa-vars.instance_type_centos6}"
    key_name = "${var.afpa-vars.private_key_name}"
    subnet_id = "${var.afpa-vars.subnet_id}"
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.afpa_sg_allow_all.id}"]
#    private_dns = "${var.afpa-hostname.sgbd1}"
    tags {
        Name = "[afpa] [terraform] Serveur SGBD 1"
        Hostname = "${var.afpa-hostname.sgbd1}"
    }

    connection {
        user = "root"
        key_file = "${var.afpa-vars.private_key_path}"
        agent = false
    }

    # Renommer le hostname, creation d'un utilisateur centos et installation de git
    provisioner "remote-exec" {
        inline = [
        "yum install -y  git",
        "useradd centos",
        "cp -Rp /root/.ssh /home/centos/",
        "chown -R centos:centos /home/centos",
       ### centos sudo
        "echo 'centos    ALL=(ALL)       ALL' >>  /etc/sudoers",
        "echo 'centos          ALL=(ALL)       NOPASSWD: ALL' >>  /etc/sudoers",
        "echo 'Defaults:centos    !requiretty' >>  /etc/sudoers",
        "su -l centos -c \"mkdir -p ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"cd ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"git init ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"cd ${var.afpa-vars.git_path} && git pull ${var.afpa-vars.git_url}\"",
        "sudo sed -i s/HOSTNAME=.*/HOSTNAME=${aws_instance.afpa_terraform_sgbd1.tags.Hostname}/g /etc/sysconfig/network",
        "sudo service iptables stop",
        "chkconfig iptables off",
        "echo '${var.afpa-vars.public-ssh-key}' >> /home/centos/.ssh/authorized_keys "
        ]
    }

    # copier les packages RPM
    provisioner "file" {
        source = "${var.afpa-vars.source_pkg}"
        destination = "${var.afpa-vars.destination_pkg}"
    }

    # Redemarrer l'instance
    provisioner "remote-exec" {
        inline = [
        "sudo -s reboot"
        ]
    }

}


##### SGBD2 centos 6
resource "aws_instance" "afpa_terraform_sgbd2" {
    ami           = "${var.afpa-vars.centos6_ami}"
    instance_type = "${var.afpa-vars.instance_type_centos6}"
    key_name = "${var.afpa-vars.private_key_name}"
    subnet_id = "${var.afpa-vars.subnet_id}"
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.afpa_sg_allow_all.id}"]
#    private_dns = "${var.afpa-hostname.sgbd2}"
    tags {
        Name = "[afpa] [terraform] Serveur SGBD 2"
        Hostname = "${var.afpa-hostname.sgbd2}"
    }

    connection {
        user = "root"
        key_file = "${var.afpa-vars.private_key_path}"
        agent = false
    }

    # Renommer le hostname, creation d'un utilisateur centos et installation de git
    provisioner "remote-exec" {
        inline = [
        "yum install -y  git",
        "useradd centos",
        "cp -Rp /root/.ssh /home/centos/",
        "chown -R centos:centos /home/centos",
       ### centos sudo
        "echo 'centos    ALL=(ALL)       ALL' >>  /etc/sudoers",
        "echo 'centos          ALL=(ALL)       NOPASSWD: ALL' >>  /etc/sudoers",
        "echo 'Defaults:centos    !requiretty' >>  /etc/sudoers",
        "su -l centos -c \"mkdir -p ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"cd ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"git init ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"cd ${var.afpa-vars.git_path} && git pull ${var.afpa-vars.git_url}\"",
        "sudo sed -i s/HOSTNAME=.*/HOSTNAME=${aws_instance.afpa_terraform_sgbd2.tags.Hostname}/g /etc/sysconfig/network",
        "sudo service iptables stop",
        "chkconfig iptables off",
        "echo '${var.afpa-vars.public-ssh-key}' >> /home/centos/.ssh/authorized_keys "

        ]
    }

    # copier les packages RPM
    provisioner "file" {
        source = "${var.afpa-vars.source_pkg}"
        destination = "${var.afpa-vars.destination_pkg}"
    }

    # Redemarrer l'instance
    provisioner "remote-exec" {
        inline = [
        "sudo -s reboot"
        ]
    }

}



##### MEDIATION 1 centos 6
resource "aws_instance" "afpa_terraform_mediation" {
    ami           = "${var.afpa-vars.centos6_ami}"
    instance_type = "${var.afpa-vars.instance_type_centos6}"
    key_name = "${var.afpa-vars.private_key_name}"
    subnet_id = "${var.afpa-vars.subnet_id}"
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.afpa_sg_allow_all.id}"]
    tags {
        Name = "[afpa] [terraform] Serveur MEDIATION"
        Hostname = "${var.afpa-hostname.mediation}"
    }

    connection {
        user = "root"
        key_file = "${var.afpa-vars.private_key_path}"
        agent = false
    }

    # Renommer le hostname, creation d'un utilisateur centos et installation de git
    provisioner "remote-exec" {
        inline = [
        "yum install -y  git",
        "useradd centos",
        "cp -Rp /root/.ssh /home/centos/",
        "chown -R centos:centos /home/centos",
       ### centos sudo
        "echo 'centos    ALL=(ALL)       ALL' >>  /etc/sudoers",
        "echo 'centos          ALL=(ALL)       NOPASSWD: ALL' >>  /etc/sudoers",
        "echo 'Defaults:centos    !requiretty' >>  /etc/sudoers",
        "su -l centos -c \"mkdir -p ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"cd ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"git init ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"cd ${var.afpa-vars.git_path} && git pull ${var.afpa-vars.git_url}\"",
        "sudo sed -i s/HOSTNAME=.*/HOSTNAME=${aws_instance.afpa_terraform_mediation.tags.Hostname}/g /etc/sysconfig/network",
        "sudo service iptables stop",
        "chkconfig iptables off",
        "echo '${var.afpa-vars.public-ssh-key}' >> /home/centos/.ssh/authorized_keys "

        ]
    }

    # copier les packages RPM
    provisioner "file" {
        source = "${var.afpa-vars.source_pkg}"
        destination = "${var.afpa-vars.destination_pkg}"
    }

    # Redemarrer l'instance
    provisioner "remote-exec" {
        inline = [
        "sudo -s reboot"
        ]
    }

}



##### Fichier 1 centos 6
resource "aws_instance" "afpa_terraform_fichier1" {
    ami           = "${var.afpa-vars.centos6_ami}"
    instance_type = "${var.afpa-vars.instance_type_centos6}"
    key_name = "${var.afpa-vars.private_key_name}"
    subnet_id = "${var.afpa-vars.subnet_id}"
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.afpa_sg_allow_all.id}"]
    tags {
        Name = "[afpa] [terraform] Serveur FICHIER 1"
        Hostname = "${var.afpa-hostname.fichier1}"
    }

    connection {
        user = "root"
        key_file = "${var.afpa-vars.private_key_path}"
        agent = false
    }

    # Renommer le hostname, creation d'un utilisateur centos et installation de git
    provisioner "remote-exec" {
        inline = [
        "yum install -y  git",
        "useradd centos",
        "cp -Rp /root/.ssh /home/centos/",
        "chown -R centos:centos /home/centos",
       ### centos sudo
        "echo 'centos    ALL=(ALL)       ALL' >>  /etc/sudoers",
        "echo 'centos          ALL=(ALL)       NOPASSWD: ALL' >>  /etc/sudoers",
        "echo 'Defaults:centos    !requiretty' >>  /etc/sudoers",
        "su -l centos -c \"mkdir -p ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"cd ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"git init ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"cd ${var.afpa-vars.git_path} && git pull ${var.afpa-vars.git_url}\"",
        "sudo sed -i s/HOSTNAME=.*/HOSTNAME=${aws_instance.afpa_terraform_fichier1.tags.Hostname}/g /etc/sysconfig/network",
        "sudo service iptables stop",
        "chkconfig iptables off",
        "echo '${var.afpa-vars.public-ssh-key}' >> /home/centos/.ssh/authorized_keys "

        ]
    }

    # copier les packages RPM
    provisioner "file" {
        source = "${var.afpa-vars.source_pkg}"
        destination = "${var.afpa-vars.destination_pkg}"
    }

    # Redemarrer l'instance
    provisioner "remote-exec" {
        inline = [
        "sudo -s reboot"
        ]
    }

}




##### Fichier 2 centos 6
resource "aws_instance" "afpa_terraform_fichier2" {
    ami           = "${var.afpa-vars.centos6_ami}"
    instance_type = "${var.afpa-vars.instance_type_centos6}"
    key_name = "${var.afpa-vars.private_key_name}"
    subnet_id = "${var.afpa-vars.subnet_id}"
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.afpa_sg_allow_all.id}"]
    tags {
        Name = "[afpa] [terraform] Serveur FICHIER 2"
        Hostname = "${var.afpa-hostname.fichier2}"
    }

    connection {
        user = "root"
        key_file = "${var.afpa-vars.private_key_path}"
        agent = false
    }

    # Renommer le hostname, creation d'un utilisateur centos et installation de git
    provisioner "remote-exec" {
        inline = [
        "yum install -y  git",
        "useradd centos",
        "cp -Rp /root/.ssh /home/centos/",
        "chown -R centos:centos /home/centos",
       ### centos sudo
        "echo 'centos    ALL=(ALL)       ALL' >>  /etc/sudoers",
        "echo 'centos          ALL=(ALL)       NOPASSWD: ALL' >>  /etc/sudoers",
        "echo 'Defaults:centos    !requiretty' >>  /etc/sudoers",
        "su -l centos -c \"mkdir -p ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"cd ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"git init ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"cd ${var.afpa-vars.git_path} && git pull ${var.afpa-vars.git_url}\"",
        "sudo sed -i s/HOSTNAME=.*/HOSTNAME=${aws_instance.afpa_terraform_fichier2.tags.Hostname}/g /etc/sysconfig/network",
        "sudo service iptables stop",
        "chkconfig iptables off",
        "echo '${var.afpa-vars.public-ssh-key}' >> /home/centos/.ssh/authorized_keys "

        ]
    }

    # copier les packages RPM
    provisioner "file" {
        source = "${var.afpa-vars.source_pkg}"
        destination = "${var.afpa-vars.destination_pkg}"
    }

    # Redemarrer l'instance
    provisioner "remote-exec" {
        inline = [
        "sudo -s reboot"
        ]
    }

}




##### WEBDAV centos 6
resource "aws_instance" "afpa_terraform_webdav" {
    ami           = "${var.afpa-vars.centos6_ami}"
    instance_type = "${var.afpa-vars.instance_type_centos6}"
    key_name = "${var.afpa-vars.private_key_name}"
    subnet_id = "${var.afpa-vars.subnet_id}"
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.afpa_sg_allow_all.id}"]
    tags {
        Name = "[afpa] [terraform] Serveur WEBDAV"
        Hostname = "${var.afpa-hostname.webdav}"
    }

    connection {
        user = "root"
        key_file = "${var.afpa-vars.private_key_path}"
        agent = false
    }

    # Renommer le hostname, creation d'un utilisateur centos et installation de git
    provisioner "remote-exec" {
        inline = [
        "yum install -y  git",
        "useradd centos",
        "cp -Rp /root/.ssh /home/centos/",
        "chown -R centos:centos /home/centos",
       ### centos sudo
        "echo 'centos    ALL=(ALL)       ALL' >>  /etc/sudoers",
        "echo 'centos          ALL=(ALL)       NOPASSWD: ALL' >>  /etc/sudoers",
        "echo 'Defaults:centos    !requiretty' >>  /etc/sudoers",
        "su -l centos -c \"mkdir -p ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"cd ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"git init ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"cd ${var.afpa-vars.git_path} && git pull ${var.afpa-vars.git_url}\"",
        "sudo sed -i s/HOSTNAME=.*/HOSTNAME=${aws_instance.afpa_terraform_webdav.tags.Hostname}/g /etc/sysconfig/network",
        "sudo service iptables stop",
        "chkconfig iptables off",
        "echo '${var.afpa-vars.public-ssh-key}' >> /home/centos/.ssh/authorized_keys "

        ]
    }

    # copier les packages RPM
    provisioner "file" {
        source = "${var.afpa-vars.source_pkg}"
        destination = "${var.afpa-vars.destination_pkg}"
    }

    # Redemarrer l'instance
    provisioner "remote-exec" {
        inline = [
        "sudo -s reboot"
        ]
    }

}




##### CHACHE MEMCACHED 1 centos 6
resource "aws_instance" "afpa_terraform_memcached1" {
    ami           = "${var.afpa-vars.centos6_ami}"
    instance_type = "${var.afpa-vars.instance_type_centos6}"
    key_name = "${var.afpa-vars.private_key_name}"
    subnet_id = "${var.afpa-vars.subnet_id}"
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.afpa_sg_allow_all.id}"]
    tags {
        Name = "[afpa] [terraform] Serveur MEMCACHED 1"
        Hostname = "${var.afpa-hostname.memcached1}"
    }

    connection {
        user = "root"
        key_file = "${var.afpa-vars.private_key_path}"
        agent = false
    }

    # Renommer le hostname, creation d'un utilisateur centos et installation de git
    provisioner "remote-exec" {
        inline = [
        "yum install -y  git",
        "useradd centos",
        "cp -Rp /root/.ssh /home/centos/",
        "chown -R centos:centos /home/centos",
       ### centos sudo
        "echo 'centos    ALL=(ALL)       ALL' >>  /etc/sudoers",
        "echo 'centos          ALL=(ALL)       NOPASSWD: ALL' >>  /etc/sudoers",
        "echo 'Defaults:centos    !requiretty' >>  /etc/sudoers",
        "su -l centos -c \"mkdir -p ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"cd ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"git init ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"cd ${var.afpa-vars.git_path} && git pull ${var.afpa-vars.git_url}\"",
        "sudo sed -i s/HOSTNAME=.*/HOSTNAME=${aws_instance.afpa_terraform_memcached1.tags.Hostname}/g /etc/sysconfig/network",
        "sudo service iptables stop",
        "chkconfig iptables off",
        "echo '${var.afpa-vars.public-ssh-key}' >> /home/centos/.ssh/authorized_keys "

        ]
    }

    # copier les packages RPM
    provisioner "file" {
        source = "${var.afpa-vars.source_pkg}"
        destination = "${var.afpa-vars.destination_pkg}"
    }

    # Redemarrer l'instance
    provisioner "remote-exec" {
        inline = [
        "sudo -s reboot"
        ]
    }

}



##### CHACHE MEMCACHED 2 centos 6
resource "aws_instance" "afpa_terraform_memcached2" {
    ami           = "${var.afpa-vars.centos6_ami}"
    instance_type = "${var.afpa-vars.instance_type_centos6}"
    key_name = "${var.afpa-vars.private_key_name}"
    subnet_id = "${var.afpa-vars.subnet_id}"
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.afpa_sg_allow_all.id}"]
    tags {
        Name = "[afpa] [terraform] Serveur MEMCACHED 2"
        Hostname = "${var.afpa-hostname.memcached2}"
    }

    connection {
        user = "root"
        key_file = "${var.afpa-vars.private_key_path}"
        agent = false
    }

    # Renommer le hostname, creation d'un utilisateur centos et installation de git
    provisioner "remote-exec" {
        inline = [
        "yum install -y  git",
        "useradd centos",
        "cp -Rp /root/.ssh /home/centos/",
        "chown -R centos:centos /home/centos",
       ### centos sudo
        "echo 'centos    ALL=(ALL)       ALL' >>  /etc/sudoers",
        "echo 'centos          ALL=(ALL)       NOPASSWD: ALL' >>  /etc/sudoers",
        "echo 'Defaults:centos    !requiretty' >>  /etc/sudoers",
        "su -l centos -c \"mkdir -p ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"cd ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"git init ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"cd ${var.afpa-vars.git_path} && git pull ${var.afpa-vars.git_url}\"",
        "sudo sed -i s/HOSTNAME=.*/HOSTNAME=${aws_instance.afpa_terraform_memcached2.tags.Hostname}/g /etc/sysconfig/network",
        "sudo service iptables stop",
        "chkconfig iptables off",
        "echo '${var.afpa-vars.public-ssh-key}' >> /home/centos/.ssh/authorized_keys "

      ]
    }

    # copier les packages RPM
    provisioner "file" {
        source = "${var.afpa-vars.source_pkg}"
        destination = "${var.afpa-vars.destination_pkg}"
    }

    # Redemarrer l'instance
    provisioner "remote-exec" {
        inline = [
        "sudo -s reboot"
        ]
    }

}


##### CHACHE LOGS centos 6
resource "aws_instance" "afpa_terraform_logs" {
    ami           = "${var.afpa-vars.centos6_ami}"
    instance_type = "${var.afpa-vars.instance_type_centos6}"
    key_name = "${var.afpa-vars.private_key_name}"
    subnet_id = "${var.afpa-vars.subnet_id}"
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.afpa_sg_allow_all.id}"]
    tags {
        Name = "[afpa] [terraform] Serveur LOGS"
        Hostname = "${var.afpa-hostname.logs}"
    }

    connection {
        user = "root"
        key_file = "${var.afpa-vars.private_key_path}"
        agent = false
    }

    # Renommer le hostname, creation d'un utilisateur centos et installation de git
    provisioner "remote-exec" {
        inline = [
        "yum install -y  git",
        "useradd centos",
        "cp -Rp /root/.ssh /home/centos/",
        "chown -R centos:centos /home/centos",
        "su -l centos -c \"mkdir -p ${var.afpa-vars.git_path}\"",
       ### centos sudo
        "echo 'centos    ALL=(ALL)       ALL' >>  /etc/sudoers",
        "echo 'centos          ALL=(ALL)       NOPASSWD: ALL' >>  /etc/sudoers",
        "echo 'Defaults:centos    !requiretty' >>  /etc/sudoers",
        "su -l centos -c \"cd ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"git init ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"cd ${var.afpa-vars.git_path} && git pull ${var.afpa-vars.git_url}\"",
        "sudo sed -i s/HOSTNAME=.*/HOSTNAME=${aws_instance.afpa_terraform_logs.tags.Hostname}/g /etc/sysconfig/network",
        "sudo service iptables stop",
        "chkconfig iptables off",
        "echo '${var.afpa-vars.public-ssh-key}' >> /home/centos/.ssh/authorized_keys "

        ]
    }

    # copier les packages RPM
    provisioner "file" {
        source = "${var.afpa-vars.source_pkg}"
        destination = "${var.afpa-vars.destination_pkg}"
    }

    # Redemarrer l'instance
    provisioner "remote-exec" {
        inline = [
        "sudo -s reboot"
        ]
    }

}


##### CHACHE OUTILS centos 6
resource "aws_instance" "afpa_terraform_outils" {
    ami           = "${var.afpa-vars.centos6_ami}"
    instance_type = "${var.afpa-vars.instance_type_centos6}"
    key_name = "${var.afpa-vars.private_key_name}"
    subnet_id = "${var.afpa-vars.subnet_id}"
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.afpa_sg_allow_all.id}"]
    tags {
        Name = "[afpa] [terraform] Serveur OUTILS"
        Hostname = "${var.afpa-hostname.outils}"
    }

    connection {
        user = "root"
        key_file = "${var.afpa-vars.private_key_path}"
        agent = false
    }

    # Renommer le hostname, creation d'un utilisateur centos et installation de git
    provisioner "remote-exec" {
        inline = [
        "yum install -y  git",
        "useradd centos",
        "cp -Rp /root/.ssh /home/centos/",
        "chown -R centos:centos /home/centos",
       ### centos sudo
        "echo 'centos    ALL=(ALL)       ALL' >>  /etc/sudoers",
        "echo 'centos          ALL=(ALL)       NOPASSWD: ALL' >>  /etc/sudoers",
        "echo 'Defaults:centos    !requiretty' >>  /etc/sudoers",
        "su -l centos -c \"mkdir -p ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"cd ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"git init ${var.afpa-vars.git_path}\"",
        "su -l centos -c \"cd ${var.afpa-vars.git_path} && git pull ${var.afpa-vars.git_url}\"",
        "sudo sed -i s/HOSTNAME=.*/HOSTNAME=${aws_instance.afpa_terraform_outils.tags.Hostname}/g /etc/sysconfig/network",
        "sudo service iptables stop",
        "chkconfig iptables off",
        "echo '${var.afpa-vars.public-ssh-key}' >> /home/centos/.ssh/authorized_keys "

        ]
    }

    # copier les packages RPM
    provisioner "file" {
        source = "${var.afpa-vars.source_pkg}"
        destination = "${var.afpa-vars.destination_pkg}"
    }

    # Redemarrer l'instance
    provisioner "remote-exec" {
        inline = [
        "sudo -s reboot"
        ]
    }

}

# DNS PUBLIC
resource "aws_route53_record" "moodle1_public" {
   zone_id = "${var.afpa-vars.public-domain-id}"
   name = "moodle1.${var.afpa-vars.public-domain}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.afpa_terraform_moodle1.public_ip}"]
}

resource "aws_route53_record" "moodle2_public" {
   zone_id = "${var.afpa-vars.public-domain-id}"
   name = "moodle2.${var.afpa-vars.public-domain}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.afpa_terraform_moodle2.public_ip}"]
}


# DNS PRIVEE
resource "aws_route53_zone" "afpa-r53" {
  name = "${var.afpa-vars.domain}"
  comment = "AFPA ENV TEST _creer avec Terraform par Ismail"
  vpc_id = "${var.afpa-vars.vpc_id}"
}


resource "aws_route53_record" "moodle1" {
   zone_id = "${aws_route53_zone.afpa-r53.zone_id}"
   name = "moodle1.${var.afpa-vars.domain}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.afpa_terraform_moodle1.private_ip}"]
}

resource "aws_route53_record" "moodle2" {
   zone_id = "${aws_route53_zone.afpa-r53.zone_id}"
   name = "moodle2.${var.afpa-vars.domain}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.afpa_terraform_moodle2.private_ip}"]
}

resource "aws_route53_record" "sgbd1" {
   zone_id = "${aws_route53_zone.afpa-r53.zone_id}"
   name = "sgbd1.${var.afpa-vars.domain}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.afpa_terraform_sgbd1.private_ip}"]
}

resource "aws_route53_record" "sgbd2" {
   zone_id = "${aws_route53_zone.afpa-r53.zone_id}"
   name = "sgbd2.${var.afpa-vars.domain}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.afpa_terraform_sgbd2.private_ip}"]
}

resource "aws_route53_record" "mediation" {
   zone_id = "${aws_route53_zone.afpa-r53.zone_id}"
   name = "mediation.${var.afpa-vars.domain}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.afpa_terraform_mediation.private_ip}"]
}

resource "aws_route53_record" "fichier1" {
   zone_id = "${aws_route53_zone.afpa-r53.zone_id}"
   name = "fichier1.${var.afpa-vars.domain}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.afpa_terraform_fichier1.private_ip}"]
}

resource "aws_route53_record" "fichier2" {
   zone_id = "${aws_route53_zone.afpa-r53.zone_id}"
   name = "fichier2.${var.afpa-vars.domain}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.afpa_terraform_fichier2.private_ip}"]
}

resource "aws_route53_record" "webdav" {
   zone_id = "${aws_route53_zone.afpa-r53.zone_id}"
   name = "webdav.${var.afpa-vars.domain}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.afpa_terraform_webdav.private_ip}"]
}

resource "aws_route53_record" "memcached1" {
   zone_id = "${aws_route53_zone.afpa-r53.zone_id}"
   name = "memcached1.${var.afpa-vars.domain}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.afpa_terraform_memcached1.private_ip}"]
}


resource "aws_route53_record" "memcached2" {
   zone_id = "${aws_route53_zone.afpa-r53.zone_id}"
   name = "memcached2.${var.afpa-vars.domain}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.afpa_terraform_memcached2.private_ip}"]
}

resource "aws_route53_record" "logs" {
   zone_id = "${aws_route53_zone.afpa-r53.zone_id}"
   name = "logs.${var.afpa-vars.domain}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.afpa_terraform_logs.private_ip}"]
}

resource "aws_route53_record" "outils" {
   zone_id = "${aws_route53_zone.afpa-r53.zone_id}"
   name = "outils.${var.afpa-vars.domain}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.afpa_terraform_outils.private_ip}"]
}



# lancer la commande "terraform output hosts > hosts"  apres le lancement de "terraform apply"
#"ce fichier hosts est a copier sur l'ensemble des instances cree "
output "hosts" {
    value = "${aws_instance.afpa_terraform_moodle1.private_ip} ${var.afpa-hostname.moodle1}  \n${aws_instance.afpa_terraform_moodle2.private_ip} ${var.afpa-hostname.moodle2}  \n${aws_instance.afpa_terraform_sgbd1.private_ip} ${var.afpa-hostname.sgbd1}  \n${aws_instance.afpa_terraform_sgbd2.private_ip} ${var.afpa-hostname.sgbd2}  \n${aws_instance.afpa_terraform_mediation.private_ip} ${var.afpa-hostname.mediation}  \n${aws_instance.afpa_terraform_fichier1.private_ip} ${var.afpa-hostname.fichier1}  \n${aws_instance.afpa_terraform_fichier2.private_ip} ${var.afpa-hostname.fichier2}  \n${aws_instance.afpa_terraform_webdav.private_ip} ${var.afpa-hostname.webdav}  \n${aws_instance.afpa_terraform_memcached1.private_ip} ${var.afpa-hostname.memcached1}  \n${aws_instance.afpa_terraform_memcached2.private_ip} ${var.afpa-hostname.memcached2}  \n${aws_instance.afpa_terraform_logs.private_ip} ${var.afpa-hostname.logs}  \n${aws_instance.afpa_terraform_outils.private_ip} ${var.afpa-hostname.outils}"
}

output "aws-ips-public" {
  value = "${aws_instance.afpa_terraform_moodle1.public_ip} \n${aws_instance.afpa_terraform_moodle2.public_ip} \n${aws_instance.afpa_terraform_sgbd1.public_ip} \n${aws_instance.afpa_terraform_sgbd2.public_ip}  \n${aws_instance.afpa_terraform_mediation.public_ip} \n${aws_instance.afpa_terraform_fichier1.public_ip} \n${aws_instance.afpa_terraform_fichier2.public_ip}  \n${aws_instance.afpa_terraform_webdav.public_ip}  \n${aws_instance.afpa_terraform_memcached1.public_ip} \n${aws_instance.afpa_terraform_memcached2.public_ip}  \n${aws_instance.afpa_terraform_logs.public_ip}  \n${aws_instance.afpa_terraform_outils.public_ip} "
}

output "outputcsv" {
    value = " #$private_dns,$hostname,$private_ip,$public_ip,$public_domain\n ${aws_route53_record.moodle1.name},${var.afpa-hostname.moodle1},${aws_instance.afpa_terraform_moodle1.private_ip},${aws_instance.afpa_terraform_moodle1.public_ip},${aws_route53_record.moodle1_public.name}\n ${aws_route53_record.moodle2.name},${var.afpa-hostname.moodle2},${aws_instance.afpa_terraform_moodle2.private_ip},${aws_instance.afpa_terraform_moodle2.public_ip},${aws_route53_record.moodle2_public.name}\n ${aws_route53_record.sgbd1.name},${var.afpa-hostname.sgbd1},${aws_instance.afpa_terraform_sgbd1.private_ip},${aws_instance.afpa_terraform_sgbd1.public_ip}\n ${aws_route53_record.sgbd2.name},${var.afpa-hostname.sgbd2},${aws_instance.afpa_terraform_sgbd2.private_ip},${aws_instance.afpa_terraform_sgbd2.public_ip}\n ${aws_route53_record.mediation.name},${var.afpa-hostname.mediation},${aws_instance.afpa_terraform_mediation.private_ip},${aws_instance.afpa_terraform_mediation.public_ip}\n ${aws_route53_record.fichier1.name},${var.afpa-hostname.fichier1},${aws_instance.afpa_terraform_fichier1.private_ip},${aws_instance.afpa_terraform_fichier1.public_ip}\n ${aws_route53_record.fichier2.name},${var.afpa-hostname.fichier2},${aws_instance.afpa_terraform_fichier2.private_ip},${aws_instance.afpa_terraform_fichier2.public_ip}\n ${aws_route53_record.webdav.name},${var.afpa-hostname.webdav},${aws_instance.afpa_terraform_webdav.private_ip},${aws_instance.afpa_terraform_webdav.public_ip}\n ${aws_route53_record.memcached1.name},${var.afpa-hostname.memcached1},${aws_instance.afpa_terraform_memcached1.private_ip},${aws_instance.afpa_terraform_memcached1.public_ip}\n ${aws_route53_record.fichier2.name},${var.afpa-hostname.memcached2},${aws_instance.afpa_terraform_memcached2.private_ip},${aws_instance.afpa_terraform_memcached2.public_ip}\n ${aws_route53_record.logs.name},${var.afpa-hostname.logs},${aws_instance.afpa_terraform_logs.private_ip},${aws_instance.afpa_terraform_logs.public_ip}\n ${aws_route53_record.outils.name},${var.afpa-hostname.outils},${aws_instance.afpa_terraform_outils.private_ip},${aws_instance.afpa_terraform_outils.public_ip}\n"
}
