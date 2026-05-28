import re

def asm(input):
    print(input)
    for line in input.strip().split('\n'):
        if line.startswith('//'): continue
        parts = re.split(r'[\s,\(\)]+', line.split('//')[0].split(':')[1].strip())
        op = parts[0]
        
        if op == "ADD": h = f"0000{int(parts[1][1]):03b}{int(parts[2][1]):03b}{int(parts[3][1]):03b}000"
        elif op == "SUB": h = f"0001{int(parts[1][1]):03b}{int(parts[2][1]):03b}{int(parts[3][1]):03b}000"
        elif op == "LOAD": h = f"0110{int(parts[1][1]):03b}{int(parts[3][1]):03b}{int(parts[2])&0x3F:06b}"
        elif op == "STORE": h = f"0111{int(parts[1][1]):03b}{int(parts[3][1]):03b}{int(parts[2])&0x3F:06b}"
        elif op == "BEQ": h = f"1001{int(parts[1][1]):03b}{int(parts[2][1]):03b}{int(parts[3])&0x3F:06b}"
        elif op == "JUMP": h = f"1000{int(parts[1])&0xFFF:012b}"
            
        print(f"uut.Instr_Mem[{line.split(':')[0]}] = 16'h{int(h, 2):04X}; // {line.split('//')[0].strip()}")

# Программа вычисления n-ого числа Мерсенна (M_n = 2^n - 1)
mersenne = """
0: LOAD R1, 0(R0)     // R1 = n
1: LOAD R4, 2(R0)     // R4 = 1
2: LOAD R3, 2(R0)     // R3 = 1
3: BEQ R1, R0, 3      // Если n == 0, прыгаем 7
4: ADD R3, R3, R3     // R3 = R3 * 2 (умножение сложением)
5: SUB R1, R1, R4     // n = n - 1 (уменьшаем счетчик)
6: JUMP 3             // Повторяем цикл
7: SUB R3, R3, R4     // res = res - 1
8: STORE R3, 1(R0)    // Сохраняем результат в Data_Mem[1]
9: JUMP 9             // Остановка
"""

asm(mersenne)