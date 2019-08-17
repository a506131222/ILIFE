//
//  aes_cbc.h
//  NetworkingDemo
//
//  Created by zhourx5211 on 12/27/14.
//  Copyright (c) 2014 zhourx5211. All rights reserved.
//

#ifndef NetworkingDemo_aes_cbc_h
#define NetworkingDemo_aes_cbc_h

void AES_CBC_Encrypt(unsigned char *PlainText,
                     unsigned int PlainTextLength,
                     unsigned char *Key,
                     unsigned int KeyLength,
                     unsigned char *IV,
                     unsigned int IVLength,
                     unsigned char *CipherText,
                     unsigned int *CipherTextLength);

void AES_CBC_Decrypt(unsigned char *CipherText,
                     unsigned int CipherTextLength,
                     unsigned char *Key,
                     unsigned int KeyLength,
                     unsigned char *IV,
                     unsigned int IVLength,
                     unsigned char *PlainText,
                     unsigned int *PlainTextLength);
#endif
