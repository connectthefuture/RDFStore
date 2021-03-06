#include <sys/types.h>
#include <sys/time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>

#include <time.h>

/*#include <sys/syslimits.h>*/
#if !defined(WIN32)
#include <sys/param.h>
#endif
#include <sys/file.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/errno.h>
#include <sys/uio.h>

#include "rdfstore.h"
#include "rdfstore_log.h"
#include "rdfstore_utf8.h"

int main ( int argc, char * * argv ) {
	unsigned char string[255];
	unsigned char utf8_buff[UTF8_MAXLEN]; /* one utf8 char */
	unsigned char utf8_casefolded_string[UTF8_MAXLEN_FOLD*255]; /* 255 utf8 case-folded chars */
	unsigned long cc=0;
	unsigned int utf8_size=0;
	int i=0;

	/* utf8 stuff */
	strcpy(string," "); /* not valid */
	strcpy(string,"A"); /* valid */
	strcpy(string,"è"); /* valid */
	strcpy(string,"�"); /* not valid */
	strcpy(string,"��"); /* not valid */
	strcpy(string,"€"); /* valid */

	cc = 0x0391;
	cp_to_utf8( cc, &utf8_size, utf8_buff);
	printf("Code point '%04X' got converted to utf8 of '%d' bytes length '",cc,utf8_size);
	for(i=0;i<utf8_size;i++) {
		printf("%02X",utf8_buff[i]);
		};
	printf("'\n");
	cc = 0;
	utf8_to_cp( utf8_size, utf8_buff,&utf8_size, &cc );
	printf("The original code point is '%04X'\n",cc);

	strcpy(string,"�"); /* valid */
	if ( is_utf8( string, &utf8_size ) ) {
		printf("OK is utf8 of '%d' bytes length\n",utf8_size);
	} else {
		utf8_size=0;
		if ( cp_to_utf8( (unsigned long)string[0], &utf8_size, utf8_buff) ) {
			printf("cannot convert char to utf8\n");
			return -1;
			};
		printf("Got converted to utf8 of '%d' bytes length, '%s'\n",utf8_size,utf8_buff);
		utf8_size=0;
		if ( is_utf8( utf8_buff, &utf8_size ) ) {
			printf("And not it is utf8 of '%d' bytes length '",utf8_size);
			for ( i = 0 ; i < utf8_size ; i++ ) {
				printf("%02x",utf8_buff[i]);
				};
			printf("'\n");
		} else {
			printf("not utf8 still.....\n");
				};
		};

	/* utf8 case-fold stuff */
	strcpy(string,"AlBerTo"); /* to get alberto */
	if ( string_to_utf8_foldedcase( strlen(string), string, &utf8_size, utf8_casefolded_string) ) {
		printf("Cannot case-fold input string\n");
		return -1;
		};
	printf("Your input string '%s' in utf8 case-folded is '%s'\n",string,utf8_casefolded_string);

	return 0;
};
