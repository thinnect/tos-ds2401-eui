# tos-ds2401-eui
EUI from DS2401 with CRC check. Not a proper EUI64, but pretends to be one.

Depends on a Ds2401OneWirePinC component being available for a target platform.
The Ds2401OneWirePinC simply needs to export the correct GeneralIO.

Note: Enters an infinite loop if unable to read a proper ID from the DS2401.
