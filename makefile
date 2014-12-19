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
	token.swift \
	json.swift \
	main.swift

TARGET=octopus

all: $(SRCS) bridge.h
	xcrun -sdk macosx swiftc -g -o $(TARGET) -import-objc-header bridge.h $(SRCS)

run: all
	./$(TARGET)
