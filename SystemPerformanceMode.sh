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

STMD="";
QTMD="";
BTSG=""; #BatteryConservation flag
FCGM=""; #RapidCharge flag
low="0x0";
high="0x1";

echo '\_SB.PCI0.LPC0.EC0.STMD' > /proc/acpi/call
STMD="$(tr -d '\0' <  /proc/acpi/call)";

echo '\_SB.PCI0.LPC0.EC0.QTMD' > /proc/acpi/call
QTMD="$(tr -d '\0' <  /proc/acpi/call)";

if [ "$STMD" == "$low" ] && [ "$QTMD" == "$low" ]; then
	echo "Mode: Extreme Performance"
elif [ "$STMD" == "$low" ] && [ "$QTMD" == "$high" ]; then
	echo "Mode: Battery Saving"
elif [ "$STMD" == "$high" ] && [ "$QTMD" == "$low" ]; then
	echo "Mode: Intelligent Cooling"
fi

echo '\_SB.PCI0.LPC0.EC0.BTSG' > /proc/acpi/call
BTSG="$(tr -d '\0' <  /proc/acpi/call)"; #Battery Conservation

if [ "$BTSG" == "$low" ]; then
	echo "Battery Conservation: Off"
elif [ "$BTSG" == "$high" ]; then
	echo "Battery Conservation: On"
fi

echo '\_SB.PCI0.LPC0.EC0.FCGM' > /proc/acpi/call
FCGM="$(tr -d '\0' <  /proc/acpi/call)"; #Rapid Charge

if [ "$FCGM" == "$low" ]; then
	echo "Rapid Charge: Off"
elif [ "$FCGM" == "$high" ]; then
	echo "Rapid Charge: On"
fi
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

modprobe acpi_call

TurnBatteryConservationOn(){
	echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x03' > /proc/acpi/call
}

TurnBatteryConservationOff(){
	echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x05' > /proc/acpi/call
}

TurnRapidChargeOn(){
	echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x07' > /proc/acpi/call
}

TurnRapidChargeOff(){
	echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x08' > /proc/acpi/call
}

ToggleBatteryConservation(){
	if [ "$BTSG" == "$low" ]; then
		if [ "$FCGM" == "$low" ]; then
  			TurnBatteryConservationOn
		elif [ "$FCGM" == "$high" ]; then
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
		
	elif [ "$BTSG" == "$high" ]; then
		TurnBatteryConservationOff
	fi
}

ToggleRapidCharge(){
	if [ "$FCGM" == "$low" ]; then
		if [ "$BTSG" == "$low" ]; then
			TurnRapidChargeOn
		elif [ "$BTSG" == "$high" ]; then
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
		
	elif [ "$FCGM" == "$high" ]; then
		TurnRapidChargeOff
	fi
}

case $selection in

  $BatterySaving)
	echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0013B001' > /proc/acpi/call
    ;;

  $IntelligentCooling)
	echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x000FB001' > /proc/acpi/call
    ;;

  $ExtremePerformance)
	echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0012B001' > /proc/acpi/call
    ;;
  $BatteryConservation)
	ToggleBatteryConservation
  ;;
  $RapidCharge)
	ToggleRapidCharge
  ;;
  *)
    echo "Your selection not exist."
    ;;
esac