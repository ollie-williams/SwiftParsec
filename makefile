SRCS=\
	parser.swift \
	followedBy.swift \
	pipe.swift \
	repeats.swift \
	main.swift

TARGET=octopus

all: $(SRCS)
	xcrun -sdk macosx swiftc -o $(TARGET) $(SRCS)

run: all
	./$(TARGET)
