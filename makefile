SRCS=\
	parser.swift \
	strings.swift \
	followedBy.swift \
	pipe.swift \
	repeats.swift \
	alternates.swift \
	main.swift

TARGET=octopus

all: $(SRCS)
	xcrun -sdk macosx swiftc -o $(TARGET) $(SRCS)

run: all
	./$(TARGET)
