#!/system/bin/sh
#=============================================================================
#persist.debug.cpu.dvfs.config
#testing_phase=`getprop persist.debug.cpu.dvfs.config`
#=============================================================================

echo "Just for CPU DVFS Debug"

#ntest*delay= 1200S
ntest=4000
delay=0.3    ## 300ms

platform=`getprop ro.board.platform`

CPUFREQ_INFO_PATH="/sys/devices/system/cpu/cpufreq"
CPUFREQ_LIST_PATH="scaling_available_frequencies"
CPUFREQ_CURFREQ_PATH="scaling_cur_freq"
CPUFREQ_MAX_PATH="scaling_max_freq"
CPUFREQ_MIN_PATH="scaling_min_freq"

policies=(0 4 7)

lit_cfrqs=(`cat $CPUFREQ_INFO_PATH/policy${policies[0]}/$CPUFREQ_LIST_PATH`)
big_cfrqs=(`cat $CPUFREQ_INFO_PATH/policy${policies[1]}/$CPUFREQ_LIST_PATH`)
gold_cfrqs=(`cat $CPUFREQ_INFO_PATH/policy${policies[2]}/$CPUFREQ_LIST_PATH`)

display_freq() {
    echo "policy0 cur_freq: " $(< $CPUFREQ_INFO_PATH/policy${policies[0]}/$CPUFREQ_CURFREQ_PATH)
    echo "policy4 cur_freq: " $(< $CPUFREQ_INFO_PATH/policy${policies[1]}/$CPUFREQ_CURFREQ_PATH)
    echo "policy7 cur_freq: " $(< $CPUFREQ_INFO_PATH/policy${policies[2]}/$CPUFREQ_CURFREQ_PATH)
}

