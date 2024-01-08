#!/bin/bash

#Variable
#Elements Linux DEB / RPM

deblink="https://download.withsecure.com/PSB/latest/f-secure-linuxsecurity.deb"
rpmlink="https://download.withsecure.com/PSB/latest/f-secure-linuxsecurity.rpm"



################################################################################################################
# Fonction pour détecter la distribution
detect_distribution() {
    if [ -e /etc/os-release ]; then
        # Utilisation de /etc/os-release pour récupérer les informations
        source /etc/os-release
        if [ -n "$ID" ]; then
            DISTRIBUTION=$ID
        else
            DISTRIBUTION="Unknown"
        fi
    else
        # Si /etc/os-release n'est pas présent, essayons d'utiliser d'autres méthodes
        if [ -e /etc/lsb-release ]; then
            source /etc/lsb-release
            DISTRIBUTION=$DISTRIB_ID
        elif [ -e /etc/debian_version ]; then
            DISTRIBUTION="Debian"
        elif [ -e /etc/redhat-release ]; then
            DISTRIBUTION=$(awk '{print tolower($1)}' /etc/redhat-release)
        else
            DISTRIBUTION="Unknown"
        fi
    fi
}

# Fonction pour détecter la version
detect_version() {
    if [ -n "$VERSION_ID" ]; then
        VERSION=$VERSION_ID
    elif [ -n "$DISTRIB_RELEASE" ]; then
        VERSION=$DISTRIB_RELEASE
    elif [ -e /etc/debian_version ]; then
        VERSION=$(cat /etc/debian_version)
    elif [ -e /etc/redhat-release ]; then
        VERSION=$(awk '{print $3}' /etc/redhat-release)
    else
        VERSION="Unknown"
    fi
}

install_libraries() {
    local distribution=$1
    local version=$2
	
	cd /tmp/

    case $distribution in
        "amazon"|"centos"|"oracle"|"rhel")
            if [ "$version" == "7" ]; then
                sudo yum install -y fuse-libs libcurl python
            fi
            ;;
        "almalinux"|"centos"|"oracle"|"rhel")
            if [ "$version" == "8" ]; then
                sudo yum install -y fuse-libs libcurl python39
            fi
            ;;
        "almalinux"|"rhel")
            if [ "$version" == "9" ]; then
                sudo yum install -y libcurl python3
            fi
            ;;
        "debian"|"ubuntu")
            if [ "$version" == "10" ]; then
                sudo apt-get install -y libfuse2 libcurl4 python
            elif [ "$version" == "11" ]; then
                sudo apt-get install -y libfuse2 libcurl4 python3
            elif [ "$version" == "18.04" ]; then
                sudo apt-get install -y libfuse2 libcurl4 python
            elif [ "$version" == "20.04" ]; then
                sudo apt-get install -y libfuse2 libcurl4 python3
            elif [ "$version" == "22.04" ]; then
                sudo apt-get install -y libcurl4 python3
            fi
            ;;
		"suse")
            sudo zypper install -y libfuse2 libcurl4 python3
            ;;
        *)
            echo "Aucune installation de bibliothèque spécifique pour cette distribution."
            ;;
    esac
}

install_libraries_auditd() {
    local distribution=$1
    local version=$2
	
	cd /tmp/

    case $distribution in
        "amazon"|"centos"|"oracle"|"rhel")
            if [ "$version" == "7" ]; then
                sudo yum install -y fuse-libs libcurl python auditd
            fi
            ;;
        "almalinux"|"centos"|"oracle"|"rhel")
            if [ "$version" == "8" ]; then
                sudo yum install -y fuse-libs libcurl python39 auditd
            fi
            ;;
        "almalinux"|"rhel")
            if [ "$version" == "9" ]; then
                sudo yum install -y libcurl python3 auditd
            fi
            ;;
        "debian"|"ubuntu")
            if [ "$version" == "10" ]; then
                sudo apt-get install -y libfuse2 libcurl4 python auditd
            elif [ "$version" == "11" ]; then
                sudo apt-get install -y libfuse2 libcurl4 python3 auditd
            elif [ "$version" == "18.04" ]; then
                sudo apt-get install -y libfuse2 libcurl4 python auditd
            elif [ "$version" == "20.04" ]; then
                sudo apt-get install -y libfuse2 libcurl4 python3 auditd
            elif [ "$version" == "22.04" ]; then
                sudo apt-get install -y libcurl4 python3 auditd
            fi
            ;;
		"suse")
            sudo zypper install -y libfuse2 libcurl4 python3
            ;;
        *)
            echo "Aucune installation de bibliothèque spécifique pour cette distribution."
            ;;
    esac
}

ask_license_key() {
    local license_key=$(zenity --entry --title="Clé de Licence" --text="Veuillez saisir votre clé de licence :")

    if [ -n "$license_key" ]; then
        echo "Clé de licence : $license_key"
		sudo /opt/f-secure/linuxsecurity/bin/activate --psb --subscription-key $license_key
    else
        echo "Aucune clé de licence saisie."
    fi
}

download_and_install_package() {
    local distribution=$1

    case $distribution in
        "debian"|"ubuntu")
            wget $deblink
            sudo dpkg -i f-secure-linuxsecurity.deb
            #sudo apt-get install -f  # Pour résoudre les dépendances
            ;;
        "centos"|"almalinux"|"oracle"|"rhel")
            wget $rpmlink
            sudo rpm -i f-secure-linuxsecurity.rpm
            ;;
        *)
            echo "Aucun paquet spécifique à installer pour cette distribution."
            ;;
    esac
}


while [ "$menu" != 1 ]; do

OPTION=$(whiptail --title "WithSecure Elements Linux" --menu "Install WithSecure Elements Linux agent" --fb --cancel-button "Exit" 30 70 10 \
"1" "Install Elements EPP" \
"2" "Install Elements EPP + EDR" \
"3" "Activation licence" \
"4" "WSDIAG" \ 3>&1 1>&2 2>&3)

#clear
exitstatus=$?
if [ $exitstatus = 0 ]; then

     
	if [ "$OPTION" = "1" ]; then
          
		detect_distribution
		detect_version
         
		install_libraries "$DISTRIBUTION" "$VERSION" 
		
		download_and_install_package "$DISTRIBUTION"
		 
		ask_license_key
 
    fi





if [ "$OPTION" = "2" ]; then

		detect_distribution
		detect_version
         
		install_libraries_auditd "$DISTRIBUTION" "$VERSION" 
		
		download_and_install_package "$DISTRIBUTION"
		
		ask_license_key
    fi
	
	
if [ "$OPTION" = "3" ]; then

		ask_license_key

fi
 


if [ "$OPTION" = "4" ]; then
desti=$(whiptail --title "Change destination fsdiag folder" --inputbox "Destination folder " 10 60 /opt/f-secure/fspms/bin/ --nocancel 3>&1 1>&2 2>&3)
/opt/f-secure/fspms/bin/fsdiag
	if [ $desti = "/opt/f-secure/fspms/bin/" ]; then
	    echo "ok"
	else
	mv /opt/f-secure/fspms/bin/fsdiag.tar.gz $desti
	fi
fi


fi

else
sleep 1
exit 0
fi
done
