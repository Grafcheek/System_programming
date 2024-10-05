#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(){
    char password [] = "pass123";
    char in [20];
    for(int i = 0; i < 5; i++){
        scanf("%s", in);
        if(strcmp(in, password) == 0){
            printf("Вошли\n");
            return 0;
        } //!!!
        printf("Невереный пароль\n");
    }
    printf("Неудача\n");
    return 0;
}