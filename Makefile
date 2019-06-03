all: check

OBJS = parser.tab.o  \
       codegen.o  \
       cc.o    \
       parser.lex.o  \

LLVMCONFIG = llvm-config-3.9
CPPFLAGS = `$(LLVMCONFIG) --cppflags` -std=c++11
LDFLAGS = `$(LLVMCONFIG) --ldflags` -lpthread -ldl -lz -lncurses -rdynamic
LIBS = `$(LLVMCONFIG) --libs`

parser.tab.cpp: parser.y
	bison -d parser.y -o parser.tab.cpp

parser.tab.hpp: parser.tab.cpp

parser.lex.cpp: tokenizer.l parser.tab.hpp
	flex -o parser.lex.cpp -l tokenizer.l

%.o: %.cpp
	g++ -c $(CPPFLAGS) -o $@ $<

cc: $(OBJS)
	g++ -ggdb -g -O0 -o $@ $(OBJS) $(LIBS) $(LDFLAGS)

test: cc $(file).ji
	@ rm $(file).ll; rm $(file).bc; make > /dev/null 2> /dev/null; ./cc $(file).ji > /dev/null 2> $(file).ll; llvm-as-3.9 $(file).ll;lli-3.9 $(file).bc 

check: cc test1.ji
	./cc test1.ji ;echo "To run the code with lli run \"make test file=test1\""

clean:
	$(RM) -rf parser.tab.cpp parser.tab.hpp cc parser.lex.cpp $(OBJS); $(RM) *.ll *.bc 