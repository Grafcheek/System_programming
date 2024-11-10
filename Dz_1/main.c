#include <stdio.h>
#include <stdlib.h>

extern long *init_queue();
extern long *free_queue();
extern long q_push(long);
extern long q_pop();
extern void rand_fill(long);
extern long ends_with_one();
extern long count_even();
extern void remove_even_and_push_odd_back();

int main() {
  long *arr, n, cap;
  scanf("%ld", &n);
  arr = init_queue(n);
  if (arr == NULL) {
    fprintf(stderr, "Ошибка выделения памяти\n");
    return 1;
  }

  cap = 5;
  rand_fill(cap);  // Заполнение случайными числами

  for (int i = 0; i < cap; i++) {
    printf("%ld\n", arr[i]);
  }

  printf("ends with 1 = %ld\n", ends_with_one());
  printf("even count = %ld\n", count_even());

  // Удаление четных чисел и возврат нечетных в конец
  remove_even_and_push_odd_back();

  for (int i = 0; i < n; i++) {
    printf("%ld\n", arr[i]);
  }

  printf("poped=%ld\n", q_pop());
  printf("poped=%ld\n", q_pop());

  free_queue();

  return 0;
}
