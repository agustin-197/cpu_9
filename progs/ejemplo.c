volatile int a = 5;
volatile int b = 4;
volatile int c;

int main(void)
{
    c = a + b;
    for(;;);
}