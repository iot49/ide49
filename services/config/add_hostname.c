#include <stdio.h>
#include <unistd.h>

#define N 1000

void main() {

    char hostname[N+1];
    gethostname(hostname, N);
    printf("adding host '%s' to /etc/hosts\n", hostname);
    FILE *f = fopen("/etc/hosts", "a");
    fprintf(f, "127.0.0.1 %s\n", hostname);
}
