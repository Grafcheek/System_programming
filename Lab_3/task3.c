#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc == 4) {
        int a = atoi(argv[1]);
        int b = atoi(argv[2]);
        int c = atoi(argv[3]);
        
        if (b == 0) {
            printf("Invalid input: division by zero\n");
            return 1;
        }

        int result = (((((a / b) - a) / b) * c) + a);
        printf("%d\n", result);
    } else {
        printf("Invalid input: please provide three integers\n");
    }
    return 0;
}
