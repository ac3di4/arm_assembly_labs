# LAB5

[Общее условие](lab5.pdf) \
[Выданный вариант](var25.pdf) \
[Отчет](final.pdf)


## Сборка
По умолчанию собираются оба варианта.

Собрать С: \
`make c_build`

Собрать асм: \
`make asm_build`

Так же при сборке можно отдельно указать флаги компиляции для файла с алгоритмом на си. \
Необходимо для удобного тестирования производительности. \
Пример:
`make clean && make c_build C_CCFLAGS=-O3`


## Тесты
`qemu-aarch64-static c_build test1.bmp out1.bmp` \
`qemu-aarch64-static asm_build test2.bmp out2.bmp` \
Файлы тестов - две картинки: test1.bmp и test2.bmp


## Отчет
Отчет представляет замеры тестов с помощью утилиты. `time` \
Для каждой строки измерения выполнялись 3 раза. \
Значение имеют не цифры а их динамика в целом.