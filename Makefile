all: check

OBJS = parser.tab.o  \
       codegen.o  \
       cc.o    \
       parser.lex.o  \

LLVMCONFIG = llvm-config-3.9
CPPFLAGS = `$(LLVMCONFIG) --cppflags` -std=c++11
LDFLAGS = `$(LLVMCONFIG) --ldflags` -lpthread -ldl -lz -lncurses -rdynamic
LIBS = `$(LLVMCONFIG) --libs`

parser.tab.hpp: parser.tab.cpp

parser.lex.cpp: tokenizer.l parser.tab.hpp
	@ flex -o parser.lex.cpp -l tokenizer.l

parser.tab.cpp: parser.y
	@ bison -d parser.y -o parser.tab.cpp -Wnone

%.o: %.cpp
	@ g++ -c $(CPPFLAGS) -o $@ $<

cc: $(OBJS)
	@ g++ -ggdb -g -O0 -o $@ $(OBJS) $(LIBS) $(LDFLAGS)

exe: cc $(file)
	@  make > /dev/null 2> /dev/null; ./cc $(file) > /dev/null 2> $(file).ll; llvm-as-3.9 $(file).ll;lli-3.9 $(file).bc 

check: cc $(file)
	./cc $(file) ;echo "To run the code with lli run \"make exe file=out.ji\""

clean:
	$(RM) -rf parser.tab.cpp parser.tab.hpp cc parser.lex.cpp $(OBJS); $(RM) *.ll *.bc 