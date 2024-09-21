
# include <stdio.h>

// int main() {
//     long long number = 2634342072;
//     int s = 0;

//     while (number > 0) {
//         s += number % 10;
//         number /= 10;      
//     }

//     printf("%d\n", s);
//     return 0;
// }



int main() {
    long n = 2634342072;
    char s = 0;    
    for (; n; n /= 10) s += n % 10;    
    printf("%d\n", s);
    return 0;
}

