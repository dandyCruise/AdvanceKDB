#include<stdio.h>
#include<stdlib.h>
#include<sys/time.h>
#include<math.h>
#include"k.h"
#include <string.h>

int main(int argc, char **argv) {

 I handle;
 I portnumber= 5011;


 if (argc>1) {
     portnumber= atol(argv[1]);
 }

 S hostname= "psclxd00625";
 S usernamePassword= "cruisea:Dublin18!";

 K result, singleRow;
 int* i=0;
 FILE* stream = fopen("APIQuote.csv", "r");
 handle= khpu(hostname, portnumber, usernamePassword);
 
 if(handle<0)
	return EXIT_FAILURE;

 char line[1024];

 while (fgets(line, 1024, stream))
 {
  if(i>0)
   {
   char* tmp = strdup(line);
   char *token;
   token = strtok(tmp, ",");
   K row = ktn(0,5);

   kK(row)[0] = ks((S) token);
   printf( " %s\n", token );
   
   token = strtok(NULL, ",");
   kK(row)[1] = kf(atol(token));
   printf( " %s\n", token );

   token = strtok(NULL, ",");
   kK(row)[2] = kf(atol(token));
   printf( " %s\n", token );

   token = strtok(NULL, ",");
   kK(row)[3] = ki(atol(token));
   printf( " %s\n", token );
      
   token = strtok(NULL, ",");
   kK(row)[4] = ki(atol(token));
   printf( " %s\n", token );

   token = strtok(NULL, ",");
   result= k(handle, ".u.upd", ks((S) "quote"), row, (K) 0);
   
   if(!result) {
     kclose(handle);
      return EXIT_FAILURE;
       }
        
		free(tmp);
        r0(result);
   }
        i++;
  }
          kclose(handle);
                 return EXIT_SUCCESS;
          }


