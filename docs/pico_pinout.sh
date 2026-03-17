#!/bin/bash

# ANSI color codes
UART='\033[0;35m'    # purple
I2C='\033[0;36m'     # cyan
SPI='\033[0;34m'     # blue
ADC='\033[0;33m'     # yellow
PWR='\033[0;31m'     # red
GND='\033[1;30m'     # dark gray
SYS='\033[0;95m'     # bright magenta
DBG='\033[0;91m'     # bright red/orange
GPIO='\033[0;32m'    # green
LED='\033[1;33m'     # bright yellow
USB='\033[0;94m'     # bright blue
DIM='\033[2;37m'     # dim white
NUM='\033[2;37m'     # dim gray
BRD='\033[0;32m'     # dark green (board label)
PIN='\033[1;37m'     # bright white (pin names)
RST='\033[0m'        # reset

echo ""
echo -e "                                           ${DIM}┌─────${RST}${USB}[USB]${RST}${DIM}─────┐${RST}"
echo -e "                                           ${DIM}│${RST}  ${LED}LED (GP25)↑${RST}  ${DIM}│${RST}"
echo -e "  ${UART}UART0TX${RST}  ${I2C}I2C0SDA${RST}  ${SPI}SPI0RX${RST}  ${GPIO}[GPIO]${RST}  ${PIN}GP0${RST}  ${NUM}1${RST} ${GPIO}●${RST}               ${PWR}●${RST} ${NUM}40${RST}  ${PIN}VBUS${RST}    ${PWR}[PWR]${RST}"
echo -e "  ${UART}UART0RX${RST}  ${I2C}I2C0SCL${RST}  ${SPI}SPI0CSn${RST} ${GPIO}[GPIO]${RST}  ${PIN}GP1${RST}  ${NUM}2${RST} ${GPIO}●${RST}               ${PWR}●${RST} ${NUM}39${RST}  ${PIN}VSYS${RST}    ${PWR}[PWR]${RST}"
echo -e "                             ${GND}[GND]${RST}  ${PIN}GND${RST}  ${NUM}3${RST} ${GND}●${RST}               ${GND}●${RST} ${NUM}38${RST}  ${PIN}GND${RST}     ${GND}[GND]${RST}"
echo -e "           ${I2C}I2C1SDA${RST}  ${SPI}SPI0SCK${RST} ${GPIO}[GPIO]${RST}  ${PIN}GP2${RST}  ${NUM}4${RST} ${GPIO}●${RST}               ${SYS}●${RST} ${NUM}37${RST}  ${PIN}3V3_EN${RST}  ${SYS}[SYS]${RST}"
echo -e "           ${I2C}I2C1SCL${RST}  ${SPI}SPI0TX${RST}  ${GPIO}[GPIO]${RST}  ${PIN}GP3${RST}  ${NUM}5${RST} ${GPIO}●${RST}    ${BRD}RP2040${RST}     ${PWR}●${RST} ${NUM}36${RST}  ${PIN}3V3OUT${RST}  ${PWR}[PWR]${RST}"
echo -e "  ${UART}UART1TX${RST}  ${I2C}I2C0SDA${RST}  ${SPI}SPI0RX${RST}  ${GPIO}[GPIO]${RST}  ${PIN}GP4${RST}  ${NUM}6${RST} ${GPIO}●${RST}               ${ADC}●${RST} ${NUM}35${RST}  ${PIN}ADC_VREF${RST} ${ADC}[ADC]${RST}"
echo -e "  ${UART}UART1RX${RST}  ${I2C}I2C0SCL${RST}  ${SPI}SPI0CSn${RST} ${GPIO}[GPIO]${RST}  ${PIN}GP5${RST}  ${NUM}7${RST} ${GPIO}●${RST}               ${ADC}●${RST} ${NUM}34${RST}  ${PIN}GP28${RST}    ${ADC}[ADC]${RST}  ${ADC}ADC2${RST}"
echo -e "                             ${GND}[GND]${RST}  ${PIN}GND${RST}  ${NUM}8${RST} ${GND}●${RST}               ${GND}●${RST} ${NUM}33${RST}  ${PIN}GND/AGND${RST} ${GND}[GND]${RST}"
echo -e "           ${I2C}I2C1SDA${RST}  ${SPI}SPI0SCK${RST} ${GPIO}[GPIO]${RST}  ${PIN}GP6${RST}  ${NUM}9${RST} ${GPIO}●${RST}               ${ADC}●${RST} ${NUM}32${RST}  ${PIN}GP27${RST}    ${ADC}[ADC]${RST}  ${ADC}ADC1${RST}  ${I2C}I2C1SCL${RST}"
echo -e "           ${I2C}I2C1SCL${RST}  ${SPI}SPI0TX${RST}  ${GPIO}[GPIO]${RST}  ${PIN}GP7${RST} ${NUM}10${RST} ${GPIO}●${RST}               ${ADC}●${RST} ${NUM}31${RST}  ${PIN}GP26${RST}    ${ADC}[ADC]${RST}  ${ADC}ADC0${RST}  ${I2C}I2C1SDA${RST}"
echo -e "  ${UART}UART1TX${RST}  ${I2C}I2C0SDA${RST}  ${SPI}SPI1RX${RST}  ${GPIO}[GPIO]${RST}  ${PIN}GP8${RST} ${NUM}11${RST} ${GPIO}●${RST}               ${SYS}●${RST} ${NUM}30${RST}  ${PIN}RUN${RST}     ${SYS}[SYS]${RST}"
echo -e "  ${UART}UART1RX${RST}  ${I2C}I2C0SCL${RST}  ${SPI}SPI1CSn${RST} ${GPIO}[GPIO]${RST}  ${PIN}GP9${RST} ${NUM}12${RST} ${GPIO}●${RST}               ${GPIO}●${RST} ${NUM}29${RST}  ${PIN}GP22${RST}    ${GPIO}[GPIO]${RST}"
echo -e "                             ${GND}[GND]${RST}  ${PIN}GND${RST} ${NUM}13${RST} ${GND}●${RST}               ${GND}●${RST} ${NUM}28${RST}  ${PIN}GND${RST}     ${GND}[GND]${RST}"
echo -e "           ${I2C}I2C1SDA${RST}  ${SPI}SPI1SCK${RST} ${GPIO}[GPIO]${RST} ${PIN}GP10${RST} ${NUM}14${RST} ${GPIO}●${RST}               ${GPIO}●${RST} ${NUM}27${RST}  ${PIN}GP21${RST}    ${GPIO}[GPIO]${RST}  ${I2C}I2C0SCL${RST}"
echo -e "           ${I2C}I2C1SCL${RST}  ${SPI}SPI1TX${RST}  ${GPIO}[GPIO]${RST} ${PIN}GP11${RST} ${NUM}15${RST} ${GPIO}●${RST}               ${GPIO}●${RST} ${NUM}26${RST}  ${PIN}GP20${RST}    ${GPIO}[GPIO]${RST}  ${I2C}I2C0SDA${RST}"
echo -e "  ${UART}UART0TX${RST}  ${I2C}I2C0SDA${RST}  ${SPI}SPI1RX${RST}  ${GPIO}[GPIO]${RST} ${PIN}GP12${RST} ${NUM}16${RST} ${GPIO}●${RST}               ${GPIO}●${RST} ${NUM}25${RST}  ${PIN}GP19${RST}    ${GPIO}[GPIO]${RST}  ${SPI}SPI0TX${RST}   ${I2C}I2C1SCL${RST}"
echo -e "  ${UART}UART0RX${RST}  ${I2C}I2C0SCL${RST}  ${SPI}SPI1CSn${RST} ${GPIO}[GPIO]${RST} ${PIN}GP13${RST} ${NUM}17${RST} ${GPIO}●${RST}               ${GPIO}●${RST} ${NUM}24${RST}  ${PIN}GP18${RST}    ${GPIO}[GPIO]${RST}  ${SPI}SPI0SCK${RST}  ${I2C}I2C1SDA${RST}"
echo -e "                             ${GND}[GND]${RST}  ${PIN}GND${RST} ${NUM}18${RST} ${GND}●${RST}               ${GND}●${RST} ${NUM}23${RST}  ${PIN}GND${RST}     ${GND}[GND]${RST}"
echo -e "           ${I2C}I2C1SDA${RST}  ${SPI}SPI1SCK${RST} ${GPIO}[GPIO]${RST} ${PIN}GP14${RST} ${NUM}19${RST} ${GPIO}●${RST}               ${GPIO}●${RST} ${NUM}22${RST}  ${PIN}GP17${RST}    ${GPIO}[GPIO]${RST}  ${SPI}SPI0CSn${RST}  ${I2C}I2C0SCL${RST}  ${UART}UART0RX${RST}"
echo -e "           ${I2C}I2C1SCL${RST}  ${SPI}SPI1TX${RST}  ${GPIO}[GPIO]${RST} ${PIN}GP15${RST} ${NUM}20${RST} ${GPIO}●${RST}               ${GPIO}●${RST} ${NUM}21${RST}  ${PIN}GP16${RST}    ${GPIO}[GPIO]${RST}  ${SPI}SPI0RX${RST}   ${I2C}I2C0SDA${RST}  ${UART}UART0TX${RST}"
echo -e "                                           ${DIM}│               │${RST}"
echo -e "                                           ${DIM}│    ${RST}${DBG}[DEBUG]${RST}${DIM}    │${RST}"
echo -e "                                           ${DIM}└───────────────┘${RST}"
echo -e "                                               ${DIM}│   │   │${RST}"
echo -e "                                             ${DBG}SWCLK${RST} ${GND}GND${RST} ${DBG}SWDIO${RST}"
echo -e "                                              ${DBG}[DBG]${RST}${GND}[GND]${RST}${DBG}[DBG]${RST}"
echo ""
echo -e "  ${UART}■ UART${RST}   ${I2C}■ I2C${RST}   ${SPI}■ SPI${RST}   ${GPIO}■ GPIO${RST}   ${ADC}■ ADC${RST}   ${PWR}■ PWR${RST}   ${GND}■ GND${RST}   ${SYS}■ SYS${RST}   ${DBG}■ DBG${RST}   ${LED}■ LED${RST}"
echo ""
