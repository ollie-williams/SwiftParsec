SRCS=\
	stream.swift \
	parser.swift \
	strings.swift \
	followedBy.swift \
	pipe.swift \
	repeats.swift \
	alternates.swift \
	late.swift \
	main.swift

TARGET=octopus

all: $(SRCS)
	xcrun -sdk macosx swiftc -g -o $(TARGET) $(SRCS)

run: all
	./$(TARGET)
