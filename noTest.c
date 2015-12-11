#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>

int main (void)
{
  DIR *dp;
  struct dirent *ep;     
  dp = opendir ("./dotnc");
  FILE * file = fopen("transcription1.config", "w");

  if (dp != NULL)
    {
      while (ep = readdir (dp))
	fprintf (file, "./dotnc/%s,", ep->d_name);

      (void) closedir (dp);
    }
  else
    perror ("Couldn't open the directory");
  fclose(file);
  return 0;
}
