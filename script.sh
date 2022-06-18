#!/bin/bash

## 18.06 küçük düzeltmeler :: devam edecek

# aktif branchi alıyorum
brnc=$(git branch | grep '*' | awk '{ print $2 }')

# kullanıcının seçimine göre açılacak olan build fonksyonu
build() {
    # main ve master kontrolu yapıyorum
    if [[ $1 == "main" || $1 == "master" ]]
    then
        echo -n 'şu anda master ya da main branchindesiniz, build almak istiyor musunuz [y/n] : '
        # kullanıcıdan onay alıyorum
        read confirm
        # eğer hayır denmişse programdan çıkacak
        [[ $confirm == [nN] ]] && exit 0 # 
    fi
    # diğer işlemler
    git checkout $1
    npm install
    npm script.js
    compress
}

# sıkıştırma işlemi :: yapılacak
compress() {
    echo "comp işlemi"
}

# kullanım mesajı
usage() {
    echo 'Usage:'
    echo -e '\t-b  <branch name>\t Branch name'
    echo -e '\t-n  <new branch>\t Create new branch'
    echo -e '\t-f  <zip|tar>\t\t Compress format'
    echo -e '\t-p  <artifact path>\t Copy artifact to spesific path'
    echo -e '\t-d  <>\t\t\t Debug mode'
}

# argümanın --help olması durumunda kullanım mesajı gözükecek
if [ "$1" == "--help" ]
then
    usage
    exit 0
fi

# kullanıcını girdiği argümanları almak için getops ile while döngüsü başlatıyorum
while getopts ":b:nf:p:d" arg
do
    # her bir argüman için işlemleri belirliyorum
    case "$arg" in
    d) # debug mod
        cmd="${cmd} --inspect"
        ;;

    b) # branchname ataması
        branchname=${OPTARG}
        build $branchname
        ;;

    n) # yeni branch oluşturma
        name=${OPTARG}
        git checkout -b $name
        ;;

    f) # sıkıştırma işleminde kullanıcıdan sıkıştırma türünü alıyorum
        typ=${OPTARG}
        if [[ $typ == "zip" ]]; then
            zip -q ${brnc}_${name} *
        elif [[ $typ == "tar" ]]; then
            tar -czf ./${brnc}_${name} * 2>/dev/null
        else
            exit 1
        fi
        ;;

    p)
        # sıkıştırılmış dosyanın kopyalanacağı yol
        art_path=${OPTARG}
        mv ${brnc}_${name}* $art_path
        ;;

    *)
        echo 'hatalı argüman'
        usage
        ;;
    esac
done

