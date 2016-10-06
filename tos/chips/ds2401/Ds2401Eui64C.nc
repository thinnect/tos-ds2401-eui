/**
 * EUI from DS2401 with CRC check. Not a proper EUI64, but pretends to be one.
 *
 * @author Raido Pahtma
 * @license MIT
 */
configuration Ds2401Eui64C {
	provides interface LocalIeeeEui64;
}
implementation {

	components OneWireMasterC;

	components Ds2401Eui64P;
	LocalIeeeEui64 = Ds2401Eui64P.LocalIeeeEui64;
	Ds2401Eui64P.HplDs2401 -> HplDs2401C.Hpl;

	components Ds2401OneWirePinC;
	OneWireMasterC.Pin -> Ds2401OneWirePinC.Pin;

	components BusyWaitMicroC;
	OneWireMasterC.BusyWaitMicro -> BusyWaitMicroC.BusyWait;

	components HplDs2401C;
	HplDs2401C.OneWire -> OneWireMasterC.OneWire;

}
