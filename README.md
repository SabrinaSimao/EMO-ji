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

### Passo 2:

Compilar seu codigo com a AST usando llvm

make test file=<arquivo_desejado>

Exemplo:
> make test file=out

## Exemplos disponíveis:

- Fibonacci
- Fizz Buzz
- Loop While
- Checkup de Funcionalidades

## Referências:

https://github.com/sandeep007734/Toy-C-Compiler-using-Flex-Bison-LLVM

https://pypi.org/project/emoji/





