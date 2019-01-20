#/bin/bash
cd ~
rm -rf MERGE_masternode_setup.sh*
echo "****************************************************************************"
echo "*       This script will install and configure your MERGE masternode       *"
echo "*                             (Remote Wallet)                              *"
echo "*                                                                          *"
echo "*      If you have any issues, please ask for help on Merge's Discord:     *"
echo "*                        https://discord.gg/b88VWfB                        *"
echo "*                                                                          *"
echo "*                         https://projectmerge.org                         *"
echo "****************************************************************************"
echo ""
echo ""
echo "****************************************************************************"
echo "*                           Installation Script                            *"
echo "****************************************************************************"
echo ""
echo ""

echo "Hit [ENTER] to start the masternode setup"
read setup
rm -rf MERGE_masternode_setup.sh*
MERGE_CLI_CMD="merge-cli"
MERGE_TX_CMD="merge-tx"
MERGED_CMD="merged"
MERGE_CLI=`find . -name "$MERGE_CLI_CMD" | tail -1`
MERGE_TX=`find . -name "$MERGE_TX_CMD" | tail -1`
MERGED=`find . -name "$MERGED_CMD" | tail -1`
$MERGE_CLI stop
echo "Configuring your VPS with the recommended settings..."
sudo apt-get update
sudo apt-get install -y build-essential
sudo apt-get install -y autoconf
sudo apt-get install -y automake
sudo apt-get install -y libssl1.0-dev
sudo apt-get install -y libboost-all-dev
sudo apt-get install -y libdb4.8-dev 
sudo apt-get install -y libdb4.8++-dev
sudo apt-get install -y libevent-pthreads-2.0-5
sudo apt-get install -y miniupnpc
sudo apt-get install -y pkg-config
sudo apt-get install -y libtool
sudo apt-get install -y libevent-dev
sudo apt-get install -y git
sudo apt-get install -y screen
sudo apt-get install -y autotools-dev
sudo apt-get install -y bsdmainutils
sudo apt-get install -y lsof
sudo apt-get install -y dos2unix
sudo apt-get install -y zlib1g-dev
sudo apt-get install -y curl
sudo apt-get install -y ufw
sudo apt-get install -y libgmp-dev 
sudo apt-get install -y libssl-dev 
sudo apt-get install -y libcurl4-openssl-dev 
sudo apt-get install -y wge
sudo apt-get install -y software-properties-common 
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw logging on
sudo ufw allow 22
sudo ufw allow 52000
echo "y" | sudo ufw enable
sudo ufw status
echo ""
echo ""
echo "Installing/Updating your masternode..."
$MERGE_CLI stop
rm $MERGED
rm $MERGE_CLI
rm $MERGE_TX
# Retrieve the latest wallet release
LATEST_RELEASE_URL=https://api.github.com/repos/ProjectMerge/merge/releases/latest
FILE_ENDIND=x86_64-linux-gnu.tar.gz
release_file_url=$(curl -s $LATEST_RELEASE_URL | grep "browser_download_url.*$FILE_ENDIND" | cut -d : -f 2,3 | tr -d \")
release_file_name=$(basename $release_file_url)
wget $release_file_url
tar -xf $release_file_name
rm $release_file_name

MERGE_CLI=`find . -name "$MERGE_CLI_CMD" | tail -1`
MERGE_TX=`find . -name "$MERGE_TX_CMD" | tail -1`
MERGED=`find . -name "$MERGED_CMD" | tail -1`

echo "Masternode Configuration"
# Ask for the IP address
IP=$(sudo ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | tail -n 1)
echo "Your IP address is: $IP"
echo "Is this the IP address you wish to use for your masternode? [y/n], followed by [ENTER]"
read ipd
if [[ $ipd =~ "n" ]] || [[ $ipd =~ "N" ]] ; then
	echo "Type the custom IP address for this masternode, followed by [ENTER]: "
    read IP
fi
# Ask for the masternode's private key
echo "Enter the masternode's private key, followed by [ENTER]: "
read PRIVKEY

# Remove old configuration file
CONF_DIR=~/.merge
CONF_FILE=merge.conf
today=`date '+%Y_%m_%d_%H-%M-%S'`
echo "mv $CONF_DIR $CONF_DIR.oldnetwork.$today"
mv $CONF_DIR $CONF_DIR.oldnetwork.$today

# Edit configuration file
PORT=52000
mkdir -p $CONF_DIR
echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> $CONF_DIR/$CONF_FILE
echo "rpcpassword=passw"`shuf -i 100000-10000000 -n 1` >> $CONF_DIR/$CONF_FILE
echo "rpcallowip=127.0.0.1" >> $CONF_DIR/$CONF_FILE
echo "listen=1" >> $CONF_DIR/$CONF_FILE
echo "server=1" >> $CONF_DIR/$CONF_FILE
echo "daemon=1" >> $CONF_DIR/$CONF_FILE
echo "logtimestamps=1" >> $CONF_DIR/$CONF_FILE
echo "maxconnections=256" >> $CONF_DIR/$CONF_FILE
echo "masternode=1" >> $CONF_DIR/$CONF_FILE
echo "" >> $CONF_DIR/$CONF_FILE
echo "port=$PORT" >> $CONF_DIR/$CONF_FILE
echo "externalip=$IP" >> $CONF_DIR/$CONF_FILE
echo "masternodeprivkey=$PRIVKEY" >> $CONF_DIR/$CONF_FILE
echo "" >> $CONF_DIR/$CONF_FILE
# shuffle among predefined addnodes
declare -a arr_ip=("149.28.52.154" "144.202.50.69" "104.238.146.20" "144.202.120.254" "45.63.105.42" "54.39.37.35" "54.39.37.36" "54.39.37.37" "54.39.37.39" "54.39.37.40" "66.42.78.65" "45.77.187.63" "149.248.58.187" "185.92.220.61" "173.199.70.76" "50.3.74.76" "199.188.100.174" "104.206.242.136" "107.174.59.173" "107.172.27.143" "54.39.37.41" "54.39.37.42" "54.39.37.43" "54.39.37.44" "149.56.4.253" "45.32.37.22" "45.77.169.99" "209.250.227.55" "45.63.119.183" "95.179.176.55" "130.255.76.82" "95.179.162.143" "45.77.64.136" "149.248.52.218" "104.238.137.115" "45.76.228.139")

ARR_LENGTH=${#arr_ip[@]}

STRING_ADDNODES=`awk -v loop=10 -v range=$ARR_LENGTH -v arr="${arr_ip[*]}" 'BEGIN{
  split(arr, list, " ")
  srand()
  do {
    numb = 1 + int(rand() * range)
    if (!(numb in prev)) {
       if(count>0)
          printf ","
       printf "addnode=%s",list[numb]
       prev[numb] = 1
       count++
    }
  } while (count<loop)
}'`

IFS=',' read -ra ARRAY_ADDNODES <<< "$STRING_ADDNODES"
for i in "${ARRAY_ADDNODES[@]}"; do
    echo "$i" >> $CONF_DIR/$CONF_FILE
done

$MERGED -resync
echo "If the server fails to start, try $MERGED -reindex"
echo ""

echo "****************************************************************************"
echo "*                      Your masternode is now setup.                       *"
echo "*              Please continue with the Post-requisites steps.             *"
echo "*                                                                          *"
echo "*                                  Merge                                   *"
echo "****************************************************************************"
echo ""
