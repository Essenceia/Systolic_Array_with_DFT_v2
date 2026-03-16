#ifndef _BUS_PROTOCOL_H
#define _BUS_PROTOCOL_H
/* common bus protocol defines */

/* data ctrl */
{ valid: 1b, mode: 2b }
#define CTRL_WR_W 3

#define CTRL_WR_MODE_WEIGHT 0x0
#define CTRL_WR_MODE_DATA   0x1
#define CTRL_WR_MODE_RST    0x2
#define CTRL_WR_MODE_ASM    0x3

#endif // _BUS_PROTOCOL_H
