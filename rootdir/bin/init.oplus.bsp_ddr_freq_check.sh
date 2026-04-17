#!/system/bin/sh

#=============================================================================
#persist.debug.ddr.vcorefs.config
#testing_phase=`getprop persist.debug.ddr.vcorefs.config`
#=============================================================================

#### wait latency for each DVFS finish (0.1=100ms, 0.001=1ms) 600 = 60s
T_DVFS_INTERVAL=1
ntest=120
T_WAIT_RANDOM=10
echo test start >> /data/DDR_FREQ_CHECK_RESULT.txt

platform=`getprop ro.board.platform`
echo "platform is $platform"
echo "platform is $platform" >> /data/DDR_FREQ_CHECK_RESULT.txt

if echo "$platform" | grep -q "mt"; then
    PLAT="MTK"
else
    PLAT="QCOM"
fi

echo "PLAT is $PLAT"
echo "PLAT is $PLAT" >> /data/DDR_FREQ_CHECK_RESULT.txt

if [ $PLAT == "QCOM" ]; then
    if [ ${#bimc_scaling_freq_list_temp[*]} == 0 ]; then
        bimc_scaling_freq_list_temp=(`cat /sys/devices/system/cpu/bus_dcvs/DDR/available_frequencies`)
    fi
    bimc_scaling_freq_list_temp_len=${#bimc_scaling_freq_list_temp[*]}
    echo "bimc_scaling_freq_list_temp : ${bimc_scaling_freq_list_temp[@]}"
else
    if [ x"$platform" = x"mt6877" ] || [ x"$platform" = x"mt6833" ]; then
        DVFSRC_PATH="/sys/devices/platform/10012000.dvfsrc/helio-dvfsrc/"
    else
        DVFSRC_PATH="/sys/kernel/helio-dvfsrc/"
    fi
    NUM_DVFSRC_OPP=$(($(cat ${DVFSRC_PATH}dvfsrc_num_opps)-1))
fi

if [ ${#DDR_Freq_List[*]} == 0 ]; then
    if [ -f /cache/factory/DDR_Freq_Config.csv ]; then
        echo "/cache/factory/DDR_Freq_Config.csv exist"
        DDR_Freq_Config="/cache/factory/DDR_Freq_Config.csv"
        while read line; do
            echo "${line[@]}"
        done < "$DDR_Freq_Config"
        echo $line
        BAK_IFS=$IFS
        IFS=','
        DDR_Freq_List=($line)
        echo "DDR_Freq_List Length: ${#DDR_Freq_List[*]}"
        echo "DDR_Freq_List: ${DDR_Freq_List[@]}"
        echo "DDR_Freq_List Length: ${#DDR_Freq_List[*]}" >> /data/DDR_FREQ_CHECK_RESULT.txt
        echo "DDR_Freq_List: ${DDR_Freq_List[@]}" >> /data/DDR_FREQ_CHECK_RESULT.txt
        IFS=$BAK_IFS
    else
        echo "/cache/factory/DDR_Freq_Config.csv not exist"
        DDR_Freq_List=()
        if [ $PLAT == "QCOM" ]; then
            for i in  $(seq 0 $(($bimc_scaling_freq_list_temp_len))); do
                if [ $i == 0 ]; then
                    DDR_Freq_List[i]="Qcom"
                else
                    DDR_Freq_List[i]=${bimc_scaling_freq_list_temp[$(($i-1))]}
                fi
                echo "DDR_Freq_List[$i] is ${DDR_Freq_List[$i]}"
            done
        else
            for i in  $(seq 0 $(($NUM_DVFSRC_OPP+1))); do
                if [ $i == 0 ]; then
                    DDR_Freq_List[i]="MTK"
                else
                    DDR_Freq_List[i]=$(($i-1))
                fi
                echo "DDR_Freq_List[$i] is ${DDR_Freq_List[$i]}"
            done
        fi

        echo "DDR_Freq_List Length: ${#DDR_Freq_List[*]}"
        echo "DDR_Freq_List: ${DDR_Freq_List[@]}"
        echo "DDR_Freq_List Length: ${#DDR_Freq_List[*]}" >> /data/DDR_FREQ_CHECK_RESULT.txt
        echo "DDR_Freq_List: ${DDR_Freq_List[@]}" >> /data/DDR_FREQ_CHECK_RESULT.txt
    fi
fi

DDR_Freq_List_Len=${#DDR_Freq_List[*]}
NUM_DVFSRC_OPP=$((${#DDR_Freq_List[*]}-1))

if [ $PLAT == "QCOM" ]; then
    bimc_scaling_freq_list=()
    for i in  $(seq 0 $(($DDR_Freq_List_Len-1))); do
        echo "i is $i"
        if [ $i == 0 ]; then
            continue
        else
            bimc_scaling_freq_list[(($i-1))]=${DDR_Freq_List[$i]}
            echo "bimc_scaling_freq_list[$(($i-1))] is ${bimc_scaling_freq_list[$(($i-1))]}"
        fi
    done
    echo "bimc_scaling_freq_list : ${bimc_scaling_freq_list[@]}"
    echo "bimc_scaling_freq_list_len : ${#bimc_scaling_freq_list[*]}"
fi

DDR_FREQ_TABLE_TEMP=()
for i in $(seq 1 $NUM_DVFSRC_OPP);
do
    DDR_FREQ_TABLE_TEMP[i]=0
done
echo "DDR_FREQ_TABLE_TEMP is : ${DDR_FREQ_TABLE_TEMP[@]}"
DDR_FREQ_TABLE_TEMP_LEN=${#DDR_FREQ_TABLE_TEMP[*]}
DDR_FREQ_TABLE_TEMP_INDEX=1
for element in ${DDR_Freq_List[@]}
do
    if [ "$element" = "QCOM" ]; then
        echo "element is $element continue"
        continue
    elif [ "$element" = "MTK" ]; then
        echo "element is $element continue"
        continue
    else
        if  [ $PLAT == "QCOM" ]; then
            DDR_FREQ=`expr $element / 1000`
        else
            opp=$(($element+5))
            p=p
            line=$opp$p
            echo "line is $line"
            DVFSRC_OPP_TABLE_LINE=$(cat ${DVFSRC_PATH}dvfsrc_opp_table | sed -n $line | cut -c22-)
            DDR_FREQ=$(cat ${DVFSRC_PATH}dvfsrc_opp_table | sed -n $line | cut -c22- | sed 's/[^0-9]//g')
            if echo "$DVFSRC_OPP_TABLE_LINE" | grep -q "kbps"; then
                DDR_FREQ=`expr $DDR_FREQ / 1000`
            fi
        fi
        echo "*****DDR_FREQ is $DDR_FREQ"
        echo "*****DDR_FREQ_TABLE_TEMP_INDEX is $DDR_FREQ_TABLE_TEMP_INDEX"
        DDR_FREQ_TABLE_TEMP[$DDR_FREQ_TABLE_TEMP_INDEX]=$DDR_FREQ
        ((DDR_FREQ_TABLE_TEMP_INDEX++))
    fi
done
echo "*****NOW DDR_FREQ_TABLE_TEMP is : ${DDR_FREQ_TABLE_TEMP[@]}" >> /data/DDR_FREQ_CHECK_RESULT.txt

temp_file="data/ddrtempfreq"
for element in "${DDR_FREQ_TABLE_TEMP[@]}"
do
    if ! grep -q "$element" $temp_file; then
        echo "$element" >> $temp_file
    fi
done
DDR_FREQ_TABLE=( $(cat $temp_file | sort -u) )
DDR_FREQ_TABLE_LEN=${#DDR_FREQ_TABLE[*]}
echo "*****NEW DDR_FREQ_TABLE is : ${DDR_FREQ_TABLE[@]}" >> /data/DDR_FREQ_CHECK_RESULT.txt
echo "*****NEW DDR_FREQ_TABLE_LEN is : ${#DDR_FREQ_TABLE[*]}" >> /data/DDR_FREQ_CHECK_RESULT.txt

DDR_FREQ_TEST_TABLE=()
for i in $(seq 1 ${#DDR_FREQ_TABLE[*]});
do
  DDR_FREQ_TEST_TABLE[i]=0
done
echo "before test, DDR_FREQ_TEST_TABLE is : ${DDR_FREQ_TEST_TABLE[@]}"


do_ddr_freq_check(){
    DDR_FREQ_MATCH_COUNT=0
    echo $DDR_FREQ_MATCH_COUNT
    for element in ${DDR_FREQ_TABLE[@]}
    do
        echo "element is $element ======"
        for i in ${DDR_FREQ_TEST_TABLE[@]}
        do
            echo "i is $i"
            if [ $i == $element ]; then
                echo "i==element ***matched***"
                ((DDR_FREQ_MATCH_COUNT++))
                break
            else
                if [ $i -gt $element ]; then
                    echo "i>element"
                    res=$(($i-$element))
                else
                    echo "i<element"
                    res=$(($element-$i))
                fi
                echo "res is $res"
            fi

            if [ $res -lt 120 ]; then
                echo "i close to element ***matched***"
                ((DDR_FREQ_MATCH_COUNT++))
                break
            else
                continue
            fi
        done
    done
    echo "======CHECK END======="
    echo "DDR_FREQ_MATCH_COUNT is $DDR_FREQ_MATCH_COUNT"
    echo "DDR_FREQ_TEST_TABLE is : ${DDR_FREQ_TEST_TABLE[@]}"
    echo "DDR_FREQ_TABLE is : ${DDR_FREQ_TABLE[@]}"

    echo "======CHECK END=======" >> /data/DDR_FREQ_CHECK_RESULT.txt
    echo "DDR_FREQ_MATCH_COUNT is $DDR_FREQ_MATCH_COUNT" >> /data/DDR_FREQ_CHECK_RESULT.txt
    echo "DDR_FREQ_TEST_TABLE is : ${DDR_FREQ_TEST_TABLE[@]}" >> /data/DDR_FREQ_CHECK_RESULT.txt
    echo "DDR_FREQ_TABLE is : ${DDR_FREQ_TABLE[@]}" >> /data/DDR_FREQ_CHECK_RESULT.txt
    if [ $DDR_FREQ_MATCH_COUNT == $DDR_FREQ_TABLE_LEN ]; then
        DDR_FREQ_CHECK_RESULT="SUCCESS"
    else
        DDR_FREQ_CHECK_RESULT="FAIL"
    fi
    echo "DDR_FREQ_CHECK_RESULT is $DDR_FREQ_CHECK_RESULT"
    echo "DDR_FREQ_CHECK_RESULT is $DDR_FREQ_CHECK_RESULT" >> /data/DDR_FREQ_CHECK_RESULT.txt
}


do_record_current_ddr_freq(){
    DDR_FREQ_TEST_TABLE_LEN=${#DDR_FREQ_TEST_TABLE[*]}

    if [ $PLAT == "QCOM" ]; then
        DDR_CUR_FREQ_TEMP=`cat /sys/kernel/debug/clk/measure_only_mccc_clk/clk_measure`
        DDR_CUR_FREQ=`expr $DDR_CUR_FREQ_TEMP / 1000000`
    else
        DDR_FREQ_DUMP=$(cat ${DVFSRC_PATH}dvfsrc_dump | grep -e "DDR       :")
        DDR_CUR_FREQ=$(cat ${DVFSRC_PATH}dvfsrc_dump | grep -e "DDR       :" | sed 's/[^0-9]//g')
        if echo "$DDR_FREQ_DUMP" | grep -q "kbps"; then
            DDR_CUR_FREQ=`expr $DDR_CUR_FREQ / 1000`
        fi
    fi
    echo "DDR_CUR_FREQ is $DDR_CUR_FREQ"

    for i in $(seq 1 ${DDR_FREQ_TEST_TABLE_LEN})
    do
        echo "i is $i"
        echo "DDR_FREQ_TEST_TABLE[$i] is ${DDR_FREQ_TEST_TABLE[$i]}"
        if [ ${DDR_FREQ_TEST_TABLE[$i]} == $DDR_CUR_FREQ ]; then
            echo "DDR_CUR_FREQ $DDR_CUR_FREQ have been recorded, break"
            break
        elif [ ${DDR_FREQ_TEST_TABLE[$i]} == 0 ]; then
            echo "record DDR_CUR_FREQ $DDR_CUR_FREQ"
            DDR_FREQ_TEST_TABLE[$i]=$DDR_CUR_FREQ
            break
        else
            echo "continue"
            continue
        fi
    done
}

do_get_ddr_freq(){
    while [ 1 ]
    do
        ddr_testphase=`getprop persist.debug.ddr.vcorefs.config`
        if [ "$ddr_testphase" = "random" ]; then
            echo "test_phase is random" >> /data/DDR_FREQ_CHECK_RESULT.txt
            for i in $(seq 1 ${ntest})
            do
                sleep $T_DVFS_INTERVAL
                if [ $PLAT == "QCOM" ]; then
                    ddr_cur_freq=(`cat /sys/kernel/debug/clk/measure_only_mccc_clk/clk_measure`)
                else
                    ddr_cur_freq=$(cat ${DVFSRC_PATH}dvfsrc_dump | grep -e "DDR       :" | sed 's/[^0-9]//g')
                fi
                echo "ddr_cur_freq: $ddr_cur_freq" >> /data/DDR_FREQ_CHECK_RESULT.txt
                do_record_current_ddr_freq
                echo "DDR_FREQ_TEST_TABLE is : ${DDR_FREQ_TEST_TABLE[@]}"
            done
            break
        else
            echo "test_phase is $ddr_testphase, not random, waiting..."
            sleep $T_WAIT_RANDOM
            continue
        fi
    done
    echo "do_get_ddr_freq end"
    echo "do_get_ddr_freq end" >> /data/DDR_FREQ_CHECK_RESULT.txt
}


do_get_ddr_freq
do_ddr_freq_check

