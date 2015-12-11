#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>
#include <string.h>

int main (void)
{
  DIR *dp;
  struct dirent *ep;     
  dp = opendir ("./dotnc");
  FILE * file = fopen("transcription.config", "w");

  if (dp != NULL)
    {
      while (ep = readdir (dp)) {
	fprintf (file, "./dotnc/%s,", ep->d_name);
	if (!strncasecmp("3", ep->d_name, 1))
	  break;
      }
      fprintf(file, "\n");
      while (ep = readdir (dp)) {
        fprintf (file, "./dotnc/%s,", ep->d_name);
	if (!strncasecmp("4", ep->d_name, 1))
          break;
      }
      fprintf(file, "\n");
      while (ep = readdir (dp)) {
        fprintf (file, "./dotnc/%s,", ep->d_name);
      }
      (void) closedir (dp);
    }
  else
    perror ("Couldn't open the directory");
  fclose(file);
  return 0;
}
