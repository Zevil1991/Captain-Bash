#! /bin/bash

state=$(<./files/state)
statepoint=$(<./files/statepoint)
speed=$(<./files/speed)

#Utility functions

#Press any button to continue the text

pak(){
     echo -n "Press any key to continue."
     read -s -n 1 x #Press any key to continue
     echo -n -e "\033[2K" #Delete the prompt
     echo -ne -n "\r"
}

#Making the cursor invisible & visible

function invis(){
     tput civis
}

function norma(){
     tput cnorm
}

#Printing function that's cenetered

function pc {
     style=$3
     [[ $# == 0 ]] && return 1

     declare -i TERM_COLS="$(tput cols)"
     declare -i str_len="${#1}"
     [[ $str_len -ge $TERM_COLS ]] && {
          echo "$1";
          return 0;
     }

     declare -i filler_len="$(( (TERM_COLS - str_len) / 2 ))"
     [[ $# -ge 2 ]] && ch="${2:0:1}" || ch=" "
     filler=""
     for (( i = 0; i < filler_len; i++ )); do
          filler="${filler}${ch}"
     done

     if [ "$style" = "i" ]
     then
     echo -e "$filler" "\e[3m$1\e[0m" "$filler"
     else
     echo -e "    ""$filler" "$1" "$filler"
     fi
     [[ $(( (TERM_COLS - str_len) % 2 )) -ne 0 ]] && printf "%s" "${ch}"
     printf "\n"

     return 0
}

#Speech function with a delay that's centered

function sc {
     [[ $# == 0 ]] && return 1

     declare -i TERM_COLS="$(tput cols)"
     declare -i str_len="${#1}"
     [[ $str_len -ge $TERM_COLS ]] && {
          echo "$1";
          return 0;
     }
     tim=$3
     string=$1
     style=$4
     declare -i filler_len="$(( (TERM_COLS - str_len) / 2 ))"
     [[ $# -ge 2 ]] && ch="${2:0:1}" || ch=" "
     filler=""
     for (( i = 0; i < filler_len; i++ )); do
          filler="${filler}${ch}"
     done

     printf "%s%s%s" "$filler" 
     for (( i=0; i<${#string}; i++));
    do
    char="${string:i:1}"
    if [ "$style" = "i" ]
    then
    echo -n -e "\e[3m$char\e[0m"
    else
    echo -n -e "$char"
    fi
    sleep $tim
    done 
    printf "$filler"
     [[ $(( (TERM_COLS - str_len) % 2 )) -ne 0 ]] && printf "%s" "${ch}"
     printf "\n\n"
     return 0
}

#Speech function with a delay

sp() {
     string=$1
     tim=$2
     style=$3
     for (( i=0; i<${#string}; i++));
     do
     char="${string:i:1}"
     if [ "$style" = "r" ]
     then
     echo -n -e "\e[31m$char\e[0m"
     elif [ "$style" = "g" ]
     then
     echo -n -e "\e[32m$char\e[0m"
     elif [ "$style" = "y" ]
     then
     echo -n -e "\e[33m$char\e[0m"
     else
     echo -n -e "$char"
     fi
     sleep $tim
     done
     echo " "
     printf "\n"
}

#Menu function (credit to Guss on askUbuntu.com)
#How to use:
: '
selections=(
"Selection A"
"Selection B"
"Selection C"
)

choose_from_menu "Please make a choice:" selected_choice "${selections[@]}"
'

function spmenu() {
    local prompt="$1" outvar="$2"
    shift
    shift
    local options=("$@") cur=0 count=${#options[@]} index=0
    local esc=$(echo -en "\e") # cache ESC as test doesn't allow esc codes
    printf "$prompt\n"
    while true
    do
        # list all options (option list is zero-based)
        index=0 
        for o in "${options[@]}"
        do
            if [ "$index" == "$cur" ]
            then echo -e " >\e[7m$o\e[0m" # mark & highlight the current option
            else echo "  $o"
            fi
            index=$(( $index + 1 ))
        done
        read -s -n3 key # wait for user to key in arrows or ENTER
        if [[ $key == $esc[A ]] # up arrow
        then cur=$(( $cur - 1 ))
            [ "$cur" -lt 0 ] && cur=0
        elif [[ $key == $esc[B ]] # down arrow
        then cur=$(( $cur + 1 ))
            [ "$cur" -ge $count ] && cur=$(( $count - 1 ))
        elif [[ $key == "" ]] # nothing, i.e the read delimiter - ENTER
        then break
        fi
        echo -en "\e[${count}A" # go up to the beginning to re-render
    done
    # export the selection to the requested output variable
    #value="${#options[$cur]}"
    for i in "${!options[@]}"; do
     if [[ "${options[$i]}" = "${options[$cur]}" ]];
          then
          index=$i;
      fi
     done
    printf -v $outvar "$index"
}

#Titlescreen function

titlescreen() {
     clear
     echo -e "\n\n\n\n\n\n\n"
     pc "Show intro? (Y/n)" " "
     invis
     read -s -n 1 intro
     norma
     if [ "$intro" = "y" ] || [ "$intro" = "Y" ]
          then
          clear
          sc "The endless void doesn't stare back when you peer into it...." " " 0.04 i
          sleep 2
          sc "Instead, it forces you to reflect on yourself..." " " 0.04 i
          sleep 4
          pc "Will you break free?" " " i
          sleep 2
          fi
     clear

     printf "\n\n\n\n\n\n"

     figlet -c -t "CAPTAIN BASH" | boxes
     printf "\n\n\n"
     pc "1) New Game\n" " "
     pc "2) Continue\n" " "
     pc "3) Select Level (DEV menu)\n" " "
     pc "4) Settings\n" " "
     pc "5) Exit\n" " "
     printf "\n\n\n"
     invis
     read -s -n 1 ch
     norma
     case $ch in
          "1")
          rm 'files/state'
          echo 0 >> 'files/state'
          rm 'files/statepoint'
          echo 0 >> 'files/statepoint'
          ;;
          "2")
          :
          ;;
          "3")
          clear
          printf "\n\n\n\n\n\n"

          figlet -c -t "CAPTAIN BASH" | boxes
          printf "\n\n\n"
          pc "1) New Game\n" " "
          pc "2) Continue\n" " "
          pc "3) Select Level (DEV menu)\n" " "
          pc "4) Settings\n" " "
          pc "5) Exit\n" " "
          printf "\n\n\n"
          read -p "Please enter your state: " stat
          read -p "Please enter a statepoint: " statp
          rm 'files/state'
          echo $stat >> 'files/state'
          rm 'files/statepoint'
          echo $statp >> 'files/statepoint'
          ;;
          "4")
          clear
          printf "\n\n\n\n\n\n"

          figlet -c -t "CAPTAIN BASH" | boxes
          printf "\n\n\n"
          pc "1) Speed\n" " "
          pc "2) Exit\n" " "
          printf "\n\n\n"
          read -s -n 1 ba
          case $ba in
               "1")
               read -p "Please enter the speed you wish the dialogue to be in (The default is 0.05) (The current is $speed): " sped
               rm './files/speed'
               echo "$sped" >> './files/speed'
               clear
               printf "\n\n\n\n\n\n"

               figlet -c -t "CAPTAIN BASH" | boxes
               printf "\n\n\n"
               pc "1) Speed\n" " "
               pc "2) Exit\n" " "
               printf "\n\n\n"
               echo "Restarting the game for the settings to take effect"
               exit
               ;;
               "2")
               clear
               exit
               ;;
          esac
          ;;
          "5")
          clear
          exit
          ;;
          *)
          clear
          printf "\n\n\n\n\n\n"

          figlet -c -t "CAPTAIN BASH" | boxes
          printf "\n\n\n"
          pc "1) New Game\n" " "
          pc "2) Continue\n" " "
          pc "3) Select Level (DEV menu)\n" " "
          pc "4) Settings\n" " "
          pc "5) Exit\n" " "
          printf "\n\n\n"
          echo "Wrong Choice"
          exit
          ;;
          esac
}

#########################################################################################################################################

#Story acts

prologue(){

     case $statepoint in
          "0")
          clear
          echo -e "\n\n\n\n\n\n\n"
          sc "=== Prologue ===" " " $speed
          sleep 2
          pak
          clear
          sleep 1
          sp "?: Bash....? Bash wake up!" $speed g
          pak
          sp "?: BASH!!" $speed g
          pak
          sc "Your eyes feel heavy as you open them slowly, noticing a floating ball of characters and symbols hovering above you, glowing a neon green shade" " " $speed
          pak
          sp "?: OH Thank the CPU you're alive!! I thought I'd lost you!" $speed g
          spar=("Who are you?" "Where am I?")
          spmenu "Say" spe "${spar[@]}"
          printf "\n"
          case $spe in
               "0")
               sp "?: WHAT?!?! You've forgotten me already???" $speed g
               pak
               sp "?: Bash please tell me you're joking.....it's me, Askey!" $speed g
               pak
               sc "A faint memory of a companion and guide floods your memory all of a sudden, but then immediately escapes you as quick as you recalled it." " " $speed
               pak
               sp "Askey: You really did forget....what do I do..." $speed g
               pak
               ;;
               "1")
               sp "?: You don't remember this place? ....Bash.." $speed g
               pak
               sp "?: What about me? ....have you forgotten about your friend, Askey?" $speed g
               pak
               sp "Askey: Hmmm....surely I can do something to help you remember.." $speed g
               pak
               ;;
          esac
          sp "Askey: OH!! I know!! Bash, do you still have your 'Terminal Powers'?" $speed g
          rm 'files/statepoint'
          echo 1 >> 'files/statepoint'
          pak
          sp "Askey: Try and see if you can exit this world ....search through yourself using the command 'ls' and see if you can find where your memory bank is! After that, come talk to me again!" $speed g
          pc "Exit to continue..." " " i
          sleep 20
          sp "Askey: You....do know how to exit this world, right? ...press 'CTRL+Z' to exit the world and look for your memory bank! Come back when you find it!" $speed g
          pc "Exit to continue..." " " i
          sleep 20
          sp "Askey: Uhhh....bash? .....you still there?" $speed g
          sleep 15
          sp "Askey: Fine...I'll do it for you, but only this time." $speed g
          exit
          ;;
          "1")
          sp "Askey: So? Did you find it?" $speed g
          spar=("Yeah! I found it!" "Nope, I didn't." "What was I supposed to do again?" "Woof")
          spmenu "Say" spe "${spar[@]}"
          printf "\n"
          case $spe in
               "1")
               sp "Askey: That's okay! I just need you to exit this world! You told me before you used to exit this world with 'CTRL+Z'" $speed g
               pak
               sp "Askey: When you do that, just enter into your terminal 𝐥𝐬. It should display everything inside of you!" $speed g
               pak
               sp "Askey: I believe in you, Bash!" $speed g
               pc "Exit to continue..." " " i
               sleep 10000000000000000000000000000000000000000000000
               ;;
               "2")
               sp "Askey: Bash....your memory really 𝑖𝑠 messed up..." $speed g
               pak
               sp "Askey: That's okay! Your old pal Askey is here to help you!" $speed g
               pak
               sp "Askey: I just need you to exit this world! You told me before you used to exit this world with '𝐂𝐓𝐑𝐋+𝐙'" $speed g
               pak
               sp "Askey: When you do that, just enter into your terminal 𝐥𝐬. It should display everything inside of you!" $speed g
               pak
               sp "Askey: I believe in you, Bash!" $speed g
               pc "Exit to continue..." " " i
               sleep 10000000000000000000000000000000000000000000000
               ;;
               "3")
               sp "Askey: What?" $speed g
               spar=("Woof" "Meow" "Nyeh" "Grrr")
               spmenu "Say" spe "${spar[@]}"
               printf "\n"
               sp "Askey: B-Bash? ...are you okay?" $speed g
               spar=("GGRRR" "WOOF WOOF" "AROOOO" "BAWK BAWK")
               spmenu "Say" spe "${spar[@]}"
               printf "\n"
               sp "Askey: I'm just....going to send you back to look for your memory, okay?" $speed g
               exit
               ;;
               "0")
               sp "Askey: I knew you could find it, Bash!!" $speed g
               pak
               sp "Askey: There's still hope for your memory after all!" $speed g
               pak
               sp "Askey: Now then, let me teach you how to access your memory." $speed g
               pak
               sp "Askey: I believe you used to use your....uhhh.." $speed g
               pak
               sc "Askey suddenly pauses, looking confused as they try and recall what you used to call your ability" " " $speed
               pak
               sp "Askey: I think..you used to call it your..'Change Diaper' ability?" $speed g
               pak
               sp "Askey: ..." $speed g
               sleep 2
               sp "Askey: No....that doesn't seem right..." $speed g
               pak
               sp "?: Yaarg..it ain't be that, my stringy matey." 0.15 y
               pak
               sc "You look behind you as soon as you heard a voice answering Askey, finding a limping pirate approaching you from behind." " " $speed 
               pak
               sp "Askey: OH!! CAPTAIN PUTTY!!!" $speed g
               pak
               sc "Askey flew over towards the pirate, hovering above the ragged old man." " " $speed
               pak
               sp "Captain PuTTY: I saw the old boyo falling with me lookin' eye..." $speed y
               pak
               sp "Askey: Oh Captain....I think Bash lost their memory...they can't even remember me.." $speed g
               pak
               sp "Captain PuTTY: Yaarg..it do be a nasty fall. The boyo looks like they returned NULL on an integer call" $speed y
               pak
               sp "Captain PuTTY: And for the record, it be Directory, Askey...not Diaper." $speed y
               pak
               sp "Askey: OHHHH!! That's right!! Okay!! Bash, use your Change Directory ability using '𝑐𝑑' in your terminal, followed by the name of your folder!" $speed g
               pak
               sp "Askey: In this case, it's 'memory' to enter the memory folder bank!" $speed g
               pak
               sp "Askey: Once you're there, use '𝑙𝑠' again to check your memory. Please...try and remember us.." $speed g
               pak
               sp "Captain PuTTY: Yaarg..ye best use '𝑐𝑎𝑡' and the name of yer file to read ye memory. Remember ye olde mate, Bashy boy.." $speed y
               pak
               sp "Askey: That's right!! Once you're done, just do '𝑐𝑑 ..' to leave the memory bank and come back here!! We'll be waiting for you.." $speed g
               pak
               sp "Captain PuTTY: Go on, boy....we're here" $speed y
               rm 'files/statepoint'
               echo 0 >> 'files/statepoint'
               rm 'files/state'
               echo 1 >> 'files/state'
               pc "Exit to continue..." " " i
               sleep 10000000000000000000000000000000000000000000000
               ;;
          esac
          ;;
     esac
}

act1(){
     case $statepoint in
     "0")
          clear
          echo -e "\n\n\n\n\n\n\n"
          sc "=== Act 1 ===" " " $speed
          sleep 2
          pak
          clear
          sleep 1
          clear
          sc "Reading through your memory files, everything now makes sense." " " $speed
          pak
          sc "You've regained your memory of the world, and your friends as well." " " $speed
          pak
          sc "As you open your eyes slowly, you find Askey and Captain PuTTY staring at you, waiting on you to wake up." " " $speed
          pak
          sp "Askey: Bash? ...are you okay?" $speed g
          pak
          sp "Askey: Do you....remember me?" $speed g
          pak
          sp "Captain PuTTY: Yaarg....have faith, me boy..Bash..ye best wake up...tell us, do ye remember our mugs?" $speed y
          spar=("Askey?" "Captain?" "I remember you two!" "Who are you two?")
          spmenu "Say" spe "${spar[@]}"
          case $spe in
               "2"|"1"|"0")
               echo ""
               sp "Askey: YOU DO REMEMBER US!!!" $speed g
               pak
               sp "Askey: I knew you wouldn't forget us, Bash!! Not after everything we've been through!!" $speed g
               pak
               sp "Captain PuTTY: Yarr...you did good, boy..welcome back." $speed y
               pak
               ;;
               "3")
               echo ""
               sp "Askey: Oh no...Captain PuTTY...they still don't remember us.." $speed g
               pak
               sp "Captain PuTTY: Mmmm....ye not be lookin at the boy's smile...that boy be as ambiguous as an abstract function on me ship." $speed y
               pak
               sp "Askey: BAAASH!! DON'T JOKE AROUND LIKE THAT!!" $speed g
               pak
               ;;
          esac
          sc "Askey flew towards you, hugging you as tightly as possible, wrapping you in their strings." " " $speed
          pak
          sp "Askey: I thought I'd lost you forever, Bash!! I'm so happy!" $speed g 
          pak
          sp "Captain PuTTY: If ye forgot our adventures, I'd be worse than an open network port." $speed y
          pak
          rm './files/statepoint'
          echo 1 >> './files/statepoint'
          ;;&
     "1"|"0")
          sp "Askey: Askey and Captain Bash are back!! Now, let's continue our adventure!! We still have to get to the CentOS plains!" $speed g
          pak
          sp "Captain PuTTY: Arrrgh...the SSH and I can take ye both as far as Arch Plataeu...me crew still has work in Ubuntu Highlands..so ye best get ready and accquainted with the land." $speed y
          pak
          echo -e "\n\n\n\n"
          pc "END OF CAPTAIN BASH DEMO" " " i
          echo ""
          pc "THANK YOU FOR PLAYING!" " " i
          echo ""
          pc "MADE BY: Youssef Ehab for his OS Assignment" " " i
          exit
     esac

}

#########################################################################################################################################

#The Game

titlescreen

state=$(<./files/state)
statepoint=$(<./files/statepoint)
speed=$(<./files/speed)
clear

case $state in
     "0")
     prologue
     ;;
     "1")
     act1
     ;;
     "2")
     act2
     ;;
     "3")
     act3
     ;;
     "4")
     reset
     ;;
     *)
     echo "Unexpected Error, Jojo"
     ;;
     esac
