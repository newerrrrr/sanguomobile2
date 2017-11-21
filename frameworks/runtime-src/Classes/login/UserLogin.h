#ifndef USERLOGIN_H_
#define USERLOGIN_H_
#include <string>
#include <vector>

class UserLogin {
public:
	UserLogin(){}
	virtual ~UserLogin();

	static std::string decode(const std::string &text, const std::string &key);
	static std::string encode(const std::string &text, const std::string &key);
	static std::string sha1(char* input);

private:
	static std::vector<int> transKey(const std::string &key);
};

#endif /* USERLOGIN_H_ */
