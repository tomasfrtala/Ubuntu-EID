#!/bin/bash

function checkVersion {
	if ! [ "$(. /etc/os-release; echo $ID)" == "ubuntu" ] && [ "$(echo $(. /etc/os-release; echo $VERSION_ID) | cut -c -2)" -ge 18 ]; then
        echo "Not Ubuntu 18.04. Exiting now" 
        exit 1
    fi
}

function hello {
    echo "Welcome to fix libcurl3/4 dependency of EID 3.0.0 for Ubuntu 18.04 Linux"
}

function alterPackage() {
    echo "Start altering package..."

    local tmpDir="/tmp/fix-eid"
    mkdir "${tmpDir}"

    echo "Unpacking package"
    dpkg-deb -R "$1/$2" "${tmpDir}"

    echo "Adjusting package dependencies"
    sed -i -e 's/libcurl3/libcurl3|libcurl4/g' "${tmpDir}/DEBIAN/control"

    echo "Packaging up"
    dpkg-deb -b "${tmpDir}" "$1/fix-$2"

    echo "Cleaning"
    rm -r "${tmpDir}"
}

function downloadLibcurl3 {
    local package="libcurl3_7.58.0-2ubuntu2_amd64.deb"
    local url="http://archive.ubuntu.com/ubuntu/pool/main/c/curl3/${package}"
    local tmpFile="/tmp/$package"
    local tmpDir="/tmp/libcurl3"
    local srcLib="${tmpDir}/usr/lib/x86_64-linux-gnu/libcurl.so.4.5.0"
    local targetLib="/usr/lib/x86_64-linux-gnu/libcurl.so.3"

    echo "Downloading installation package"
    wget "${url}" -O ${tmpFile}

    echo "Unpacking package"
    mkdir "${tmpDir}"
    dpkg-deb -x "${tmpFile}" "${tmpDir}"

    echo "Coping lib of version 3 next to version 4"
    sudo cp -vn "${srcLib}" "${targetLib}"

    echo "Cleaning"
    rm -rf "${tmpDir}"
    rm "${tmpFile}"
}

function createShortcut {
    echo "Almost done! :-)"
    echo "Before you start the EAC_MW_klient you have to tell where the old libcurl3 is located. Example:"
    echo "env LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libcurl.so.3 EAC_MW_klient"

    local tmpShortcut="/tmp/start-eid"
    local shortcut="/usr/local/bin/eid"

    read -p "Do you want to create shortcut for above command as 'eid' in ${shortcut} for easier access [Y/n]? " choiceCli
    case "$choiceCli" in
        y|Y)
            echo '#!/bin/bash

env LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libcurl.so.3 EAC_MW_klient' > "${tmpShortcut}"
            sudo mv "${tmpShortcut}" "${shortcut}"
            sudo chmod a+rx "${shortcut}"

	    echo "Command line shortcut created"

	    local desktopShortcut="~/.local/share/applications/eid.desktop"
	    read -p "Do you want to create desktop icon launcher for super easier access [Y/n]? " choiceDesktop
	    case "$choiceDesktop" in
                y|Y)
		    echo '[Desktop Entry]
Encoding=UTF-8
Version=3.0.0
Name=eID klient (fixed)
Comment=eID klient with changed env for curl3
Exec=/usr/local/bin/eid
Icon=/usr/lib/eac_mw_klient/img/sk_logo.png
Terminal=false
StartupWMClass=eid
Type=Application
Categories=Utility;' > "$HOME/.local/share/applications/eid.desktop"
                    echo "Finished! ;-) You can start the app by executing command eid or just using your desktop launcher with typing eid"
		;;
                n|N)
                    echo "Finished! ;-) The app will start by executing command eid"
		;;
                *)
                echo "Invalid option. Exiting..."
                ;;
            esac

        ;;
        n|N) 
            echo "Exiting..."
        ;;
        *)
            echo "Invalid option. Exiting..."
        ;;
    esac
}

function downloadEID {
    local file="Aplikacia_pre_eID_amd64_ubuntu.tar.gz"
    local package="Aplikacia_pre_eID_amd64_ubuntu.deb"
    local tmpFile="/tmp/$file"
    local tmpDir="/tmp/eid"
    local url="https://eidas.minv.sk/TCTokenService/download/linux/ubuntu/$file"
 
    echo "Downloading installation package..."
    wget "${url}" -O ${tmpFile}
    echo "Unpacking"
    mkdir "${tmpDir}"
    tar xzf "${tmpFile}" -C "${tmpDir}"

    echo "Preparing instalation..."
    local installed=`dpkg -s libcurl4 | grep Status | awk {'print $4'}`

    case "$installed" in
        ("installed")
            echo "Alert! You have libcurl4 installed. For correct work the dependencies of ${package} needs to be altered."
            echo "In next steps the package $package will be altered and the file libcurl3 will be downloaded."

            read -p "Continue [Y/n]? " choice
            case "$choice" in
                y|Y)
                    alterPackage "${tmpDir}" "${package}"

                    echo "Installing the fix-${package}"
                    sudo dpkg -i "${tmpDir}/fix-${package}"
                    downloadLibcurl3

                    createShortcut
	        ;;
                n|N) 
		    echo "Exiting..."
		;;
                *)
                    echo "Invalid option. Exiting..."
		;;
            esac
        ;;
        (*)
            echo "Installing the ${package}"
            sudo dpkg -i "${tmpDir}/${package}"
        ;;
    esac

    echo "Cleaning temp..."
    rm -r "${tmpDir}"
    rm "${tmpFile}"
}

function checkInstalledEID {
    local installed=`dpkg -s eac-mw-klient | grep Status | awk {'print $4'}`

    case "$installed" in
	    ("installed")
    		local version=`dpkg -s eac-mw-klient | grep Version | awk {'print $2'}`
    		echo "Installed version: $version. Nothing to do. Exiting..."
		;;
	    (*)
		read -p "Download EID 3.0.0 for Ubuntu 18.04 Linux [Y/n]? " choice
                case "$choice" in
                    y|Y)
	                downloadEID
	            ;;
                    n|N) 
			echo "Exiting..."
		    ;;
                    *) 
		        echo "Invalid option. Exiting..."
		    ;;
                esac
	        ;;
    esac
}

# Main loop
hello
checkVersion
checkInstalledEID
