#!/bin/bash

# esopipes_list="amber;cr2re;crire;detmon;efosc;eris;esotk;espda;espdr;fors;giraf;gravity;harps;hawki;iiinstrument;isaac;kmos;matisse;midi;molecfit;muse;naco;nirps;sinfo;sofi;spher;uves;vcam;vimos;visir;xshoo"
esopipes_list="molecfit"

IFS=';' read -r -a packages <<< "$esopipes_list"

for package in "${packages[@]}"
do
    echo "Installing $package..."
    dnf install -y esopipe-"$package" esopipe-"$package"-wkf
    find /usr/share/reflex/workflows/$package* -type f -name "*.xml" -exec sed -i 's|value="/usr/share/esopipes/datademo/'"$package"'/"|value="$HOME/reflex_rawdata/"|g' {} +
done