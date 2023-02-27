#!/bin/bash

echo "
1. Battery Saving
2. Intelligent Cooling
3. Extreme Performance
"

BatterySaving=1;
IntelligentCooling=2;
ExtremePerformance=3;

STMD="";
QTMD="";
low="0x0";
high="0x1";

read -p 'Your selection: ' selection

echo "-------------------------------------------------------------"

if [ "$selection" == "$BatterySaving" ]; then
	modprobe acpi_call
	echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0013B001' > /proc/acpi/call
elif [ "$selection" == "$IntelligentCooling" ]; then
	modprobe acpi_call
	echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x000FB001' > /proc/acpi/call
elif [ "$selection" == "$ExtremePerformance" ]; then
	modprobe acpi_call
	echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0012B001' > /proc/acpi/call

else echo "Your selection not exist."
fi


echo '\_SB.PCI0.LPC0.EC0.STMD' > /proc/acpi/call
STMD="$(tr -d '\0' <  /proc/acpi/call)";

echo '\_SB.PCI0.LPC0.EC0.QTMD' > /proc/acpi/call
QTMD="$(tr -d '\0' <  /proc/acpi/call)";

if [ "$STMD" == "$low" ] && [ "$QTMD" == "$low" ]; then
	echo "Current: Extreme Performance"
elif [ "$STMD" == "$low" ] && [ "$QTMD" == "$high" ]; then
	echo "Current: Battery Saving"
elif [ "$STMD" == "$high" ] && [ "$QTMD" == "$low" ]; then
	echo "Current: Intelligent Cooling"
fi
