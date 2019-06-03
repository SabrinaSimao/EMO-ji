## Apresentação

[Em PDF](https://github.com/SabrinaSimao/EMO-ji/blob/master/pdf/EMOJI.pdf)

(formatação de emojis fica um pouco estranha em pdf de web browser)

ou pela versão online do PowerPoint

https://bit.ly/2HRo9Gi

## Dependências:
Flex

Bison

CLANG 3.9

Python3
- modulo emoji

## Setup e Instalação:

Para instalar corretamente clang e llvm 3.9:

Primeiro tente o mais básico:

>sudo apt-get update 

>sudo apt-get install clang-3.9 lldb-3.9

Caso não funcione a instalação direta, use os seguintes comandos:

> wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -

> sudo apt-add-repository "deb https://apt.llvm.org/xenial/ llvm-toolchain-xenial-3.9 main"

> sudo apt-get update

Caso o sudo apt-get update de um erro de autenticação em alguma chave, rode o comando abaixo

> sudo apt -o Acquire::AllowInsecureRepositories=true update

Finalmente:

>sudo apt-get install clang-3.9 lldb-3.9


## Rodando o código:
Código é escrito com emojis e então traduzido para Unicode através do script em python

### Passo 1:

Rodar scrip python com seu codigo:
> python3 Emoji.py code.txt

(gera arquivo out.ji)

OPICIONAL:

Na pasta Emoji_Examples tem alguns exemplos disponíveis para teste. Neste caso, faça
> python3 Emoji.py Emoji_Examples/<arquivo.txt>

### Passo 2:

Compilar seu codigo com a AST usando lli

make exe file=<arquivo_desejado>

Exemplo:
> make exe file=out.ji

Caso não deseje que a lli execute o programa, somente queira ver o código em IR, rode
>make file=<desired_file>

### Cleaning up

>make clean

### Outros códigos

Não é necessário recompilar a ast entre os testes. Uma vez compilada, rode quantas vezes quiser
>make exe file=out.ji

Se quiser, pode mudar o arquivo de out.ji para outro, ou refazer o conteudo do mesmo usando o script python do Passo 1

## Exemplos disponíveis:

- Fibonacci
- Fizz Buzz
- Loop While
- Fatorial
- Funções Basicas (+-/*)

## Funcionalidades
- Funções
- Vars: int, long, char, double, void
- Operadores aritméticos (+)
- Operadores Unários (++)
- Comparadores (==)
- If/else
- While
- For
- Globals
- Declaração de Funções

## Referências:

https://github.com/sandeep007734/Toy-C-Compiler-using-Flex-Bison-LLVM

https://pypi.org/project/emoji/

https://llvm.org/docs/CommandGuide/lli.html




