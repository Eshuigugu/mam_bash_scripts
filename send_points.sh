#!/bin/bash
set -e
set -x
cd working_dir
curlm="curlm path"

r='{"success":true,"type":"gift","amount":1000,"seedbonus":0,"to":"","toName":""}'
user_id=`cat start_user.txt`
#user_id=$((user_id+ RANDOM % 3))

succ=-1
fails=0

while [[ $r =~ "1000" ]]
do

        r=$($curlm 'https://www.myanonamouse.net/json/bonusBuy.php/?spendtype=gift&amount=1000&giftTo='$user_id  | jq '.timestamp=now'  --indent 0)

        if [[ `echo $r | jq .error` == '"Amount more than current points"' ]]
        then
                r=1000
                user_id=$((user_id-1))
                sleep 3600
        else
                echo "$r" >> points_sent.log
                if [[ $r =~ "1000" ]]
                then
                        if [[ `$curlm 'https://www.myanonamouse.net/jsonLoad.php?id='$user_id | jq .uploaded` != '"0.00 KiB"' ]]
                        then
                                $curlm 'https://www.myanonamouse.net/json/bonusBuy.php/?spendtype=sendWedge&giftTo='$user_id
                        fi
                        succ=$((succ+1))
                        suc_id=$((user_id))
                else
                        fails=$((fails+1))
                        if [[ $fails -lt 5 ]]
                        then
                                r=1000
                        fi
                fi
        fi


        user_id=$((user_id+1))
        sleep 4
done

if [[ $succ -ge 1 ]]
then
    echo $((suc_id+1)) > start_user.txt
else
        # this part aids in skipping disabled users
        if [ $((RANDOM%200)) -eq 0 ]
        then
                #echo $((user_id+ RANDOM % 10)) > start_user.txt
                echo $((suc_id+5)) > start_user.txt
        fi
fi
