
#ifndef _SMTIOT_H_
#define _SMTIOT_H_

int InitSmartConnection(void);
int StartSmartConnection(const char *SSID, const char *Password,
                         const char *Target, char AuthMode);
int StopSmartConnection(void);

#endif