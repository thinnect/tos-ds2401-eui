/**
 * EUI from DS2401 with CRC check. Not a proper EUI64, but pretends to be one.
 *
 * @author (different people),..., Raido Pahtma
 * @license MIT
 */
#include "Ds2401.h" // ds2401_serial_t
#include "IeeeEui64.h" // ieee_eui64_t
#include "crc8.h"
module Ds2401Eui64P {
	provides interface LocalIeeeEui64;
	uses interface HplDs2401;
}
implementation {

	#define __MODUUL__ "Eui64"
	#define __LOG_LEVEL__ ( LOG_LEVEL_LocalIeeeEui64 & BASE_LOG_LEVEL )
	#include "log.h"

	// https://scaryreasoner.wordpress.com/2009/02/28/checking-sizeof-at-compile-time/
	#define BUILD_BUG_ON(condition) ((void)sizeof(char[1 - 2*!!(condition)]))

	ieee_eui64_t m_id;
	bool m_id_valid = FALSE;

	// Read until a normal value is retrieved
	// Reject values with wrong crc and values with all bytes equal
	command ieee_eui64_t LocalIeeeEui64.getId() {
		BUILD_BUG_ON(sizeof(ieee_eui64_t) != sizeof(ds2401_serial_t));

		if(m_id_valid == FALSE) {
			while(1) {
				error_t err;
				ds2401_serial_t* rom = (ds2401_serial_t*)&(m_id);
				uint8_t i = 0, crc = 0;

				atomic err = call HplDs2401.read(rom);

				// restart loop on read error
				if(err != SUCCESS) {
					err1("read %u", err);
					continue;
				}

				// restart loop on wrong crc
				for(i = 0; i < sizeof(rom->data) - 1; i++) {
					crc = crc8Byte(crc, rom->data[i]);
				}
				if(crc != rom->crc) {
					err1("crc %u read %u", crc, rom->crc);
					continue;
				}

				// Make sure that all bytes are not equal (all 00 and FF pass CRC, but are bad)
				for(i = 1; i < sizeof(rom->data); i++) {
					if(rom->data[0] != rom->data[i]) {
						break;
					}
				}
				if(i == sizeof(rom->data)) {
					errb1("bad", rom->data, sizeof(rom->data));
					continue; // no "break" was executed, all bytes are the same, try again
				}

				m_id_valid = TRUE;
				debugb1("IEEE 64-bit UID: ", rom->data, sizeof(rom->data));
				return m_id;
			}
		}
		return m_id;
	}

}
