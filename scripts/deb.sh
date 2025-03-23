#!/bin/bash

# Variables
scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
projectDir="$(dirname "$scriptDir")"
programName="MyGesClient"
packageVersion="1.0"
architecture="all"
buildDir="$projectDir/builds"
srcDir="$projectDir/src"
debDir="$srcDir/DEBIAN"

# Préparation des répertoires
mkdir -p "$srcDir/usr/bin"
mkdir -p "$srcDir/usr/share/applications"
mkdir -p "$srcDir/usr/share/icons/$programName"
mkdir -p "$debDir"

# Copier l'exécutable
cp "$projectDir/$programName" "$srcDir/usr/bin/"
# Copier l'icône dans le paquet
cp "$projectDir/icons/appicon.png" "$srcDir/usr/share/icons/$programName/$programName.png"

# Créer le fichier de contrôle
cat <<EOF > "$debDir/control"
Package: $programName
Version: $packageVersion
Architecture: $architecture
Maintainer: Spatulox
Description: MyGes Native Desktop for Debian
Section: utils
Priority: optional
Depends: libwebkit2gtk-4.0-37, libgtk-3-0
EOF

# Créer un script pre-installation
cat <<EOF > "$debDir/preinst"
#!/bin/bash
set -e

# Vérifier et installer les dépendances
if ! dpkg -s libwebkit2gtk-4.0-37 libgtk-3-0 >/dev/null 2>&1; then
    echo "Installation des dépendances nécessaires..."
    apt-get update
    apt-get install -y libwebkit2gtk-4.0-37 libgtk-3-0
fi

echo "Vérification des dépendances terminée."
EOF
chmod 755 "$debDir/preinst"

# Créer le fichier .desktop pour le raccourci
cat <<EOF > "$srcDir/usr/share/applications/$programName.desktop"
[Desktop Entry]
Name=$programName
Exec=/usr/bin/$programName
Icon=/usr/share/icons/$programName/$programName.png
Type=Application
Categories=Utility;
EOF

# Ajouter un script post-installation
cat <<EOF > "$debDir/postinst"
#!/bin/bash
echo "Installation terminée pour $programName."
chmod +x /usr/bin/$programName
sudo update-desktop-database
sudo gtk-update-icon-cache -f -t /usr/share/icons
EOF
chmod 755 "$debDir/postinst"

# Changer les permissions pour root (nécessaire pour dpkg)
sudo chown -R root:root "$srcDir"

# Construire le paquet Debian
mkdir -p "$buildDir"
dpkg-deb --build "$srcDir" "$buildDir/${programName}_${packageVersion}.deb"

# Nettoyer les permissions après la construction
sudo chown -R $USER:$USER "$srcDir"

# Nettoyage des fichiers temporaires (optionnel)
rm -rf "$srcDir/usr" "$debDir"

echo "Paquet créé : $buildDir/${programName}_${packageVersion}.deb"
