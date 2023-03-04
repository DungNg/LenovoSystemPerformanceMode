#!/bin/bash
clear
echo "
Current System Information"
echo "----------------------------"

BatterySaving=1;
IntelligentCooling=2;
ExtremePerformance=3;
BatteryConservation=4;
RapidCharge=5;
low="0x0";
high="0x1";

modprobe acpi_call

GetSTMD(){
	echo '\_SB.PCI0.LPC0.EC0.STMD' > /proc/acpi/call
	STMD="$(tr -d '\0' <  /proc/acpi/call)";
	if [ "$STMD" == "$low" ]; then
		return 0
	elif [ "$STMD" == "$high" ]; then
		return 1
	fi
}

GetQTMD(){
	echo '\_SB.PCI0.LPC0.EC0.QTMD' > /proc/acpi/call
	QTMD="$(tr -d '\0' <  /proc/acpi/call)";
	if [ "$QTMD" == "$low" ]; then
		return 0
	elif [ "$QTMD" == "$high" ]; then
		return 1
	fi
}

GetCurrentSystemPerformanceMode(){
	GetSTMD
	STMD=$?

	GetQTMD
	QTMD=$?

	if [ "$STMD" -eq 0 ] && [ "$QTMD" -eq 0 ]; then
		return $ExtremePerformance
	elif [ "$STMD" -eq 0 ] && [ "$QTMD" -eq 1 ]; then
		return $BatterySaving
	elif [ "$STMD" -eq 1 ] && [ "$QTMD" -eq 0 ]; then
		return $IntelligentCooling
	fi
}

GetCurrentBatteryConservationStatus(){
	echo '\_SB.PCI0.LPC0.EC0.BTSG' > /proc/acpi/call
	currentStatus="$(tr -d '\0' <  /proc/acpi/call)"; #Battery Conservation

	if [ "$currentStatus" == "$low" ]; then
		return 0
	elif [ "$currentStatus" == "$high" ]; then
		return 1
	fi
}

GetCurrentRapidChargeStatus(){
	echo '\_SB.PCI0.LPC0.EC0.FCGM' > /proc/acpi/call
	currentStatus="$(tr -d '\0' <  /proc/acpi/call)"; #Rapid Charge

	if [ "$currentStatus" == "$low" ]; then
		return 0
	elif [ "$currentStatus" == "$high" ]; then
		return 1
	fi
}

PrintSystemPerformanceMode(){
	if [ "$1" -eq $BatterySaving ]; then
		echo "Mode: Battery Saving"
	elif [ "$1" -eq $ExtremePerformance ]; then
		echo "Mode: Extreme Performance"
	elif [ "$1" -eq $IntelligentCooling ]; then
		echo "Mode: Intelligent Cooling"
	fi
}

PrintBatteryConservationStatus(){
	if [ "$1" -eq 0 ]; then 
		echo "Battery Conservation: Off"
	elif [ "$1" -eq 1 ]; then
		echo "Battery Conservation: On"
	fi
}

PrintRapidChargeStatus(){
	if [ "$1" -eq 0 ]; then 
		echo "Rapid Charge: Off"
	elif [ "$1" -eq 1 ]; then
		echo "Rapid Charge: On"
	fi
}

GetCurrentSystemPerformanceMode
CurrentSPM=$?
PrintSystemPerformanceMode "$CurrentSPM"

GetCurrentBatteryConservationStatus
CurrentBC=$?
PrintBatteryConservationStatus "$CurrentBC"

GetCurrentRapidChargeStatus
CurrentRC=$?
PrintRapidChargeStatus "$CurrentRC"

echo "----------------------------"
echo "
1. Battery Saving
2. Intelligent Cooling
3. Extreme Performance
4. Toggle Battery Conservation
5. Toggle Rapid Charge
"

read -p 'Your selection: ' selection

echo "-------------------------------------------------------------"

TurnBatteryConservationOn(){
	echo 'Turn On Battery Conservation'
	echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x03' > /proc/acpi/call
}

TurnBatteryConservationOff(){
	echo 'Turn Off Battery Conservation'
	echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x05' > /proc/acpi/call
}

TurnRapidChargeOn(){
	echo 'Turn On Rapid Charge'
	echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x07' > /proc/acpi/call
}

TurnRapidChargeOff(){
	echo 'Turn Off Rapid Charge'
	echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x08' > /proc/acpi/call
}

ToggleBatteryConservation(){
	GetCurrentBatteryConservationStatus
	currentBCStatus=$?
	if [ "$currentBCStatus" -eq 0 ]; then
		GetCurrentRapidChargeStatus
		currentRCStatus=$?
		if [ "$currentRCStatus" -eq 0 ]; then
  			TurnBatteryConservationOn
		elif [ "$currentRCStatus" -eq 1 ]; then
			read -p "Rapid Charge(RC) is On, turn Battery Conservation On will turn RC Off, do you want to continue? (Y/n)" answer
			case $answer in 
				Y | y | "\n")
					TurnRapidChargeOff
					TurnBatteryConservationOn
				;;
				N | n)
					return;
				;;
				*)
					TurnRapidChargeOff
					TurnBatteryConservationOn
				;;
			esac

		fi
		
	elif [ "$currentBCStatus" -eq 1 ]; then
		TurnBatteryConservationOff
	fi
}

ToggleRapidCharge(){
	GetCurrentRapidChargeStatus
	currentRCStatus=$?
	if [ "$currentRCStatus" -eq 0 ]; then
		GetCurrentBatteryConservationStatus
		currentBCStatus=$?
		if [ "$currentBCStatus" -eq 0 ]; then
			TurnRapidChargeOn
		elif [ "$currentBCStatus" -eq 1 ]; then
			read -p "Battery Conservation(BC) is On, turn Rapid Charge On will turn BC Off, do you want to continue? (Y/n)" answer
			case $answer in 
				Y | y)
					TurnBatteryConservationOff
					TurnRapidChargeOn
				;;
				N | n)
					return;
				;;
				*)
					TurnBatteryConservationOff
					TurnRapidChargeOn
				;;
			esac
		fi
		
	elif [ "$currentRCStatus" -eq 1 ]; then
		TurnRapidChargeOff
	fi
}

case $selection in

  $BatterySaving)
	echo 'Turn on Battery Saving Mode'
	echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0013B001' > /proc/acpi/call
    ;;

  $IntelligentCooling)
  	echo 'Turn on Intelligent Cooling Mode'
	echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x000FB001' > /proc/acpi/call
    ;;

  $ExtremePerformance)
  	echo 'Turn on Extreme Performance Mode'
	echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0012B001' > /proc/acpi/call
    ;;
  $BatteryConservation)
	ToggleBatteryConservation
  ;;
  $RapidCharge)
	ToggleRapidCharge
  ;;
  *)
    echo "!!!WARNING: Your selection not exist.
	"
    ;;
esac