#cpu dvfs ramdom
do_cpudvfs_random(){
    for i in $(seq 1 ${ntest})
    do
        l=$(($RANDOM%${#lit_cfrqs[@]}))
        g=$(($RANDOM%${#big_cfrqs[@]}))
        gg=$(($RANDOM%${#gold_cfrqs[@]}))
        echo ${lit_cfrqs[l]} > $CPUFREQ_INFO_PATH/policy${policies[0]}/$CPUFREQ_MAX_PATH
        echo ${lit_cfrqs[l]} > $CPUFREQ_INFO_PATH/policy${policies[0]}/$CPUFREQ_MIN_PATH
        echo ${big_cfrqs[g]} > $CPUFREQ_INFO_PATH/policy${policies[1]}/$CPUFREQ_MAX_PATH
        echo ${big_cfrqs[g]} > $CPUFREQ_INFO_PATH/policy${policies[1]}/$CPUFREQ_MIN_PATH
        echo ${gold_cfrqs[gg]} > $CPUFREQ_INFO_PATH/policy${policies[2]}/$CPUFREQ_MAX_PATH
        echo ${gold_cfrqs[gg]} > $CPUFREQ_INFO_PATH/policy${policies[2]}/$CPUFREQ_MIN_PATH

        display_freq
        sleep ${delay}
    done
}

#cpu dvfs fixOPPmax
do_cpudvfs_fixOPPmax(){
    echo "cpu dvfs fixOPPmin"
    for i in $(seq 1 ${ntest})
    do
        l=0
        g=0
        gg=0
        echo ${lit_cfrqs[l]} > $CPUFREQ_INFO_PATH/policy${policies[0]}/$CPUFREQ_MAX_PATH
        echo ${lit_cfrqs[l]} > $CPUFREQ_INFO_PATH/policy${policies[0]}/$CPUFREQ_MIN_PATH
        echo ${big_cfrqs[g]} > $CPUFREQ_INFO_PATH/policy${policies[1]}/$CPUFREQ_MAX_PATH
        echo ${big_cfrqs[g]} > $CPUFREQ_INFO_PATH/policy${policies[1]}/$CPUFREQ_MIN_PATH
        echo ${gold_cfrqs[gg]} > $CPUFREQ_INFO_PATH/policy${policies[2]}/$CPUFREQ_MAX_PATH
        echo ${gold_cfrqs[gg]} > $CPUFREQ_INFO_PATH/policy${policies[2]}/$CPUFREQ_MIN_PATH

        display_freq
        sleep ${delay}
    done
}


#cpu dvfs fixOPPmin
do_cpudvfs_fixOPPmin(){
    echo "cpu dvfs fixOPPmax"
    for i in $(seq 1 ${ntest})
    do
        l=${#lit_cfrqs[@]}-1
        g=${#big_cfrqs[@]}-1
        gg=${#gold_cfrqs[@]}-1
        echo ${lit_cfrqs[l]} > $CPUFREQ_INFO_PATH/policy${policies[0]}/$CPUFREQ_MAX_PATH
        echo ${lit_cfrqs[l]} > $CPUFREQ_INFO_PATH/policy${policies[0]}/$CPUFREQ_MIN_PATH
        echo ${big_cfrqs[g]} > $CPUFREQ_INFO_PATH/policy${policies[1]}/$CPUFREQ_MAX_PATH
        echo ${big_cfrqs[g]} > $CPUFREQ_INFO_PATH/policy${policies[1]}/$CPUFREQ_MIN_PATH
        echo ${gold_cfrqs[gg]} > $CPUFREQ_INFO_PATH/policy${policies[2]}/$CPUFREQ_MAX_PATH
        echo ${gold_cfrqs[gg]} > $CPUFREQ_INFO_PATH/policy${policies[2]}/$CPUFREQ_MIN_PATH

        display_freq
        sleep ${delay}
    done
}


#cpu dvfs OPPmax-OPPmin
do_cpudvfs_OPPmax_OPPmin(){
    echo "cpu dvfs fixOPP0"
    for i in $(seq 1 ${ntest})
    do
        check=$(($RANDOM%2))
        if [ $check -eq 0 ]; then
            l=0
            g=0
            gg=0
        else
            l=${#lit_cfrqs[@]}-1
            g=${#big_cfrqs[@]}-1
            gg=${#gold_cfrqs[@]}-1
        fi
        echo ${lit_cfrqs[l]} > $CPUFREQ_INFO_PATH/policy${policies[0]}/$CPUFREQ_MAX_PATH
        echo ${lit_cfrqs[l]} > $CPUFREQ_INFO_PATH/policy${policies[0]}/$CPUFREQ_MIN_PATH
        echo ${big_cfrqs[g]} > $CPUFREQ_INFO_PATH/policy${policies[1]}/$CPUFREQ_MAX_PATH
        echo ${big_cfrqs[g]} > $CPUFREQ_INFO_PATH/policy${policies[1]}/$CPUFREQ_MIN_PATH
        echo ${gold_cfrqs[gg]} > $CPUFREQ_INFO_PATH/policy${policies[2]}/$CPUFREQ_MAX_PATH
        echo ${gold_cfrqs[gg]} > $CPUFREQ_INFO_PATH/policy${policies[2]}/$CPUFREQ_MIN_PATH
        display_freq
        sleep ${delay}
    done
}

do_cpudvfs_longstep_random(){
    echo "cpu dvfs long step random"
    llen=$((${#lit_cfrqs[@]}-1))
    glen=$((${#big_cfrqs[@]}-1))
    gglen=$((${#gold_cfrqs[@]}-1))
    lcurrent=0
    gcurrent=0
    ggcurrent=0
    lmid=$(($llen/2))
    gmid=$(($glen/2))
    ggmid=$(($gglen/2))
    for i in $(seq 1 ${ntest})
    do
        do_cpuhotplug

        lstep=$(($(($RANDOM%$(($llen-5))))+5))
        gstep=$(($(($RANDOM%$(($glen-5))))+5))
        ggstep=$(($(($RANDOM%$(($gglen-5))))+5))

        if [ $lcurrent -lt $lstep ]; then
            lcurrent=$(($lcurrent+$lstep))
        else
            lcurrent=$(($lcurrent-$lstep))
        fi
        if [ $gcurrent -lt $gstep ]; then
            gcurrent=$(($gcurrent+$gstep))
        else
            gcurrent=$(($gcurrent-$gstep))
        fi
        if [ $ggcurrent -lt $ggstep ]; then
            ggcurrent=$(($ggcurrent+$ggstep))
        else
            ggcurrent=$(($ggcurrent-$ggstep))
        fi

        if [ $lcurrent -lt 0 ]; then
            lcurrent=0
        fi
        if [ $gcurrent -lt 0 ]; then
            gcurrent=0
        fi
        if [ $ggcurrent -lt 0 ]; then
            ggcurrent=0
        fi

        if [ $lcurrent -eq $llen ]; then
            lcurrent=$llen
        fi
        if [ $gcurrent -eq $glen ]; then
            gcurrent=$glen
        fi
        if [ $ggcurrent -eq $gglen ]; then
            ggcurrent=$gglen
        fi

        if [ $lcurrent -gt $llen ]; then
            lcurrent=$llen
        fi
        if [ $gcurrent -gt $glen ]; then
            gcurrent=$glen
        fi
        if [ $ggcurrent -gt $gglen ]; then
            ggcurrent=$gglen
        fi

        echo ${lit_cfrqs[lcurrent]} > $CPUFREQ_INFO_PATH/policy${policies[0]}/$CPUFREQ_MAX_PATH
        echo ${lit_cfrqs[lcurrent]} > $CPUFREQ_INFO_PATH/policy${policies[0]}/$CPUFREQ_MIN_PATH
        echo ${big_cfrqs[gcurrent]} > $CPUFREQ_INFO_PATH/policy${policies[1]}/$CPUFREQ_MAX_PATH
        echo ${big_cfrqs[gcurrent]} > $CPUFREQ_INFO_PATH/policy${policies[1]}/$CPUFREQ_MIN_PATH
        echo ${gold_cfrqs[ggcurrent]} > $CPUFREQ_INFO_PATH/policy${policies[2]}/$CPUFREQ_MAX_PATH
        echo ${gold_cfrqs[ggcurrent]} > $CPUFREQ_INFO_PATH/policy${policies[2]}/$CPUFREQ_MIN_PATH
        echo ${lcurrent}
        echo ${gcurrent}
        echo ${ggcurrent}
        display_freq
        sleep ${delay}
    done
}

do_cpudvfs_shortstep_random(){
    echo "cpu dvfs short step random"
    l=$(($RANDOM%${#lit_cfrqs[@]}))
    g=$(($RANDOM%${#big_cfrqs[@]}))
    gg=$(($RANDOM%${#gold_cfrqs[@]}))
    for i in $(seq 1 ${ntest})
    do
        do_cpuhotplug
        LL_step=$(($RANDOM%3))
        L_step=$(($RANDOM%3))
        SL_step=$(($RANDOM%3))

        l=$(($l+1+$LL_step))
        g=$(($g+1+$L_step))
        gg=$(($gg+1+$SL_step))

        l=$(($l%${#lit_cfrqs[@]}))
        g=$(($g%${#big_cfrqs[@]}))
        gg=$(($gg%${#gold_cfrqs[@]}))

        echo ${lit_cfrqs[l]} > $CPUFREQ_INFO_PATH/policy${policies[0]}/$CPUFREQ_MAX_PATH
        echo ${lit_cfrqs[l]} > $CPUFREQ_INFO_PATH/policy${policies[0]}/$CPUFREQ_MIN_PATH
        echo ${big_cfrqs[g]} > $CPUFREQ_INFO_PATH/policy${policies[1]}/$CPUFREQ_MAX_PATH
        echo ${big_cfrqs[g]} > $CPUFREQ_INFO_PATH/policy${policies[1]}/$CPUFREQ_MIN_PATH
        echo ${gold_cfrqs[gg]} > $CPUFREQ_INFO_PATH/policy${policies[2]}/$CPUFREQ_MAX_PATH
        echo ${gold_cfrqs[gg]} > $CPUFREQ_INFO_PATH/policy${policies[2]}/$CPUFREQ_MIN_PATH

        display_freq
        sleep ${delay}
    done
}


#cpu Hotplug ittle cpu core >=2, big core >=0
do_cpuhotplug(){
    # little cpu core >=2, big core >=0
}


enable_cpu_hotplug_dvfs_test(){
    while [ 1 ]
    do
        cpu_debugconfig=`getprop persist.debug.cpu.dvfs.config`
        if [ "$cpu_debugconfig" = "done" ]; then
            break
        fi
        setprop persist.debug.cpu.dvfs.config max
        cpu_debugconfig=`getprop persist.debug.cpu.dvfs.config`
        echo "cpu_debugconfig:$cpu_debugconfig."
        if [ "$cpu_debugconfig" = "max" ]; then
            do_cpudvfs_fixOPPmax
        fi

        cpu_debugconfig=`getprop persist.debug.cpu.dvfs.config`
        if [ "$cpu_debugconfig" = "done" ]; then
            break
        fi
        setprop persist.debug.cpu.dvfs.config min
        cpu_debugconfig=`getprop persist.debug.cpu.dvfs.config`
        echo "cpu_debugconfig:$cpu_debugconfig."
        if [ "$cpu_debugconfig" = "min" ]; then
            do_cpudvfs_fixOPPmin
        fi

        cpu_debugconfig=`getprop persist.debug.cpu.dvfs.config`
        if [ "$cpu_debugconfig" = "done" ]; then
            break
        fi
        setprop persist.debug.cpu.dvfs.config max_min
        cpu_debugconfig=`getprop persist.debug.cpu.dvfs.config`
        echo "cpu_debugconfig:$cpu_debugconfig."
        if [ "$cpu_debugconfig" = "max_min" ]; then
            do_cpudvfs_OPPmax_OPPmin
        fi

        cpu_debugconfig=`getprop persist.debug.cpu.dvfs.config`
        if [ "$cpu_debugconfig" = "done" ]; then
            break
        fi
        setprop persist.debug.cpu.dvfs.config longstep_random
        cpu_debugconfig=`getprop persist.debug.cpu.dvfs.config`
        echo "cpu_debugconfig:$cpu_debugconfig."
        if [ "$cpu_debugconfig" = "longstep_random" ]; then
            do_cpudvfs_longstep_random
        fi

        cpu_debugconfig=`getprop persist.debug.cpu.dvfs.config`
        if [ "$cpu_debugconfig" = "done" ]; then
            break
        fi
        setprop persist.debug.cpu.dvfs.config shortstep_random
        cpu_debugconfig=`getprop persist.debug.cpu.dvfs.config`
        echo "cpu_debugconfig:$cpu_debugconfig."
        if [ "$cpu_debugconfig" = "shortstep_random" ]; then
            do_cpudvfs_shortstep_random
        fi

        cpu_debugconfig=`getprop persist.debug.cpu.dvfs.config`
        if [ "$cpu_debugconfig" = "done" ]; then
            break
        fi
        setprop persist.debug.cpu.dvfs.config random
        cpu_debugconfig=`getprop persist.debug.cpu.dvfs.config`
        echo "cpu_debugconfig:$cpu_debugconfig."
        if [ "$cpu_debugconfig" = "random" ]; then
            do_cpudvfs_random
        fi
    done
    echo "The test is done and PASS if no exception occurred."
}

enable_cpu_hotplug_dvfs_test_manual(){
    cpu_debugconfig=`getprop persist.debug.cpu.dvfs.config`
    while [ 1 ]
    do
        if [ "$cpu_debugconfig" != "done" ]; then
            break
        fi
        cpu_manualconfig=`getprop persist.debug.cpu.dvfs.manual`
        echo "cpu_manualconfig:$cpu_manualconfig."
        if [ "$cpu_manualconfig" = "random" ]; then
            do_cpudvfs_ramdom
        elif [ "$cpu_manualconfig" = "max" ]; then
            do_cpudvfs_fixOPPmax
        elif [ "$cpu_manualconfig" = "min" ]; then
            do_cpudvfs_fixOPPmin
        elif [ "$cpu_manualconfig" = "max_min" ]; then
            do_cpudvfs_OPPmax_OPPmin
        elif [ "$cpu_manualconfig" = "longstep_random" ]; then
            do_cpudvfs_longstep_random
        elif [ "$cpu_manualconfig" = "shortstep_random" ]; then
            do_cpudvfs_shortstep_random
        elif [ "$cpu_manualconfig" = "done" ]; then
            break
        else
            sleep 10
        fi
    done
    echo "The cpu_manualconfig is done and PASS if no exception occurred."
}

enable_cpu_hotplug_dvfs_test
enable_cpu_hotplug_dvfs_test_manual
