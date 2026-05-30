int cursor = 0;
char color = 0x07;

void putInMemory(int segment, int address, char character);
int getChar();

void printChar(c)
char c;
{
    char attr;
    int addr;
    attr = color;
    addr = cursor * 2;
    putInMemory(0xB800, addr, c);
    putInMemory(0xB800, addr + 1, attr);
    cursor++;
}

void newline()
{
    int col;
    col = cursor - ((cursor / 80) * 80);
    cursor += (80 - col);
}

void printString(str)
char *str;
{
    int i;
    i = 0;
    while (str[i] != '\0') {
        if (str[i] == '\n') {
            newline();
        } else {
            printChar(str[i]);
        }
        i++;
    }
}

void clearScreen()
{
    int i;
    for (i = 0; i < 2000; i++) {
        putInMemory(0xB800, i * 2, ' ');
        putInMemory(0xB800, i * 2 + 1, color);
    }
    cursor = 0;
}

void readString(buf)
char *buf;
{
    int i;
    char c;
    i = 0;
    while (1) {
        c = getChar();
        if (c == 13) {
            buf[i] = '\0';
            return;
        } else if (c == 8) {
            if (i > 0) {
                i--;
                cursor--;
                printChar(' ');
                cursor--;
            }
        } else {
            buf[i] = c;
            i++;
            printChar(c);
        }
    }
}

int strcmp(a, b)
char *a;
char *b;
{
    int i;
    i = 0;
    while (a[i] != '\0' && b[i] != '\0') {
        if (a[i] != b[i]) return 0;
        i++;
    }
    return (a[i] == '\0' && b[i] == '\0');
}

int startsWith(str, prefix)
char *str;
char *prefix;
{
    int i;
    i = 0;
    while (prefix[i] != '\0') {
        if (str[i] != prefix[i]) return 0;
        i++;
    }
    return 1;
}

int atoi(str)
char *str;
{
    int result;
    int i;
    int neg;
    result = 0;
    i = 0;
    neg = 0;
    if (str[0] == '-') { neg = 1; i = 1; }
    while (str[i] >= '0' && str[i] <= '9') {
        result = result * 10 + (str[i] - '0');
        i++;
    }
    if (neg) return -result;
    return result;
}

void intToString(n, buf)
int n;
char *buf;
{
    int i;
    int neg;
    char tmp[12];
    int j;
    int digit;
    i = 0;
    neg = 0;

    if (n == 0) { buf[0] = '0'; buf[1] = '\0'; return; }
    if (n < 0) { neg = 1; n = -n; }

    while (n > 0) {
        digit = n - ((n / 10) * 10);
        tmp[i] = '0' + digit;
        i++;
        n = n / 10;
    }
    if (neg) { tmp[i] = '-'; i++; }

    j = 0;
    while (i > 0) {
        i--;
        buf[j] = tmp[i];
        j++;
    }
    buf[j] = '\0';
}

int factorial(n)
int n;
{
    int result;
    int i;
    result = 1;
    for (i = 2; i <= n; i++) {
        result = result * i;
        if (result < 0 || result > 32767) return -1;
    }
    return result;
}

void main()
{
    char cmd[64];
    char buf[16];
    char tmp[12];
    char *season;
    int i;
    int j;
    int k;
    int a;
    int b;
    int n;
    int result;
    int row;
    int col;

    clearScreen();
    printString("Welcome to Assistant's Last Gift");
    newline();
    printString("type 'help'");
    newline();
    newline();

    while (1) {
        printString("> ");
        readString(cmd);
        newline();

        if (strcmp(cmd, "check")) {
            printString("ok");

        } else if (strcmp(cmd, "clear")) {
            clearScreen();

        } else if (strcmp(cmd, "help")) {
            printString("Commands: check, add, sub, fac, season, triangle, clear, help");

        } else if (startsWith(cmd, "add ")) {
            i = 4;
            while (cmd[i] == ' ') i++;
            j = i;
            while (cmd[j] != ' ' && cmd[j] != '\0') j++;
            for (k = 0; k < j - i; k++) tmp[k] = cmd[i + k];
            tmp[j - i] = '\0';
            a = atoi(tmp);
            i = j;
            while (cmd[i] == ' ') i++;
            b = atoi(cmd + i);
            result = a + b;
            intToString(result, buf);
            printString(buf);

        } else if (startsWith(cmd, "sub ")) {
            i = 4;
            while (cmd[i] == ' ') i++;
            j = i;
            while (cmd[j] != ' ' && cmd[j] != '\0') j++;
            for (k = 0; k < j - i; k++) tmp[k] = cmd[i + k];
            tmp[j - i] = '\0';
            a = atoi(tmp);
            i = j;
            while (cmd[i] == ' ') i++;
            b = atoi(cmd + i);
            result = a - b;
            intToString(result, buf);
            printString(buf);

        } else if (startsWith(cmd, "fac ")) {
            i = 4;
            while (cmd[i] == ' ') i++;
            n = atoi(cmd + i);
            result = factorial(n);
            if (result == -1) {
                printString("know your limit little bro.");
            } else {
                intToString(result, buf);
                printString(buf);
            }

        } else if (startsWith(cmd, "season ")) {
            i = 7;
            while (cmd[i] == ' ') i++;
            season = cmd + i;
            if (strcmp(season, "winter")) {
                color = 0x09;
                printString("winter mode");
            } else if (strcmp(season, "spring")) {
                color = 0x0A;
                printString("spring mode");
            } else if (strcmp(season, "summer")) {
                color = 0x0E;
                printString("summer mode");
            } else if (strcmp(season, "fall")) {
                color = 0x06;
                printString("fall mode");
            } else if (strcmp(season, "radiant")) {
                color = 0x0D;
                printString("radiant mode");
            } else {
                printString("unknown season");
            }

        } else if (startsWith(cmd, "triangle ")) {
            i = 9;
            while (cmd[i] == ' ') i++;
            n = atoi(cmd + i);
            for (row = 1; row <= n; row++) {
                for (col = 0; col < row; col++) {
                    printChar('x');
                }
                newline();
            }

        } else {
            printString("unknown command");
        }

        newline();
    }
}