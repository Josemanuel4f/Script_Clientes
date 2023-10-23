#!/bin/bash

# Verifica que se proporcionen argumentos
if [ "$#" -ne 3 ]; then
    echo "Uso: $0 NOMBRE_CLIENTE TAMAÑO_VOLUMEN RED"
    exit 1
fi

# Variables
nombremaquina="$1"
tamadisco="$2"
nombrered="$3"

# Plantilla

# Crear nuevo volumen

echo "Creando disco enlazado"s

virsh -c qemu:///system vol-create-as default $nombremaquina.qcow2 ${tamadisco}G --format qcow2 --backing-vol plantilla-cliente.qcow2 --backing-vol-format qcow2

# Cambiar el hostname

sudo virt-customize -c qemu:///system -a /var/lib/libvirt/images/$nombremaquina.qcow2 --hostname $nombremaquina

# Redimension
qemu-img resize /var/lib/libvirt/images/$nombremaquina.qcow2 ${tamadisco}G
cp /var/lib/libvirt/images/$nombremaquina.qcow2 /var/lib/libvirt/images/nuevo$nombremaquina.qcow2
virt-resize --expand /dev/sda1 /var/lib/libvirt/images/$nombremaquina.qcow2 /var/lib/libvirt/images/nuevo$nombremaquina.qcow2
mv /var/lib/libvirt/images/nuevo$nombremaquina.qcow2 /var/lib/libvirt/images/$nombremaquina.qcow2

# Creación de máquina

echo "Creando maquina"

virt-install --connect qemu:///system \
             --noautoconsole \
			 --virt-type kvm \
			 --name $nombremaquina \
			 --os-variant debian10 \
			 --disk path=/var/lib/libvirt/images/$nombremaquina.qcow2,size=$tamadisco,format=qcow2 \
			 --memory 1024 \
			 --vcpus 1 \
			 --import \
			 --network network=$nombrered


echo "La máquina $nombremaquina se ha creado conectada a la red $nombrered."
