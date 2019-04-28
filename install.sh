# ! /bin/bash
# Programa que permite manejar las utilidades de Postres
# Autor: Noe Huaccharaque @noemk2

opcion=0
fechaActual=`date +%Y%m%d`
#fuction que permite manejar las utilidadesd de postgres
instalar_postgres(){
    echo -e "\n verificar instalacion de postgres ..." 
    verifyInstall=$(which psql &>/dev/null) 
    if [ $? -eq 0 ]; then
        echo -e "\n Postgres ya se encuentra instalado en el equipo"
    else 
     echo -e "\n "
     read -s -p "Ingresar contraseña de sudo: " password
     echo -e "\n "
     read -s -p "Ingresar contraseña a utilizar en postgres:" passwordPostgres
     echo -e "\n "
     echo -e "\n INSTALANDO..."
     echo "$password" | sudo -S apt update
     echo "$password" | sudo -S apt-get -y install postgresql postgresql-contrib
     sudo -u postgres psql -c "AlTER USER postgres WITH PASSWORD '{$PASSWORDpostgres}';"
     echo "$password" | sudo -S systemctl enable postgresql.service
     echo "$password" | sudo -S systemctl start postgresql.service
    fi
    read -n 1 -s -r -p "PRESIONE [ENTER] para continuar"
}
desinstalar_postgres(){
    read -s -p "Ingresar contraseña de sudo" password
    echo -e "\n"
    echo "$password" | sudo -S systemctl stop postgresql.service
    echo "$password" | sudo -S apt-get -y --purge remove postgresql\*
    echo "$password" | sudo -S rm -r /etc/postgresql
    echo "$password" | sudo -S rm -r /var/lib/postgresql
    echo "$password" | sudo -S userdel -r postgres
    echo "$password" | sudo -S groupdel -r postgresql
    read -n 1 -s -r -p "PRESIONE [ENTER] para continuar"

}
sacar_respaldo(){
    echo "Listar las bases de datos"
    sudo -u postgres psql -c "\l"
    read -p "Elegir la base de datos a respaldar: " bddResapaldo
    echo -e "\n "
    if [ -d "$1" ]; then
        echo "Establecer permisos al directorio"
        echo "$password" | sudo -S chmod 755 $1
        echo "Realizando respaldo..."
        sudo -u postgres pg_dump -Fc $bddResapaldo > "$1/bddResapaldo$fechaActual.bak"
        echo "Respaldo realizado correctamente en la ubicacion: $1/bddResapaldo$fechaActual.bak"
         read -n 1 -s -r -p "PRESIONE [ENTER] para continuar"
    else
    echo "El directorio $1 no existe"
    fi
}
restaurar_respaldo(){
    echo "Listar respaldos..."
    read -p "Ingresar el directorio donde estan los respaldos: " directorioBackup
    ls -la $directorioBackup
    read -p "Elegir el respaldo a restaurar:" respaldoRestaurar
    echo -e "\n "
    read "Ingrese e l nombre de la base de datos destino: " bddDestino
    #verficar si la bdd existe
    verfyBdd = $(sud -u postgres psql -lqt | cut-d \| -f 1 | grep -wq $bddDestino)
    if [ $? -eq 0 ]; then 
        echo "Restaurando en la bdd destino: $bddDestino"
    else
        sudo -u postgres psql -c "create database $bddDestino"
    fi
    if [ -f "$1/$respaldoRestaurar" ]; then
        echo "Restaurando respaldo...."
        sudo -u postgres psql -c "\l"
        sudo -u -postgres ps_restore -Fc -d $bddDestino "$directorioBackup/$respaldoRestaurar"
    else
        echo "El respaldo  $respaldoRestaurar no existe"
    fi
         read -n 1 -s -r -p "PRESIONE [ENTER] para continuar"
}


while :
do
    #Limpiar la pantalla
    clear
    #Desplegar el menú de opciones
    echo "_________________________________________"
    echo "PGUTIL - Programa de Utilidad de Postgres"
    echo "_________________________________________"
    echo "                MENÚ PRINCIPAL           "
    echo "_________________________________________"
    echo "1. Instalar Postgres"
    echo "2. Desinstalar Postgres"
    echo "3. Sacar un respaldo"
    echo "4. Restar respaldo"
    echo "5. Salir"

    #Leer los datos del usuario - capturar información
    read -n1 -p "Ingrese una opción [1-5]:" opcion

    #Validar la opción ingresada
    case $opcion in
        1)
            instalar_postgres
            sleep 3
            ;;
        2) 
            desinstalar_postgres        
            sleep 3
            ;;
        3) 
            echo -e "\n "
            read -p "Directorio Backup: " directorioBackup
            sacar_respaldo $directorioBackup
            sleep 3
            ;;
        4) 
            echo -e "\n "
            read -p "Directorio Respaldo:" directorioRespaldos
            restaurar_respaldo $directorioRespaldos
            sleep 3
            ;;
        5)  
            echo "Salir del Programa"
            exit 0
            ;;
    esac
done    