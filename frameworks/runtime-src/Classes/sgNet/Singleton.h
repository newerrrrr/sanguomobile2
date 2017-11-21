

#ifndef SINGLETON_H_
#define SINGLETON_H_

#include <memory>

template<class T>
class Singleton {
	friend class std::auto_ptr<T>;
protected:
	static std::auto_ptr<T> m_Instance;
protected:
	Singleton() {};
	virtual ~Singleton() {};
public:
	static T* Instance() {
		if(m_Instance.get() == NULL) {
			m_Instance.reset(new T());
		}
		return m_Instance.get();
	}
    
    static void clear() {
        m_Instance.reset(NULL);
    }
private:
	Singleton(const Singleton&) {};
	Singleton& operator= (const Singleton &){return NULL;};
};

template<class T>
std::auto_ptr<T> Singleton<T>::m_Instance;

#endif /* SINGLETON_H_ */
