#ifndef MD5_TOOLS_H
#define MD5_TOOLS_H

#include <string>
#include <fstream>

typedef unsigned char byte;
typedef unsigned int uint32;

class Md5{
public:
	Md5();
	Md5(const void *input, size_t length);
	Md5(const std::string &str);
	Md5(std::ifstream &in);
	void update(const void *input, size_t length);
	void update(const std::string &str);
	void update(std::ifstream &in);
	const byte* digest();
	std::string toString();
	void reset();
private:
	void update(const byte *input, size_t length);
	void final();
	void transform(const byte block[64]);
	void encode(const uint32 *input, byte *output, size_t length);
	void decode(const byte *input, uint32 *output, size_t length);
	std::string bytesToHexString(const byte *input, size_t length);
	Md5(const Md5&);
	Md5& operator=(const Md5&);
private:
	uint32 _state[4];
	uint32 _count[2];
	byte _buffer[64];
	byte _digest[16];
	bool _finished;
	static const byte PADDING[64];
	static const char HEX[16];
	static const size_t BUFFER_SIZE = 1024;
};
#endif /*MD5_TOOLS_H*/
