########################################
# BASH DEPENDENCY CHECKER
# 
########################################

# create an array of packages depended on
declare -a DEPENDENCIES=(
  'curl' 'jq'
  )

# loop through each dependency. if it doesn't exist, 
# recomend a package control install based on what's available
# or, at the very least, echo "Please install $PACKAGE"
for PACKAGE in ${DEPENDENCIES[@]}; do
  if [ "$(which "$PACKAGE")" = "" ]; then
    echo
    echo "Please install $PACKAGE!"
    echo
    echo -n "Try:"

    if [ "$(which brew)" ]; then
      echo "  $ brew install $PACKAGE"      
    elif [ "$(which port)" ]; then
      echo "  $ port install $PACKAGE"  
    elif [ "$(which apt-get)" ]; then
      echo "  $ apt-get install $PACKAGE"  
    elif [ "$(which yum)" ]; then
      echo "  $ yum install $PACKAGE"
    elif [ "$(which rpm)" ]; then
      echo "  $ rpm --install $PACKAGE"
    else
      echo
    fi
    exit 1 # if your name's not on the list, we can't let you in buddy.
  fi  
done
