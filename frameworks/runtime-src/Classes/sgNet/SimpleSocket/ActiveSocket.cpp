/*---------------------------------------------------------------------------*/
/*                                                                           */
/* CActiveSocket.cpp - Active Socket Implementation							 */
/*                                                                           */
/* Author : Mark Carrier (mark@carrierlabs.com)                              */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* Copyright (c) 2007-2009 CarrierLabs, LLC.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * 4. The name "CarrierLabs" must not be used to
 *    endorse or promote products derived from this software without
 *    prior written permission. For written permission, please contact
 *    mark@carrierlabs.com.
 *
 * THIS SOFTWARE IS PROVIDED BY MARK CARRIER ``AS IS'' AND ANY
 * EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL MARK CARRIER OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *----------------------------------------------------------------------------*/
#include "ActiveSocket.h"


CActiveSocket::CActiveSocket(CSocketType nType) : CSimpleSocket(nType)
{
}


//------------------------------------------------------------------------------
//
// ConnectTCP() -
//
//------------------------------------------------------------------------------
bool CActiveSocket::ConnectTCP(const uint8 *pAddr, int16 nPort)
{
    bool           bRetVal = false;
    struct in_addr stIpAddress;

    //------------------------------------------------------------------
    // Preconnection setup that must be preformed					 
    //------------------------------------------------------------------
    memset(&m_stServerSockaddr, 0, sizeof(m_stServerSockaddr));
    m_stServerSockaddr.sin_family = AF_INET;

    if ((m_pHE = GETHOSTBYNAME(pAddr)) == NULL) 
    {
#ifdef WIN32
        TranslateSocketError();
#else
        if (h_errno == HOST_NOT_FOUND)
        {
            SetSocketError(SocketInvalidAddress);
        }
#endif
        return bRetVal;
    }

    memcpy(&stIpAddress, m_pHE->h_addr_list[0], m_pHE->h_length);
    m_stServerSockaddr.sin_addr.s_addr = stIpAddress.s_addr;

    if ((int32)m_stServerSockaddr.sin_addr.s_addr == CSimpleSocket::SocketError)
    {
        TranslateSocketError();
        return bRetVal;
    }

    m_stServerSockaddr.sin_port = htons(nPort);

    //------------------------------------------------------------------
    // Connect to address "xxx.xxx.xxx.xxx"	(IPv4) address only.  
    // 
    //------------------------------------------------------------------
    m_timer.Initialize();
    m_timer.SetStartTime();

    if (connect(m_socket, (struct sockaddr*)&m_stServerSockaddr, sizeof(m_stServerSockaddr)) == 
	CSimpleSocket::SocketError)
    {
        //--------------------------------------------------------------
        // Get error value this might be a non-blocking socket so we 
        // must first check.
        //--------------------------------------------------------------
        TranslateSocketError();

        //--------------------------------------------------------------
        // If the socket is non-blocking and the current socket error
        // is SocketEinprogress or SocketEwouldblock then poll connection 
        // with select for designated timeout period.
        // Linux returns EINPROGRESS and Windows returns WSAEWOULDBLOCK.
        //--------------------------------------------------------------
        if ((IsNonblocking()) && 
            ((GetSocketError() == CSimpleSocket::SocketEwouldblock) || 
	     (GetSocketError() == CSimpleSocket::SocketEinprogress)))
        {
            bRetVal = Select(GetConnectTimeoutSec(), GetConnectTimeoutUSec());
        }
    }
    else
    {
        TranslateSocketError();
        bRetVal = true;
    }

    m_timer.SetEndTime();

    return bRetVal;
}


//------------------------------------------------------------------------------
//
// ConnectUDP() -
//
//------------------------------------------------------------------------------
bool CActiveSocket::ConnectUDP(const uint8 *pAddr, int16 nPort)
{
    bool           bRetVal = false;
    struct in_addr stIpAddress;

    //------------------------------------------------------------------
    // Pre-connection setup that must be preformed					 
    //------------------------------------------------------------------
    memset(&m_stServerSockaddr, 0, sizeof(m_stServerSockaddr));
    m_stServerSockaddr.sin_family = AF_INET;

    if ((m_pHE = GETHOSTBYNAME(pAddr)) == NULL) 
    {
#ifdef WIN32
        TranslateSocketError();
#else
        if (h_errno == HOST_NOT_FOUND)
        {
            SetSocketError(SocketInvalidAddress);
        }
#endif
        return bRetVal;
    }

    memcpy(&stIpAddress, m_pHE->h_addr_list[0], m_pHE->h_length);
    m_stServerSockaddr.sin_addr.s_addr = stIpAddress.s_addr;

    if ((int32)m_stServerSockaddr.sin_addr.s_addr == CSimpleSocket::SocketError)
    {
        TranslateSocketError();
        return bRetVal;
    }

    m_stServerSockaddr.sin_port = htons(nPort);

    //------------------------------------------------------------------
    // Connect to address "xxx.xxx.xxx.xxx"	(IPv4) address only.  
    // 
    //------------------------------------------------------------------
    m_timer.Initialize();
    m_timer.SetStartTime();

    if (connect(m_socket, (struct sockaddr*)&m_stServerSockaddr, sizeof(m_stServerSockaddr)) != CSimpleSocket::SocketError)
    {
        bRetVal = true;
    }

    TranslateSocketError();

    m_timer.SetEndTime();

    return bRetVal;
}


