SRCS=\
	stream.swift \
	parser.swift \
	infix.swift \
	late.swift \
	strings.swift \
	numbers.swift \
	followedBy.swift \
	pipe.swift \
	repeats.swift \
	alternates.swift \
	main.swift

TARGET=octopus

all: $(SRCS)
	xcrun -sdk macosx swiftc -g -o $(TARGET) $(SRCS)

run: all
	./$(TARGET)
