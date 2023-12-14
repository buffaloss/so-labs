# Laboratory Work No. 4

### Author:
Name: __Beatricia Golban__
Group: __FAF-213__

### Theoretical Considerations:

* The allocated sectors are in the limit 2281-2310 

Head: 0 (0x0)

Track: 14 (0xE)

Sector: 63 (0x3F) 

__to__

Head: 0 (0x7)

Track: 7 (0x7)

Sector: 64 (0x40)

* The chosen task: Dec-to-Hex and Hex-to-Dec convertor

### Compilation Commands:

```bash
nasm -f bin -o boot.bin boot.asm &&
nasm -f bin -o menu.bin menu.asm &&
truncate boot.bin -s 1167872 && 
cat boot.bin menu.bin > boot.img &&
truncate boot.img -s 1474560 && 
rm boot.bin menu.bin
```