//------------------------------------------------------------------------------
//
// ConnectRAW() -
//
//------------------------------------------------------------------------------
bool CActiveSocket::ConnectRAW(const uint8 *pAddr, int16 nPort)
{
    bool           bRetVal = false;
    struct in_addr stIpAddress;
    //------------------------------------------------------------------
    // Pre-connection setup that must be preformed					 
    //------------------------------------------------------------------
    memset(&m_stServerSockaddr, 0, sizeof(m_stServerSockaddr));
    m_stServerSockaddr.sin_family = AF_INET;

    if ((m_pHE = GETHOSTBYNAME(pAddr)) == NULL) 
    {
#ifdef WIN32
        TranslateSocketError();
#else
        if (h_errno == HOST_NOT_FOUND)
        {
            SetSocketError(SocketInvalidAddress);
        }
#endif
        return bRetVal;
    }

    memcpy(&stIpAddress, m_pHE->h_addr_list[0], m_pHE->h_length);
    m_stServerSockaddr.sin_addr.s_addr = stIpAddress.s_addr;

    if ((int32)m_stServerSockaddr.sin_addr.s_addr == CSimpleSocket::SocketError)
    {
        TranslateSocketError();
        return bRetVal;
    }

    m_stServerSockaddr.sin_port = htons(nPort);

    //------------------------------------------------------------------
    // Connect to address "xxx.xxx.xxx.xxx"	(IPv4) address only.  
    // 
    //------------------------------------------------------------------
    m_timer.Initialize();
    m_timer.SetStartTime();

    if (connect(m_socket, (struct sockaddr*)&m_stServerSockaddr, sizeof(m_stServerSockaddr)) != CSimpleSocket::SocketError)
    {
        bRetVal = true;
    }

    TranslateSocketError();

    m_timer.SetEndTime();

    return bRetVal;
}



//------------------------------------------------------------------------------
//
// Open() - Create a connection to a specified address on a specified port
//
//------------------------------------------------------------------------------
bool CActiveSocket::Open(const uint8 *pAddr, int16 nPort)
{
    
    bool bRetVal = false;

    //get host ip
    struct addrinfo hints;
    struct addrinfo *res, *tmp;
    char strPort[16];

    sprintf(strPort, "%d", nPort);
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC; 
    //hints.ai_protocol = IPPROTO_TCP;
    hints.ai_socktype = SOCK_STREAM;
    
    
    if (0 == getaddrinfo((char *)pAddr, strPort, &hints, &res)) //success 
    {
        for (tmp = res; tmp != NULL; tmp = tmp->ai_next) 
        { 
            if (tmp->ai_family == AF_INET ||tmp->ai_family == AF_INET6)
            {
                //create socket 
                m_socket = socket(tmp->ai_family, tmp->ai_socktype, tmp->ai_protocol);
                if (m_socket < 0) 
                {
                    continue;
                }

                SetSocketOption();          
              
               if (connect(m_socket, tmp->ai_addr, tmp->ai_addrlen) < 0) 
                {
                    TranslateSocketError();
                    //--------------------------------------------------------------
                    // If the socket is non-blocking and the current socket error
                    // is SocketEinprogress or SocketEwouldblock then poll connection 
                    // with select for designated timeout period.
                    // Linux returns EINPROGRESS and Windows returns WSAEWOULDBLOCK.
                    //--------------------------------------------------------------
                    if ((m_bIsBlocking == false) && ((GetSocketError() == SocketEwouldblock) || (GetSocketError() == SocketEinprogress)))
                    {
                        bRetVal = Select(m_stConnectTimeout.tv_sec, m_stConnectTimeout.tv_usec);
                    }
                    else
                    {
                        CLOSE(m_socket);
                        m_socket = INVALID_SOCKET;
                        bRetVal = false;
                    } 

                    if (bRetVal)
                    {
                        SetSocketError(SocketSuccess);
                        break;
                    }
                    continue;
                }   
                else 
                {
                    SetSocketError(SocketSuccess);
                    bRetVal = true;
                    break;
                }
            }
        } 
        
        freeaddrinfo(res); //---------free  before  connect() will result error !!! why ???????????????????????????
    }
    else 
    {
        SetSocketError(SocketInvalidAddress);
        bRetVal = false;
    }

    if (IsSocketValid() == false)
    {
        SetSocketError(SocketInvalidSocket);
        bRetVal = false;
    }



    return bRetVal;


    



#if 0
    //--------------------------------------------------------------------------
    // If successful then create a local copy of the address and port							
    //--------------------------------------------------------------------------
    if (bRetVal)
    {
        socklen_t nSockLen = sizeof(struct sockaddr);

        memset(&m_stServerSockaddr, 0, nSockLen);
        getpeername(m_socket, (struct sockaddr *)&m_stServerSockaddr, &nSockLen);

        nSockLen = sizeof(struct sockaddr);
        memset(&m_stClientSockaddr, 0, nSockLen);
        getsockname(m_socket, (struct sockaddr *)&m_stClientSockaddr, &nSockLen);

        SetSocketError(SocketSuccess);
    }

    return bRetVal;
   #endif
}
