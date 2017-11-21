
#ifndef CAUTOLOCK_H_
#define CAUTOLOCK_H_

#include <thread>


class CAutoLock
{
public:
    CAutoLock(std::mutex* ptLock)
    {
        m_ptLock = ptLock;
        m_ptLock->lock();
    }
    
    ~CAutoLock()
    {
        m_ptLock->unlock();
    }
    
private:
    std::mutex* m_ptLock;
};


#endif /* CAUTOLOCK_H_ */
