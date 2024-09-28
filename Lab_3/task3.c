#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc == 4) {
        int a = atoi(argv[1]);
        int b = atoi(argv[2]);
        int c = atoi(argv[3]);
        
        if (b == 0) {
            printf("Invalid input\n");
            return 1;
        }

        double result = ((((((double)a / b) - a) / b) * c) + a);
        printf("%lf\n", result);
    } else {
        printf("Invalid input\n");
    }
    return 0;
}
